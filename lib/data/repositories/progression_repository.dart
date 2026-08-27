import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/progression_model.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/progression.dart';
import 'package:fayemath_academy/domain/repositories/progression_repository.dart';

/// Implementation du [ProgressionRepository] : lecture LOCALE et ecriture
/// LOCALE D'ABORD de la progression de l'eleve, avec pousse best-effort vers
/// Supabase.
///
/// ## Ecriture (le cœur de l'etape 22)
/// [definirEtat] ecrit d'abord dans Drift (immediat, jamais bloque par le
/// reseau : l'ecran se rafraichit via le flux `.watch()`), PUIS tente un
/// `upsert` Supabase en best-effort. Un echec de cette tentative (hors-ligne,
/// serveur injoignable) est NORMAL (contrat hors-ligne, GLOSSAIRE §6 regle 5) :
/// il est trace en debug, jamais remonte a l'ecran, jamais leve en
/// `EchecEnregistrement` (a la difference du choix de classe, etape 14, qui lui
/// EXIGE le reseau). L'id est genere cote CLIENT (UUID v4) pour pouvoir ecrire
/// sans round-trip ; la colonne serveur `uuid default gen_random_uuid()` accepte
/// une valeur fournie.
///
/// ## Lecture : LOCALE PURE a cette etape (ecart assume au cadrage §3 point 4)
/// Les deux `observer...` lisent UNIQUEMENT le cache Drift, sans resynchro
/// serveur en arriere-plan — contrairement aux repositories de LECTURE
/// (chapitres, profil...). Raison : un `pull` serveur qui remplace le cache
/// (delete + insert, comme `chapitre_repository`) EFFACERAIT une ecriture faite
/// hors-ligne et pas encore poussee (il n'y a pas encore de file de
/// synchronisation : c'est l'etape 23). La progression etant une donnee que
/// l'eleve ECRIT, le local est ici la source de verite ; le flux serveur ->
/// local et la reconciliation « la modification la plus recente l'emporte »
/// arrivent avec l'etape 23. Ecart documente au Journal (CONVENTIONS §9).
class ProgressionRepositoryOfflineFirst implements ProgressionRepository {
  ProgressionRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  static const Uuid _uuid = Uuid();

  @override
  Stream<EtatProgression> observerEtat({
    required String utilisateurId,
    required String chapitreId,
  }) {
    // Deux `where` combines en AND par Drift (meme idiome que les autres repos,
    // evite l'operateur `&`). Une seule ligne par (eleve, chapitre) : c'est le
    // seul ecrivain (definirEtat) et il reutilise l'id existant -> pas de doublon.
    return (_base.select(_base.progressions)
          ..where((p) => p.utilisateurId.equals(utilisateurId))
          ..where((p) => p.chapitreId.equals(chapitreId)))
        .watchSingleOrNull()
        .map(_etatDeLigne);
  }

  @override
  Stream<Map<String, EtatProgression>> observerEtats(String utilisateurId) {
    return (_base.select(_base.progressions)
          ..where((p) => p.utilisateurId.equals(utilisateurId)))
        .watch()
        .map((lignes) {
          return {
            for (final ligne in lignes)
              ligne.chapitreId: EtatProgression.depuisValeurSql(ligne.etat),
          };
        });
  }

  @override
  Future<void> definirEtat({
    required String utilisateurId,
    required String chapitreId,
    required EtatProgression etat,
  }) async {
    // On reutilise l'id de la ligne existante si elle existe (sinon la contrainte
    // serveur `unique(utilisateur_id, chapitre_id)` serait violee au push, et on
    // creerait un doublon local). Sinon, id genere cote client.
    final existante =
        await (_base.select(_base.progressions)
              ..where((p) => p.utilisateurId.equals(utilisateurId))
              ..where((p) => p.chapitreId.equals(chapitreId)))
            .getSingleOrNull();

    final progression = Progression(
      id: existante?.id ?? _uuid.v4(),
      utilisateurId: utilisateurId,
      chapitreId: chapitreId,
      etat: etat,
      // Heure de l'appareil : sert de trace, et deviendra l'arbitre du « plus
      // recent l'emporte » a l'etape 23 (pas de reconciliation d'horloge ici).
      dateMaj: DateTime.now(),
    );

    // 1. LOCAL d'abord (immediat) : l'ecran reagit via le flux `.watch()`.
    await _base
        .into(_base.progressions)
        .insertOnConflictUpdate(ProgressionModel.versCompanion(progression));

    // 2. Serveur en best-effort, non bloquant : on n'attend pas et on n'echoue
    //    jamais l'action ressentie par l'eleve si le reseau manque.
    unawaited(_pousserVersServeur(progression));
  }

  /// Pousse la progression vers Supabase. `upsert` sur (utilisateur, chapitre) :
  /// modifier deux fois le meme chapitre ne cree pas de doublon (contrainte
  /// `unique`, migration 01). BEST-EFFORT : toute erreur est tracee en debug et
  /// ravalee — jamais un `catch` silencieux (CONVENTIONS §5), jamais remontee.
  Future<void> _pousserVersServeur(Progression progression) async {
    try {
      await _supabase
          .from('progression')
          .upsert(
            ProgressionModel.versJson(progression),
            onConflict: 'utilisateur_id, chapitre_id',
          );
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint(
          '[progression] push best-effort ignore : ${erreur.runtimeType}',
        );
      }
    }
  }

  EtatProgression _etatDeLigne(ProgressionLocale? ligne) => ligne == null
      ? EtatProgression
            .aFaire // absence de ligne = « A faire » (defaut, Point 4)
      : EtatProgression.depuisValeurSql(ligne.etat);
}

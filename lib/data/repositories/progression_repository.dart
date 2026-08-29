import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/progression_model.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/progression.dart';
import 'package:fayemath_academy/domain/repositories/progression_repository.dart';
import 'package:fayemath_academy/domain/usecases/reconciliation_progression.dart';

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
/// ## Lecture : toujours LOCALE (les `observer...` lisent le cache Drift)
/// Les deux `observer...` lisent UNIQUEMENT le cache Drift : c'est la lecture
/// offline-first, immediate et sans reseau. Ce qui les rafraichit apres coup n'est
/// PAS un `pull` au moment de la lecture (il effacerait une ecriture hors-ligne
/// pas encore poussee), mais [synchroniser], declenche au RETOUR du reseau.
///
/// ## Synchronisation (etape 23) : le drapeau `enAttenteSync` + la regle pure
/// Chaque ecriture locale marque la ligne « en attente » (`enAttenteSync = true`).
/// [synchroniser] vide cette file (push) et adopte les valeurs serveur plus
/// recentes (pull), chapitre par chapitre, arbitre par
/// [ReconciliationProgression] (« local en attente gagne, sinon le plus recent
/// l'emporte » — decision Ousseynou du 29/08). Cela leve l'ecart de lecture pure
/// assume a l'etape 22 SANS jamais ecraser une modification faite hors-ligne.
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

    // 1. LOCAL d'abord (immediat) : l'ecran reagit via le flux `.watch()`. On
    //    marque la ligne « en attente » (etape 23) : toute NOUVELLE modification
    //    remet le drapeau a `true`, meme si un push precedent avait reussi — sinon
    //    une modif faite juste apres une synchro ne repartirait jamais au serveur.
    await _base
        .into(_base.progressions)
        .insertOnConflictUpdate(
          ProgressionModel.versCompanion(
            progression,
          ).copyWith(enAttenteSync: const Value(true)),
        );

    // 2. Serveur en best-effort, non bloquant : on n'attend pas et on n'echoue
    //    jamais l'action ressentie par l'eleve si le reseau manque.
    unawaited(_pousserVersServeur(progression));
  }

  @override
  Future<void> synchroniser({required String utilisateurId}) async {
    // 1. PULL best-effort. Si le reseau lache, on abandonne en silence : rien
    //    n'est perdu (les lignes « en attente » repartiront au prochain retour).
    final List<Progression> duServeur;
    try {
      final data = await _supabase
          .from('progression')
          .select()
          .eq('utilisateur_id', utilisateurId);
      duServeur = [for (final ligne in data) ProgressionModel.depuisJson(ligne)];
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint('[progression] pull ignore : ${erreur.runtimeType}');
      }
      return;
    }

    // 2. Snapshot local courant, puis plan pur (regle de reconciliation, lot B).
    final locales = await (_base.select(
      _base.progressions,
    )..where((p) => p.utilisateurId.equals(utilisateurId))).get();
    final plan = planifier(locales: locales, serveur: duServeur);

    // 3. ADOPTION serveur -> local (chemin d'ecriture locale testable).
    await appliquerAdoptions(plan.aAdopter);

    // 4. PUSH de la file d'attente (hors transaction : appels reseau). Chaque
    //    succes marque la ligne synchronisee (garde sur `dateMaj`, cf. plus bas).
    for (final p in plan.aPousser) {
      await _pousserVersServeur(p);
    }
  }

  /// Ecrit en local les valeurs SERVEUR adoptees, en UNE transaction (un seul
  /// rafraichissement des ecrans, anti-clignotement etape 21). delete+insert (et
  /// non un simple upsert) car l'id serveur peut differer de l'id local sur un
  /// vrai conflit 2 appareils : on garantit ainsi UNE SEULE ligne par (eleve,
  /// chapitre), portant l'id serveur. Les lignes ecrites ne sont plus « en
  /// attente » (elles viennent du serveur). `@visibleForTesting` : c'est le seul
  /// effet local de `synchroniser` verifiable sans reseau (le reste = DoD appareil).
  @visibleForTesting
  Future<void> appliquerAdoptions(List<Progression> aAdopter) async {
    if (aAdopter.isEmpty) return;
    await _base.transaction(() async {
      for (final p in aAdopter) {
        await (_base.delete(_base.progressions)
              ..where((r) => r.utilisateurId.equals(p.utilisateurId))
              ..where((r) => r.chapitreId.equals(p.chapitreId)))
            .go();
        await _base
            .into(_base.progressions)
            .insert(
              ProgressionModel.versCompanion(
                p,
              ).copyWith(enAttenteSync: const Value(false)),
            );
      }
    });
  }

  /// Decide, a partir du snapshot LOCAL et du snapshot SERVEUR, ce qu'il faut
  /// ADOPTER (serveur -> local) et POUSSER (local -> serveur), chapitre par
  /// chapitre. Fonction PURE (aucune I/O) : c'est la boucle testable qui applique
  /// [ReconciliationProgression.decider] a chaque couple. `synchroniser` ne fait
  /// plus que l'I/O autour d'elle (prouvee sur appareil, DoD Phase 3).
  @visibleForTesting
  static ({List<Progression> aAdopter, List<Progression> aPousser}) planifier({
    required List<ProgressionLocale> locales,
    required List<Progression> serveur,
  }) {
    final parChapitreLocal = {for (final l in locales) l.chapitreId: l};
    final parChapitreServeur = {for (final s in serveur) s.chapitreId: s};
    final chapitreIds = {
      ...parChapitreLocal.keys,
      ...parChapitreServeur.keys,
    };

    final aAdopter = <Progression>[];
    final aPousser = <Progression>[];
    for (final chapitreId in chapitreIds) {
      final locale = parChapitreLocal[chapitreId];
      final serveurP = parChapitreServeur[chapitreId];
      final decision = ReconciliationProgression.decider(
        local: locale == null
            ? null
            : (dateMaj: locale.dateMaj, enAttente: locale.enAttenteSync),
        serveurDateMaj: serveurP?.dateMaj,
      );
      switch (decision) {
        case DecisionReconciliation.adopterServeur:
          aAdopter.add(serveurP!);
          break;
        case DecisionReconciliation.pousserVersServeur:
          aPousser.add(ProgressionModel.depuisLigne(locale!));
          break;
        case DecisionReconciliation.rienAFaire:
          break;
      }
    }
    return (aAdopter: aAdopter, aPousser: aPousser);
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
      // Push confirme : la ligne n'est plus « en attente ». GARDE sur `dateMaj` :
      // on ne debloque QUE la version qu'on vient de pousser. Si l'eleve a
      // re-modifie entre-temps (nouvelle `dateMaj`), la ligne reste « en attente »
      // et repartira a la prochaine synchro.
      await (_base.update(_base.progressions)
            ..where((p) => p.id.equals(progression.id))
            ..where((p) => p.dateMaj.equals(progression.dateMaj)))
          .write(const ProgressionsCompanion(enAttenteSync: Value(false)));
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

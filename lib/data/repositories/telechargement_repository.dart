import 'dart:async';
import 'dart:io' show File, SocketException;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/core/telechargement/chemins_telechargement.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/telechargement_model.dart';
import 'package:fayemath_academy/data/remote/telechargeur_fichier.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';

/// Implementation du [TelechargementRepository] (etape 19, Lot C) : orchestre
/// l'obtention d'une URL SIGNEE (Supabase Storage), le transfert atomique
/// ([TelechargeurFichier], Lot B) vers l'espace prive de l'appareil, puis
/// l'enregistrement de la trace dans la table `telechargement`.
///
/// Sequence de [telecharger] :
///   1. URL signee via `createSignedUrl` — c'est ICI que la policy Storage
///      (migration 06) tranche : un invite ou un premium sans abonnement se voit
///      refuser des cette etape (traduit en `nonAutorise` / `introuvable`) ;
///   2. transfert delegue au [TelechargeurFichier] (progression relayee) ;
///   3. a la reussite SEULEMENT, enregistrement de la ligne `telechargement`.
///
/// Le VRAI « telecharge » est le FICHIER sur le disque (present de facon atomique),
/// pas la ligne serveur (decision 5.3) : l'ecriture de la trace est donc
/// BEST-EFFORT — si elle echoue juste apres le transfert, le document reste
/// ouvrable localement, on ne fait pas echouer le telechargement pour autant
/// (contrat hors-ligne, regle 4).
class TelechargementRepositoryStorage implements TelechargementRepository {
  TelechargementRepositoryStorage(
    this._base,
    this._supabase,
    this._telechargeur,
  );

  final BaseLocale _base;
  final SupabaseClient _supabase;
  final TelechargeurFichier _telechargeur;

  static const _bucket = 'bibliotheque';

  /// Duree de validite de l'URL signee : le transfert demarre immediatement, une
  /// fenetre courte suffit (limite l'exposition du jeton — SECURITY.md §5).
  static const _ttlSignatureSecondes = 300;

  /// Racine privee de l'app (`path_provider`), resolue une seule fois. Espace
  /// PRIVE, invisible des autres apps, efface a la desinstallation (SECURITY.md
  /// §4) — jamais un stockage public partage.
  Future<String>? _racineMemo;
  Future<String> _racinePrivee() =>
      _racineMemo ??= getApplicationSupportDirectory().then((d) => d.path);

  @override
  Future<String?> cheminLocalSiPresent(String ressourceId) async {
    final racine = await _racinePrivee();
    final chemin = CheminsTelechargement.fichierFinal(racine, ressourceId);
    return await File(chemin).exists() ? chemin : null;
  }

  @override
  Stream<double> telecharger(Ressource ressource) {
    final controleur = StreamController<double>();
    StreamSubscription<double>? sousJacent;
    // Annuler l'ecoute annule le transfert sous-jacent (qui annule dio + nettoie).
    controleur.onCancel = () async => sousJacent?.cancel();

    Future<void> demarrer() async {
      try {
        final cheminStorage = ressource.cheminStorage;
        // Rien a telecharger : pas de fichier serveur, ou deja embarque (assets/).
        if (cheminStorage == null ||
            CheminsTelechargement.estAssetEmbarque(cheminStorage)) {
          await _echouer(controleur, CauseTelechargement.introuvable);
          return;
        }

        // 1. URL signee (echec = refus policy / reseau / objet absent).
        final String url;
        try {
          url = await _supabase.storage
              .from(_bucket)
              .createSignedUrl(cheminStorage, _ttlSignatureSecondes);
        } catch (erreur) {
          await _echouer(controleur, traduireEchecSupabase(erreur), erreur);
          return;
        }

        // 2. Transfert atomique, progression relayee telle quelle.
        final racine = await _racinePrivee();
        sousJacent = _telechargeur
            .telecharger(
              url: url,
              cheminPartiel: CheminsTelechargement.fichierPartiel(
                racine,
                ressource.id,
              ),
              cheminFinal: CheminsTelechargement.fichierFinal(
                racine,
                ressource.id,
              ),
            )
            .listen(
              (progression) {
                if (!controleur.isClosed) controleur.add(progression);
              },
              // L'erreur est deja un EchecTelechargement (Lot B) : on la relaie.
              onError: (Object erreur) async {
                if (!controleur.isClosed) {
                  controleur.addError(erreur);
                  await controleur.close();
                }
              },
              onDone: () async {
                // 3. Succes du transfert : enregistrer la trace (best-effort).
                await _enregistrerLigne(ressource.id);
                if (!controleur.isClosed) await controleur.close();
              },
            );
      } catch (erreur) {
        await _echouer(controleur, CauseTelechargement.inattendu, erreur);
      }
    }

    unawaited(demarrer());
    return controleur.stream;
  }

  Future<void> _echouer(
    StreamController<double> controleur,
    CauseTelechargement cause, [
    Object? erreur,
  ]) async {
    if (!controleur.isClosed) {
      // Diagnostic = le seul type d'erreur, jamais l'URL signee (SECURITY.md §5).
      controleur.addError(
        EchecTelechargement(cause, diagnostic: erreur?.runtimeType.toString()),
      );
      await controleur.close();
    }
  }

  /// Enregistre la ligne `telechargement` (serveur puis miroir Drift). Le serveur
  /// genere l'id (`gen_random_uuid`) et la date ; on recupere la ligne pour la
  /// mettre en cache. `upsert` sur (utilisateur, ressource) : re-telecharger le
  /// meme document ne cree pas de doublon (contrainte `unique`, migration 01).
  ///
  /// BEST-EFFORT : un echec ici n'empeche NI l'ouverture du document (le fichier
  /// est deja sur l'appareil) NI la reussite du telechargement — juste une trace
  /// pas encore synchronisee. Trace en debug, jamais un `catch` silencieux.
  Future<void> _enregistrerLigne(String ressourceId) async {
    final utilisateurId = _supabase.auth.currentUser?.id;
    // Un telechargement suppose un compte connecte (policy Storage) : sans id, on
    // ne peut pas ecrire la trace, mais le fichier local reste valide.
    if (utilisateurId == null) return;
    try {
      final json = await _supabase
          .from('telechargement')
          .upsert({
            'utilisateur_id': utilisateurId,
            'ressource_id': ressourceId,
          }, onConflict: 'utilisateur_id, ressource_id')
          .select()
          .single();
      final telechargement = TelechargementModel.depuisJson(json);
      await _base
          .into(_base.telechargements)
          .insertOnConflictUpdate(
            TelechargementModel.versCompanion(telechargement),
          );
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint(
          '[telechargement] trace non enregistree : ${erreur.runtimeType}',
        );
      }
    }
  }

  /// Traduit un echec d'obtention d'URL signee en [CauseTelechargement]. PURE et
  /// testable. Les codes exacts renvoyes par la policy Storage restent a confirmer
  /// sur appareil (le mapping est prudent : 404 -> introuvable, 401/403 -> refus).
  static CauseTelechargement traduireEchecSupabase(Object erreur) {
    if (erreur is SocketException) return CauseTelechargement.reseau;
    if (erreur is StorageException) {
      final code = erreur.statusCode;
      if (code == '404') return CauseTelechargement.introuvable;
      if (code == '401' || code == '403') {
        return CauseTelechargement.nonAutorise;
      }
      return CauseTelechargement.inattendu;
    }
    return CauseTelechargement.inattendu;
  }
}

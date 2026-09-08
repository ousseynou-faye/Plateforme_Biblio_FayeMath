import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/network/limiteur_resynchro.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/abonnement_model.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';

/// Implementation offline-first de [AbonnementRepository] : le cache local Drift
/// ([BaseLocale]) est la source immediate, Supabase le rafraichissement. Meme
/// sequence que `ChapitreRepositoryOfflineFirst` (docs/ARCHITECTURE.md §7) :
///   1. lire le cache local de l'eleve et le renvoyer IMMEDIATEMENT s'il existe ;
///   2. en arriere-plan, resynchroniser depuis Supabase (best-effort) ;
///   3. cache vide : attendre le serveur une fois, puis relire.
///
/// Cache vide = etat legitime (l'eleve n'a pas d'abonnement, cas le plus frequent
/// en V1). Le reseau absent n'est PAS une erreur (contrat offline-first) : la
/// resynchro ravale l'echec (trace en debug), jamais un `catch` silencieux
/// (docs/CONVENTIONS.md §5). Consequence assumee (decision 5.3) : un abonne dont
/// le cache n'est pas encore synchronise se voit reproposer « Voir l'offre »
/// jusqu'a la prochaine resynchro — jamais l'inverse (le serveur reste seul juge
/// de la delivrance d'un fichier, policy Storage).
///
/// Le cache est un miroir RECONSTRUCTIBLE : la resynchro remplace les lignes de
/// CET eleve (delete cible + insert) dans une TRANSACTION, pour que les flux
/// `.watch()` (etape 21) ne voient pas l'etat vide intermediaire.
class AbonnementRepositoryOfflineFirst implements AbonnementRepository {
  AbonnementRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  /// Garde anti-rafale des resynchros en arriere-plan (etape 21), cle par eleve.
  final LimiteurResynchro _limiteur = LimiteurResynchro();

  @override
  Stream<Abonnement?> observerAbonnement(String utilisateurId) async* {
    // Cache non vide : rendu immediat + resynchro en fond sous garde anti-rafale.
    // Cache vide : on attend une synchro d'abord (comme le chemin des chapitres).
    final local = await _abonnementsLocaux(utilisateurId);
    if (local.isNotEmpty) {
      if (_limiteur.doitResynchroniser(utilisateurId)) {
        unawaited(_synchroniser(utilisateurId));
      }
    } else {
      await _synchroniser(utilisateurId);
    }
    yield* (_base.select(_base.abonnements)
          ..where((a) => a.utilisateurId.equals(utilisateurId)))
        .watch()
        .map(
          (lignes) =>
              _plusProtecteur(lignes.map(AbonnementModel.depuisLigne).toList()),
        );
  }

  // --- Lecture du cache local -------------------------------------------------

  Future<List<Abonnement>> _abonnementsLocaux(String utilisateurId) async {
    final lignes =
        await (_base.select(_base.abonnements)
              ..where((a) => a.utilisateurId.equals(utilisateurId)))
            .get();
    return lignes.map(AbonnementModel.depuisLigne).toList();
  }

  /// L'abonnement dont la date de fin est la plus lointaine (le plus protecteur),
  /// ou `null` si la liste est vide. Un eleve peut avoir un historique (anciens
  /// abonnements expires + un courant) : la regle d'acces n'a besoin que du plus
  /// protecteur (si l'un couvre le jour, c'est celui-ci).
  Abonnement? _plusProtecteur(List<Abonnement> abonnements) {
    if (abonnements.isEmpty) return null;
    return abonnements.reduce((a, b) => b.dateFin.isAfter(a.dateFin) ? b : a);
  }

  // --- Resynchronisation depuis Supabase (best-effort, ciblee sur l'eleve) ----

  Future<void> _synchroniser(String utilisateurId) async {
    try {
      // RLS = SELECT de soi : le filtre explicite est redondant cote serveur mais
      // garde le cache local coherent si plusieurs comptes ont servi l'appareil.
      final lignes = await _supabase
          .from('abonnement')
          .select()
          .eq('utilisateur_id', utilisateurId);
      final serveur = lignes.map(AbonnementModel.depuisJson).toList();

      await _base.transaction(() async {
        await (_base.delete(_base.abonnements)
              ..where((a) => a.utilisateurId.equals(utilisateurId)))
            .go();
        await _base.batch(
          (b) => b.insertAll(
            _base.abonnements,
            serveur.map(AbonnementModel.versCompanion),
          ),
        );
      });
    } catch (erreur) {
      if (kDebugMode) {
        debugPrint(
          '[abonnement] resynchro ($utilisateurId) ignoree : '
          '${erreur.runtimeType}',
        );
      }
    }
  }
}

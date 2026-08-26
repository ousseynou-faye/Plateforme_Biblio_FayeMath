import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/network/limiteur_resynchro.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/ressource_model.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';

/// Implementation offline-first du [RessourceRepository] : le cache local Drift
/// ([BaseLocale]) est la source immediate, Supabase le rafraichissement. Meme
/// sequence que `ChapitreRepositoryOfflineFirst` (docs/ARCHITECTURE.md §7) :
///   1. lire le cache local du chapitre et le renvoyer IMMEDIATEMENT s'il n'est
///      pas vide ;
///   2. en arriere-plan, resynchroniser ce chapitre depuis Supabase (best-effort) ;
///   3. cache vide : attendre le serveur une fois, puis relire.
///
/// Cache vide = etat legitime tant que le contenu reel n'existe pas (etape 18) :
/// sur le seul nombre de lignes, on ne peut pas distinguer « pas encore
/// synchronise » de « chapitre reellement sans document » ; dans les deux cas on
/// tente une lecture serveur puis on rend ce qu'on a (souvent une liste vide). Le
/// reseau absent n'est PAS une erreur (contrat offline-first) : la resynchro
/// ravale l'echec (trace en debug), jamais un `catch` silencieux (CONVENTIONS §5).
///
/// Le cache est un miroir RECONSTRUCTIBLE : la resynchro remplace UNIQUEMENT les
/// ressources de ce chapitre (delete cible + insert), dans une TRANSACTION pour
/// que les flux `.watch()` (etape 21) ne voient pas l'etat vide intermediaire,
/// sans toucher aux ressources des autres chapitres deja en cache. Les
/// `sujet_examen` (chapitre_id null) ne sont jamais concernes : ils ne remontent
/// pas dans une lecture par chapitre.
class RessourceRepositoryOfflineFirst implements RessourceRepository {
  RessourceRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  /// Garde anti-rafale des resynchros en arriere-plan (etape 21, Point 6), cle par
  /// chapitre.
  final LimiteurResynchro _limiteur = LimiteurResynchro();

  @override
  Stream<List<Ressource>> observerRessourcesDuChapitre({
    required String chapitreId,
  }) async* {
    // Cache non vide : rendu immediat + resynchro en fond sous garde anti-rafale.
    // Cache vide : on attend une synchro d'abord, comme le chemin `Future`.
    final local = await _ressourcesLocales(chapitreId);
    if (local.isNotEmpty) {
      if (_limiteur.doitResynchroniser(chapitreId)) {
        unawaited(_synchroniserRessources(chapitreId));
      }
    } else {
      await _synchroniserRessources(chapitreId);
    }
    yield* (_base.select(
      _base.ressources,
    )..where((r) => r.chapitreId.equals(chapitreId))).watch().map(
      (lignes) =>
          lignes.map(RessourceModel.depuisLigne).toList()
            ..sort((a, b) => a.ordre.compareTo(b.ordre)),
    );
  }

  // --- Lecture du cache local (l'ordre d'affichage est garanti ici) -----------

  Future<List<Ressource>> _ressourcesLocales(String chapitreId) async {
    final lignes = await (_base.select(
      _base.ressources,
    )..where((r) => r.chapitreId.equals(chapitreId))).get();
    return lignes.map(RessourceModel.depuisLigne).toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
  }

  // --- Resynchronisation depuis Supabase (best-effort, ciblee sur le chapitre) -

  Future<void> _synchroniserRessources(String chapitreId) async {
    try {
      final lignes = await _supabase
          .from('ressource')
          .select()
          .eq('chapitre_id', chapitreId);
      final ressourcesServeur = lignes.map(RessourceModel.depuisJson).toList();

      // Remplacement CIBLE (on ne purge que ce chapitre) dans UNE transaction :
      // `.watch()` n'emet qu'au commit, jamais l'etat vide du delete.
      await _base.transaction(() async {
        await (_base.delete(
          _base.ressources,
        )..where((r) => r.chapitreId.equals(chapitreId))).go();
        await _base.batch(
          (b) => b.insertAll(
            _base.ressources,
            ressourcesServeur.map(RessourceModel.versCompanion),
          ),
        );
      });
    } catch (erreur) {
      _tracerSyncRavalee(chapitreId, erreur);
    }
  }

  /// Une resynchro qui echoue ne casse rien (offline-first) mais laisse une
  /// trace en debug — jamais un `catch` silencieux (docs/CONVENTIONS.md §5).
  void _tracerSyncRavalee(String chapitreId, Object erreur) {
    if (kDebugMode) {
      debugPrint(
        '[ressource] resynchro ($chapitreId) ignoree : ${erreur.runtimeType}',
      );
    }
  }
}

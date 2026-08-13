import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/chapitre_model.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';

/// Implementation offline-first du [ChapitreRepository] : le cache local Drift
/// ([BaseLocale]) est la source immediate, Supabase le rafraichissement. Meme
/// sequence que `CatalogueRepositoryOfflineFirst` (docs/ARCHITECTURE.md §7) :
///   1. lire le cache local du couple (classe, matiere) et le renvoyer
///      IMMEDIATEMENT s'il n'est pas vide ;
///   2. en arriere-plan, resynchroniser ce couple depuis Supabase (best-effort) ;
///   3. cache vide : attendre le serveur une fois, puis relire.
///
/// Cache vide = etat legitime tant que le contenu reel n'existe pas (etape 18) :
/// on ne peut pas, sur le seul nombre de lignes, distinguer « pas encore
/// synchronise » de « bibliotheque reellement vide » ; dans les deux cas on tente
/// une lecture serveur puis on rend ce qu'on a (souvent une liste vide). Le
/// reseau absent n'est PAS une erreur (contrat offline-first) : la resynchro
/// ravale l'echec (trace en debug), jamais un `catch` silencieux (CONVENTIONS §5).
///
/// Le cache est un miroir RECONSTRUCTIBLE : la resynchro remplace UNIQUEMENT les
/// lignes de ce couple (delete cible + insert), sans toucher aux chapitres des
/// autres (classe, matiere) deja en cache.
class ChapitreRepositoryOfflineFirst implements ChapitreRepository {
  ChapitreRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  @override
  Future<List<Chapitre>> chapitresDe({
    required String classeId,
    required String matiereId,
  }) async {
    final local = await _chapitresLocaux(classeId, matiereId);
    if (local.isNotEmpty) {
      unawaited(_synchroniserChapitres(classeId, matiereId));
      return local;
    }
    await _synchroniserChapitres(classeId, matiereId);
    return _chapitresLocaux(classeId, matiereId);
  }

  // --- Lecture du cache local (l'ordre d'affichage est garanti ici) -----------

  Future<List<Chapitre>> _chapitresLocaux(
    String classeId,
    String matiereId,
  ) async {
    // Deux `where` : Drift les combine en AND (comme `profil_repository`), on
    // evite ainsi l'operateur `&` et son import.
    final lignes =
        await (_base.select(_base.chapitres)
              ..where((c) => c.classeId.equals(classeId))
              ..where((c) => c.matiereId.equals(matiereId)))
            .get();
    return lignes.map(ChapitreModel.depuisLigne).toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
  }

  // --- Resynchronisation depuis Supabase (best-effort, ciblee sur le couple) --

  Future<void> _synchroniserChapitres(
    String classeId,
    String matiereId,
  ) async {
    try {
      final lignes = await _supabase
          .from('chapitre')
          .select()
          .eq('classe_id', classeId)
          .eq('matiere_id', matiereId);
      final chapitresServeur = lignes.map(ChapitreModel.depuisJson).toList();

      // Remplacement CIBLE : on ne purge que ce couple, pas toute la table.
      await (_base.delete(_base.chapitres)
            ..where((c) => c.classeId.equals(classeId))
            ..where((c) => c.matiereId.equals(matiereId)))
          .go();
      await _base.batch(
        (b) => b.insertAll(
          _base.chapitres,
          chapitresServeur.map(ChapitreModel.versCompanion),
        ),
      );
    } catch (erreur) {
      _tracerSyncRavalee(classeId, matiereId, erreur);
    }
  }

  /// Une resynchro qui echoue ne casse rien (offline-first) mais laisse une
  /// trace en debug — jamais un `catch` silencieux (docs/CONVENTIONS.md §5).
  void _tracerSyncRavalee(String classeId, String matiereId, Object erreur) {
    if (kDebugMode) {
      debugPrint(
        '[chapitre] resynchro ($classeId/$matiereId) ignoree : '
        '${erreur.runtimeType}',
      );
    }
  }
}

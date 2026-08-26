import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/network/limiteur_resynchro.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/classe_model.dart';
import 'package:fayemath_academy/data/models/matiere_model.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';

/// Implementation offline-first du [CatalogueRepository] : le cache local Drift
/// ([BaseLocale]) est la source immediate, Supabase le rafraichissement.
///
/// Sequence (docs/ARCHITECTURE.md §7), identique pour `classes()` et `matieres()`
///   1. lire le cache local et le renvoyer IMMEDIATEMENT s'il n'est pas vide ;
///   2. en arriere-plan, resynchroniser depuis Supabase (best-effort) ;
///   3. cache vide (1er lancement) : attendre le serveur une fois, puis relire.
///
/// Le reseau absent n'est PAS une erreur (contrat offline-first) : la
/// resynchronisation ravale l'echec (trace en debug), elle ne le propage jamais.
/// Le cache est un miroir RECONSTRUCTIBLE (base_locale.dart) : la resynchro le
/// remplace en entier (delete + insert), ce qui reflete aussi les suppressions
/// serveur. Ce delete+insert est fait dans une TRANSACTION : les flux `.watch()`
/// (etape 21) ne voient qu'un seul changement au commit, jamais l'etat vide
/// intermediaire qui ferait clignoter l'ecran.
class CatalogueRepositoryOfflineFirst implements CatalogueRepository {
  CatalogueRepositoryOfflineFirst(this._base, this._supabase);

  final BaseLocale _base;
  final SupabaseClient _supabase;

  /// Garde anti-rafale des resynchros en arriere-plan (etape 21, Point 6) : une
  /// instance par repository, cle par type de lecture (« classes » / « matieres »).
  final LimiteurResynchro _limiteur = LimiteurResynchro();

  @override
  Stream<List<Classe>> observerClasses() async* {
    // Cache non vide : on rend la main tout de suite (le flux emet le local) et on
    // resynchronise en fond, sous garde anti-rafale. Cache vide (1er lancement) :
    // on attend une premiere synchro, comme le chemin `Future`, pour ne pas
    // afficher un ecran vide avant que le contenu n'arrive.
    final local = await _classesLocales();
    if (local.isNotEmpty) {
      if (_limiteur.doitResynchroniser('classes')) {
        unawaited(_synchroniserClasses());
      }
    } else {
      await _synchroniserClasses();
    }
    yield* _base
        .select(_base.classes)
        .watch()
        .map(
          (lignes) =>
              lignes.map(ClasseModel.depuisLigne).toList()
                ..sort((a, b) => a.ordre.compareTo(b.ordre)),
        );
  }

  @override
  Stream<List<Matiere>> observerMatieres() async* {
    final local = await _matieresLocales();
    if (local.isNotEmpty) {
      if (_limiteur.doitResynchroniser('matieres')) {
        unawaited(_synchroniserMatieres());
      }
    } else {
      await _synchroniserMatieres();
    }
    yield* _base
        .select(_base.matieres)
        .watch()
        .map(
          (lignes) =>
              lignes.map(MatiereModel.depuisLigne).toList()
                ..sort((a, b) => a.nom.compareTo(b.nom)),
        );
  }

  // --- Lecture du cache local (l'ordre d'affichage est garanti ici) -----------

  Future<List<Classe>> _classesLocales() async {
    final lignes = await _base.select(_base.classes).get();
    return lignes.map(ClasseModel.depuisLigne).toList()
      ..sort((a, b) => a.ordre.compareTo(b.ordre));
  }

  Future<List<Matiere>> _matieresLocales() async {
    final lignes = await _base.select(_base.matieres).get();
    return lignes.map(MatiereModel.depuisLigne).toList()
      ..sort((a, b) => a.nom.compareTo(b.nom));
  }

  // --- Resynchronisation depuis Supabase (best-effort) ------------------------

  Future<void> _synchroniserClasses() async {
    try {
      final lignes = await _supabase.from('classe').select();
      final classesServeur = lignes.map(ClasseModel.depuisJson).toList();
      // delete + insert dans UNE transaction : `.watch()` n'emet qu'au commit.
      await _base.transaction(() async {
        await _base.delete(_base.classes).go();
        await _base.batch(
          (b) => b.insertAll(
            _base.classes,
            classesServeur.map(ClasseModel.versCompanion),
          ),
        );
      });
    } catch (erreur) {
      _tracerSyncRavalee('classe', erreur);
    }
  }

  Future<void> _synchroniserMatieres() async {
    try {
      final lignes = await _supabase.from('matiere').select();
      final matieresServeur = lignes.map(MatiereModel.depuisJson).toList();
      // delete + insert dans UNE transaction : `.watch()` n'emet qu'au commit.
      await _base.transaction(() async {
        await _base.delete(_base.matieres).go();
        await _base.batch(
          (b) => b.insertAll(
            _base.matieres,
            matieresServeur.map(MatiereModel.versCompanion),
          ),
        );
      });
    } catch (erreur) {
      _tracerSyncRavalee('matiere', erreur);
    }
  }

  /// Une resynchro qui echoue ne casse rien (offline-first) mais laisse une
  /// trace en debug — jamais un `catch` silencieux (docs/CONVENTIONS.md §5).
  void _tracerSyncRavalee(String table, Object erreur) {
    if (kDebugMode) {
      debugPrint(
        '[catalogue] resynchro $table ignoree : ${erreur.runtimeType}',
      );
    }
  }
}

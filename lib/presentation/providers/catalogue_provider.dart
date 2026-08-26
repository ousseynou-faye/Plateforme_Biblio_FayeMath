import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';

/// Fournit l'implementation du contrat de catalogue.
///
/// Volontairement NON resolue ici, comme `authRepositoryProvider` : `presentation/`
/// n'a pas le droit d'importer `data/` (docs/ARCHITECTURE.md §3). L'implementation
/// offline-first est injectee a la racine de composition (`main.dart`) via
/// `overrideWith` ; en test, on l'override par un faux repository.
final catalogueRepositoryProvider = Provider<CatalogueRepository>(
  (ref) => throw UnimplementedError(
    'catalogueRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// Les classes du catalogue (6e … Terminale), offline-first et REACTIVES (etape
/// 21) : `StreamProvider` adosse a Drift `.watch()` — l'ecran se rafraichit tout
/// seul quand une resynchro met le cache a jour. Le type expose reste `AsyncValue`
/// (chargement / donnees / erreur), identique a un `FutureProvider` : les `.when`
/// des ecrans ne changent pas.
final classesProvider = StreamProvider<List<Classe>>(
  (ref) => ref.watch(catalogueRepositoryProvider).observerClasses(),
);

/// Les matieres du catalogue (Mathematiques, Physique-chimie), offline-first et
/// reactives (meme principe que [classesProvider]).
final matieresProvider = StreamProvider<List<Matiere>>(
  (ref) => ref.watch(catalogueRepositoryProvider).observerMatieres(),
);

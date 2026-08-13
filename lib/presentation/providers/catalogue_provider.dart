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

/// Les classes du catalogue (6e … Terminale), offline-first. L'ecran gere les
/// trois etats de l'`AsyncValue` (chargement / donnees / erreur).
final classesProvider = FutureProvider<List<Classe>>(
  (ref) => ref.watch(catalogueRepositoryProvider).classes(),
);

/// Les matieres du catalogue (Mathematiques, Physique-chimie), offline-first.
final matieresProvider = FutureProvider<List<Matiere>>(
  (ref) => ref.watch(catalogueRepositoryProvider).matieres(),
);

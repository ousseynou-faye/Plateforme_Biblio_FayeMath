import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';

/// Fournit l'implementation du contrat de ressources. Comme
/// `chapitreRepositoryProvider` : volontairement NON resolue ici
/// (`presentation/` n'importe pas `data/`, docs/ARCHITECTURE.md §3).
/// L'implementation offline-first est injectee a la racine (`main.dart`) via
/// `overrideWith` ; en test, on l'override par un faux repository.
final ressourceRepositoryProvider = Provider<RessourceRepository>(
  (ref) => throw UnimplementedError(
    'ressourceRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// Les ressources d'un chapitre, offline-first. `family` keyee par `chapitreId` :
/// un etat (et un cache) distinct par chapitre. L'ecran gere les trois etats de
/// l'`AsyncValue` (chargement / donnees / erreur) ; une liste VIDE n'est pas une
/// erreur, c'est l'etat normal tant que le contenu reel n'existe pas (etape 18).
final ressourcesProvider = FutureProvider.family<List<Ressource>, String>(
  (ref, chapitreId) => ref
      .watch(ressourceRepositoryProvider)
      .ressourcesDuChapitre(chapitreId: chapitreId),
);

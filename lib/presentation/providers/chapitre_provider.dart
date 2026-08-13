import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';

/// Le couple (classe, matiere) qui identifie une bibliotheque de chapitres.
/// Record nomme : son egalite structurelle fait que le `.family` met en cache
/// PAR couple — deux lectures du meme couple partagent le meme etat.
typedef CibleChapitres = ({String classeId, String matiereId});

/// Fournit l'implementation du contrat de chapitres. Comme
/// `catalogueRepositoryProvider` / `profilRepositoryProvider` : volontairement
/// NON resolue ici (`presentation/` n'importe pas `data/`, docs/ARCHITECTURE.md
/// §3). L'implementation offline-first est injectee a la racine (`main.dart`)
/// via `overrideWith` ; en test, on l'override par un faux repository.
final chapitreRepositoryProvider = Provider<ChapitreRepository>(
  (ref) => throw UnimplementedError(
    'chapitreRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// Les chapitres d'une (classe, matiere), offline-first. `family` : un etat (et
/// un cache) distinct par couple. L'ecran gere les trois etats de l'`AsyncValue`
/// (chargement / donnees / erreur) ; une liste VIDE n'est pas une erreur, c'est
/// l'etat normal tant que le contenu reel n'existe pas (etape 18).
final chapitresProvider =
    FutureProvider.family<List<Chapitre>, CibleChapitres>(
      (ref, cible) => ref
          .watch(chapitreRepositoryProvider)
          .chapitresDe(classeId: cible.classeId, matiereId: cible.matiereId),
    );

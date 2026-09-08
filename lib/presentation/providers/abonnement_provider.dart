import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';

/// Fournit l'implementation du contrat d'abonnement. Comme les autres repos
/// (`chapitreRepositoryProvider`...) : volontairement NON resolue ici
/// (`presentation/` n'importe pas `data/`, docs/ARCHITECTURE.md §3). L'implementation
/// offline-first est injectee a la racine (`main.dart`) via `overrideWith` ; en
/// test, on l'override par un faux repository.
///
/// Le provider METIER qui relie cet abonnement a l'etat d'authentification et a la
/// regle [DroitAccesDocument] (`abonnementPremiumProvider` / `accesDocumentProvider`)
/// arrive au lot C, dans ce meme fichier.
final abonnementRepositoryProvider = Provider<AbonnementRepository>(
  (ref) => throw UnimplementedError(
    'abonnementRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

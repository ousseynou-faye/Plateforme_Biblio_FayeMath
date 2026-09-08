import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Fournit l'implementation du contrat d'abonnement. Comme les autres repos
/// (`chapitreRepositoryProvider`...) : volontairement NON resolue ici
/// (`presentation/` n'importe pas `data/`, docs/ARCHITECTURE.md §3). L'implementation
/// offline-first est injectee a la racine (`main.dart`) via `overrideWith` ; en
/// test, on l'override par un faux repository.
final abonnementRepositoryProvider = Provider<AbonnementRepository>(
  (ref) => throw UnimplementedError(
    'abonnementRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// L'abonnement premium du compte CONNECTE, en flux offline-first (`null` s'il n'en
/// a aucun). Renvoie `null` sans toucher le repository si l'eleve n'est pas
/// connecte (invite/deconnecte) : pour lui la question de l'abonnement ne se pose
/// pas, l'obstacle est le compte (cf. [AccesDocument.compteRequis]).
///
/// Se re-emet tout seul quand l'authentification change (connexion/deconnexion) ou
/// quand une resynchro met le cache a jour.
final abonnementPremiumProvider = StreamProvider<Abonnement?>((ref) {
  final etat = ref.watch(etatAuthProvider);
  if (etat is! AuthConnecte) return Stream.value(null);
  return ref
      .watch(abonnementRepositoryProvider)
      .observerAbonnement(etat.session.utilisateurId);
});

/// Ce que l'eleve peut faire d'un document, selon son drapeau `premium`, ICI ET
/// MAINTENANT. `family` par ce booleen : deux etats seulement (gratuit / premium),
/// recalcule automatiquement quand l'authentification ou l'abonnement change.
///
/// Point de jonction unique entre l'etat d'authentification (les 3 profils),
/// l'abonnement courant et la regle metier pure [DroitAccesDocument] (lot A) : les
/// ecrans (detail, lecteur) lisent CE provider, jamais la regle en direct — une
/// seule source pour « peut-il ouvrir ce document ? ». `maintenant` = horloge de
/// l'appareil (etape 23), la comparaison d'activite etant a la journee.
final accesDocumentProvider = Provider.family<AccesDocument, bool>((
  ref,
  premium,
) {
  final etat = ref.watch(etatAuthProvider);
  final abonnement = ref.watch(abonnementPremiumProvider).value;
  return DroitAccesDocument.evaluer(
    premium: premium,
    estConnecte: etat is AuthConnecte,
    abonnement: abonnement,
    maintenant: DateTime.now(),
  );
});

import 'package:fayemath_academy/domain/entities/abonnement.dart';

/// Le contrat de l'abonnement premium en LECTURE SEULE cote app. L'eleve ne peut
/// pas s'offrir un abonnement en ecrivant une ligne : le RLS `abonnement`
/// (migration 03 §D) n'autorise que le SELECT de soi ; seul `service_role` (le
/// futur webhook de paiement, etape 28) en cree. D'ou l'absence de methode
/// d'ecriture ici — exactement comme `ChapitreRepository` / `CatalogueRepository`
/// (le domaine DECLARE le besoin, `data/` s'y plie, docs/ARCHITECTURE.md §3).
///
/// Offline-first (docs/ARCHITECTURE.md §7) : l'implementation lit le cache local
/// Drift d'abord et rend la main immediatement, puis se rafraichit depuis Supabase
/// en arriere-plan. Le contrat n'impose que le resultat, pas la mecanique.
abstract interface class AbonnementRepository {
  /// Flux REACTIF de l'abonnement le plus PROTECTEUR de l'eleve [utilisateurId] —
  /// celui dont la date de fin est la plus lointaine — ou `null` s'il n'en a
  /// aucun. Emet immediatement le cache local, puis se re-emet tout seul apres une
  /// resynchro en arriere-plan (etape 21).
  ///
  /// On ne renvoie PAS « l'abonnement actif » : juger de l'activite (comparer a la
  /// date du jour) revient a la regle metier [DroitAccesDocument] (lot A), pas au
  /// repository. Si un abonnement couvre le jour, c'est forcement le plus
  /// protecteur — le renvoyer suffit a la regle pour trancher.
  Stream<Abonnement?> observerAbonnement(String utilisateurId);
}

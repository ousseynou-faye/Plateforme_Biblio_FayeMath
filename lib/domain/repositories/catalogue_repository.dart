import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';

/// Le contrat du catalogue en LECTURE SEULE : les classes et les matières que
/// l'application sait afficher. Le domaine DECLARE le besoin ; l'implementation
/// (`data/`) lit Drift puis Supabase et s'y plie — inversion de dependance de
/// docs/ARCHITECTURE.md §3.
///
/// Lecture seule cote app : le catalogue est ecrit uniquement par
/// `service_role` (migrations), jamais par l'eleve — RLS `classe`/`matiere`
/// autorise le SELECT a `anon` et `authenticated`, aucune ecriture (migration
/// 03, section A). D'ou l'absence de methode d'ecriture ici.
///
/// Offline-first (docs/ARCHITECTURE.md §7) : l'implementation lit le cache local
/// d'abord et rend la main immediatement, puis se rafraichit depuis le serveur
/// en arriere-plan. Le contrat n'impose que le resultat, pas la mecanique.
abstract interface class CatalogueRepository {
  /// Les 7 classes (6e … Terminale) en FLUX REACTIF (etape 21), triees par leur
  /// `ordre` d'affichage : emet immediatement le cache local, puis re-emet tout
  /// seul chaque fois qu'une resynchro en arriere-plan met le cache a jour —
  /// l'ecran se rafraichit sans action de l'eleve (ARCHITECTURE §7, 4e etape enfin
  /// tenue).
  Stream<List<Classe>> observerClasses();

  /// Les matieres du catalogue (Mathematiques, Physique-chimie) en flux reactif,
  /// meme principe que [observerClasses].
  Stream<List<Matiere>> observerMatieres();
}

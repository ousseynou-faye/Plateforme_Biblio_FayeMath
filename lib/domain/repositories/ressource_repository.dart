import 'package:fayemath_academy/domain/entities/ressource.dart';

/// Le contrat des ressources d'un chapitre en LECTURE SEULE : les documents d'un
/// chapitre, pour l'ecran de detail (maquette ecran 6, etape 16). Meme forme que
/// `ChapitreRepository` — le domaine DECLARE le besoin, `data/` s'y plie
/// (inversion de dependance, docs/ARCHITECTURE.md §3).
///
/// Lecture seule cote app : le catalogue de ressources est ecrit uniquement par
/// `service_role` (migrations / contenu reel, etape 18), jamais par l'eleve — le
/// RLS `ressource` (migration 03) autorise le SELECT et aucune ecriture. D'ou
/// l'absence de methode d'ecriture ici.
///
/// Offline-first (docs/ARCHITECTURE.md §7) : l'implementation lit le cache local
/// d'abord et rend la main immediatement, puis se rafraichit depuis Supabase en
/// arriere-plan. Le contrat n'impose que le resultat, pas la mecanique.
abstract interface class RessourceRepository {
  /// Les ressources rattachees a ce chapitre, triees par `ordre` croissant.
  ///
  /// Ne renvoie que les documents d'un CHAPITRE : un `sujet_examen` (rattache a
  /// une classe + matiere, `chapitre_id` null — voir [Ressource]) est
  /// naturellement exclu, ce qui correspond a l'ecran 6 qui liste « les documents
  /// du chapitre ».
  ///
  /// Liste VIDE si aucune ressource n'existe encore pour ce chapitre : c'est le
  /// cas normal tant que le contenu reel n'est pas produit (etape 18), pas une
  /// erreur — l'ecran affiche alors son etat vide.
  Future<List<Ressource>> ressourcesDuChapitre({required String chapitreId});
}

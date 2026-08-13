import 'package:fayemath_academy/domain/entities/chapitre.dart';

/// Le contrat des chapitres en LECTURE SEULE : les chapitres d'une (classe,
/// matiere), pour la liste des chapitres (maquette ecran 5, etape 15). Meme
/// forme que `CatalogueRepository` — le domaine DECLARE le besoin, `data/` s'y
/// plie (inversion de dependance, docs/ARCHITECTURE.md §3).
///
/// Lecture seule cote app : le catalogue de chapitres est ecrit uniquement par
/// `service_role` (migrations / contenu reel, etape 18), jamais par l'eleve — le
/// RLS `chapitre` (migration 03) autorise le SELECT a `anon`/`authenticated` et
/// aucune ecriture. D'ou l'absence de methode d'ecriture ici.
///
/// Offline-first (docs/ARCHITECTURE.md §7) : l'implementation lit le cache local
/// d'abord et rend la main immediatement, puis se rafraichit depuis Supabase en
/// arriere-plan. Le contrat n'impose que le resultat, pas la mecanique.
abstract interface class ChapitreRepository {
  /// Les chapitres de la (classe, matiere), tries par `ordre` croissant.
  ///
  /// Liste VIDE si aucun chapitre n'existe encore pour ce couple : c'est le cas
  /// normal tant que le contenu reel n'est pas produit (etape 18), pas une
  /// erreur — l'ecran affiche alors son etat vide.
  Future<List<Chapitre>> chapitresDe({
    required String classeId,
    required String matiereId,
  });
}

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';

/// Un chapitre et les documents de ce chapitre deja telecharges sur l'appareil :
/// un groupe de la liste « Mes telechargements » (maquette ecran 8, etape 20).
class GroupeTelechargements {
  const GroupeTelechargements({required this.chapitre, required this.documents});

  final Chapitre chapitre;
  final List<Ressource> documents;
}

/// Groupe les documents PRESENTS sur l'appareil par chapitre, pour l'affichage.
/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : elle vit dans `domain/`, se teste
/// sans Flutter ni disque — meme esprit que [RegroupementParStrate] (etape 15).
///
/// Chapitres ordonnes par `ordre`, documents d'un chapitre ordonnes par leur `ordre`
/// interne (cours, resume, exercices...). Un document dont le chapitre n'est pas
/// fourni (autre bibliotheque — impossible en V1 avec une seule) est ecarte plutot
/// qu'affiche sans en-tete.
abstract final class RegroupementDocumentsHorsLigne {
  static List<GroupeTelechargements> de(
    List<Ressource> presents,
    List<Chapitre> chapitres,
  ) {
    final chapitreParId = {for (final c in chapitres) c.id: c};

    final documentsParChapitre = <String, List<Ressource>>{};
    for (final ressource in presents) {
      final chapitreId = ressource.chapitreId;
      if (chapitreId == null || !chapitreParId.containsKey(chapitreId)) continue;
      (documentsParChapitre[chapitreId] ??= []).add(ressource);
    }

    final chapitresAvecDocuments =
        documentsParChapitre.keys.map((id) => chapitreParId[id]!).toList()
          ..sort((a, b) => a.ordre.compareTo(b.ordre));

    return [
      for (final chapitre in chapitresAvecDocuments)
        GroupeTelechargements(
          chapitre: chapitre,
          documents: documentsParChapitre[chapitre.id]!
            ..sort((a, b) => a.ordre.compareTo(b.ordre)),
        ),
    ];
  }
}

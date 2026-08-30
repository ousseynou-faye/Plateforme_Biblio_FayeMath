import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';

/// L'avancement d'UNE matiere : combien de chapitres « fait » sur le total de
/// cette matiere, et le pourcentage qui en decoule.
class AvancementMatiere {
  const AvancementMatiere({
    required this.matiereId,
    required this.fait,
    required this.total,
  });

  final String matiereId;
  final int fait;
  final int total;

  /// Arrondi a l'entier. `0 %` si la matiere n'a aucun chapitre (jamais une
  /// division par zero).
  int get pourcentage => total == 0 ? 0 : ((fait * 100) / total).round();

  @override
  bool operator ==(Object other) =>
      other is AvancementMatiere &&
      other.matiereId == matiereId &&
      other.fait == fait &&
      other.total == total;

  @override
  int get hashCode => Object.hash(matiereId, fait, total);

  @override
  String toString() =>
      'AvancementMatiere($matiereId, fait: $fait, total: $total)';
}

/// L'avancement GLOBAL de l'eleve : l'anneau (pourcentage tous chapitres), le
/// detail par etat (les 4 mini-stats de la maquette ecran 9) et l'avancement
/// par matiere. Tout se derive du meme couple (chapitres, etats).
class AvancementProgression {
  const AvancementProgression({
    required this.total,
    required this.fait,
    required this.enCours,
    required this.aRevoir,
    required this.aFaire,
    required this.parMatiere,
  });

  final int total;
  final int fait;
  final int enCours;
  final int aRevoir;
  final int aFaire;

  /// Une entree par matiere presente dans les chapitres, DANS L'ORDRE
  /// d'apparition (donc de `ordre` croissant). Vide si aucun chapitre.
  final List<AvancementMatiere> parMatiere;

  /// L'anneau global : chapitres « fait » sur le total, arrondi. `0 %` si vide.
  int get pourcentageGlobal => total == 0 ? 0 : ((fait * 100) / total).round();
}

/// Calcule l'[AvancementProgression] a partir des chapitres et de leur etat.
/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : vit dans `domain/`, se teste
/// sans Flutter ni Supabase. Alimente l'ecran « Ma progression » (ecran 9) et le
/// tableau de bord (ecran 4), etape 24.
///
/// « fait » garde son sens strict (fiche de revision validee, GLOSSAIRE §5) : le
/// pourcentage ne compte QUE les chapitres a l'etat `fait`, jamais un cours
/// simplement ouvert. Un chapitre absent de [etats] vaut `aFaire` (defaut, meme
/// convention que `observerEtats`). Le regroupement par matiere est PILOTE PAR LA
/// DONNEE (`chapitre.matiereId`), jamais une liste codee en dur : correct des
/// qu'une 2e bibliotheque existera, meme si une seule matiere s'affiche en V1.
abstract final class AgregationProgression {
  static AvancementProgression calculer({
    required List<Chapitre> chapitres,
    required Map<String, EtatProgression> etats,
  }) {
    final tries = [...chapitres]..sort((a, b) => a.ordre.compareTo(b.ordre));

    var fait = 0, enCours = 0, aRevoir = 0, aFaire = 0;
    final ordreMatieres = <String>[];
    final totalParMatiere = <String, int>{};
    final faitParMatiere = <String, int>{};

    for (final chapitre in tries) {
      final etat = etats[chapitre.id] ?? EtatProgression.aFaire;
      switch (etat) {
        case EtatProgression.fait:
          fait++;
          break;
        case EtatProgression.enCours:
          enCours++;
          break;
        case EtatProgression.aRevoir:
          aRevoir++;
          break;
        case EtatProgression.aFaire:
          aFaire++;
          break;
      }

      final matiereId = chapitre.matiereId;
      if (!totalParMatiere.containsKey(matiereId)) ordreMatieres.add(matiereId);
      totalParMatiere[matiereId] = (totalParMatiere[matiereId] ?? 0) + 1;
      if (etat == EtatProgression.fait) {
        faitParMatiere[matiereId] = (faitParMatiere[matiereId] ?? 0) + 1;
      }
    }

    return AvancementProgression(
      total: tries.length,
      fait: fait,
      enCours: enCours,
      aRevoir: aRevoir,
      aFaire: aFaire,
      parMatiere: [
        for (final matiereId in ordreMatieres)
          AvancementMatiere(
            matiereId: matiereId,
            fait: faitParMatiere[matiereId] ?? 0,
            total: totalParMatiere[matiereId]!,
          ),
      ],
    );
  }
}

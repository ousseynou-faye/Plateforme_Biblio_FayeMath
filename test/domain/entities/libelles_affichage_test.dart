import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';

/// Les libelles affiches a l'eleve doivent etre stables (ils viennent de la
/// maquette / du GLOSSAIRE) et SANS ACCENTS (CONVENTIONS §1).
void main() {
  // Lettres accentuees interdites cote eleve (CONVENTIONS §1). Volontairement
  // exhaustif pour attraper un accent glisse par megarde.
  final accents = RegExp('[àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ]');

  group('TypeRessource.libelleAffichage', () {
    test('libelle exact pour chacun des 8 types', () {
      expect(TypeRessource.cours.libelleAffichage, 'Cours');
      expect(TypeRessource.resume.libelleAffichage, 'Resume');
      expect(TypeRessource.exercices.libelleAffichage, 'Exercices');
      // Les 4 du kit standard reprennent la maquette (KIT, ecran 6).
      expect(TypeRessource.corrige.libelleAffichage, 'Corrige detaille');
      expect(TypeRessource.revision.libelleAffichage, 'Fiche de revision');
      expect(TypeRessource.evaluation.libelleAffichage, 'Evaluation');
      expect(
        TypeRessource.corrigeEvaluation.libelleAffichage,
        "Corrige d'evaluation",
      );
      expect(TypeRessource.sujetExamen.libelleAffichage, "Sujet d'examen");
    });

    test('aucun libelle ne porte d\'accent', () {
      for (final type in TypeRessource.values) {
        expect(
          accents.hasMatch(type.libelleAffichage),
          isFalse,
          reason: '${type.name} : ${type.libelleAffichage}',
        );
      }
    });
  });

  group('EtatProgression.libelleAffichage', () {
    test('libelle exact pour chacun des 4 etats', () {
      expect(EtatProgression.aFaire.libelleAffichage, 'A faire');
      expect(EtatProgression.enCours.libelleAffichage, 'En cours');
      expect(EtatProgression.fait.libelleAffichage, 'Fait');
      expect(EtatProgression.aRevoir.libelleAffichage, 'A revoir');
    });

    test('aucun libelle ne porte d\'accent', () {
      for (final etat in EtatProgression.values) {
        expect(accents.hasMatch(etat.libelleAffichage), isFalse);
      }
    });
  });
}

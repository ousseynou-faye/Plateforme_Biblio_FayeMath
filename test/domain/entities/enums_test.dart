import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';

void main() {
  group('TypeRessource', () {
    test('les 8 valeurs SQL correspondent exactement au schema', () {
      expect(TypeRessource.values.map((t) => t.valeurSql).toList(), [
        'cours',
        'resume',
        'exercices',
        'corrige',
        'revision',
        'evaluation',
        'corrige_evaluation',
        'sujet_examen',
      ]);
    });

    test('conversion aller-retour pour chaque valeur', () {
      for (final type in TypeRessource.values) {
        expect(TypeRessource.depuisValeurSql(type.valeurSql), type);
      }
    });

    test('une valeur inconnue leve une erreur (parsing strict)', () {
      expect(
        () => TypeRessource.depuisValeurSql('fiche_prof'),
        throwsArgumentError,
      );
    });
  });

  group('EtatProgression', () {
    test('les 4 valeurs SQL correspondent exactement au schema', () {
      expect(EtatProgression.values.map((e) => e.valeurSql).toList(), [
        'a_faire',
        'en_cours',
        'fait',
        'a_revoir',
      ]);
    });

    test('conversion aller-retour pour chaque valeur', () {
      for (final etat in EtatProgression.values) {
        expect(EtatProgression.depuisValeurSql(etat.valeurSql), etat);
      }
    });

    test('une valeur inconnue leve une erreur', () {
      expect(
        () => EtatProgression.depuisValeurSql('termine'),
        throwsArgumentError,
      );
    });
  });

  group('Cycle', () {
    test('conversion aller-retour', () {
      for (final cycle in Cycle.values) {
        expect(Cycle.depuisValeurSql(cycle.valeurSql), cycle);
      }
    });

    test('une valeur inconnue leve une erreur', () {
      expect(() => Cycle.depuisValeurSql('primaire'), throwsArgumentError);
    });
  });

  group('Serie', () {
    test('les valeurs SQL sont les codes L / S1 / S2', () {
      expect(Serie.serieL.valeurSql, 'L');
      expect(Serie.serieS1.valeurSql, 'S1');
      expect(Serie.serieS2.valeurSql, 'S2');
    });

    test('conversion aller-retour', () {
      for (final serie in Serie.values) {
        expect(Serie.depuisValeurSql(serie.valeurSql), serie);
      }
    });

    test('une valeur inconnue leve une erreur', () {
      expect(() => Serie.depuisValeurSql('S3'), throwsArgumentError);
    });
  });

  group('FormuleAbonnement', () {
    test('les 3 valeurs SQL correspondent au schema', () {
      expect(FormuleAbonnement.values.map((f) => f.valeurSql).toList(), [
        'mensuel',
        'trimestriel',
        'annee_scolaire',
      ]);
    });

    test('conversion aller-retour', () {
      for (final formule in FormuleAbonnement.values) {
        expect(FormuleAbonnement.depuisValeurSql(formule.valeurSql), formule);
      }
    });

    test('une valeur inconnue leve une erreur', () {
      expect(
        () => FormuleAbonnement.depuisValeurSql('hebdomadaire'),
        throwsArgumentError,
      );
    });
  });
}

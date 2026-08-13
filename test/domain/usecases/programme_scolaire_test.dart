import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/usecases/programme_scolaire.dart';

/// Fabrique une classe de test (id/ordre sans importance pour la regle).
Classe classe(String nom, Cycle cycle) =>
    Classe(id: 'id-$nom', nom: nom, cycle: cycle, ordre: 1);

const maths = Matiere(id: 'm-maths', nom: 'Mathématiques');
const pc = Matiere(id: 'm-pc', nom: 'Physique-chimie');

/// Le vrai catalogue (les 2 matieres reelles de la migration 07).
const catalogue = [maths, pc];

void main() {
  group('ProgrammeScolaire.serieRequise', () {
    test('non demandee au college et en 2nde', () {
      expect(
        ProgrammeScolaire.serieRequise(classe('6e', Cycle.college)),
        false,
      );
      expect(
        ProgrammeScolaire.serieRequise(classe('5e', Cycle.college)),
        false,
      );
      expect(
        ProgrammeScolaire.serieRequise(classe('4e', Cycle.college)),
        false,
      );
      expect(
        ProgrammeScolaire.serieRequise(classe('3e', Cycle.college)),
        false,
      );
      expect(
        ProgrammeScolaire.serieRequise(classe('2nde', Cycle.lycee)),
        false,
      );
    });

    test('demandee en 1ere et Terminale', () {
      expect(ProgrammeScolaire.serieRequise(classe('1ère', Cycle.lycee)), true);
      expect(
        ProgrammeScolaire.serieRequise(classe('Terminale', Cycle.lycee)),
        true,
      );
    });

    test(
      'un nom de classe hors programme leve une erreur (parsing strict)',
      () {
        expect(
          () => ProgrammeScolaire.serieRequise(classe('1re', Cycle.lycee)),
          throwsArgumentError,
        );
      },
    );
  });

  group('ProgrammeScolaire.matieresAutorisees — college et 2nde', () {
    test('6e et 5e : mathematiques seulement', () {
      expect(
        ProgrammeScolaire.matieresAutorisees(
          classe: classe('6e', Cycle.college),
          serie: null,
          catalogue: catalogue,
        ),
        [maths],
      );
      expect(
        ProgrammeScolaire.matieresAutorisees(
          classe: classe('5e', Cycle.college),
          serie: null,
          catalogue: catalogue,
        ),
        [maths],
      );
    });

    test(
      '4e, 3e, 2nde : mathematiques puis physique-chimie (dans l\'ordre)',
      () {
        for (final c in [
          classe('4e', Cycle.college),
          classe('3e', Cycle.college),
          classe('2nde', Cycle.lycee),
        ]) {
          expect(
            ProgrammeScolaire.matieresAutorisees(
              classe: c,
              serie: null,
              catalogue: catalogue,
            ),
            [maths, pc],
          );
        }
      },
    );
  });

  group(
    'ProgrammeScolaire.matieresAutorisees — 1ere / Terminale selon serie',
    () {
      for (final nom in ['1ère', 'Terminale']) {
        test('$nom sans serie : indetermine -> aucune matiere', () {
          expect(
            ProgrammeScolaire.matieresAutorisees(
              classe: classe(nom, Cycle.lycee),
              serie: null,
              catalogue: catalogue,
            ),
            isEmpty,
          );
        });

        test(
          '$nom serie L : mathematiques seulement (pas de physique-chimie)',
          () {
            expect(
              ProgrammeScolaire.matieresAutorisees(
                classe: classe(nom, Cycle.lycee),
                serie: Serie.serieL,
                catalogue: catalogue,
              ),
              [maths],
            );
          },
        );

        test('$nom series S1 et S2 : les deux matieres', () {
          expect(
            ProgrammeScolaire.matieresAutorisees(
              classe: classe(nom, Cycle.lycee),
              serie: Serie.serieS1,
              catalogue: catalogue,
            ),
            [maths, pc],
          );
          expect(
            ProgrammeScolaire.matieresAutorisees(
              classe: classe(nom, Cycle.lycee),
              serie: Serie.serieS2,
              catalogue: catalogue,
            ),
            [maths, pc],
          );
        });
      }
    },
  );

  group('ProgrammeScolaire.matieresAutorisees — robustesse au catalogue', () {
    test('une matiere du programme absente du catalogue est ignoree', () {
      expect(
        ProgrammeScolaire.matieresAutorisees(
          classe: classe('4e', Cycle.college),
          serie: null,
          catalogue: const [maths], // physique-chimie pas encore en base
        ),
        [maths],
      );
    });

    test('une matiere du catalogue hors programme n\'est jamais proposee', () {
      const informatique = Matiere(id: 'm-info', nom: 'Informatique');
      expect(
        ProgrammeScolaire.matieresAutorisees(
          classe: classe('4e', Cycle.college),
          serie: null,
          catalogue: const [maths, pc, informatique],
        ),
        [maths, pc],
      );
    });

    test('un nom de classe hors programme leve une erreur', () {
      expect(
        () => ProgrammeScolaire.matieresAutorisees(
          classe: classe('CE2', Cycle.college),
          serie: null,
          catalogue: catalogue,
        ),
        throwsArgumentError,
      );
    });
  });
}

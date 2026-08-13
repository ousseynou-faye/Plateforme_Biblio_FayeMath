import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/constants/bibliotheques_pretes.dart';

void main() {
  group('BibliothequesPretes.estPrete', () {
    test('6e Mathematiques est la seule bibliotheque prete au lancement', () {
      expect(
        BibliothequesPretes.estPrete(
          classeNom: '6e',
          matiereNom: 'Mathématiques',
        ),
        true,
      );
    });

    test('la physique-chimie de 6e n\'est pas prete', () {
      expect(
        BibliothequesPretes.estPrete(
          classeNom: '6e',
          matiereNom: 'Physique-chimie',
        ),
        false,
      );
    });

    test('les autres classes ne sont pas pretes au lancement', () {
      expect(
        BibliothequesPretes.estPrete(
          classeNom: '5e',
          matiereNom: 'Mathématiques',
        ),
        false,
      );
      expect(
        BibliothequesPretes.estPrete(
          classeNom: 'Terminale',
          matiereNom: 'Mathématiques',
        ),
        false,
      );
    });

    test('un couple inconnu renvoie faux, jamais une erreur', () {
      expect(
        BibliothequesPretes.estPrete(classeNom: 'CE2', matiereNom: 'Dessin'),
        false,
      );
    });
  });
}

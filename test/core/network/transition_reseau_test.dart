import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/network/transition_reseau.dart';

void main() {
  group('TransitionReseau.calculer', () {
    test('pas d interface depuis en ligne -> hors ligne', () {
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.enLigne,
          connecte: false,
        ),
        EtatReseau.horsLigne,
      );
    });

    test('pas d interface depuis hors ligne -> reste hors ligne', () {
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.horsLigne,
          connecte: false,
        ),
        EtatReseau.horsLigne,
      );
    });

    test('pas d interface pendant une reconnexion -> hors ligne', () {
      // Le reseau retombe avant la fin du transitoire : on revient a hors_ligne.
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.reconnexion,
          connecte: false,
        ),
        EtatReseau.horsLigne,
      );
    });

    test('interface retrouvee depuis hors ligne -> reconnexion', () {
      // Le seul cas qui produit le transitoire : le reseau REVIENT.
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.horsLigne,
          connecte: true,
        ),
        EtatReseau.reconnexion,
      );
    });

    test('interface toujours la depuis en ligne -> reste en ligne', () {
      // Un evenement de connectivite alors qu'on etait deja en ligne ne doit
      // jamais faire clignoter « Reconnexion... ».
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.enLigne,
          connecte: true,
        ),
        EtatReseau.enLigne,
      );
    });

    test('evenement connecte pendant une reconnexion -> en ligne', () {
      // Le reseau se confirme : on promeut directement, le minuteur du detecteur
      // n'a plus a le faire.
      expect(
        TransitionReseau.calculer(
          precedent: EtatReseau.reconnexion,
          connecte: true,
        ),
        EtatReseau.enLigne,
      );
    });
  });
}

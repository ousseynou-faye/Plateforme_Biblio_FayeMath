import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/etat_telechargement.dart';
import 'package:fayemath_academy/domain/usecases/resolution_etat_telechargement.dart';

void main() {
  group('ResolutionEtatTelechargement.resoudre', () {
    test('rien de tente -> telechargeable', () {
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: false,
          enCours: false,
          aEchoue: false,
        ),
        EtatTelechargement.telechargeable,
      );
    });

    test('transfert en cours -> enCours', () {
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: false,
          enCours: true,
          aEchoue: false,
        ),
        EtatTelechargement.enCours,
      );
    });

    test('fichier present -> local', () {
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: true,
          enCours: false,
          aEchoue: false,
        ),
        EtatTelechargement.local,
      );
    });

    test('dernier essai en echec -> echec', () {
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: false,
          enCours: false,
          aEchoue: true,
        ),
        EtatTelechargement.echec,
      );
    });

    test('enCours prime sur tout le reste', () {
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: true,
          enCours: true,
          aEchoue: true,
        ),
        EtatTelechargement.enCours,
      );
    });

    test('local prime sur un echec passe', () {
      // Un fichier deja present ne doit pas etre masque par l'echec d'un essai
      // anterieur.
      expect(
        ResolutionEtatTelechargement.resoudre(
          estLocal: true,
          enCours: false,
          aEchoue: true,
        ),
        EtatTelechargement.local,
      );
    });
  });
}

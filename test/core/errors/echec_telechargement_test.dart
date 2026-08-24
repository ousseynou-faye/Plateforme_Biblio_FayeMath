import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';

void main() {
  group('EchecTelechargement', () {
    test('porte la cause fournie', () {
      const echec = EchecTelechargement(CauseTelechargement.reseau);
      expect(echec.cause, CauseTelechargement.reseau);
      expect(echec.diagnostic, isNull);
    });

    test('les cinq causes reelles du moteur sont couvertes', () {
      // Verrouille l'ensemble : si une cause est ajoutee/retiree sans mise a jour
      // des messages d'affichage (Lot E), ce test le signale.
      expect(CauseTelechargement.values, hasLength(5));
      expect(
        CauseTelechargement.values,
        containsAll(<CauseTelechargement>[
          CauseTelechargement.reseau,
          CauseTelechargement.nonAutorise,
          CauseTelechargement.stockagePlein,
          CauseTelechargement.introuvable,
          CauseTelechargement.inattendu,
        ]),
      );
    });

    test('toString expose la cause et le diagnostic non sensible', () {
      const echec = EchecTelechargement(
        CauseTelechargement.stockagePlein,
        diagnostic: 'ecriture disque',
      );
      expect(
        echec.toString(),
        'EchecTelechargement(stockagePlein, ecriture disque)',
      );
    });

    test('toString sans diagnostic n\'ajoute pas de virgule', () {
      const echec = EchecTelechargement(CauseTelechargement.introuvable);
      expect(echec.toString(), 'EchecTelechargement(introuvable)');
    });
  });
}

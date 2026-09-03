import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/autorisation_telechargement.dart';
import 'package:fayemath_academy/core/network/type_interface_reseau.dart';

void main() {
  group('AutorisationTelechargement.decider', () {
    test('reglage desactive : autorise meme en donnees mobiles', () {
      expect(
        AutorisationTelechargement.decider(
          wifiSeulement: false,
          interface: TypeInterfaceReseau.donneesMobiles,
        ),
        DecisionTelechargement.autorise,
      );
    });

    test('reglage actif + donnees mobiles : bloque', () {
      expect(
        AutorisationTelechargement.decider(
          wifiSeulement: true,
          interface: TypeInterfaceReseau.donneesMobiles,
        ),
        DecisionTelechargement.bloqueDonneesMobiles,
      );
    });

    test('reglage actif + Wi-Fi : autorise', () {
      expect(
        AutorisationTelechargement.decider(
          wifiSeulement: true,
          interface: TypeInterfaceReseau.wifi,
        ),
        DecisionTelechargement.autorise,
      );
    });

    test('reglage actif + hors ligne : autorise (le moteur echouera seul)', () {
      expect(
        AutorisationTelechargement.decider(
          wifiSeulement: true,
          interface: TypeInterfaceReseau.aucune,
        ),
        DecisionTelechargement.autorise,
      );
    });
  });
}

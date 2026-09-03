import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/type_interface_reseau.dart';

// La classification est pure (l'enum ConnectivityResult est du Dart, testable
// sans le plugin natif) : on verifie le mapping et la priorite du Wi-Fi.
void main() {
  group('TypeInterfaceReseau.depuis', () {
    test('wifi -> wifi', () {
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.wifi]),
        TypeInterfaceReseau.wifi,
      );
    });

    test('ethernet et vpn comptent comme wifi (non factures)', () {
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.ethernet]),
        TypeInterfaceReseau.wifi,
      );
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.vpn]),
        TypeInterfaceReseau.wifi,
      );
    });

    test('donnees mobiles -> donneesMobiles', () {
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.mobile]),
        TypeInterfaceReseau.donneesMobiles,
      );
    });

    test('le Wi-Fi prime sur les donnees mobiles quand les deux sont actives', () {
      expect(
        TypeInterfaceReseau.depuis([
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
        ]),
        TypeInterfaceReseau.wifi,
      );
    });

    test('none, liste vide ou interfaces non pertinentes -> aucune', () {
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.none]),
        TypeInterfaceReseau.aucune,
      );
      expect(TypeInterfaceReseau.depuis([]), TypeInterfaceReseau.aucune);
      expect(
        TypeInterfaceReseau.depuis([ConnectivityResult.bluetooth]),
        TypeInterfaceReseau.aucune,
      );
    });
  });
}

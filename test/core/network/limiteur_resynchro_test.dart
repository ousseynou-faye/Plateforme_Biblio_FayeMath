import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/limiteur_resynchro.dart';

void main() {
  group('LimiteurResynchro.doitResynchroniser', () {
    test('une cle jamais vue est autorisee (premier abonnement)', () {
      final limiteur = LimiteurResynchro(horloge: () => DateTime(2026, 8, 26));
      expect(limiteur.doitResynchroniser('6e/maths'), isTrue);
    });

    test('un second appel dans la fenetre est refuse', () {
      var maintenant = DateTime(2026, 8, 26, 10, 0, 0);
      final limiteur = LimiteurResynchro(
        intervalle: const Duration(seconds: 60),
        horloge: () => maintenant,
      );
      expect(limiteur.doitResynchroniser('6e/maths'), isTrue);
      maintenant = maintenant.add(const Duration(seconds: 30));
      expect(limiteur.doitResynchroniser('6e/maths'), isFalse);
    });

    test('un appel apres la fenetre est de nouveau autorise', () {
      var maintenant = DateTime(2026, 8, 26, 10, 0, 0);
      final limiteur = LimiteurResynchro(
        intervalle: const Duration(seconds: 60),
        horloge: () => maintenant,
      );
      expect(limiteur.doitResynchroniser('6e/maths'), isTrue);
      maintenant = maintenant.add(const Duration(seconds: 61));
      expect(limiteur.doitResynchroniser('6e/maths'), isTrue);
    });

    test('deux cles distinctes sont limitees independamment', () {
      var maintenant = DateTime(2026, 8, 26, 10, 0, 0);
      final limiteur = LimiteurResynchro(
        intervalle: const Duration(seconds: 60),
        horloge: () => maintenant,
      );
      expect(limiteur.doitResynchroniser('6e/maths'), isTrue);
      // Une autre cle n'est pas affectee par la premiere.
      expect(limiteur.doitResynchroniser('5e/maths'), isTrue);
      // Mais la premiere reste bien bloquee dans sa fenetre.
      maintenant = maintenant.add(const Duration(seconds: 10));
      expect(limiteur.doitResynchroniser('6e/maths'), isFalse);
    });

    test('exactement a l intervalle, on autorise (limite non stricte)', () {
      var maintenant = DateTime(2026, 8, 26, 10, 0, 0);
      final limiteur = LimiteurResynchro(
        intervalle: const Duration(seconds: 60),
        horloge: () => maintenant,
      );
      expect(limiteur.doitResynchroniser('cle'), isTrue);
      // pile 60 s : difference == intervalle, la condition « < intervalle » est
      // fausse -> on autorise.
      maintenant = maintenant.add(const Duration(seconds: 60));
      expect(limiteur.doitResynchroniser('cle'), isTrue);
    });
  });
}

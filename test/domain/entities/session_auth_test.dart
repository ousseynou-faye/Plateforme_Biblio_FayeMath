import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/session_auth.dart';

void main() {
  group('SessionAuth', () {
    test('deux sessions du meme compte sont egales', () {
      const a = SessionAuth(utilisateurId: 'u1');
      const b = SessionAuth(utilisateurId: 'u1');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('deux comptes differents ne sont pas egaux', () {
      const a = SessionAuth(utilisateurId: 'u1');
      const b = SessionAuth(utilisateurId: 'u2');
      expect(a, isNot(equals(b)));
    });
  });
}

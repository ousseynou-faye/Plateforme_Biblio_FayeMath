// Test de fumee : verifie que l'application se construit et affiche son ecran
// d'accueil (la galerie de composants de l'etape 11) sans erreur.

import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/app.dart';

void main() {
  testWidgets('L\'application demarre sur la galerie de composants', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FayeMathApp());
    await tester.pumpAndSettle();

    // Le titre de l'AppBar de l'ecran d'accueil doit etre present.
    expect(find.text('Charte & composants'), findsOneWidget);
  });
}

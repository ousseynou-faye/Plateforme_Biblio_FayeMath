import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/screens/authentification_screen.dart';

/// Faux repository inerte : les tests ci-dessous n'atteignent jamais Supabase
/// (la validation cliente echoue avant, ou l'on ne fait que basculer le mode).
class _FauxAuthRepository implements AuthRepository {
  @override
  SessionAuth? get sessionCourante => null;
  @override
  Stream<SessionAuth?> get changementsSession => const Stream.empty();
  @override
  Future<void> sInscrire({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seConnecter({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seDeconnecter() async {}
}

Future<void> monterEcran(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(_FauxAuthRepository()),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const AuthentificationScreen(),
      ),
    ),
  );
}

void main() {
  testWidgets('ouvre en mode inscription avec le parcours sans compte', (
    tester,
  ) async {
    await monterEcran(tester);

    // Titre + bouton principal « Creer mon compte ».
    expect(
      find.widgetWithText(FilledButton, 'Creer mon compte'),
      findsOneWidget,
    );
    // La bascule vers la connexion et le parcours invite sont presents.
    expect(find.widgetWithText(TextButton, 'Se connecter'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Continuer sans compte'),
      findsOneWidget,
    );
  });

  testWidgets('la validation cliente bloque un e-mail invalide', (
    tester,
  ) async {
    await monterEcran(tester);

    await tester.enterText(find.byType(TextFormField).first, 'pas-un-email');
    await tester.enterText(find.byType(TextFormField).last, 'motdepasse1');
    await tester.tap(find.widgetWithText(FilledButton, 'Creer mon compte'));
    await tester.pump();

    expect(find.text('Saisis une adresse e-mail valide.'), findsOneWidget);
  });

  testWidgets(
    'la regle de mot de passe s\'applique a l\'inscription (chiffre manquant)',
    (tester) async {
      await monterEcran(tester);

      await tester.enterText(
        find.byType(TextFormField).first,
        'awa@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'motdepasse');
      await tester.tap(find.widgetWithText(FilledButton, 'Creer mon compte'));
      await tester.pump();

      expect(find.textContaining('Il manque un chiffre'), findsOneWidget);
    },
  );

  testWidgets('la bascule passe en mode connexion', (tester) async {
    await monterEcran(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Se connecter'));
    await tester.pump();

    // Le bouton principal devient « Se connecter » ; la bascule inverse propose
    // desormais de creer un compte.
    expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Creer un compte'), findsOneWidget);
  });
}

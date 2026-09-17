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
  @override
  Future<void> demanderReinitialisation({required String email}) async {}
  @override
  Future<void> verifierCodeReinitialisation({
    required String email,
    required String code,
  }) async {}
  @override
  Future<void> definirNouveauMotDePasse({required String motDePasse}) async {}

  @override
  Future<void> supprimerMonCompte() async {}
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

  // --- Sous-flux « mot de passe oublie » (lot « Qualite B ») -----------------

  /// Passe en mode connexion puis ouvre le sous-flux de reinitialisation.
  Future<void> ouvrirReinitialisation(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(TextButton, 'Se connecter'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Mot de passe oublie ?'));
    await tester.pumpAndSettle();
  }

  testWidgets('« Mot de passe oublie ? » ouvre l\'etape demande', (
    tester,
  ) async {
    await monterEcran(tester);
    await ouvrirReinitialisation(tester);

    expect(find.text('Mot de passe oublie'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Envoyer le code'), findsOneWidget);
  });

  testWidgets('un code non numerique est refuse par la validation cliente', (
    tester,
  ) async {
    await monterEcran(tester);
    await ouvrirReinitialisation(tester);

    await tester.enterText(find.byType(TextFormField), 'awa@example.com');
    await tester.tap(find.widgetWithText(FilledButton, 'Envoyer le code'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'abc');
    await tester.tap(find.widgetWithText(FilledButton, 'Valider le code'));
    await tester.pump();

    expect(find.text('Le code fait 6 chiffres.'), findsOneWidget);
  });

  testWidgets(
    'parcours complet : demande -> code -> nouveau mdp -> succes -> connexion',
    (tester) async {
      await monterEcran(tester);
      await ouvrirReinitialisation(tester);

      // Etape demande : e-mail -> envoyer le code.
      await tester.enterText(find.byType(TextFormField), 'awa@example.com');
      await tester.tap(find.widgetWithText(FilledButton, 'Envoyer le code'));
      await tester.pumpAndSettle();
      expect(find.text('Verifie ta boite mail'), findsOneWidget);

      // Etape verification : saisir le code -> devoile le nouveau mot de passe.
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.widgetWithText(FilledButton, 'Valider le code'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Definir le mot de passe'),
        findsOneWidget,
      );

      // Nouveau mot de passe (regle 8 caracteres + un chiffre) -> succes.
      await tester.enterText(find.byType(TextFormField), 'nouveaumdp1');
      await tester.tap(
        find.widgetWithText(FilledButton, 'Definir le mot de passe'),
      );
      await tester.pumpAndSettle();

      // Confirmation + retour au formulaire de connexion.
      expect(find.textContaining('Mot de passe modifie'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
    },
  );

  testWidgets('« Annuler » revient au formulaire d\'authentification', (
    tester,
  ) async {
    await monterEcran(tester);
    await ouvrirReinitialisation(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();

    expect(find.text('Mot de passe oublie'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Se connecter'), findsOneWidget);
  });
}

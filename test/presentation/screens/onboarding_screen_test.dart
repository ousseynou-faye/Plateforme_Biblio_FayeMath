import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/repositories/preferences_onboarding_repository.dart';
import 'package:fayemath_academy/presentation/providers/onboarding_provider.dart';
import 'package:fayemath_academy/presentation/screens/onboarding_screen.dart';

/// Faux memoire d'onboarding : retient l'appel a [marquerOnboardingVu].
class _FauxPreferencesOnboarding implements PreferencesOnboardingRepository {
  bool vu = false;

  @override
  Future<bool> onboardingVu() async => vu;
  @override
  Future<void> marquerOnboardingVu() async => vu = true;
  @override
  Future<void> reinitialiserOnboarding() async => vu = false;
}

Future<void> monterEcran(
  WidgetTester tester, {
  bool reduireAnimations = false,
  PreferencesOnboardingRepository? fake,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesOnboardingRepositoryProvider.overrideWithValue(
          fake ?? _FauxPreferencesOnboarding(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: Builder(
          builder: (context) => MediaQuery(
            // Simule (ou non) « reduire les animations » du systeme (persona Sam).
            data: MediaQuery.of(
              context,
            ).copyWith(disableAnimations: reduireAnimations),
            child: const OnboardingScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('diapo 1 (marque) : tag, badge et CTA « Suivant »', (
    tester,
  ) async {
    await monterEcran(tester);

    expect(find.text('La reussite se construit a domicile'), findsOneWidget);
    expect(find.text('2 matieres'), findsOneWidget);
    // « Passer » est un vrai bouton, visible sur les premieres diapos.
    expect(find.widgetWithText(TextButton, 'Passer'), findsOneWidget);
    // CTA « Suivant » (pas encore « Commencer »).
    expect(find.widgetWithText(FilledButton, 'Suivant'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Commencer'), findsNothing);
  });

  testWidgets('« Suivant » avance : hors-ligne -> humaine (avec apercu concret)', (
    tester,
  ) async {
    await monterEcran(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Fonctionne sans connexion'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
    await tester.pumpAndSettle();
    expect(
      find.text('Un vrai professeur derriere l\'application'),
      findsOneWidget,
    );
    // Apercu CONCRET de la diapo 3 (correctif d'audit) + CTA « Commencer ».
    expect(find.text('Cours — Le cercle'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Commencer'), findsOneWidget);
    // Sur la derniere diapo, « Passer » laisse la place au CTA « Commencer ».
    expect(find.widgetWithText(TextButton, 'Passer'), findsNothing);
  });

  testWidgets(
    'derniere diapo : le CTA pulse (ScaleTransition) quand les animations sont actives',
    (tester) async {
      await monterEcran(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
      await tester.pumpAndSettle();

      // La pulsation limitee est identifiee par sa cle dediee (d'autres
      // ScaleTransition existent dans l'arbre, ex. la transition de route).
      expect(find.byKey(const ValueKey('cta-pulsant')), findsOneWidget);
    },
  );

  testWidgets(
    'reduction d\'animations : aucune pulsation (pas de ScaleTransition), CTA fonctionnel',
    (tester) async {
      final fake = _FauxPreferencesOnboarding();
      await monterEcran(tester, reduireAnimations: true, fake: fake);

      await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
      await tester.pumpAndSettle();

      // Persona Sam : sous reduction d'animations, la pulsation est coupee.
      expect(find.byKey(const ValueKey('cta-pulsant')), findsNothing);

      // Et « Commencer » marque tout de meme l'onboarding comme vu.
      await tester.tap(find.widgetWithText(FilledButton, 'Commencer'));
      await tester.pump();
      expect(fake.vu, isTrue);
    },
  );

  testWidgets('« Passer » marque l\'onboarding comme vu', (tester) async {
    final fake = _FauxPreferencesOnboarding();
    await monterEcran(tester, fake: fake);

    await tester.tap(find.widgetWithText(TextButton, 'Passer'));
    await tester.pump();

    expect(fake.vu, isTrue);
  });
}

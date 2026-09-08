// Tests de l'ecran « Voir l'offre » (ecran 17 minimal, etape 25 lot F). Prouvent
// les decisions du point 5.5 : les trois tarifs verrouilles sont AFFICHES, il n'y
// a AUCUN bouton d'achat, la matrice est celle du document 2 §2.1 (exercices
// gratuits sur 2 chapitres, 1 sujet gratuit par classe), et la promesse « de la 6e
// a la Terminale » n'est PAS reprise. Le bandeau reseau est present (route racine).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/screens/offre_premium_screen.dart';

Future<void> _monter(WidgetTester tester) async {
  // Surface haute : la carte des tarifs est en bas de la ListView et ne serait
  // sinon pas construite dans le viewport 600 px par defaut.
  await tester.binding.setSurfaceSize(const Size(600, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        etatReseauProvider.overrideWith(
          (ref) => Stream.value(EtatReseau.enLigne),
        ),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const OffrePremiumScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche les trois tarifs verrouilles + « offert au tutorat »', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.text('Ce que change Premium'), findsOneWidget);
    expect(find.text('1 000 FCFA'), findsOneWidget);
    expect(find.text('2 500 FCFA'), findsOneWidget);
    expect(find.text('6 000 FCFA'), findsOneWidget);
    expect(find.text('par mois'), findsOneWidget);
    expect(find.text('par trimestre'), findsOneWidget);
    expect(find.text('par annee scolaire'), findsOneWidget);
    expect(
      find.textContaining('Offert aux eleves inscrits au tutorat'),
      findsOneWidget,
    );
    expect(find.textContaining('disponible prochainement'), findsOneWidget);
  });

  testWidgets('aucun bouton d\'achat (etape 25 : pas de paiement)', (
    tester,
  ) async {
    await _monter(tester);

    // Ni CTA rempli, ni verbe d'achat.
    expect(find.byType(FilledButton), findsNothing);
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            RegExp(
              r'acheter|souscrire|payer|abonner',
              caseSensitive: false,
            ).hasMatch(w.data ?? ''),
      ),
      findsNothing,
    );
  });

  testWidgets('matrice fidele au document 2 §2.1 (pas la version simplifiee)', (
    tester,
  ) async {
    await _monter(tester);

    // Les deux corrections vis-a-vis de la maquette §4.2.
    expect(find.text('2 premiers chapitres'), findsOneWidget); // exercices
    expect(find.text('1 par classe'), findsOneWidget); // sujets d'examen
    // Les lignes premium clefs.
    expect(find.text('Corriges detailles'), findsOneWidget);
    expect(find.text('Evaluations et leurs corriges'), findsOneWidget);
    // En-tetes de colonnes.
    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Premium'), findsWidgets);
  });

  testWidgets('ne reprend PAS la promesse « de la 6e a la Terminale »', (
    tester,
  ) async {
    await _monter(tester);

    expect(find.textContaining('Terminale'), findsNothing);
  });

  testWidgets('le bandeau reseau est present (route racine)', (tester) async {
    await _monter(tester);

    expect(find.text('En ligne'), findsOneWidget);
  });
}

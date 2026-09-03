// Tests de l'ecran « Accueil / Tableau de bord » (ecran 4), complement du 03/09 :
// la section « Ta prochaine etape » (chapitre a revoir ou etat positif), sans
// regression de la carte de progression. On override directement les providers
// derives (valeurs), pas besoin de faux repositories ni de routeur ici.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/screens/tableau_bord_screen.dart';

Chapitre _chapitre() => const Chapitre(
  id: 'c-1',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 1,
  titre: 'Les nombres entiers',
  strate: 'Activites numeriques',
  ordre: 1,
);

Future<void> _monter(WidgetTester tester, {required Chapitre? aRevoir}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        avancementProgressionProvider.overrideWithValue(
          AsyncData(
            AgregationProgression.calculer(
              chapitres: const [],
              etats: const {},
            ),
          ),
        ),
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData<BibliothequeCourante?>(null),
        ),
        prochainChapitreARevoirProvider.overrideWithValue(aRevoir),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const TableauBordScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('carte de progression + « Ta prochaine etape » (chapitre a revoir)', (
    tester,
  ) async {
    await _monter(tester, aRevoir: _chapitre());

    // La carte de progression reste presente (non-regression).
    expect(find.text('Ta progression'), findsOneWidget);
    expect(find.text('Ma progression'), findsOneWidget);

    // La nouvelle section propose le chapitre a revoir.
    expect(find.text('Ta prochaine etape'), findsOneWidget);
    expect(find.text('Revoir ce chapitre'), findsOneWidget);
    expect(find.text('Chapitre 1 · Les nombres entiers'), findsOneWidget);
    expect(find.textContaining('Rien a revoir'), findsNothing);
  });

  testWidgets('rien a revoir -> etat positif (pas de carte)', (tester) async {
    await _monter(tester, aRevoir: null);

    expect(find.text('Ta prochaine etape'), findsOneWidget);
    expect(find.textContaining('Rien a revoir'), findsOneWidget);
    expect(find.text('Revoir ce chapitre'), findsNothing);
  });
}

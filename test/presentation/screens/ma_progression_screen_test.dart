import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/screens/ma_progression_screen.dart';

const _classe = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);
const _matiere = Matiere(id: 'm-maths', nom: 'Mathematiques');
const _chapitreARevoir = Chapitre(
  id: 'ch-2',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 2,
  titre: 'Les angles',
  strate: null,
  ordre: 2,
);

// 4 chapitres : 2 fait, 1 en cours, 1 a revoir -> 50 % global, matiere a 50 %.
const _avancement = AvancementProgression(
  total: 4,
  fait: 2,
  enCours: 1,
  aRevoir: 1,
  aFaire: 0,
  parMatiere: [AvancementMatiere(matiereId: 'm-maths', fait: 2, total: 4)],
);

Future<void> _monter(WidgetTester tester, {Chapitre? aRevoir}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        avancementProgressionProvider.overrideWithValue(
          const AsyncData(_avancement),
        ),
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData(
            BibliothequeCourante(classe: _classe, matiere: _matiere),
          ),
        ),
        matieresProvider.overrideWithValue(const AsyncData([_matiere])),
        prochainChapitreARevoirProvider.overrideWithValue(aRevoir),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const MaProgressionScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche l\'avancement global, par etat et par matiere', (
    tester,
  ) async {
    await _monter(tester, aRevoir: _chapitreARevoir);

    // Anneau global (+ libelle).
    expect(find.text('termine'), findsOneWidget);
    // Callout du sens de « fait ».
    expect(find.text('Ce que veut dire « fait »'), findsOneWidget);
    // Section + barre par matiere avec le nom resolu depuis le catalogue.
    expect(find.text('Par matiere'), findsOneWidget);
    expect(find.text('Mathematiques'), findsOneWidget);
    // Mini-stats : les 4 libelles d'etat.
    expect(find.text('fait'), findsOneWidget);
    expect(find.text('en cours'), findsOneWidget);
    expect(find.text('a revoir'), findsOneWidget);
    expect(find.text('a faire'), findsOneWidget);
    // Prochaine action : le chapitre a revoir est propose.
    expect(find.text('Ta prochaine action'), findsOneWidget);
    expect(find.textContaining('Les angles'), findsOneWidget);
  });

  testWidgets('sans chapitre a revoir : pas de carte « prochaine action »', (
    tester,
  ) async {
    await _monter(tester, aRevoir: null);

    expect(find.text('Ta prochaine action'), findsNothing);
    // Le reste de l'ecran reste affiche.
    expect(find.text('Par matiere'), findsOneWidget);
  });
}

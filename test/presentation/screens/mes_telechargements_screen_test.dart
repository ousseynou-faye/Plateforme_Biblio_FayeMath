import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_documents_hors_ligne.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/mes_telechargements_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';
import 'package:fayemath_academy/presentation/screens/mes_telechargements_screen.dart';

/// Espion : capture les ids passes a [supprimer] pour verifier le cablage.
class _SpyTelechargementRepository implements TelechargementRepository {
  final List<String> supprimes = [];

  @override
  Future<void> supprimer(String ressourceId) async => supprimes.add(ressourceId);

  @override
  Future<String?> cheminLocalSiPresent(String ressourceId) async => null;
  @override
  Future<List<Ressource>> listerPresents() async => const [];
  @override
  Stream<double> telecharger(Ressource ressource) =>
      const Stream<double>.empty();
}

const _classe = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);
const _maths = Matiere(id: 'm-maths', nom: 'Mathematiques');
const _biblio = BibliothequeCourante(classe: _classe, matiere: _maths);

const _chapitre1 = Chapitre(
  id: 'ch1',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 1,
  titre: 'Les entiers naturels',
  strate: 'Activites numeriques',
  ordre: 1,
);

Ressource _cours() => const Ressource(
  id: 'r-cours',
  chapitreId: 'ch1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.cours,
  titre: 'Cours',
  tailleOctets: 44000,
  premium: false,
  version: 1,
  cheminStorage: '6e/mathematiques/01/cours.pdf',
  ordre: 1,
);

Ressource _resume() => const Ressource(
  id: 'r-resume',
  chapitreId: 'ch1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.resume,
  titre: 'Methodes',
  tailleOctets: 20000,
  premium: false,
  version: 1,
  cheminStorage: '6e/mathematiques/01/resume.pdf',
  ordre: 2,
);

/// Monte l'ecran avec une bibliotheque resolue et un apercu injecte : on teste le
/// RENDU (l'anneau, le compteur, les groupes), la logique pure etant couverte par
/// ses propres tests.
Future<void> _monter(
  WidgetTester tester,
  ApercuHorsLigne apercu, {
  TelechargementRepository? telechargement,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData<BibliothequeCourante?>(_biblio),
        ),
        apercuHorsLigneProvider.overrideWith((ref, cle) async => apercu),
        telechargementRepositoryProvider.overrideWithValue(
          telechargement ?? _SpyTelechargementRepository(),
        ),
      ],
      child: const MaterialApp(home: MesTelechargementsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche l\'anneau, le compteur et les documents groupes', (
    tester,
  ) async {
    final apercu = ApercuHorsLigne(
      ratio: const RatioHorsLigne(chapitresHorsLigne: 1, chapitresTotal: 2),
      groupes: [
        GroupeTelechargements(chapitre: _chapitre1, documents: [_cours()]),
      ],
    );
    await _monter(tester, apercu);

    expect(find.text('50 %'), findsOneWidget);
    expect(
      find.text('1 sur 2 chapitres disponibles hors-ligne'),
      findsOneWidget,
    );
    expect(find.text('Chapitre 1 · Les entiers naturels'), findsOneWidget);
    // Le libelle d'affichage du type (getter pur, etape 16), pas la valeur SQL.
    expect(find.text('Cours'), findsOneWidget);
  });

  testWidgets('etat vide quand rien n\'est telecharge', (tester) async {
    await _monter(
      tester,
      const ApercuHorsLigne(
        ratio: RatioHorsLigne(chapitresHorsLigne: 0, chapitresTotal: 2),
        groupes: [],
      ),
    );

    expect(find.text('Aucun document hors-ligne'), findsOneWidget);
    expect(find.text('Chapitre 1 · Les entiers naturels'), findsNothing);
  });

  ApercuHorsLigne apercuAvecCours() => ApercuHorsLigne(
    ratio: const RatioHorsLigne(chapitresHorsLigne: 1, chapitresTotal: 2),
    groupes: [
      GroupeTelechargements(chapitre: _chapitre1, documents: [_cours()]),
    ],
  );

  testWidgets('poubelle -> confirmer -> supprime le document + SnackBar', (
    tester,
  ) async {
    final spy = _SpyTelechargementRepository();
    await _monter(tester, apercuAvecCours(), telechargement: spy);

    await tester.tap(find.byTooltip('Supprimer ce document'));
    await tester.pumpAndSettle();
    expect(find.text('Supprimer ce document ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(spy.supprimes, ['r-cours']);
    expect(find.text('Document supprime'), findsOneWidget);
  });

  testWidgets('poubelle -> annuler -> ne supprime rien', (tester) async {
    final spy = _SpyTelechargementRepository();
    await _monter(tester, apercuAvecCours(), telechargement: spy);

    await tester.tap(find.byTooltip('Supprimer ce document'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Annuler'));
    await tester.pumpAndSettle();

    expect(spy.supprimes, isEmpty);
    expect(find.text('Supprimer ce document ?'), findsNothing);
  });

  testWidgets('Tout supprimer -> confirmer -> supprime tous les documents', (
    tester,
  ) async {
    final spy = _SpyTelechargementRepository();
    await _monter(
      tester,
      ApercuHorsLigne(
        ratio: const RatioHorsLigne(chapitresHorsLigne: 0, chapitresTotal: 2),
        groupes: [
          GroupeTelechargements(
            chapitre: _chapitre1,
            documents: [_cours(), _resume()],
          ),
        ],
      ),
      telechargement: spy,
    );

    await tester.tap(find.widgetWithText(TextButton, 'Tout supprimer'));
    await tester.pumpAndSettle();
    expect(find.text('Tout supprimer ?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Supprimer'));
    await tester.pumpAndSettle();

    expect(spy.supprimes, ['r-cours', 'r-resume']);
    expect(find.text('Documents supprimes'), findsOneWidget);
  });
}

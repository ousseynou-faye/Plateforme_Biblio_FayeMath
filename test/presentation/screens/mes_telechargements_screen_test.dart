import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_documents_hors_ligne.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/mes_telechargements_provider.dart';
import 'package:fayemath_academy/presentation/screens/mes_telechargements_screen.dart';

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

/// Monte l'ecran avec une bibliotheque resolue et un apercu injecte : on teste le
/// RENDU (l'anneau, le compteur, les groupes), la logique pure etant couverte par
/// ses propres tests.
Future<void> _monter(WidgetTester tester, ApercuHorsLigne apercu) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bibliothequeCouranteProvider.overrideWithValue(
          const AsyncData<BibliothequeCourante?>(_biblio),
        ),
        apercuHorsLigneProvider.overrideWith((ref, cle) async => apercu),
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
}

// Tests de l'ecran « Detail d'un chapitre » (etape 16), monte isolement avec un
// faux repository. L'etat charge ne se voit PAS sur appareil (la base est vide
// jusqu'a l'etape 18) : ces tests sont la preuve de l'affichage des documents (N
// compte, libelle, taille en Ko, badge gratuit/premium) et de l'etat vide.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/screens/detail_chapitre_screen.dart';

class _FauxRessourceRepository implements RessourceRepository {
  _FauxRessourceRepository(this.ressources);

  final List<Ressource> ressources;

  @override
  Future<List<Ressource>> ressourcesDuChapitre({
    required String chapitreId,
  }) async => ressources;
}

const _chapitre = Chapitre(
  id: 'ch-3',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 3,
  titre: 'Les triangles',
  strate: 'Activites geometriques',
  ordre: 3,
);

Ressource _doc({
  required TypeRessource type,
  required int octets,
  required bool premium,
  required int ordre,
}) => Ressource(
  id: 'r-$ordre',
  chapitreId: 'ch-3',
  classeId: null,
  matiereId: null,
  type: type,
  titre: type.libelleAffichage,
  tailleOctets: octets,
  premium: premium,
  version: 1,
  cheminStorage: null,
  ordre: ordre,
);

Future<void> _monter(
  WidgetTester tester, {
  required List<Ressource> ressources,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ressourceRepositoryProvider.overrideWithValue(
          _FauxRessourceRepository(ressources),
        ),
      ],
      child: const MaterialApp(
        home: DetailChapitreScreen(chapitre: _chapitre),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche le titre, le compteur, les documents et leur statut', (
    tester,
  ) async {
    await _monter(
      tester,
      ressources: [
        _doc(
          type: TypeRessource.cours,
          octets: 168 * 1024,
          premium: false,
          ordre: 1,
        ),
        _doc(
          type: TypeRessource.corrige,
          octets: 194 * 1024,
          premium: true,
          ordre: 2,
        ),
      ],
    );

    // AppBar « Chapitre N » + titre du chapitre.
    expect(find.text('Chapitre 3'), findsOneWidget);
    expect(find.text('Les triangles'), findsOneWidget);

    // Statut de progression : affichage seulement, toujours « A faire ».
    expect(find.text('Statut :'), findsOneWidget);
    expect(find.text('A faire'), findsOneWidget);
    expect(find.text('Modifier'), findsOneWidget);

    // Le compteur est calcule (jamais « 4 » en dur).
    expect(find.text('Les 2 documents du chapitre'), findsOneWidget);

    // Libelles de type (repris de la maquette) + tailles en Ko.
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('Corrige detaille'), findsOneWidget);
    expect(find.text('168 Ko'), findsOneWidget);
    expect(find.text('194 Ko'), findsOneWidget);

    // Un badge Gratuit et un badge Premium (lus tels quels, jamais recalcules).
    expect(find.text('Gratuit'), findsOneWidget);
    expect(find.text('Premium'), findsOneWidget);
  });

  testWidgets('compteur au singulier avec un seul document', (tester) async {
    await _monter(
      tester,
      ressources: [
        _doc(
          type: TypeRessource.cours,
          octets: 168 * 1024,
          premium: false,
          ordre: 1,
        ),
      ],
    );

    expect(find.text('1 document du chapitre'), findsOneWidget);
  });

  testWidgets('aucune ressource -> etat vide (pas une erreur)', (tester) async {
    await _monter(tester, ressources: const []);

    expect(find.text('Documents bientot disponibles'), findsOneWidget);
    expect(find.textContaining('pas encore en ligne'), findsOneWidget);
    // Ce n'est pas l'etat d'erreur.
    expect(find.text('Impossible de charger les documents.'), findsNothing);
  });
}

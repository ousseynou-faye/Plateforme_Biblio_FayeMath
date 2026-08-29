// Tests de l'ecran « Detail d'un chapitre » (etape 16), monte isolement avec un
// faux repository. L'etat charge ne se voit PAS sur appareil (la base est vide
// jusqu'a l'etape 18) : ces tests sont la preuve de l'affichage des documents (N
// compte, libelle, taille en Ko, badge gratuit/premium) et de l'etat vide.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/progression_repository.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/screens/detail_chapitre_screen.dart';

class _FauxRessourceRepository implements RessourceRepository {
  _FauxRessourceRepository(this.ressources);

  final List<Ressource> ressources;

  @override
  Stream<List<Ressource>> observerRessourcesDuChapitre({
    required String chapitreId,
  }) => Stream.value(ressources);
}

/// Faux auth : « connecte » si [session] est non nul (sinon deconnecte -> invite).
class _FauxAuthRepository implements AuthRepository {
  _FauxAuthRepository({this.session});

  final SessionAuth? session;

  @override
  SessionAuth? get sessionCourante => session;
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

/// Faux suivi de progression, avec mouchard sur la derniere ecriture.
class _FauxProgressionRepository implements ProgressionRepository {
  _FauxProgressionRepository([Map<String, EtatProgression>? etats])
    : etats = {...?etats};

  final Map<String, EtatProgression> etats;
  String? dernierChapitreEcrit;
  EtatProgression? dernierEtatEcrit;

  @override
  Stream<EtatProgression> observerEtat({
    required String utilisateurId,
    required String chapitreId,
  }) => Stream.value(etats[chapitreId] ?? EtatProgression.aFaire);

  @override
  Stream<Map<String, EtatProgression>> observerEtats(String utilisateurId) =>
      Stream.value(etats);

  @override
  Future<void> definirEtat({
    required String utilisateurId,
    required String chapitreId,
    required EtatProgression etat,
  }) async {
    dernierChapitreEcrit = chapitreId;
    dernierEtatEcrit = etat;
    etats[chapitreId] = etat;
  }

  @override
  Future<void> synchroniser({required String utilisateurId}) async {}
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
  SessionAuth? session = const SessionAuth(utilisateurId: 'u1'),
  _FauxProgressionRepository? progression,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        etatReseauProvider.overrideWith(
          (ref) => const Stream<EtatReseau>.empty(),
        ),
        authRepositoryProvider.overrideWithValue(
          _FauxAuthRepository(session: session),
        ),
        ressourceRepositoryProvider.overrideWithValue(
          _FauxRessourceRepository(ressources),
        ),
        progressionRepositoryProvider.overrideWithValue(
          progression ?? _FauxProgressionRepository(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const DetailChapitreScreen(chapitre: _chapitre),
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

    // Statut de progression reel : defaut « A faire » (aucune progression).
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

  testWidgets('la pastille reflete l\'etat enregistre (etape 22)', (
    tester,
  ) async {
    await _monter(
      tester,
      ressources: const [],
      progression: _FauxProgressionRepository(const {
        'ch-3': EtatProgression.enCours,
      }),
    );

    // Le chip montre l'etat reel, pas le « A faire » fige d'avant l'etape 22.
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('A faire'), findsNothing);
  });

  testWidgets('« Modifier » ouvre le selecteur des 4 etats + la regle « Fait »', (
    tester,
  ) async {
    await _monter(tester, ressources: const []);

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();

    // Les 4 etats sont proposes (le titre du chip + les options du selecteur ->
    // « A faire » apparait deux fois : chip + option).
    expect(find.text('A faire'), findsNWidgets(2));
    expect(find.text('En cours'), findsOneWidget);
    expect(find.text('Fait'), findsOneWidget);
    expect(find.text('A revoir'), findsOneWidget);
    // La regle metier de « Fait » est rappelee au moment de choisir (Point 1).
    expect(find.textContaining('fiche de revision'), findsOneWidget);
  });

  testWidgets('choisir un etat appelle definirEtat avec le bon etat', (
    tester,
  ) async {
    final progression = _FauxProgressionRepository();
    await _monter(tester, ressources: const [], progression: progression);

    await tester.tap(find.text('Modifier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fait'));
    await tester.pumpAndSettle();

    expect(progression.dernierChapitreEcrit, 'ch-3');
    expect(progression.dernierEtatEcrit, EtatProgression.fait);
  });

  testWidgets(
    'invite : « Modifier » invite a creer un compte, pas d\'ecriture',
    (tester) async {
      final progression = _FauxProgressionRepository();
      // session null -> l'etat d'auth est « deconnecte » (pas AuthConnecte).
      await _monter(
        tester,
        ressources: const [],
        session: null,
        progression: progression,
      );

      await tester.tap(find.text('Modifier'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Cree un compte'), findsOneWidget);
      expect(progression.dernierEtatEcrit, isNull);
    },
  );
}

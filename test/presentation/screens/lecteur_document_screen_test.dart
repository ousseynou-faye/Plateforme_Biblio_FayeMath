// Tests du lecteur de document (etape 17, ecran 7). Le rendu PDF reel ne se
// teste PAS ici : `PdfViewPinch` leve UnimplementedError sous Windows (l'hote des
// tests) et n'existe que sur la cible Android — il se verifie sur appareil (DoD,
// Lot D). On couvre donc : les libelles PURS, et le chrome de l'ecran quand le
// document n'est PAS encore sur l'appareil (aucun PDF local -> pas de PdfViewPinch).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';
import 'package:fayemath_academy/presentation/screens/lecteur_document_screen.dart';

class _FauxCatalogueRepository implements CatalogueRepository {
  _FauxCatalogueRepository(this.lesClasses, this.lesMatieres);

  final List<Classe> lesClasses;
  final List<Matiere> lesMatieres;

  @override
  Stream<List<Classe>> observerClasses() => Stream.value(lesClasses);
  @override
  Stream<List<Matiere>> observerMatieres() => Stream.value(lesMatieres);
}

/// Faux moteur de telechargement : aucun fichier sur le disque, un flux inerte.
class _FauxTelechargementRepository implements TelechargementRepository {
  @override
  Future<String?> cheminLocalSiPresent(String ressourceId) async => null;

  @override
  Stream<double> telecharger(Ressource ressource) =>
      const Stream<double>.empty();

  // Non exercees par les tests du lecteur (liste/suppression = ecran 8).
  @override
  Future<List<Ressource>> listerPresents() async => const [];

  @override
  Future<void> supprimer(String ressourceId) async {}
}

/// Faux abonnement : renvoie l'abonnement fourni (ou null).
class _FauxAbonnementRepository implements AbonnementRepository {
  _FauxAbonnementRepository(this.abonnement);

  final Abonnement? abonnement;

  @override
  Stream<Abonnement?> observerAbonnement(String utilisateurId) =>
      Stream.value(abonnement);
}

/// Faux repository d'auth minimal : une session presente = eleve connecte.
class _FauxAuthRepository implements AuthRepository {
  _FauxAuthRepository({this.sessionInitiale});

  final SessionAuth? sessionInitiale;
  final _controleur = StreamController<SessionAuth?>.broadcast();

  @override
  SessionAuth? get sessionCourante => sessionInitiale;
  @override
  Stream<SessionAuth?> get changementsSession => _controleur.stream;
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

const _maths = Matiere(id: 'm-maths', nom: 'Mathématiques');
const _classe6e = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);

const _chapitre = Chapitre(
  id: 'ch-1',
  classeId: 'c-6e',
  matiereId: 'm-maths',
  numero: 1,
  titre: 'Nombres decimaux arithmetiques',
  strate: 'Activites numeriques',
  ordre: 1,
);

Ressource _ressource({
  required TypeRessource type,
  required String? cheminStorage,
  bool premium = false,
}) => Ressource(
  id: 'r-1',
  chapitreId: 'ch-1',
  classeId: null,
  matiereId: null,
  type: type,
  titre: 'Document de test',
  tailleOctets: 12345,
  premium: premium,
  version: 1,
  cheminStorage: cheminStorage,
  ordre: 1,
);

Future<void> _monter(
  WidgetTester tester,
  Ressource ressource, {
  bool connecte = true,
  Abonnement? abonnement,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        etatReseauProvider.overrideWith(
          (ref) => const Stream<EtatReseau>.empty(),
        ),
        catalogueRepositoryProvider.overrideWithValue(
          _FauxCatalogueRepository(const [_classe6e], const [_maths]),
        ),
        telechargementRepositoryProvider.overrideWithValue(
          _FauxTelechargementRepository(),
        ),
        authRepositoryProvider.overrideWithValue(
          _FauxAuthRepository(
            sessionInitiale: connecte
                ? const SessionAuth(utilisateurId: 'u1')
                : null,
          ),
        ),
        abonnementRepositoryProvider.overrideWithValue(
          _FauxAbonnementRepository(abonnement),
        ),
      ],
      child: MaterialApp(
        home: LecteurDocumentScreen(ressource: ressource, chapitre: _chapitre),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Variante avec un vrai routeur, pour prouver la NAVIGATION vers « Voir l'offre »
/// (etape 25, lot F) : la route racine `offre` est ici un ecran sentinelle.
Future<void> _monterAvecRouteur(WidgetTester tester, Ressource ressource) async {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            LecteurDocumentScreen(ressource: ressource, chapitre: _chapitre),
      ),
      GoRoute(
        name: 'offre',
        path: '/offre',
        builder: (context, state) =>
            const Scaffold(body: Text('ECRAN_OFFRE_SENTINELLE')),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        etatReseauProvider.overrideWith(
          (ref) => const Stream<EtatReseau>.empty(),
        ),
        catalogueRepositoryProvider.overrideWithValue(
          _FauxCatalogueRepository(const [_classe6e], const [_maths]),
        ),
        telechargementRepositoryProvider.overrideWithValue(
          _FauxTelechargementRepository(),
        ),
        authRepositoryProvider.overrideWithValue(
          _FauxAuthRepository(sessionInitiale: const SessionAuth(utilisateurId: 'u1')),
        ),
        abonnementRepositoryProvider.overrideWithValue(
          _FauxAbonnementRepository(null),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('LibellesLecteur', () {
    test(
      'sousTitre : « Chapitre N · Matiere Classe » quand tout est connu',
      () {
        expect(
          LibellesLecteur.sousTitre(
            numero: 1,
            matiere: 'Mathématiques',
            classe: '6e',
          ),
          'Chapitre 1 · Mathématiques 6e',
        );
      },
    );

    test(
      'sousTitre : « Chapitre N » seul si un libelle manque (jamais « null »)',
      () {
        expect(
          LibellesLecteur.sousTitre(numero: 3, matiere: null, classe: '6e'),
          'Chapitre 3',
        );
        expect(
          LibellesLecteur.sousTitre(
            numero: 3,
            matiere: 'Mathématiques',
            classe: null,
          ),
          'Chapitre 3',
        );
      },
    );

    test(
      'pagination : « Page X sur N », ou « Page X » si le total est inconnu',
      () {
        expect(LibellesLecteur.pagination(page: 3, total: 6), 'Page 3 sur 6');
        expect(LibellesLecteur.pagination(page: 3, total: null), 'Page 3');
      },
    );
  });

  group('NavigationPage', () {
    test(
      'precedente possible seulement au-dela de la page 1 (et doc charge)',
      () {
        expect(NavigationPage.precedentePossible(page: 1, total: 6), isFalse);
        expect(NavigationPage.precedentePossible(page: 2, total: 6), isTrue);
        // total null = document pas encore charge -> jamais active.
        expect(
          NavigationPage.precedentePossible(page: 2, total: null),
          isFalse,
        );
      },
    );

    test(
      'suivante possible seulement avant la derniere page (et doc charge)',
      () {
        expect(NavigationPage.suivantePossible(page: 6, total: 6), isFalse);
        expect(NavigationPage.suivantePossible(page: 5, total: 6), isTrue);
        expect(NavigationPage.suivantePossible(page: 1, total: null), isFalse);
      },
    );
  });

  testWidgets(
    'document sans PDF local -> etat « pas encore sur l\'appareil » + sous-bandeau',
    (tester) async {
      await _monter(
        tester,
        _ressource(type: TypeRessource.exercices, cheminStorage: null),
      );

      // Barre du haut = type du document.
      expect(find.text('Exercices'), findsOneWidget);
      // Sous-bandeau : titre du chapitre + « Chapitre N · Matiere Classe ».
      expect(find.text('Nombres decimaux arithmetiques'), findsOneWidget);
      expect(find.text('Chapitre 1 · Mathématiques 6e'), findsOneWidget);
      // Etat disponibilite (pas d'erreur reseau) : le document n'est pas la.
      expect(find.text('Document pas encore sur l\'appareil'), findsOneWidget);

      // Sans document ouvert, zoom ET partage sont desactives (rien a agrandir
      // ni a partager) — porte par onPressed null, pas par la seule apparence.
      final zoom = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.format_size),
      );
      final partage = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.share_outlined),
      );
      expect(zoom.onPressed, isNull);
      expect(partage.onPressed, isNull);
    },
  );

  testWidgets(
    'un chemin du bucket Storage (non asset) reste « pas encore sur l\'appareil »',
    (tester) async {
      // Un vrai chemin Storage (pas prefixe `assets/`) = document non telecharge :
      // on n'ouvre pas de PdfViewPinch, on montre l'etat dedie (Phase 3 pour le
      // telechargement). Garantit que le lecteur n'essaie pas d'ouvrir n'importe quoi.
      await _monter(
        tester,
        _ressource(
          type: TypeRessource.cours,
          cheminStorage: '6e-maths/chap01/cours.pdf',
        ),
      );

      expect(find.text('Document pas encore sur l\'appareil'), findsOneWidget);
    },
  );

  group('LibellesTelechargement.messageEchec', () {
    test('reseau, stockage plein, introuvable : messages actionnables', () {
      expect(
        LibellesTelechargement.messageEchec(
          cause: CauseTelechargement.reseau,
          premium: false,
        ),
        contains('connexion'),
      );
      expect(
        LibellesTelechargement.messageEchec(
          cause: CauseTelechargement.stockagePlein,
          premium: false,
        ),
        contains('Stockage plein'),
      );
      expect(
        LibellesTelechargement.messageEchec(
          cause: CauseTelechargement.introuvable,
          premium: false,
        ),
        contains('introuvable'),
      );
    });

    test('un refus serveur sur un document premium parle de Premium', () {
      expect(
        LibellesTelechargement.messageEchec(
          cause: CauseTelechargement.nonAutorise,
          premium: true,
        ),
        contains('Premium'),
      );
    });

    test('cause inconnue / nulle : message generique', () {
      expect(
        LibellesTelechargement.messageEchec(cause: null, premium: false),
        'Le telechargement a echoue. Reessaie.',
      );
    });
  });

  testWidgets('eleve connecte : bouton « Telecharger (taille) » propose', (
    tester,
  ) async {
    await _monter(
      tester,
      _ressource(
        type: TypeRessource.cours,
        cheminStorage: '6e/maths/cours.pdf',
      ),
    );

    // 12345 octets -> « 12 Ko » (TailleFichier), annonce dans le bouton.
    expect(find.text('Telecharger (12 Ko)'), findsOneWidget);
  });

  testWidgets('invite : pas de bouton telecharger, mais « Creer un compte »', (
    tester,
  ) async {
    await _monter(
      tester,
      _ressource(
        type: TypeRessource.cours,
        cheminStorage: '6e/maths/cours.pdf',
      ),
      connecte: false,
    );

    expect(find.text('Creer un compte'), findsOneWidget);
    expect(find.textContaining('Telecharger ('), findsNothing);
  });

  testWidgets(
    'connecte sans abonnement, document premium : « Voir l\'offre » (pas de telechargement)',
    (tester) async {
      await _monter(
        tester,
        _ressource(
          type: TypeRessource.corrige,
          cheminStorage: '6e/maths/corrige.pdf',
          premium: true,
        ),
      );

      // Verrou premium (etape 25) : on mene a l'offre, on ne propose ni le
      // telechargement (aucun octet) ni « Creer un compte » (l'eleve est connecte).
      expect(find.text('Voir l\'offre'), findsOneWidget);
      expect(find.textContaining('Telecharger ('), findsNothing);
      expect(find.text('Creer un compte'), findsNothing);
    },
  );

  testWidgets('« Voir l\'offre » mene a l\'ecran de l\'offre (lot F)', (
    tester,
  ) async {
    await _monterAvecRouteur(
      tester,
      _ressource(
        type: TypeRessource.corrige,
        cheminStorage: '6e/maths/corrige.pdf',
        premium: true,
      ),
    );

    expect(find.text('ECRAN_OFFRE_SENTINELLE'), findsNothing);
    await tester.tap(find.text('Voir l\'offre'));
    await tester.pumpAndSettle();
    expect(find.text('ECRAN_OFFRE_SENTINELLE'), findsOneWidget);
  });
}

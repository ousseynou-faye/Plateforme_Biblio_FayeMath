// Tests de l'ecran « Profil » (lot Qualite C, maquette V2.1 ecran 10), monte
// isolement avec de faux repositories. Couvre : le rendu de l'identite adaptee
// (classe/matiere, pas de prenom), les sections et leurs libelles, la
// deconnexion (deplacee ici depuis la liste des chapitres) pour un compte
// connecte ET pour un invite, et le message d'attente des lignes sans ecran.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/domain/repositories/preferences_reglages_repository.dart';
import 'package:fayemath_academy/domain/repositories/profil_repository.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/providers/reglages_provider.dart';
import 'package:fayemath_academy/presentation/screens/profil_screen.dart';

class _FauxAuthRepository implements AuthRepository {
  _FauxAuthRepository({this.session});

  final SessionAuth? session;

  /// Mouchard : passe a vrai des que l'ecran demande la deconnexion serveur.
  bool deconnexionAppelee = false;

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
  Future<void> seDeconnecter() async {
    deconnexionAppelee = true;
  }

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

class _FauxCatalogueRepository implements CatalogueRepository {
  _FauxCatalogueRepository(this.lesClasses, this.lesMatieres);

  final List<Classe> lesClasses;
  final List<Matiere> lesMatieres;

  @override
  Stream<List<Classe>> observerClasses() => Stream.value(lesClasses);
  @override
  Stream<List<Matiere>> observerMatieres() => Stream.value(lesMatieres);
}

class _FauxReglages implements PreferencesReglagesRepository {
  bool wifiSeulement = true;

  @override
  Future<bool> telechargerEnWifiSeulement() async => wifiSeulement;

  @override
  Future<void> definirTelechargerEnWifiSeulement({required bool valeur}) async {
    wifiSeulement = valeur;
  }
}

class _FauxProfilRepository implements ProfilRepository {
  _FauxProfilRepository(this.profil);

  Utilisateur? profil;

  @override
  Future<Utilisateur?> profilCourant(String utilisateurId) async => profil;
  @override
  Stream<Utilisateur?> observerProfilCourant(String utilisateurId) =>
      Stream.value(profil);
  @override
  Future<void> definirClasseEtSerie({
    required String utilisateurId,
    required String classeId,
    required Serie? serie,
  }) async {}
}

// Nom EXACT attendu par ProgrammeScolaire (accentue, comme en base) : sinon la
// matiere n'est pas reconnue au programme et la bibliotheque resterait nulle.
const _maths = Matiere(id: 'm-maths', nom: 'Mathématiques');
const _classe6e = Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1);

Future<_FauxAuthRepository> _monter(
  WidgetTester tester, {
  required bool connecte,
  Abonnement? abonnement,
}) async {
  // Surface haute : l'ecran Profil (ListView) tient en entier, tous ses elements
  // sont construits (« Se deconnecter » est en bas et ne serait sinon pas rendu
  // dans le viewport 600 px par defaut, ListView paresseuse).
  await tester.binding.setSurfaceSize(const Size(600, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final auth = _FauxAuthRepository(
    session: connecte ? const SessionAuth(utilisateurId: 'u1') : null,
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        preferencesReglagesRepositoryProvider.overrideWithValue(_FauxReglages()),
        catalogueRepositoryProvider.overrideWithValue(
          _FauxCatalogueRepository(const [_classe6e], const [_maths]),
        ),
        profilRepositoryProvider.overrideWithValue(
          _FauxProfilRepository(
            connecte
                ? Utilisateur(
                    id: 'u1',
                    classeId: 'c-6e',
                    serie: null,
                    creeLe: DateTime(2026, 9, 3),
                  )
                : null,
          ),
        ),
        abonnementPremiumProvider.overrideWith((ref) => Stream.value(abonnement)),
      ],
      child: MaterialApp(
        theme: ThemeApplication.clair,
        home: const ProfilScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

Abonnement _abonnementActif() => Abonnement(
  id: 'a1',
  utilisateurId: 'u1',
  formule: FormuleAbonnement.anneeScolaire,
  dateDebut: DateTime(2026, 9, 1),
  dateFin: DateTime(2027, 6, 30),
  referencePaiement: null,
);

/// Monte le Profil dans un vrai routeur, pour prouver que « Decouvrir Premium »
/// mene a l'ecran « Voir l'offre » (ecran 17 minimal, etape 25 lot F). La route
/// racine `offre` est ici un ecran sentinelle.
Future<void> _monterAvecRouteur(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(600, 1600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const ProfilScreen()),
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
        authRepositoryProvider.overrideWithValue(
          _FauxAuthRepository(session: const SessionAuth(utilisateurId: 'u1')),
        ),
        preferencesReglagesRepositoryProvider.overrideWithValue(_FauxReglages()),
        catalogueRepositoryProvider.overrideWithValue(
          _FauxCatalogueRepository(const [_classe6e], const [_maths]),
        ),
        profilRepositoryProvider.overrideWithValue(
          _FauxProfilRepository(
            Utilisateur(
              id: 'u1',
              classeId: 'c-6e',
              serie: null,
              creeLe: DateTime(2026, 9, 3),
            ),
          ),
        ),
        abonnementPremiumProvider.overrideWith((ref) => Stream.value(null)),
      ],
      child: MaterialApp.router(
        theme: ThemeApplication.clair,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('connecte : identite adaptee + sections + deconnexion', (
    tester,
  ) async {
    await _monter(tester, connecte: true);

    // Identite REELLE (pas de prenom) : classe puis matiere.
    expect(find.text('6e'), findsOneWidget);
    expect(find.text('Mathématiques'), findsOneWidget);
    expect(find.text('Compte gratuit'), findsOneWidget);

    // Les sections et leurs lignes.
    expect(find.text('Mon compte'), findsOneWidget);
    expect(find.text('Classe, serie et matieres'), findsOneWidget);
    expect(find.text('Aide et contact'), findsOneWidget);
    // Section « Parametres » (lot Qualite D) : la bascule « Wi-Fi uniquement »
    // remplace le placeholder « Parametres et notifications ».
    expect(find.text('Parametres'), findsOneWidget);
    expect(find.text('Telecharger uniquement en Wi-Fi'), findsOneWidget);
    expect(find.text('Aller plus loin'), findsOneWidget);
    expect(find.text('Decouvrir Premium'), findsOneWidget);

    // La deconnexion vit desormais ici.
    expect(find.text('Se deconnecter'), findsOneWidget);
  });

  testWidgets('chip « Premium » quand un abonnement actif (etape 26 lot B)', (
    tester,
  ) async {
    await _monter(tester, connecte: true, abonnement: _abonnementActif());

    expect(find.text('Premium'), findsOneWidget);
    expect(find.text('Compte gratuit'), findsNothing);
  });

  testWidgets('connecte : « Se deconnecter » declenche seDeconnecter', (
    tester,
  ) async {
    final auth = await _monter(tester, connecte: true);

    await tester.tap(find.text('Se deconnecter'));
    await tester.pump();

    expect(auth.deconnexionAppelee, isTrue);
  });

  testWidgets('placeholder : une ligne sans ecran annonce « bientot disponible »', (
    tester,
  ) async {
    await _monter(tester, connecte: true);

    await tester.tap(find.text('Aide et contact'));
    await tester.pump(); // laisse apparaitre le SnackBar

    expect(find.textContaining('bientot disponible'), findsOneWidget);
  });

  testWidgets('invite : « Quitter le mode invite » + « Sans compte », et quitte', (
    tester,
  ) async {
    await _monter(tester, connecte: false);

    // Bascule en mode invite (choix « continuer sans compte »).
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfilScreen)),
    );
    container.read(etatAuthProvider.notifier).continuerSansCompte();
    await tester.pumpAndSettle();

    expect(find.text('Mode invite'), findsOneWidget);
    expect(find.text('Sans compte'), findsOneWidget);
    expect(find.text('Se deconnecter'), findsNothing);

    final quitter = find.text('Quitter le mode invite');
    expect(quitter, findsOneWidget);

    await tester.tap(quitter);
    await tester.pump();

    // L'invite est ressorti du mode invite (retour a « deconnecte »).
    expect(container.read(etatAuthProvider), isA<AuthDeconnecte>());
  });

  testWidgets('« Decouvrir Premium » mene a l\'ecran de l\'offre (lot F)', (
    tester,
  ) async {
    await _monterAvecRouteur(tester);

    expect(find.text('ECRAN_OFFRE_SENTINELLE'), findsNothing);
    await tester.tap(find.text('Decouvrir Premium'));
    await tester.pumpAndSettle();
    expect(find.text('ECRAN_OFFRE_SENTINELLE'), findsOneWidget);
  });
}

// Tests de l'app au demarrage : la redirection go_router selon l'etat d'auth
// (etape 13) ET l'etat du profil (etape 14, lot F). De faux repositories
// controlent « qui est connecte » et « a-t-il deja choisi sa classe » sans
// toucher Supabase ni Drift.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';
import 'package:fayemath_academy/domain/repositories/profil_repository.dart';
import 'package:fayemath_academy/app.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';

/// Faux repository d'auth : « connecte » si [session] est non nul.
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

/// Faux catalogue en memoire.
class _FauxCatalogueRepository implements CatalogueRepository {
  _FauxCatalogueRepository({
    this.lesClasses = const [],
    this.lesMatieres = const [],
  });

  final List<Classe> lesClasses;
  final List<Matiere> lesMatieres;

  @override
  Future<List<Classe>> classes() async => lesClasses;
  @override
  Future<List<Matiere>> matieres() async => lesMatieres;
}

/// Faux profil : renvoie [profil] tel quel ; l'enregistrement le remplace.
class _FauxProfilRepository implements ProfilRepository {
  _FauxProfilRepository({this.profil});

  Utilisateur? profil;

  @override
  Future<Utilisateur?> profilCourant(String utilisateurId) async => profil;

  @override
  Future<void> definirClasseEtSerie({
    required String utilisateurId,
    required String classeId,
    required Serie? serie,
  }) async {
    profil = Utilisateur(
      id: utilisateurId,
      classeId: classeId,
      serie: serie,
      creeLe: DateTime(2026, 8, 13),
    );
  }
}

/// Faux repository de chapitres : aucune bibliotheque -> l'accueil affiche son
/// etat vide, le cas normal de l'etape 15 (le contenu reel arrive a l'etape 18).
class _FauxChapitreRepository implements ChapitreRepository {
  @override
  Future<List<Chapitre>> chapitresDe({
    required String classeId,
    required String matiereId,
  }) async => const [];
}

const _maths = Matiere(id: 'm-maths', nom: 'Mathématiques');
final _catalogue = _FauxCatalogueRepository(
  lesClasses: const [
    Classe(id: 'c-6e', nom: '6e', cycle: Cycle.college, ordre: 1),
  ],
  lesMatieres: const [_maths],
);

Future<void> monterApp(
  WidgetTester tester, {
  required AuthRepository auth,
  CatalogueRepository? catalogue,
  ProfilRepository? profil,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        catalogueRepositoryProvider.overrideWithValue(
          catalogue ?? _FauxCatalogueRepository(),
        ),
        chapitreRepositoryProvider.overrideWithValue(_FauxChapitreRepository()),
        profilRepositoryProvider.overrideWithValue(
          profil ?? _FauxProfilRepository(),
        ),
      ],
      child: const FayeMathApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('visiteur non connecte : redirige vers l\'ecran d\'auth', (
    tester,
  ) async {
    await monterApp(tester, auth: _FauxAuthRepository());

    expect(
      find.widgetWithText(FilledButton, 'Creer mon compte'),
      findsOneWidget,
    );
  });

  testWidgets('connecte SANS classe : arrive sur l\'ecran de choix', (
    tester,
  ) async {
    await monterApp(
      tester,
      auth: _FauxAuthRepository(
        session: const SessionAuth(utilisateurId: 'u1'),
      ),
      catalogue: _catalogue,
      profil: _FauxProfilRepository(
        profil: Utilisateur(
          id: 'u1',
          classeId: null,
          serie: null,
          creeLe: DateTime(2026, 8, 13),
        ),
      ),
    );

    expect(find.text('Ta classe'), findsOneWidget);
  });

  testWidgets('connecte AVEC classe : arrive directement sur l\'accueil', (
    tester,
  ) async {
    await monterApp(
      tester,
      auth: _FauxAuthRepository(
        session: const SessionAuth(utilisateurId: 'u1'),
      ),
      catalogue: _catalogue,
      profil: _FauxProfilRepository(
        profil: Utilisateur(
          id: 'u1',
          classeId: 'c-6e',
          serie: null,
          creeLe: DateTime(2026, 8, 13),
        ),
      ),
    );

    expect(find.text('Bientot disponible'), findsOneWidget);
  });

  testWidgets('« Continuer sans compte » mene a l\'ecran de choix', (
    tester,
  ) async {
    await monterApp(tester, auth: _FauxAuthRepository(), catalogue: _catalogue);

    final boutonInvite = find.widgetWithText(
      OutlinedButton,
      'Continuer sans compte',
    );
    await tester.ensureVisible(boutonInvite);
    await tester.tap(boutonInvite);
    await tester.pumpAndSettle();

    expect(find.text('Ta classe'), findsOneWidget);
  });

  testWidgets('invite : choisit sa classe, valide, et arrive sur l\'accueil', (
    tester,
  ) async {
    await monterApp(tester, auth: _FauxAuthRepository(), catalogue: _catalogue);

    // Passe en mode invite -> ecran de choix.
    final boutonInvite = find.widgetWithText(
      OutlinedButton,
      'Continuer sans compte',
    );
    await tester.ensureVisible(boutonInvite);
    await tester.tap(boutonInvite);
    await tester.pumpAndSettle();
    expect(find.text('Ta classe'), findsOneWidget);

    // Choisit la 6e (la matiere Mathematiques est auto-selectionnee).
    await tester.tap(find.text('6e'));
    await tester.pumpAndSettle();

    // Valide -> confirmation locale -> redirection vers l'accueil.
    final boutonValider = find.widgetWithText(FilledButton, 'Valider');
    await tester.ensureVisible(boutonValider);
    await tester.tap(boutonValider);
    await tester.pumpAndSettle();

    expect(find.text('Bientot disponible'), findsOneWidget);
  });
}

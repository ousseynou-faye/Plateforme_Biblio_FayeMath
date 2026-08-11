// Tests de l'app au demarrage : la redirection go_router selon l'etat d'auth
// (etape 13, lot F). Un faux repository controle « qui est connecte » sans
// toucher Supabase.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/app.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Faux repository : « connecte » si [session] est non nul, sinon deconnecte.
/// Flux vide (aucun evenement apres l'etat initial), suffisant pour la
/// redirection au demarrage.
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

Future<void> monterApp(WidgetTester tester, AuthRepository repository) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const FayeMathApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('visiteur non connecte : redirige vers l\'ecran d\'auth', (
    tester,
  ) async {
    await monterApp(tester, _FauxAuthRepository());

    expect(
      find.widgetWithText(FilledButton, 'Creer mon compte'),
      findsOneWidget,
    );
  });

  testWidgets('session existante : ouvre directement sur l\'accueil', (
    tester,
  ) async {
    await monterApp(
      tester,
      _FauxAuthRepository(session: const SessionAuth(utilisateurId: 'u1')),
    );

    expect(find.text('Charte & composants'), findsOneWidget);
  });

  testWidgets('« Continuer sans compte » mene a l\'accueil', (tester) async {
    await monterApp(tester, _FauxAuthRepository());
    // On part de l'ecran d'authentification.
    expect(
      find.widgetWithText(FilledButton, 'Creer mon compte'),
      findsOneWidget,
    );

    final boutonInvite = find.widgetWithText(
      OutlinedButton,
      'Continuer sans compte',
    );
    await tester.ensureVisible(boutonInvite);
    await tester.tap(boutonInvite);
    await tester.pumpAndSettle();

    expect(find.text('Charte & composants'), findsOneWidget);
  });
}

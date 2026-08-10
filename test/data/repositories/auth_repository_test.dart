import 'dart:io' show SocketException;

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/data/repositories/auth_repository.dart';

/// Faux `GoTrueClient` : on ne cable aucune signature (elles sont nombreuses),
/// on intercepte tout via `noSuchMethod`. Suffisant pour prouver que le
/// repository DELEGUE l'appel et TRADUIT l'erreur — sans client Supabase reel.
class _FauxGoTrue implements GoTrueClient {
  _FauxGoTrue({this.erreurAJeter});

  /// Si non nul, chaque appel intercepte echoue avec cette erreur.
  final Object? erreurAJeter;

  /// Les methodes reellement appelees par le repository (pour verifier la
  /// delegation).
  final List<Symbol> appels = [];

  @override
  dynamic noSuchMethod(Invocation invocation) {
    appels.add(invocation.memberName);
    if (erreurAJeter != null) {
      return Future<AuthResponse>.error(erreurAJeter!);
    }
    return Future<AuthResponse>.value(AuthResponse());
  }
}

void main() {
  group('traduireEchecAuth (point de traduction)', () {
    test('code invalid_credentials -> IdentifiantsInvalides', () {
      final echec = traduireEchecAuth(
        const AuthApiException(
          'Invalid login credentials',
          statusCode: '400',
          code: 'invalid_credentials',
        ),
      );
      expect(echec, isA<IdentifiantsInvalides>());
    });

    test('code email_not_confirmed -> EmailNonConfirme', () {
      final echec = traduireEchecAuth(
        const AuthApiException(
          'Email not confirmed',
          code: 'email_not_confirmed',
        ),
      );
      expect(echec, isA<EmailNonConfirme>());
    });

    test('code user_already_exists -> CompteExistant', () {
      final echec = traduireEchecAuth(
        const AuthApiException(
          'User already registered',
          code: 'user_already_exists',
        ),
      );
      expect(echec, isA<CompteExistant>());
    });

    test('AuthRetryableFetchException -> PanneReseau', () {
      final echec = traduireEchecAuth(AuthRetryableFetchException());
      expect(echec, isA<PanneReseau>());
    });

    test('SocketException -> PanneReseau', () {
      final echec = traduireEchecAuth(const SocketException('offline'));
      expect(echec, isA<PanneReseau>());
    });

    test('repli sur le message anglais quand le code est absent', () {
      expect(
        traduireEchecAuth(const AuthApiException('Invalid login credentials')),
        isA<IdentifiantsInvalides>(),
      );
      expect(
        traduireEchecAuth(const AuthApiException('User already registered')),
        isA<CompteExistant>(),
      );
    });

    test('code inconnu -> Inattendu, diagnostic non sensible', () {
      final echec = traduireEchecAuth(
        const AuthApiException('boom', statusCode: '500', code: 'server_error'),
      );
      expect(echec, isA<EchecAuthentificationInattendu>());
      // Le diagnostic ne porte que code + statut, jamais d'e-mail / mot de passe.
      expect(echec.toString(), contains('server_error'));
      expect(echec.toString(), contains('500'));
    });

    test('une erreur non-Auth quelconque -> Inattendu', () {
      final echec = traduireEchecAuth(FormatException('x'));
      expect(echec, isA<EchecAuthentificationInattendu>());
    });

    test('un echec deja traduit n\'est pas re-emballe', () {
      const dejaTraduit = PanneReseau();
      expect(traduireEchecAuth(dejaTraduit), same(dejaTraduit));
    });
  });

  group('AuthRepositorySupabase (avec faux client)', () {
    test(
      'sInscrire delegue a signUp et n\'echoue pas quand tout va bien',
      () async {
        final faux = _FauxGoTrue();
        final repo = AuthRepositorySupabase(faux);

        await repo.sInscrire(
          email: 'awa@example.com',
          motDePasse: 'motdepasse1',
        );

        expect(faux.appels, contains(#signUp));
      },
    );

    test(
      'seConnecter traduit l\'AuthException Supabase en echec metier',
      () async {
        final faux = _FauxGoTrue(
          erreurAJeter: const AuthApiException(
            'Invalid login credentials',
            statusCode: '400',
            code: 'invalid_credentials',
          ),
        );
        final repo = AuthRepositorySupabase(faux);

        await expectLater(
          repo.seConnecter(email: 'awa@example.com', motDePasse: 'faux'),
          throwsA(isA<IdentifiantsInvalides>()),
        );
      },
    );

    test('seDeconnecter delegue a signOut', () async {
      final faux = _FauxGoTrue();
      final repo = AuthRepositorySupabase(faux);

      await repo.seDeconnecter();

      expect(faux.appels, contains(#signOut));
    });
  });
}

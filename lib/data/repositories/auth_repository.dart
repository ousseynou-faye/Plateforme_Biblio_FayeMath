import 'dart:io' show SocketException;

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';

/// Implementation du contrat [AuthRepository] adossee a Supabase Auth
/// (`GoTrueClient`). C'est le SEUL endroit de l'app qui connait les types
/// Supabase liees a l'authentification : toute exception technique y est
/// traduite en `EchecAuthentification` avant de remonter (docs/CONVENTIONS.md
/// §5). La couche `presentation/` ne voit jamais une `AuthException` brute.
class AuthRepositorySupabase implements AuthRepository {
  AuthRepositorySupabase(this._auth);

  final GoTrueClient _auth;

  @override
  SessionAuth? get sessionCourante => _versSessionAuth(_auth.currentSession);

  @override
  Stream<SessionAuth?> get changementsSession =>
      _auth.onAuthStateChange.map((etat) => _versSessionAuth(etat.session));

  @override
  Future<void> sInscrire({
    required String email,
    required String motDePasse,
  }) async {
    // La confirmation e-mail etant activee, signUp N'OUVRE PAS de session : on
    // ignore volontairement la reponse. L'appelant affiche « verifie ta boite
    // mail » ; la session arrivera par le flux, apres confirmation.
    await _proteger(() => _auth.signUp(email: email, password: motDePasse));
  }

  @override
  Future<void> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    await _proteger(
      () => _auth.signInWithPassword(email: email, password: motDePasse),
    );
  }

  @override
  Future<void> seDeconnecter() async {
    await _proteger(() => _auth.signOut());
  }

  /// Enveloppe un appel Supabase : toute erreur technique est traduite en
  /// echec metier. Aucun `catch` silencieux — on relaie toujours un echec typé.
  Future<T> _proteger<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (erreur) {
      throw traduireEchecAuth(erreur);
    }
  }

  SessionAuth? _versSessionAuth(Session? session) =>
      session == null ? null : SessionAuth(utilisateurId: session.user.id);
}

/// Traduit une erreur remontee par Supabase Auth en `EchecAuthentification`.
///
/// Point de traduction UNIQUE (docs/CONVENTIONS.md §5), volontairement expose
/// au niveau du fichier pour etre teste directement sans client Supabase reel :
/// c'est ici que se logent les bugs de « mauvais message affiche a l'eleve ».
/// Le mapping s'appuie sur le `code` serveur (chaine stable, independante de la
/// version) plutot que sur le message localisable ; un repli sur le message
/// anglais couvre les erreurs anterieures a la reponse HTTP (code absent).
EchecAuthentification traduireEchecAuth(Object erreur) {
  // Deja traduit (ne pas re-emballer).
  if (erreur is EchecAuthentification) return erreur;

  // Reseau : gotrue emballe les echecs de fetch ; une coupure dure peut aussi
  // remonter en SocketException avant l'emballage. S'inscrire / se connecter
  // exigent une connexion (contrairement au reste, offline-first).
  if (erreur is AuthRetryableFetchException) return const PanneReseau();
  if (erreur is SocketException) return const PanneReseau();

  if (erreur is AuthException) {
    switch (erreur.code) {
      case 'email_not_confirmed':
        return const EmailNonConfirme();
      case 'user_already_exists':
      case 'email_exists':
      case 'identity_already_exists':
        return const CompteExistant();
      case 'invalid_credentials':
      case 'invalid_grant':
        return const IdentifiantsInvalides();
    }
    // Repli sur le message (messages serveur Supabase en anglais, non localises)
    // quand le code est absent.
    final message = erreur.message.toLowerCase();
    if (message.contains('not confirmed')) return const EmailNonConfirme();
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return const CompteExistant();
    }
    if (message.contains('invalid login credentials')) {
      return const IdentifiantsInvalides();
    }
    // Diagnostic NON sensible : code + statut, jamais e-mail / mot de passe.
    return EchecAuthentificationInattendu(
      'auth code=${erreur.code} statut=${erreur.statusCode}',
    );
  }

  return EchecAuthentificationInattendu(erreur.runtimeType.toString());
}

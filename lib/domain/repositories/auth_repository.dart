import 'package:fayemath_academy/domain/entities/session_auth.dart';

/// Le contrat d'authentification : ce que l'application sait demander a propos
/// des comptes eleve. Le domaine DECLARE le besoin ; l'implementation (`data/`)
/// parle reellement a Supabase Auth et se plie a ce contrat — c'est l'inversion
/// de dependance de docs/ARCHITECTURE.md §3 (le metier ne devient pas prisonnier
/// de Supabase).
///
/// Toutes les methodes qui echouent levent un `EchecAuthentification`
/// (`core/errors/echecs_authentification.dart`), jamais une exception Supabase
/// brute : la couche `presentation/` ne connait que des echecs metier
/// (docs/CONVENTIONS.md §5).
abstract interface class AuthRepository {
  /// La session courante, ou `null` si personne n'est connecte. Lecture
  /// SYNCHRONE, volontairement : la redirection go_router doit trancher sans
  /// attendre le reseau (contrat offline-first).
  SessionAuth? get sessionCourante;

  /// Le flux des changements de session : une valeur emise a chaque connexion,
  /// deconnexion ou rafraichissement de jeton (`null` = deconnecte). Il alimente
  /// l'etat Riverpod et le `refreshListenable` du routeur (lot F).
  Stream<SessionAuth?> get changementsSession;

  /// Cree un compte a partir d'un e-mail et d'un mot de passe.
  ///
  /// La confirmation e-mail etant activee cote Supabase, l'inscription N'OUVRE
  /// PAS de session : l'appelant affiche « verifie ta boite mail ». Echecs
  /// possibles : `CompteExistant`, `PanneReseau`, `EchecAuthentificationInattendu`.
  Future<void> sInscrire({required String email, required String motDePasse});

  /// Ouvre une session pour un compte existant et confirme.
  ///
  /// Echecs possibles : `IdentifiantsInvalides` (e-mail ou mot de passe faux),
  /// `EmailNonConfirme` (compte pas encore confirme), `PanneReseau`,
  /// `EchecAuthentificationInattendu`.
  Future<void> seConnecter({required String email, required String motDePasse});

  /// Ferme la session : invalidee cote serveur ET effacee localement
  /// (SECURITY.md §2 — « invalider proprement le jeton, pas seulement
  /// l'effacer »).
  Future<void> seDeconnecter();
}

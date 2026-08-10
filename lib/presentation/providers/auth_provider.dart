import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';

/// Fournit l'implementation du contrat d'authentification.
///
/// Volontairement NON resolue ici : `presentation/` n'a pas le droit d'importer
/// `data/` (docs/ARCHITECTURE.md §3, interdit #2). L'implementation Supabase est
/// injectee a la racine de composition (`app.dart`/`main.dart`, hors du dossier
/// `presentation/`) via `overrideWith` — c'est le lot F. En test, on l'override
/// par un faux repository.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError(
    'authRepositoryProvider doit etre override a la racine (lot F).',
  ),
);

/// L'etat d'authentification de l'application, tel que la navigation le voit.
///
/// Trois cas, et trois seulement :
///  - [AuthConnecte]  : une session existe (e-mail confirme) ;
///  - [AuthInvite]    : « continuer sans compte » — choix 100% local, aucun
///                      appel Supabase (Decision A du 02/08) ;
///  - [AuthDeconnecte]: ni session ni choix invite -> ecran d'authentification.
///
/// Type scelle : le `switch` de redirection (lot F) est exhaustif.
sealed class EtatAuth {
  const EtatAuth();
}

class AuthConnecte extends EtatAuth {
  const AuthConnecte(this.session);

  final SessionAuth session;
}

class AuthInvite extends EtatAuth {
  const AuthInvite();
}

class AuthDeconnecte extends EtatAuth {
  const AuthDeconnecte();
}

/// Notifier qui derive [EtatAuth] du flux de session du repository, et porte le
/// choix local « continuer sans compte ».
class EtatAuthNotifier extends Notifier<EtatAuth> {
  @override
  EtatAuth build() {
    final repository = ref.watch(authRepositoryProvider);

    // Reagit aux connexions / deconnexions. Une emission `null` (pas de session)
    // ne DOIT PAS ejecter un invite vers l'ecran d'authentification : on ne
    // repasse a [AuthDeconnecte] que si l'on n'etait pas explicitement invite.
    final abonnement = repository.changementsSession.listen((session) {
      if (session != null) {
        state = AuthConnecte(session);
      } else if (state is! AuthInvite) {
        state = const AuthDeconnecte();
      }
    });
    ref.onDispose(abonnement.cancel);

    // Etat initial synchrone, avant la premiere emission du flux : la
    // redirection go_router doit pouvoir trancher sans attendre le reseau.
    final session = repository.sessionCourante;
    return session == null ? const AuthDeconnecte() : AuthConnecte(session);
  }

  /// « Continuer sans compte » : passe en mode invite (sauf si deja connecte).
  /// Aucun appel Supabase — pur etat de navigation local.
  void continuerSansCompte() {
    if (state is! AuthConnecte) state = const AuthInvite();
  }

  /// Quitte le mode invite pour revenir a l'ecran d'authentification (l'invite
  /// qui decide finalement de creer un compte).
  void quitterModeInvite() {
    if (state is AuthInvite) state = const AuthDeconnecte();
  }
}

final etatAuthProvider = NotifierProvider<EtatAuthNotifier, EtatAuth>(
  EtatAuthNotifier.new,
);

import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/screens/authentification_screen.dart';
import 'package:fayemath_academy/presentation/screens/galerie_composants_screen.dart';

/// Chemins internes de navigation.
const cheminAccueil = '/';
const cheminConnexion = '/connexion';

/// Le routeur de l'application, expose en provider pour rediriger selon l'etat
/// d'authentification ([etatAuthProvider]).
///
/// A l'etape 13, deux routes : l'ecran d'authentification et l'accueil
/// provisoire (galerie de composants, jusqu'a l'etape 14). Redirections :
///   - deconnecte           -> toujours l'ecran d'authentification ;
///   - connecte OU invite   -> l'accueil, et jamais de retour force sur l'auth.
///
/// Le routeur est construit UNE fois (provider mis en cache) ; c'est le
/// `refreshListenable` qui le fait re-evaluer, sans le recreer — la pile de
/// navigation n'est donc jamais perdue a chaque changement d'auth.
final routerProvider = Provider<GoRouter>((ref) {
  final rafraichisseur = _RafraichisseurAuth(ref);
  ref.onDispose(rafraichisseur.dispose);

  return GoRouter(
    initialLocation: cheminAccueil,
    refreshListenable: rafraichisseur,
    redirect: (context, state) {
      final etat = ref.read(etatAuthProvider);
      final surConnexion = state.matchedLocation == cheminConnexion;
      final connecteOuInvite = etat is AuthConnecte || etat is AuthInvite;

      if (!connecteOuInvite) {
        // Deconnecte : on force l'ecran d'authentification, sans boucler.
        return surConnexion ? null : cheminConnexion;
      }
      // Connecte ou invite : pas de retour sur l'ecran d'authentification.
      return surConnexion ? cheminAccueil : null;
    },
    routes: [
      GoRoute(
        path: cheminConnexion,
        builder: (context, state) => const AuthentificationScreen(),
      ),
      GoRoute(
        path: cheminAccueil,
        builder: (context, state) => const GalerieComposantsScreen(),
      ),
    ],
  );
});

/// Pont entre [etatAuthProvider] (Riverpod) et le `refreshListenable` de
/// go_router : chaque changement d'etat d'auth declenche `notifyListeners`,
/// donc une re-evaluation des redirections.
class _RafraichisseurAuth extends ChangeNotifier {
  _RafraichisseurAuth(Ref ref) {
    _abonnement = ref.listen<EtatAuth>(
      etatAuthProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<EtatAuth> _abonnement;

  @override
  void dispose() {
    _abonnement.close();
    super.dispose();
  }
}

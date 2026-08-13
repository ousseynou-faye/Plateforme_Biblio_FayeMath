import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/screens/authentification_screen.dart';
import 'package:fayemath_academy/presentation/screens/choix_classe_screen.dart';
import 'package:fayemath_academy/presentation/screens/demarrage_screen.dart';
import 'package:fayemath_academy/presentation/screens/galerie_composants_screen.dart';

/// Chemins internes de navigation.
const cheminDemarrage = '/demarrage';
const cheminConnexion = '/connexion';
const cheminChoixClasse = '/choix-classe';
const cheminAccueil = '/';

/// Le routeur de l'application, expose en provider pour rediriger selon l'etat
/// d'authentification ([etatAuthProvider]) ET, pour un connecte, l'etat de son
/// profil ([profilProvider]) — a-t-il deja choisi sa classe ? (etape 14).
///
/// Regle de destination (voir [_cibleNavigation]) :
///   - deconnecte                         -> ecran d'authentification ;
///   - connecte, profil en chargement     -> ecran de demarrage neutre ;
///   - connecte SANS classe               -> ecran de choix classe/serie/matiere ;
///   - connecte AVEC classe               -> accueil ;
///   - invite non valide                  -> ecran de choix (choix local) ;
///   - invite ayant valide                -> accueil.
///
/// Le routeur est construit UNE fois (provider mis en cache) ; c'est le
/// `refreshListenable` qui le fait re-evaluer sans le recreer — la pile de
/// navigation n'est donc jamais perdue a chaque changement d'etat.
final routerProvider = Provider<GoRouter>((ref) {
  final rafraichisseur = _RafraichisseurNavigation(ref);
  ref.onDispose(rafraichisseur.dispose);

  return GoRouter(
    initialLocation: cheminDemarrage,
    refreshListenable: rafraichisseur,
    redirect: (context, state) {
      final cible = _cibleNavigation(ref);
      // Deja au bon endroit -> ne rien faire (evite toute boucle).
      return state.matchedLocation == cible ? null : cible;
    },
    routes: [
      GoRoute(
        path: cheminDemarrage,
        builder: (context, state) => const DemarrageScreen(),
      ),
      GoRoute(
        path: cheminConnexion,
        builder: (context, state) => const AuthentificationScreen(),
      ),
      GoRoute(
        path: cheminChoixClasse,
        builder: (context, state) => const ChoixClasseScreen(),
      ),
      GoRoute(
        path: cheminAccueil,
        builder: (context, state) => const GalerieComposantsScreen(),
      ),
    ],
  );
});

/// Ou l'utilisateur doit-il se trouver, selon son etat d'auth et — s'il est
/// connecte — l'etat de son profil. Les deux `switch` sont exhaustifs (types
/// scelles [EtatAuth] et [EtatProfil]) : un cas oublie serait une erreur de
/// compilation, pas un bug de navigation silencieux.
String _cibleNavigation(Ref ref) {
  final etatAuth = ref.read(etatAuthProvider);
  return switch (etatAuth) {
    AuthDeconnecte() => cheminConnexion,
    AuthInvite() =>
      ref.read(choixClasseProvider).valide ? cheminAccueil : cheminChoixClasse,
    AuthConnecte() => switch (ref.read(profilProvider)) {
      ProfilResolu(:final classeChoisie) =>
        classeChoisie ? cheminAccueil : cheminChoixClasse,
      // Profil pas encore lu, ou etat transitoire juste apres un changement
      // d'auth : ecran de demarrage neutre, le temps de trancher.
      ProfilEnChargement() || ProfilHorsSujet() => cheminDemarrage,
    },
  };
}

/// Pont entre les providers d'etat (Riverpod) et le `refreshListenable` de
/// go_router : chaque changement d'auth, de profil ou de choix de classe
/// declenche `notifyListeners`, donc une re-evaluation des redirections.
class _RafraichisseurNavigation extends ChangeNotifier {
  _RafraichisseurNavigation(Ref ref) {
    _auth = ref.listen<EtatAuth>(etatAuthProvider, (_, _) => notifyListeners());
    _profil = ref.listen<EtatProfil>(
      profilProvider,
      (_, _) => notifyListeners(),
    );
    _choix = ref.listen<ChoixClasse>(
      choixClasseProvider,
      (_, _) => notifyListeners(),
    );
  }

  late final ProviderSubscription<EtatAuth> _auth;
  late final ProviderSubscription<EtatProfil> _profil;
  late final ProviderSubscription<ChoixClasse> _choix;

  @override
  void dispose() {
    _auth.close();
    _profil.close();
    _choix.close();
    super.dispose();
  }
}

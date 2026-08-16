import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/screens/authentification_screen.dart';
import 'package:fayemath_academy/presentation/screens/choix_classe_screen.dart';
import 'package:fayemath_academy/presentation/screens/demarrage_screen.dart';
import 'package:fayemath_academy/presentation/screens/detail_chapitre_screen.dart';
import 'package:fayemath_academy/presentation/screens/lecteur_document_screen.dart';
import 'package:fayemath_academy/presentation/screens/liste_chapitres_screen.dart';

/// Chemins internes de navigation.
const cheminDemarrage = '/demarrage';
const cheminConnexion = '/connexion';
const cheminChoixClasse = '/choix-classe';
const cheminAccueil = '/';
const cheminChapitre = '/chapitre';

/// Nom de la route de detail d'un chapitre. La liste ouvre cet ecran par
/// `context.pushNamed('chapitre', ...)`. `presentation/` ne peut pas importer
/// `routing/` (regle de dependance, docs/ARCHITECTURE.md §3) : le nom est donc
/// partage par sa VALEUR (le litteral cote liste), jamais par import.
const nomRouteChapitre = 'chapitre';

/// Nom de la route du lecteur de document (ecran 7). Le detail ouvre cet ecran
/// par `context.pushNamed('document', ...)`. Meme regle que [nomRouteChapitre] :
/// le nom est partage par sa VALEUR cote detail (le litteral), jamais par import
/// de `routing/` (regle de dependance, docs/ARCHITECTURE.md §3).
const nomRouteDocument = 'document';

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
      final ou = state.matchedLocation;
      // Deja au bon endroit -> ne rien faire (evite toute boucle).
      if (ou == cible) return null;
      // La zone « contenu » (accueil + detail d'un chapitre) forme un tout :
      // quand l'eleve a droit au contenu (cible = accueil), on ne le rejette pas
      // d'un sous-ecran de cette zone vers l'accueil — sinon tout `push` vers un
      // detail rebondirait aussitot.
      if (cible == cheminAccueil && _estZoneContenu(ou)) return null;
      return cible;
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
        builder: (context, state) => const ListeChapitresScreen(),
      ),
      GoRoute(
        name: nomRouteChapitre,
        path: '$cheminChapitre/:chapitreId',
        builder: (context, state) {
          // Le detail a besoin de l'objet Chapitre (numero, titre) : il arrive en
          // `extra`, deja charge par la liste — pas de relecture par id. `extra`
          // ne survit pas a un lien profond / redemarrage a froid ; en V1 il n'y
          // a pas de lien profond (l'app demarre sur /demarrage), donc le seul cas
          // d'`extra` absent est pathologique -> repli neutre vers l'accueil.
          final chapitre = state.extra;
          if (chapitre is! Chapitre) return const _RepliAccueil();
          return DetailChapitreScreen(chapitre: chapitre);
        },
      ),
      GoRoute(
        name: nomRouteDocument,
        path: '$cheminChapitre/:chapitreId/document/:ressourceId',
        builder: (context, state) {
          // Le lecteur (ecran 7) a besoin de la Ressource ET du Chapitre (pour le
          // sous-bandeau), deja charges par l'ecran de detail : ils arrivent
          // ENSEMBLE en `extra` (un record). Pas de relecture par id — aucun
          // repository « par id » n'existe, meme principe qu'a l'etape 16.
          // `extra` ne survit pas a un lien profond / redemarrage a froid ; en V1
          // il n'y a pas de lien profond (l'app demarre sur /demarrage), donc le
          // seul cas d'`extra` absent est pathologique -> repli vers l'accueil.
          final args = state.extra;
          if (args is ({Ressource ressource, Chapitre chapitre})) {
            return LecteurDocumentScreen(
              ressource: args.ressource,
              chapitre: args.chapitre,
            );
          }
          return const _RepliAccueil();
        },
      ),
    ],
  );
});

/// Les emplacements de la « zone contenu » : l'accueil et le detail d'un
/// chapitre. Sert au `redirect` a ne pas rejeter un sous-ecran du contenu.
bool _estZoneContenu(String emplacement) =>
    emplacement == cheminAccueil || emplacement.startsWith('$cheminChapitre/');

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

/// Repli neutre : on ne peut pas afficher un detail sans son chapitre (`extra`
/// absent). On revient a l'accueil au frame suivant. Cas limite uniquement : il
/// n'y a pas de lien profond vers cet ecran en V1 (voir le builder de la route).
class _RepliAccueil extends StatelessWidget {
  const _RepliAccueil();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(cheminAccueil);
    });
    return const SizedBox.shrink();
  }
}

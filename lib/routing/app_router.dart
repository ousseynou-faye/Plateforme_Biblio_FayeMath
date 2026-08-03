import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/screens/galerie_composants_screen.dart';

/// Configuration de navigation de l'application (go_router).
///
/// Chaque [GoRoute] associe un chemin (l'"URL" interne) a l'ecran a afficher.
/// A l'etape 11, l'unique route est la galerie de composants, qui sert d'accueil
/// provisoire jusqu'a l'etape 14 (premier vrai ecran, choix classe / serie /
/// matiere). Ce routeur pourra devenir un provider Riverpod le jour ou il faudra
/// des redirections selon l'authentification.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const GalerieComposantsScreen(),
    ),
  ],
);

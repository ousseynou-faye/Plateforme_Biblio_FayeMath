import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/screens/compteur_demo_screen.dart';
import 'package:fayemath_academy/presentation/screens/seconde_page_demo_screen.dart';

/// Configuration de navigation de l'application (go_router).
///
/// Chaque [GoRoute] associe un chemin (l'"URL" interne) a l'ecran a afficher.
/// Pour l'instant, deux routes de demonstration ; elles seront remplacees par
/// les vrais ecrans a partir de l'etape 11. Ce routeur pourra devenir un
/// provider Riverpod le jour ou il faudra des redirections selon
/// l'authentification.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          const CompteurDemoScreen(title: 'FAYEMATH ACADEMY'),
    ),
    GoRoute(
      path: '/seconde',
      builder: (context, state) => const SecondePageDemoScreen(),
    ),
  ],
);

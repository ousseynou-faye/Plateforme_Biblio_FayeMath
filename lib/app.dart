import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/routing/app_router.dart';

class FayeMathApp extends StatelessWidget {
  const FayeMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ProviderScope est le "coffre" qui detient l'etat de tous les providers
    // Riverpod. Il doit envelopper tout widget susceptible de lire un provider ;
    // on le place donc a la racine, au-dessus du MaterialApp (CLAUDE.md §8).
    // La charte graphique reelle (indigo/ocre) sera appliquee a l'etape 11.
    return ProviderScope(
      child: MaterialApp.router(
        title: 'FayeMath Academy',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        // routerConfig branche go_router : c'est lui qui decide quel ecran
        // afficher selon la route courante, a la place d'un `home:` fige.
        routerConfig: appRouter,
      ),
    );
  }
}

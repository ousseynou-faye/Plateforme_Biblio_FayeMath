import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/theme/theme.dart';
import 'package:fayemath_academy/routing/app_router.dart';

/// Widget racine de l'application. `ConsumerWidget` car il lit le routeur, qui
/// est desormais un provider (redirections selon l'authentification, etape 13).
///
/// Le `ProviderScope` et l'injection du repository Supabase vivent dans
/// `main.dart` (la racine de composition), pas ici — ainsi `app.dart` reste
/// present­ationnel et n'importe jamais `data/` (docs/ARCHITECTURE.md §3).
class FayeMathApp extends ConsumerWidget {
  const FayeMathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'FayeMath Academy',
      // Charte graphique centralisee dans core/theme/ (etape 11).
      theme: ThemeApplication.clair,
      // go_router decide quel ecran afficher selon la route et l'etat d'auth.
      routerConfig: router,
    );
  }
}

/// Ecran de repli affiche quand les secrets Supabase ne sont pas injectes (app
/// lancee sans --dart-define-from-file=config/dev.json). Volontairement autonome
/// (pas de ProviderScope, pas de router, pas de theme) : il ne depend d'aucune
/// des briques qui, justement, ont besoin de la config.
class AppNonConfiguree extends StatelessWidget {
  const AppNonConfiguree({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FayeMath Academy',
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Configuration manquante.\n\nRelance l\'application avec :\n'
              'flutter run --dart-define-from-file=config/dev.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

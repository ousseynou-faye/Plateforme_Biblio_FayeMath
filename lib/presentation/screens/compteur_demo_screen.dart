import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/providers/compteur_demo_provider.dart';

/// Ecran de demonstration (temporaire, remplace a l'etape 11).
///
/// Il herite de [ConsumerWidget] au lieu de [StatelessWidget] : c'est ce qui lui
/// donne acces a `ref`, la poignee pour lire les providers Riverpod. L'ecran n'a
/// plus d'etat local (`setState`) — l'etat du compteur vit dans le Notifier.
class CompteurDemoScreen extends ConsumerWidget {
  const CompteurDemoScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch abonne ce build au provider : des que le compteur change, seul
    // ce widget est reconstruit. C'est l'equivalent Riverpod du setState, mais
    // l'etat vit desormais hors de l'ecran, donc il est partageable.
    final compteur = ref.watch(compteurDemoProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vous avez appuyé sur le bouton ce nombre de fois :'),
            Text(
              '$compteur',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              // context.push empile la seconde route : la fleche retour de son
              // AppBar (et son bouton "Retour") ramenent ici.
              onPressed: () => context.push('/seconde'),
              child: const Text('Ouvrir la seconde page'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ref.read : lecture ponctuelle dans un callback, sans abonnement. On
        // appelle la methode du Notifier, qui met a jour l'etat partage.
        onPressed: () => ref.read(compteurDemoProvider.notifier).incrementer(),
        tooltip: 'Incrémenter',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

/// Seconde page de demonstration (temporaire, retiree a l'etape 11).
///
/// Elle ne sert qu'a prouver la navigation go_router : on y arrive depuis
/// l'ecran compteur (`context.push`), et le bouton "Retour" y ramene.
class SecondePageDemoScreen extends StatelessWidget {
  const SecondePageDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('La Nouvelle Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Vous etes sur une seconde route go_router.'),
            ElevatedButton(
              // context.pop() depile la route courante et revient a la precedente.
              onPressed: () => context.pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

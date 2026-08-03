import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier de demonstration (Lot B, etape 10) : detient un compteur entier et
/// expose une methode pour l'incrementer. Il remplace le `setState` local de
/// l'ecran par un etat partage et reactif gere par Riverpod — c'est le pattern
/// qu'utiliseront les vrais ecrans a partir de l'etape 11.
///
/// A retirer en meme temps que l'ecran de demonstration.
class CompteurDemoNotifier extends Notifier<int> {
  @override
  int build() => 0; // etat initial du compteur

  void incrementer() => state = state + 1;
}

/// Point d'acces global au compteur de demonstration.
final compteurDemoProvider = NotifierProvider<CompteurDemoNotifier, int>(
  CompteurDemoNotifier.new,
);

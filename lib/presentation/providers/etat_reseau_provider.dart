import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/network/detecteur_reseau.dart';
import 'package:fayemath_academy/core/network/etat_reseau.dart';

/// L'etat du reseau, expose a toute l'application pour le bandeau du haut (Lot D).
///
/// `StreamProvider` NON `autoDispose` : l'etat reseau vit pour toute la duree de
/// l'app (le `ProviderScope` racine), il ne doit pas etre recalcule a chaque
/// changement d'ecran. Tant que rien ne l'a lu, `AsyncValue` est en chargement ;
/// des la premiere valeur amorcee par [DetecteurReseau], il porte un [EtatReseau].
///
/// Le detecteur concret depend du plugin natif `connectivity_plus` : en test, on
/// OVERRIDE ce provider par un flux controle (aucun widget-test ne touche le
/// plugin). Sa destruction ferme proprement l'ecoute et le minuteur.
final etatReseauProvider = StreamProvider<EtatReseau>((ref) {
  final detecteur = DetecteurReseau();
  ref.onDispose(detecteur.liberer);
  return detecteur.flux;
});

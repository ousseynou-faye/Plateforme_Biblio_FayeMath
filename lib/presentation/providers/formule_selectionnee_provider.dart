import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';

/// La formule choisie sur l'ecran de l'offre (etape 26, point 5.3). C'est du PUR
/// AFFICHAGE : la selection ne declenche rien aujourd'hui — l'etape 27 (paiement)
/// viendra LIRE ce provider pour savoir quelle formule l'eleve achete. Un provider
/// (et non un etat local de widget) precisement pour que l'action de paiement, sur
/// un autre ecran, puisse le lire.
///
/// Defaut = **annee scolaire** : « la formule a mettre en avant » (document 2,
/// tableau 4 — c'est la plus avantageuse pour l'eleve et pour la fidelisation).
final formuleSelectionneeProvider =
    NotifierProvider<FormuleSelectionneeNotifier, FormuleAbonnement>(
      FormuleSelectionneeNotifier.new,
    );

class FormuleSelectionneeNotifier extends Notifier<FormuleAbonnement> {
  @override
  FormuleAbonnement build() => FormuleAbonnement.anneeScolaire;

  void choisir(FormuleAbonnement formule) => state = formule;
}

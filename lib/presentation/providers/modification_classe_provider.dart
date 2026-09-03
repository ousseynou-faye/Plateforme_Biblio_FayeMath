import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drapeau transitoire : vrai quand l'eleve ouvre l'ecran de choix (ecran 3)
/// DEPUIS le Profil pour MODIFIER sa classe — a distinguer du choix INITIAL fait
/// a l'inscription / en mode invite (lot Qualite C).
///
/// Pourquoi ce drapeau. Un eleve qui a deja une classe a pour cible de navigation
/// le tableau de bord (`_cibleNavigation`) ; sans exception, la redirection
/// go_router le renverrait a l'accueil des qu'il ouvrirait `/choix-classe`. La
/// redirection consulte donc ce drapeau pour le laisser rester sur l'ecran de
/// choix le temps de modifier. Des que le choix est enregistre (ou l'ecran quitte),
/// le drapeau retombe a faux et la redirection ejecte vers l'accueil — exactement
/// comme le choix initial d'onboarding, dont le mecanisme reste INCHANGE (drapeau
/// a faux par defaut).
class ModificationClasseNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  /// L'eleve entre volontairement dans l'ecran de choix depuis le Profil.
  void demarrer() => state = true;

  /// Le choix est enregistre, ou l'ecran est quitte : la redirection reprend son
  /// comportement normal (ejection vers l'accueil pour un ayant-droit).
  void terminer() => state = false;
}

final modificationClasseProvider =
    NotifierProvider<ModificationClasseNotifier, bool>(
      ModificationClasseNotifier.new,
    );

import 'package:fayemath_academy/core/network/type_interface_reseau.dart';

/// L'issue de la decision « peut-on lancer ce telechargement maintenant ? ».
enum DecisionTelechargement {
  /// Le telechargement peut demarrer.
  autorise,

  /// Bloque : le reglage « Wi-Fi uniquement » est actif ET on est en donnees
  /// mobiles. L'ecran invite a passer en Wi-Fi ou a changer le reglage.
  bloqueDonneesMobiles,
}

/// La regle « telechargement conscient des donnees mobiles » (lot « Qualite D »),
/// selon le reglage « Wi-Fi uniquement » et le type d'interface active.
///
/// Regle METIER PURE (aucun plugin, aucun I/O), testable directement — sur le
/// modele de `TransitionReseau`. C'est `core/` qui porte la logique de decision
/// reseau (docs/ARCHITECTURE.md §3/§4).
abstract final class AutorisationTelechargement {
  /// Ne bloque QUE le cas « reglage actif ET donnees mobiles ». En Wi-Fi, ou si
  /// le reglage est desactive, on autorise. Hors ligne
  /// ([TypeInterfaceReseau.aucune]) on autorise aussi : le moteur echouera de
  /// lui-meme avec une erreur reseau — ce n'est pas un blocage « Wi-Fi seulement ».
  static DecisionTelechargement decider({
    required bool wifiSeulement,
    required TypeInterfaceReseau interface,
  }) {
    if (wifiSeulement && interface == TypeInterfaceReseau.donneesMobiles) {
      return DecisionTelechargement.bloqueDonneesMobiles;
    }
    return DecisionTelechargement.autorise;
  }
}

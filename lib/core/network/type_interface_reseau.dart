import 'package:connectivity_plus/connectivity_plus.dart';

/// Le TYPE d'interface reseau active, quand on a besoin de le distinguer (lot
/// « Qualite D » : telechargement conscient des donnees mobiles). Volontairement
/// DISTINCT d'[EtatReseau] (les 3 etats du bandeau, SPECIFICATIONS_V2 §2.3, qui
/// restent inchanges) : ici on ne demande pas « suis-je en ligne ? » mais « PAR
/// QUELLE interface ? ».
///
/// Meme limite assumee que `DetecteurReseau` : connectivity_plus rapporte le type
/// d'interface, pas une joignabilite reelle d'Internet. Ce type sert a decider
/// s'il faut menager le forfait de donnees, pas a prouver un acces.
enum TypeInterfaceReseau {
  /// Wi-Fi ou tout reseau non facture a la donnee (ethernet, vpn).
  wifi,

  /// Donnees mobiles (4G/3G...) : un telechargement consomme le forfait.
  donneesMobiles,

  /// Aucune interface active : hors ligne.
  aucune;

  /// Classe une liste de resultats `connectivity_plus`. Le Wi-Fi (et assimiles
  /// non factures : ethernet, vpn) PRIME : si le telephone est a la fois en Wi-Fi
  /// et en donnees mobiles, on telecharge en Wi-Fi. Liste vide, `none` ou
  /// interfaces non pertinentes (bluetooth, other) -> [aucune].
  ///
  /// N'importe que l'enum `ConnectivityResult` (Dart pur, testable sans plugin
  /// natif), jamais le client `Connectivity`.
  static TypeInterfaceReseau depuis(List<ConnectivityResult> resultats) {
    var mobile = false;
    for (final resultat in resultats) {
      switch (resultat) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.ethernet:
        case ConnectivityResult.vpn:
          return TypeInterfaceReseau.wifi;
        case ConnectivityResult.mobile:
          mobile = true;
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.other:
        case ConnectivityResult.satellite:
        case ConnectivityResult.none:
          break;
      }
    }
    return mobile
        ? TypeInterfaceReseau.donneesMobiles
        : TypeInterfaceReseau.aucune;
  }
}

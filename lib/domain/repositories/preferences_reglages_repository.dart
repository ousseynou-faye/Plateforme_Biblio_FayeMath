/// Contrat des reglages NON sensibles de l'application, stockes sur l'APPAREIL
/// (comme le drapeau d'onboarding), jamais lies au compte — un invite y a droit
/// aussi (lot « Qualite D »).
///
/// Aujourd'hui un seul reglage : « telecharger uniquement en Wi-Fi ». Le domaine
/// declare le besoin ; l'implementation (`data/`) choisit le support de stockage.
abstract interface class PreferencesReglagesRepository {
  /// Vrai si l'eleve veut ne telecharger qu'en Wi-Fi (menager le forfait).
  ///
  /// DEFAUT (reglage jamais defini) : `true`. On protege le forfait par defaut —
  /// la data chere au Senegal est la raison d'etre offline-first du projet
  /// (decision Ousseynou, lot « Qualite D »).
  Future<bool> telechargerEnWifiSeulement();

  /// Enregistre le choix de l'eleve.
  Future<void> definirTelechargerEnWifiSeulement({required bool valeur});
}

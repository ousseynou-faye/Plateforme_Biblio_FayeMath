/// Contrat de nettoyage des donnees LOCALES de l'eleve sur l'appareil, utilise
/// lors de la suppression de compte (droit a l'effacement, loi 2008-12). Le
/// domaine DECLARE le besoin ; l'implementation (`data/`) connait Drift et le
/// systeme de fichiers — le metier n'en depend pas (docs/ARCHITECTURE.md §3).
///
/// « Donnees de l'eleve » = son cache Drift PERSONNEL (progression, telechargement,
/// abonnement, profil) et ses PDF telecharges. PAS le catalogue public (non
/// personnel, reconstructible), ni les preferences d'appareil (drapeau onboarding
/// vu, reglage Wi-Fi) qui ne sont pas des donnees a caractere personnel.
abstract interface class NettoyageLocalRepository {
  /// Efface de l'appareil toutes les donnees personnelles de l'eleve.
  ///
  /// BEST-EFFORT : ne leve jamais. La suppression est deja actee cote serveur
  /// (cascade) au moment ou on l'appelle ; un fichier qui resiste ou un cache
  /// verrouille ne doit pas bloquer le geste ni le faire echouer.
  Future<void> viderDonneesEleve();
}

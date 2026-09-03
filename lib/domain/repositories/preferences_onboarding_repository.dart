/// Le contrat de memoire de l'onboarding (ecran 1) : se souvenir si l'eleve a
/// deja vu — ou passe — la presentation, sur CET appareil.
///
/// Notion d'APPAREIL, pas de compte : c'est « premier lancement de l'application
/// sur ce telephone », pas « premiere connexion ». Consequence verrouillee (lot
/// « Qualite et experience eleve », point 2) : le drapeau SURVIT a une
/// deconnexion — il n'est jamais efface a la deconnexion. Un eleve qui se
/// deconnecte puis se reconnecte ne revoit pas l'onboarding.
///
/// Purement LOCAL : aucun cote serveur (ni table Supabase, ni RLS). Le domaine
/// DECLARE le besoin, `data/` s'y plie (inversion de dependance,
/// docs/ARCHITECTURE.md §3) — ici l'implementation range le drapeau dans le
/// coffre chiffre deja utilise pour les jetons de session (decision du point 1 :
/// reutiliser flutter_secure_storage plutot qu'ajouter une dependance).
abstract interface class PreferencesOnboardingRepository {
  /// true si l'onboarding a deja ete vu (ou passe) sur cet appareil.
  Future<bool> onboardingVu();

  /// Marque l'onboarding comme vu. Idempotent (un second appel ne change rien).
  Future<void> marquerOnboardingVu();

  /// Efface le drapeau. POINT D'ANCRAGE (point 3) pour un futur « Revoir la
  /// presentation » depuis l'ecran Profil (pas encore construit) : il n'aura qu'a
  /// appeler ceci. Non utilise en V1, prevu pour ne pas tout refaire ensuite.
  Future<void> reinitialiserOnboarding();
}

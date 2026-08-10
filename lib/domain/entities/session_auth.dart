/// L'identite de la session d'authentification courante, vue par le domaine.
///
/// Volontairement minimale : juste l'identifiant du compte connecte. C'est le
/// pont PUR (aucune dependance a Supabase) entre `data/` — qui traduit la
/// session Supabase — et ses consommateurs : la redirection go_router et l'etat
/// Riverpod. Le PROFIL complet de l'eleve (classe, serie ; l'entite
/// `Utilisateur`) se lit separement et releve de l'etape 14 ; ici on ne sait
/// qu'une seule chose : qui est connecte.
///
/// La confirmation e-mail etant activee cote Supabase, un compte n'obtient de
/// session qu'une fois son e-mail confirme : l'existence d'une [SessionAuth]
/// vaut donc « connecte ET e-mail confirme ».
class SessionAuth {
  const SessionAuth({required this.utilisateurId});

  /// L'identifiant du compte, egal a `auth.users.id` (et a `utilisateur.id`).
  final String utilisateurId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAuth && other.utilisateurId == utilisateurId;

  @override
  int get hashCode => utilisateurId.hashCode;
}

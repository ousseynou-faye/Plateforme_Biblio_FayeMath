/// Une matiere : Mathematiques ou physique-chimie.
///
/// Miroir de la table `matiere` (migration 01). La disponibilite reelle d'une
/// matiere pour une classe (« bientot disponible » si la bibliotheque n'existe
/// pas encore, GLOSSAIRE §2) est une regle d'affichage, pas un champ de l'entite.
class Matiere {
  const Matiere({required this.id, required this.nom});

  final String id;
  final String nom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Matiere && other.id == id && other.nom == nom;

  @override
  int get hashCode => Object.hash(id, nom);
}

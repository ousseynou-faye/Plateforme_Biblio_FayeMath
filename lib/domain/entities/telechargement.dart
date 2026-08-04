/// Un telechargement : une ressource qu'un eleve a enregistree sur son telephone.
///
/// Miroir de la table `telechargement` (migration 01). Une seule ligne par couple
/// (eleve, ressource). C'est la trace de ce qui est disponible hors-ligne — a ne
/// pas confondre avec l'etat du reseau (GLOSSAIRE §6).
class Telechargement {
  const Telechargement({
    required this.id,
    required this.utilisateurId,
    required this.ressourceId,
    required this.dateTelechargement,
  });

  final String id;
  final String utilisateurId;
  final String ressourceId;
  final DateTime dateTelechargement;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Telechargement &&
          other.id == id &&
          other.utilisateurId == utilisateurId &&
          other.ressourceId == ressourceId &&
          other.dateTelechargement == dateTelechargement;

  @override
  int get hashCode =>
      Object.hash(id, utilisateurId, ressourceId, dateTelechargement);
}

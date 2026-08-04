/// Un chapitre : l'unite de travail et l'objet du suivi de progression.
///
/// Miroir de la table `chapitre` (migration 01). [numero] est le numero officiel
/// du livret du Ministere ; [ordre] est l'ordre d'affichage, et c'est LUI qui
/// sert a la regle des N premiers chapitres gratuits (cote serveur). [strate] est
/// le regroupement d'affichage (« Activites Numeriques »...), nullable.
class Chapitre {
  const Chapitre({
    required this.id,
    required this.classeId,
    required this.matiereId,
    required this.numero,
    required this.titre,
    required this.strate,
    required this.ordre,
  });

  final String id;
  final String classeId;
  final String matiereId;
  final int numero;
  final String titre;

  /// Regroupement d'affichage au sein d'une matiere ; null si le chapitre n'en a
  /// pas (colonne `strate` nullable au schema).
  final String? strate;
  final int ordre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chapitre &&
          other.id == id &&
          other.classeId == classeId &&
          other.matiereId == matiereId &&
          other.numero == numero &&
          other.titre == titre &&
          other.strate == strate &&
          other.ordre == ordre;

  @override
  int get hashCode =>
      Object.hash(id, classeId, matiereId, numero, titre, strate, ordre);
}

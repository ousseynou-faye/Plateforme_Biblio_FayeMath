import 'package:fayemath_academy/domain/entities/type_ressource.dart';

/// Une ressource : un document publie (l'un des 8 [TypeRessource]).
///
/// Miroir de la table `ressource` (migration 01). Le rattachement depend du type
/// (voir [rattachementCoherent]) : un `sujet_examen` appartient a une classe +
/// matiere, tous les autres a un chapitre. [premium] est DERIVE cote serveur
/// (trigger, migration 02) et lu tel quel — jamais recalcule ici, y compris pour
/// `sujet_examen` (exception GLOSSAIRE §4). [tailleOctets] est en octets (la
/// conversion Ko/Mo est un probleme d'affichage).
class Ressource {
  const Ressource({
    required this.id,
    required this.chapitreId,
    required this.classeId,
    required this.matiereId,
    required this.type,
    required this.titre,
    required this.tailleOctets,
    required this.premium,
    required this.version,
    required this.cheminStorage,
    required this.ordre,
  });

  final String id;

  /// Chapitre de rattachement ; null pour un `sujet_examen` (schema nullable).
  final String? chapitreId;

  /// Classe de rattachement ; renseignee seulement pour un `sujet_examen`.
  final String? classeId;

  /// Matiere de rattachement ; renseignee seulement pour un `sujet_examen`.
  final String? matiereId;

  final TypeRessource type;
  final String titre;
  final int tailleOctets;
  final bool premium;
  final int version;

  /// Chemin dans le bucket Storage ; null tant que le fichier n'y est pas.
  final String? cheminStorage;
  final int ordre;

  bool get estSujetExamen => type == TypeRessource.sujetExamen;

  /// Reproduit la contrainte serveur `ressource_rattachement_coherent`
  /// (migration 01) : un `sujet_examen` porte une classe + matiere et pas de
  /// chapitre ; tout autre type porte un chapitre et pas de classe/matiere
  /// propres. Regle metier pure, verifiable sans base de donnees.
  bool get rattachementCoherent {
    if (estSujetExamen) {
      return chapitreId == null && classeId != null && matiereId != null;
    }
    return chapitreId != null && classeId == null && matiereId == null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ressource &&
          other.id == id &&
          other.chapitreId == chapitreId &&
          other.classeId == classeId &&
          other.matiereId == matiereId &&
          other.type == type &&
          other.titre == titre &&
          other.tailleOctets == tailleOctets &&
          other.premium == premium &&
          other.version == version &&
          other.cheminStorage == cheminStorage &&
          other.ordre == ordre;

  @override
  int get hashCode => Object.hash(
    id,
    chapitreId,
    classeId,
    matiereId,
    type,
    titre,
    tailleOctets,
    premium,
    version,
    cheminStorage,
    ordre,
  );
}

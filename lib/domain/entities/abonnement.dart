import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';

/// Un abonnement premium souscrit par un eleve.
///
/// Miroir de la table `abonnement` (migration 01). Il n'y a pas de colonne
/// « statut » : actif ou expire se DEDUIT des dates (voir [estActif]), exactement
/// comme la regle serveur `date_fin >= current_date`.
class Abonnement {
  const Abonnement({
    required this.id,
    required this.utilisateurId,
    required this.formule,
    required this.dateDebut,
    required this.dateFin,
    required this.referencePaiement,
  });

  final String id;
  final String utilisateurId;
  final FormuleAbonnement formule;
  final DateTime dateDebut;
  final DateTime dateFin;

  /// Reference du paiement ; nullable (renseignee au reglement).
  final String? referencePaiement;

  /// Vrai si l'abonnement couvre le jour [aujourdhui] : sa date de fin n'est pas
  /// anterieure a ce jour. Comparaison a la JOURNEE (les dates du schema sont de
  /// type `date`, sans heure). Regle metier pure, testable sans base.
  bool estActif(DateTime aujourdhui) {
    final finJour = DateTime(dateFin.year, dateFin.month, dateFin.day);
    final refJour = DateTime(aujourdhui.year, aujourdhui.month, aujourdhui.day);
    return !finJour.isBefore(refJour);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Abonnement &&
          other.id == id &&
          other.utilisateurId == utilisateurId &&
          other.formule == formule &&
          other.dateDebut == dateDebut &&
          other.dateFin == dateFin &&
          other.referencePaiement == referencePaiement;

  @override
  int get hashCode => Object.hash(
    id,
    utilisateurId,
    formule,
    dateDebut,
    dateFin,
    referencePaiement,
  );
}

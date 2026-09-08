import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';

/// Met en mots un abonnement pour l'en-tete « Premium actif » de l'ecran de
/// l'offre (etape 26). Regle METIER PURE (docs/ARCHITECTURE.md §9) : Dart pur,
/// testable sans Flutter, sans base — elle ne fait que formater des faits deja
/// resolus (la formule et la date de fin de l'[Abonnement]).
///
/// Le MONTANT ne vient PAS d'ici : il releve du catalogue de prix affiche a cote
/// (les 3 tarifs verrouilles le 31/07/2026) ; cet abonnement ne porte que la
/// formule souscrite et son echeance.
abstract final class ResumeAbonnement {
  /// Le libelle lisible d'une formule (sans accents, CONVENTIONS §1).
  static String libelleFormule(FormuleAbonnement formule) => switch (formule) {
    FormuleAbonnement.mensuel => 'Mensuel',
    FormuleAbonnement.trimestriel => 'Trimestriel',
    FormuleAbonnement.anneeScolaire => 'Annee scolaire',
  };

  /// Date courte JJ/MM/AAAA (pas d'`intl` : offline-first, zero dependance).
  static String dateCourte(DateTime date) =>
      '${_deuxChiffres(date.day)}/${_deuxChiffres(date.month)}/${date.year}';

  /// La ligne de l'en-tete « Premium actif » : « Formule annee scolaire, jusqu'au
  /// 30/06/2027 ». [Abonnement.dateFin] est l'echeance ; on n'affirme rien sur la
  /// reconduction (il n'y en a pas — paiement ponctuel, cf. les conditions).
  static String echeance(Abonnement abonnement) =>
      'Formule ${libelleFormule(abonnement.formule).toLowerCase()}, '
      'jusqu\'au ${dateCourte(abonnement.dateFin)}';

  static String _deuxChiffres(int n) => n.toString().padLeft(2, '0');
}

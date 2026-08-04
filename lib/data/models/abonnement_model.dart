import 'package:drift/drift.dart' show Value;

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';

/// Traduction de la table `abonnement`. Lecture seule cote app — RLS SELECT de
/// soi, aucune ecriture (reservee au futur webhook de paiement, migration 03) —
/// donc pas de `versJson`. `date_debut`/`date_fin` sont de type `date` cote
/// serveur ; `reference_paiement` est nullable.
abstract final class AbonnementModel {
  static Abonnement depuisJson(Map<String, dynamic> json) => Abonnement(
    id: lireTexte(json, 'id'),
    utilisateurId: lireTexte(json, 'utilisateur_id'),
    formule: lireEnum(json, 'formule', FormuleAbonnement.depuisValeurSql),
    dateDebut: lireDate(json, 'date_debut'),
    dateFin: lireDate(json, 'date_fin'),
    referencePaiement: lireTexteNullable(json, 'reference_paiement'),
  );

  static Abonnement depuisLigne(AbonnementLocale ligne) => Abonnement(
    id: ligne.id,
    utilisateurId: ligne.utilisateurId,
    formule: FormuleAbonnement.depuisValeurSql(ligne.formule),
    dateDebut: ligne.dateDebut,
    dateFin: ligne.dateFin,
    referencePaiement: ligne.referencePaiement,
  );

  static AbonnementsCompanion versCompanion(Abonnement abonnement) =>
      AbonnementsCompanion.insert(
        id: abonnement.id,
        utilisateurId: abonnement.utilisateurId,
        formule: abonnement.formule.valeurSql,
        dateDebut: abonnement.dateDebut,
        dateFin: abonnement.dateFin,
        referencePaiement: Value(abonnement.referencePaiement),
      );
}

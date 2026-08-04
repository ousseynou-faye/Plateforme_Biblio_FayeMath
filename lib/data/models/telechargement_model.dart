import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/telechargement.dart';

/// Traduction de la table `telechargement`. L'app lit ET ecrit ses propres
/// telechargements — RLS acces complet de soi (migration 03) — d'ou [versJson].
abstract final class TelechargementModel {
  static Telechargement depuisJson(Map<String, dynamic> json) => Telechargement(
    id: lireTexte(json, 'id'),
    utilisateurId: lireTexte(json, 'utilisateur_id'),
    ressourceId: lireTexte(json, 'ressource_id'),
    dateTelechargement: lireDate(json, 'date_telechargement'),
  );

  static Telechargement depuisLigne(TelechargementLocale ligne) =>
      Telechargement(
        id: ligne.id,
        utilisateurId: ligne.utilisateurId,
        ressourceId: ligne.ressourceId,
        dateTelechargement: ligne.dateTelechargement,
      );

  static Map<String, dynamic> versJson(Telechargement telechargement) => {
    'id': telechargement.id,
    'utilisateur_id': telechargement.utilisateurId,
    'ressource_id': telechargement.ressourceId,
    'date_telechargement': telechargement.dateTelechargement.toIso8601String(),
  };

  static TelechargementsCompanion versCompanion(
    Telechargement telechargement,
  ) => TelechargementsCompanion.insert(
    id: telechargement.id,
    utilisateurId: telechargement.utilisateurId,
    ressourceId: telechargement.ressourceId,
    dateTelechargement: telechargement.dateTelechargement,
  );
}

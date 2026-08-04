import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/progression.dart';

/// Traduction de la table `progression`. L'app lit ET ecrit sa propre
/// progression (offline-first) — RLS acces complet de soi (migration 03) — d'ou
/// [versJson]. La vraie mecanique de synchronisation reste pour la Phase 3.
abstract final class ProgressionModel {
  static Progression depuisJson(Map<String, dynamic> json) => Progression(
    id: lireTexte(json, 'id'),
    utilisateurId: lireTexte(json, 'utilisateur_id'),
    chapitreId: lireTexte(json, 'chapitre_id'),
    etat: lireEnum(json, 'etat', EtatProgression.depuisValeurSql),
    dateMaj: lireDate(json, 'date_maj'),
  );

  static Progression depuisLigne(ProgressionLocale ligne) => Progression(
    id: ligne.id,
    utilisateurId: ligne.utilisateurId,
    chapitreId: ligne.chapitreId,
    etat: EtatProgression.depuisValeurSql(ligne.etat),
    dateMaj: ligne.dateMaj,
  );

  static Map<String, dynamic> versJson(Progression progression) => {
    'id': progression.id,
    'utilisateur_id': progression.utilisateurId,
    'chapitre_id': progression.chapitreId,
    'etat': progression.etat.valeurSql,
    'date_maj': progression.dateMaj.toIso8601String(),
  };

  static ProgressionsCompanion versCompanion(Progression progression) =>
      ProgressionsCompanion.insert(
        id: progression.id,
        utilisateurId: progression.utilisateurId,
        chapitreId: progression.chapitreId,
        etat: progression.etat.valeurSql,
        dateMaj: progression.dateMaj,
      );
}

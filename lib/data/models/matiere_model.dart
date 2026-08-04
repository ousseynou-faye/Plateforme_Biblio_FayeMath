import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';

/// Traduction de la table `matiere` : JSON Supabase <-> entite, ligne Drift <->
/// entite. Catalogue en lecture seule cote app (RLS, migration 03).
abstract final class MatiereModel {
  static Matiere depuisJson(Map<String, dynamic> json) =>
      Matiere(id: lireTexte(json, 'id'), nom: lireTexte(json, 'nom'));

  static Matiere depuisLigne(MatiereLocale ligne) =>
      Matiere(id: ligne.id, nom: ligne.nom);

  static MatieresCompanion versCompanion(Matiere matiere) =>
      MatieresCompanion.insert(id: matiere.id, nom: matiere.nom);
}

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';

/// Traduction de la table `classe` : JSON Supabase <-> entite, ligne Drift <->
/// entite. Catalogue en lecture seule cote app (RLS, migration 03) : pas de
/// `versJson`, l'app n'ecrit jamais le catalogue vers le serveur.
abstract final class ClasseModel {
  static Classe depuisJson(Map<String, dynamic> json) => Classe(
    id: lireTexte(json, 'id'),
    nom: lireTexte(json, 'nom'),
    cycle: lireEnum(json, 'cycle', Cycle.depuisValeurSql),
    ordre: lireEntier(json, 'ordre'),
  );

  static Classe depuisLigne(ClasseLocale ligne) => Classe(
    id: ligne.id,
    nom: ligne.nom,
    cycle: Cycle.depuisValeurSql(ligne.cycle),
    ordre: ligne.ordre,
  );

  static ClassesCompanion versCompanion(Classe classe) =>
      ClassesCompanion.insert(
        id: classe.id,
        nom: classe.nom,
        cycle: classe.cycle.valeurSql,
        ordre: classe.ordre,
      );
}

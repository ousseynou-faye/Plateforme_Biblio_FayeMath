import 'package:drift/drift.dart' show Value;

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';

/// Traduction de la table `ressource` : JSON Supabase <-> entite, ligne Drift <->
/// entite. Catalogue en lecture seule cote app (RLS, migration 03). `premium` est
/// lu tel quel (derive cote serveur, jamais recalcule ici). Rattachement variable
/// selon le type : chapitre_id / classe_id / matiere_id sont nullables.
abstract final class RessourceModel {
  static Ressource depuisJson(Map<String, dynamic> json) => Ressource(
    id: lireTexte(json, 'id'),
    chapitreId: lireTexteNullable(json, 'chapitre_id'),
    classeId: lireTexteNullable(json, 'classe_id'),
    matiereId: lireTexteNullable(json, 'matiere_id'),
    type: lireEnum(json, 'type', TypeRessource.depuisValeurSql),
    titre: lireTexte(json, 'titre'),
    tailleOctets: lireEntier(json, 'taille_octets'),
    premium: lireBool(json, 'premium'),
    version: lireEntier(json, 'version'),
    cheminStorage: lireTexteNullable(json, 'chemin_storage'),
    ordre: lireEntier(json, 'ordre'),
  );

  static Ressource depuisLigne(RessourceLocale ligne) => Ressource(
    id: ligne.id,
    chapitreId: ligne.chapitreId,
    classeId: ligne.classeId,
    matiereId: ligne.matiereId,
    type: TypeRessource.depuisValeurSql(ligne.type),
    titre: ligne.titre,
    tailleOctets: ligne.tailleOctets,
    premium: ligne.premium,
    version: ligne.version,
    cheminStorage: ligne.cheminStorage,
    ordre: ligne.ordre,
  );

  static RessourcesCompanion versCompanion(Ressource ressource) =>
      RessourcesCompanion.insert(
        id: ressource.id,
        chapitreId: Value(ressource.chapitreId),
        classeId: Value(ressource.classeId),
        matiereId: Value(ressource.matiereId),
        type: ressource.type.valeurSql,
        titre: ressource.titre,
        tailleOctets: ressource.tailleOctets,
        premium: ressource.premium,
        version: ressource.version,
        cheminStorage: Value(ressource.cheminStorage),
        ordre: ressource.ordre,
      );
}

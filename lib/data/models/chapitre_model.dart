import 'package:drift/drift.dart' show Value;

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';

/// Traduction de la table `chapitre` : JSON Supabase <-> entite, ligne Drift <->
/// entite. Catalogue en lecture seule cote app (RLS, migration 03). `strate` est
/// nullable des deux cotes.
abstract final class ChapitreModel {
  static Chapitre depuisJson(Map<String, dynamic> json) => Chapitre(
    id: lireTexte(json, 'id'),
    classeId: lireTexte(json, 'classe_id'),
    matiereId: lireTexte(json, 'matiere_id'),
    numero: lireEntier(json, 'numero'),
    titre: lireTexte(json, 'titre'),
    strate: lireTexteNullable(json, 'strate'),
    ordre: lireEntier(json, 'ordre'),
  );

  static Chapitre depuisLigne(ChapitreLocale ligne) => Chapitre(
    id: ligne.id,
    classeId: ligne.classeId,
    matiereId: ligne.matiereId,
    numero: ligne.numero,
    titre: ligne.titre,
    strate: ligne.strate,
    ordre: ligne.ordre,
  );

  static ChapitresCompanion versCompanion(Chapitre chapitre) =>
      ChapitresCompanion.insert(
        id: chapitre.id,
        classeId: chapitre.classeId,
        matiereId: chapitre.matiereId,
        numero: chapitre.numero,
        titre: chapitre.titre,
        strate: Value(chapitre.strate),
        ordre: chapitre.ordre,
      );
}

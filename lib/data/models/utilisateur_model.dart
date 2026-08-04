import 'package:drift/drift.dart' show Value;

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/lecture_json.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';

/// Traduction de la table `utilisateur`. L'app lit ET met a jour son propre
/// profil (classe/serie choisies) — RLS SELECT + UPDATE de soi (migration 03) —
/// d'ou la presence d'un [versJson]. `classe_id` et `serie` sont nullables.
abstract final class UtilisateurModel {
  static Utilisateur depuisJson(Map<String, dynamic> json) => Utilisateur(
    id: lireTexte(json, 'id'),
    classeId: lireTexteNullable(json, 'classe_id'),
    serie: lireEnumNullable(json, 'serie', Serie.depuisValeurSql),
    creeLe: lireDate(json, 'cree_le'),
  );

  static Utilisateur depuisLigne(UtilisateurLocale ligne) => Utilisateur(
    id: ligne.id,
    classeId: ligne.classeId,
    serie: ligne.serie == null ? null : Serie.depuisValeurSql(ligne.serie!),
    creeLe: ligne.creeLe,
  );

  static Map<String, dynamic> versJson(Utilisateur utilisateur) => {
    'id': utilisateur.id,
    'classe_id': utilisateur.classeId,
    'serie': utilisateur.serie?.valeurSql,
    'cree_le': utilisateur.creeLe.toIso8601String(),
  };

  static UtilisateursCompanion versCompanion(Utilisateur utilisateur) =>
      UtilisateursCompanion.insert(
        id: utilisateur.id,
        classeId: Value(utilisateur.classeId),
        serie: Value(utilisateur.serie?.valeurSql),
        creeLe: utilisateur.creeLe,
      );
}

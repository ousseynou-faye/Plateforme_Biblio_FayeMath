import 'package:fayemath_academy/core/errors/donnees_invalides.dart';

/// Lecteurs types d'un JSON Supabase. Chaque lecteur leve [DonneesInvalides]
/// (jamais une `TypeError` brute) si le champ manque ou n'a pas le bon type. Les
/// modeles `_model.dart` passent par ces fonctions plutot que par des casts `as`,
/// pour respecter la regle de gestion d'erreurs (docs/CONVENTIONS.md §5).

String lireTexte(Map<String, dynamic> json, String cle) {
  final valeur = json[cle];
  if (valeur is String) return valeur;
  throw DonneesInvalides(
    'Champ "$cle" : texte attendu, obtenu ${valeur.runtimeType}',
  );
}

String? lireTexteNullable(Map<String, dynamic> json, String cle) {
  final valeur = json[cle];
  if (valeur == null) return null;
  if (valeur is String) return valeur;
  throw DonneesInvalides(
    'Champ "$cle" : texte ou null attendu, obtenu ${valeur.runtimeType}',
  );
}

int lireEntier(Map<String, dynamic> json, String cle) {
  final valeur = json[cle];
  if (valeur is int) return valeur;
  throw DonneesInvalides(
    'Champ "$cle" : entier attendu, obtenu ${valeur.runtimeType}',
  );
}

bool lireBool(Map<String, dynamic> json, String cle) {
  final valeur = json[cle];
  if (valeur is bool) return valeur;
  throw DonneesInvalides(
    'Champ "$cle" : booleen attendu, obtenu ${valeur.runtimeType}',
  );
}

DateTime lireDate(Map<String, dynamic> json, String cle) {
  final valeur = json[cle];
  if (valeur is String) {
    final date = DateTime.tryParse(valeur);
    if (date != null) return date;
  }
  throw DonneesInvalides('Champ "$cle" : date ISO attendue, obtenu "$valeur"');
}

/// Lit un champ texte puis le convertit en enum via son parseur strict
/// (`depuisValeurSql`). Traduit l'`ArgumentError` d'une valeur inconnue en
/// [DonneesInvalides], pour ne pas laisser fuiter une erreur technique.
T lireEnum<T>(
  Map<String, dynamic> json,
  String cle,
  T Function(String) depuisValeurSql,
) {
  final texte = lireTexte(json, cle);
  try {
    return depuisValeurSql(texte);
  } on ArgumentError catch (erreur) {
    throw DonneesInvalides('Champ "$cle" : ${erreur.message}');
  }
}

/// Variante nullable de [lireEnum] : rend null si le champ est absent.
T? lireEnumNullable<T>(
  Map<String, dynamic> json,
  String cle,
  T Function(String) depuisValeurSql,
) {
  if (json[cle] == null) return null;
  return lireEnum(json, cle, depuisValeurSql);
}

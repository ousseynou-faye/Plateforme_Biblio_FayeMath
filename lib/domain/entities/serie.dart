/// La serie d'une classe de lycee : L, S1 ou S2.
///
/// Vocabulaire FIGE — source : docs/GLOSSAIRE.md §2 et la contrainte CHECK de
/// `20260801100000_creer_tables_v1.sql` (colonne `utilisateur.serie`). Demandee
/// uniquement en 1ere et Terminale, toujours avant les matieres (GLOSSAIRE §2) ;
/// nullable en base, donc absente (null) pour tout eleve de college ou de 2nde.
///
/// Les constantes sont nommees `serieL/serieS1/serieS2` et non `l/s1/s2` : un `l`
/// isole se lit mal a cote de chiffres (choix d'Ousseynou, 04/08/2026).
enum Serie {
  serieL('L'),
  serieS1('S1'),
  serieS2('S2');

  const Serie(this.valeurSql);

  /// La valeur exacte stockee cote serveur (Supabase) et en base locale (Drift).
  final String valeurSql;

  /// Convertit une valeur SQL en enum. Parsing STRICT (cf. type_ressource.dart).
  static Serie depuisValeurSql(String valeur) {
    for (final serie in Serie.values) {
      if (serie.valeurSql == valeur) return serie;
    }
    throw ArgumentError.value(
      valeur,
      'valeur',
      'Serie inconnue (attendu : '
          '${Serie.values.map((s) => s.valeurSql).join(', ')})',
    );
  }
}

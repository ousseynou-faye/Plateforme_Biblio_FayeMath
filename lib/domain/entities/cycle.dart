/// Le cycle scolaire d'une classe : college ou lycee.
///
/// Vocabulaire FIGE — source : la contrainte CHECK de
/// `20260801100000_creer_tables_v1.sql` (colonne `classe.cycle`). Valeurs ASCII
/// en base ; le libelle accentue affiche a l'eleve releve de la presentation.
enum Cycle {
  college('college'),
  lycee('lycee');

  const Cycle(this.valeurSql);

  /// La valeur exacte stockee cote serveur (Supabase) et en base locale (Drift).
  final String valeurSql;

  /// Convertit une valeur SQL en enum. Parsing STRICT (cf. type_ressource.dart).
  static Cycle depuisValeurSql(String valeur) {
    for (final cycle in Cycle.values) {
      if (cycle.valeurSql == valeur) return cycle;
    }
    throw ArgumentError.value(
      valeur,
      'valeur',
      'Cycle inconnu (attendu : '
          '${Cycle.values.map((c) => c.valeurSql).join(', ')})',
    );
  }
}

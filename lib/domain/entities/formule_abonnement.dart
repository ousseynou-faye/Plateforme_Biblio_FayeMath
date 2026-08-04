/// Les 3 formules d'abonnement premium.
///
/// Vocabulaire FIGE — source : docs/GLOSSAIRE.md §7 et la contrainte CHECK de
/// `20260801100000_creer_tables_v1.sql` (colonne `abonnement.formule`). Tarifs
/// verrouilles le 31/07/2026 (mensuel 1 000 / trimestriel 2 500 / annee scolaire
/// 6 000 FCFA) — le montant releve du catalogue de prix, pas de cet enum.
enum FormuleAbonnement {
  mensuel('mensuel'),
  trimestriel('trimestriel'),
  anneeScolaire('annee_scolaire');

  const FormuleAbonnement(this.valeurSql);

  /// La valeur exacte stockee cote serveur (Supabase) et en base locale (Drift).
  final String valeurSql;

  /// Convertit une valeur SQL en enum. Parsing STRICT (cf. type_ressource.dart).
  static FormuleAbonnement depuisValeurSql(String valeur) {
    for (final formule in FormuleAbonnement.values) {
      if (formule.valeurSql == valeur) return formule;
    }
    throw ArgumentError.value(
      valeur,
      'valeur',
      'Formule d\'abonnement inconnue (attendu : '
          '${FormuleAbonnement.values.map((f) => f.valeurSql).join(', ')})',
    );
  }
}

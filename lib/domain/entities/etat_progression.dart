/// Les 4 etats de progression d'un chapitre pour un eleve.
///
/// Vocabulaire FIGE — source : docs/GLOSSAIRE.md §5 et la contrainte CHECK de
/// `20260801100000_creer_tables_v1.sql` (colonne `progression.etat`). Il y en a
/// quatre, ni plus ni moins. « fait » est une regle metier : un chapitre passe
/// « fait » quand sa fiche de revision est validee (GLOSSAIRE §5).
enum EtatProgression {
  aFaire('a_faire'),
  enCours('en_cours'),
  fait('fait'),
  aRevoir('a_revoir');

  const EtatProgression(this.valeurSql);

  /// La valeur exacte stockee cote serveur (Supabase) et en base locale (Drift).
  final String valeurSql;

  /// Le libelle affiche a l'eleve, sans accents (CONVENTIONS §1). Termes FIGES
  /// (GLOSSAIRE §5). Sert notamment au statut affiche sur l'ecran de detail d'un
  /// chapitre (etape 16), pour l'instant toujours « A faire » (aucune progression
  /// enregistree : affichage seulement, cf. Journal etape 16).
  String get libelleAffichage => switch (this) {
    EtatProgression.aFaire => 'A faire',
    EtatProgression.enCours => 'En cours',
    EtatProgression.fait => 'Fait',
    EtatProgression.aRevoir => 'A revoir',
  };

  /// Convertit une valeur SQL en enum. Parsing STRICT (cf. type_ressource.dart).
  static EtatProgression depuisValeurSql(String valeur) {
    for (final etat in EtatProgression.values) {
      if (etat.valeurSql == valeur) return etat;
    }
    throw ArgumentError.value(
      valeur,
      'valeur',
      'Etat de progression inconnu (attendu : '
          '${EtatProgression.values.map((e) => e.valeurSql).join(', ')})',
    );
  }
}

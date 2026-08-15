/// Les 8 types de ressource publies dans l'application.
///
/// Vocabulaire FIGE — source : docs/GLOSSAIRE.md §3 et la contrainte CHECK de
/// `20260801100000_creer_tables_v1.sql` (colonne `ressource.type`). Aucune valeur
/// ajoutee ni renommee : le code metier manipule l'enum, la base la chaine SQL.
enum TypeRessource {
  cours('cours'),
  resume('resume'),
  exercices('exercices'),
  corrige('corrige'),
  revision('revision'),
  evaluation('evaluation'),
  corrigeEvaluation('corrige_evaluation'),
  sujetExamen('sujet_examen');

  const TypeRessource(this.valeurSql);

  /// La valeur exacte stockee cote serveur (Supabase) et en base locale (Drift).
  final String valeurSql;

  /// Le libelle affiche a l'eleve (« Cours », « Corrige detaille »...), sans
  /// accents (CONVENTIONS §1). Les 4 types du kit standard reprennent EXACTEMENT
  /// les libelles de la maquette V2.1 (variable `KIT`, ecran 6) ; les 4 autres
  /// suivent GLOSSAIRE §3. Reste une chaine PURE : le domaine n'importe pas
  /// Flutter, donc pas d'icone ici — l'icone est un choix de presentation, cablee
  /// dans l'ecran de detail (etape 16).
  String get libelleAffichage => switch (this) {
    TypeRessource.cours => 'Cours',
    TypeRessource.resume => 'Resume',
    TypeRessource.exercices => 'Exercices',
    TypeRessource.corrige => 'Corrige detaille',
    TypeRessource.revision => 'Fiche de revision',
    TypeRessource.evaluation => 'Evaluation',
    TypeRessource.corrigeEvaluation => 'Corrige d\'evaluation',
    TypeRessource.sujetExamen => 'Sujet d\'examen',
  };

  /// Convertit une valeur SQL en enum. Parsing STRICT : une valeur hors des 8
  /// prevues leve une erreur, car le schema verrouille deja ces valeurs — un
  /// inconnu est un vrai bug a voir tout de suite, jamais a masquer.
  static TypeRessource depuisValeurSql(String valeur) {
    for (final type in TypeRessource.values) {
      if (type.valeurSql == valeur) return type;
    }
    throw ArgumentError.value(
      valeur,
      'valeur',
      'Type de ressource inconnu (attendu : '
          '${TypeRessource.values.map((t) => t.valeurSql).join(', ')})',
    );
  }
}

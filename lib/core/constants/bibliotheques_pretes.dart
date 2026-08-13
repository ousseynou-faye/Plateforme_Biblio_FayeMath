/// Fait de LANCEMENT (V1) : quelles bibliotheques (couple classe + matiere) sont
/// reellement produites au lancement. Au 13/08/2026, seule la 6e Mathematiques
/// est complete (SPECIFICATIONS_V2 §3.2 et §5.3 : 19 chapitres, 77 fiches).
///
/// Sur l'ecran de choix (etape 14), une matiere AU PROGRAMME mais dont la
/// bibliotheque n'est pas encore prete s'affiche « bientot disponible ». C'est
/// un simple avertissement statique.
///
/// ⚠️ A NE PAS CONFONDRE avec le mecanisme dynamique de « contenu indisponible »
/// de l'etape 15/16 (SPEC §7), qui comptera les VRAIS chapitres une fois
/// produits. Ici, c'est un drapeau de lancement, volontairement separe : les
/// deux ne doivent ni fusionner ni se reutiliser (decision Ousseynou, 13/08/2026).
///
/// ⚠️ A METTRE A JOUR a l'etape 18 des qu'une nouvelle bibliotheque est publiee.
/// C'est le « deuxieme endroit » assume — accepte parce qu'il tient en une seule
/// constante commentee, la ou la source de verite dynamique arrive a l'etape 15/16.
abstract final class BibliothequesPretes {
  // Nom fige de classe -> noms figes des matieres dont la bibliotheque existe.
  // Memes chaines que la migration 07 et que ProgrammeScolaire (accents compris).
  static const Map<String, Set<String>> _pretes = {
    '6e': {'Mathématiques'},
  };

  /// Vrai si la bibliotheque du couple (classe, matiere) est reellement produite
  /// au lancement. Faux sinon -> « bientot disponible » a l'ecran.
  static bool estPrete({
    required String classeNom,
    required String matiereNom,
  }) => _pretes[classeNom]?.contains(matiereNom) ?? false;
}

/// Echec de l'ENREGISTREMENT d'une donnee vers le serveur — par exemple le choix
/// de classe / serie du profil (etape 14).
///
/// Contrairement aux LECTURES, qui sont offline-first et ne considerent jamais
/// l'absence de reseau comme une erreur (docs/CONVENTIONS.md §5), une ECRITURE
/// exige le reseau : son echec est un vrai echec, a signaler a l'eleve. La
/// couche `data/` traduit l'exception technique (Supabase, coupure) en ce type
/// metier ; la couche `presentation/` ne voit jamais l'exception brute.
///
/// Volontairement DISTINCT de `EchecAuthentification` : ce n'est pas un echec
/// d'authentification, et melanger les deux familles rendrait les `switch`
/// d'affichage trompeurs. On n'introduit pas non plus une taxonomie speculative
/// (regle du prompt) : un seul type, avec le drapeau [reseau] qui suffit a
/// choisir le message (« reconnecte-toi » vs « reessaie »).
class EchecEnregistrement implements Exception {
  const EchecEnregistrement({this.reseau = false, this.diagnostic});

  /// Vrai si l'echec vient d'une absence de reseau (message actionnable pour
  /// l'eleve), faux pour une cause technique inattendue.
  final bool reseau;

  /// Detail technique NON sensible, utile a la journalisation (jamais d'id,
  /// d'e-mail ni de jeton — SECURITY.md §5). Souvent `null`.
  final String? diagnostic;

  @override
  String toString() =>
      'EchecEnregistrement(reseau: $reseau'
      '${diagnostic == null ? '' : ', $diagnostic'})';
}

/// La cause d'un echec de telechargement, en cas metier NOMMES — jamais une
/// exception technique brute (dio, Supabase, disque) remontee telle quelle a la
/// couche `presentation/` (docs/CONVENTIONS.md §5).
///
/// Chaque cas correspond a un chemin d'echec REEL du moteur de telechargement
/// (etape 19), pas a une taxonomie speculative : chacun appelle un message
/// distinct cote eleve. Honore en partie la taxonomie annoncee de longue date
/// (`PanneReseau` / `NonAutorise` / `StockagePlein`...), en la limitant ici aux
/// echecs que le telechargement produit vraiment.
enum CauseTelechargement {
  /// Reseau absent ou coupe pendant le transfert. Message actionnable : reessaie
  /// quand tu es connecte. Le hors-ligne n'est pas un bug, c'est un mode normal.
  reseau,

  /// Le serveur a refuse l'acces : ressource premium sans abonnement actif, ou
  /// compte non autorise (la policy Storage tranche cote serveur, migration 06).
  nonAutorise,

  /// Plus assez d'espace de stockage sur l'appareil pour ecrire le fichier.
  stockagePlein,

  /// Le fichier demande est introuvable cote serveur (chemin absent du bucket).
  introuvable,

  /// Cause technique inattendue, non couverte par les cas ci-dessus.
  inattendu,
}

/// Echec du TELECHARGEMENT d'un document vers l'espace prive de l'appareil.
///
/// Volontairement DISTINCT de `EchecEnregistrement` (etape 14) : ce dernier
/// concerne l'ecriture d'une donnee de profil vers le serveur ; melanger les deux
/// familles rendrait les `switch` d'affichage trompeurs. Un telechargement a
/// plusieurs causes d'echec bien differenciees (reseau vs stockage plein vs refus
/// serveur), portees par [cause] plutot que par un simple drapeau booleen.
///
/// La couche `data/` traduit l'exception technique en ce type metier au point
/// unique du repository ; la couche `presentation/` ne voit jamais l'exception
/// brute.
class EchecTelechargement implements Exception {
  const EchecTelechargement(this.cause, {this.diagnostic});

  /// La cause, qui choisit le message montre a l'eleve.
  final CauseTelechargement cause;

  /// Detail technique NON sensible, utile a la journalisation (jamais d'id,
  /// d'e-mail, de jeton ni d'URL signee — SECURITY.md §5). Souvent `null`.
  final String? diagnostic;

  @override
  String toString() =>
      'EchecTelechargement(${cause.name}'
      '${diagnostic == null ? '' : ', $diagnostic'})';
}

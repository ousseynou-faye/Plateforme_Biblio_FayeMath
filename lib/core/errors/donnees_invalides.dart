/// Echec metier : des donnees recues (JSON du serveur ou ligne locale) ne
/// respectent pas la forme attendue — champ manquant, type inattendu, valeur
/// d'enum inconnue.
///
/// La couche data/ leve cette erreur plutot que de laisser remonter une exception
/// technique brute (`TypeError`, cast rate, `ArgumentError` d'un enum) — la couche
/// au-dessus ne voit qu'un echec metier (docs/CONVENTIONS.md §5). La taxonomie
/// complete (`PanneReseau`, `NonAutorise`, `Introuvable`, `StockagePlein`) viendra
/// avec les repositories ; ceci en est le premier maillon, limite a la traduction
/// des donnees de cette etape.
class DonneesInvalides implements Exception {
  const DonneesInvalides(this.message);

  final String message;

  @override
  String toString() => 'DonneesInvalides: $message';
}

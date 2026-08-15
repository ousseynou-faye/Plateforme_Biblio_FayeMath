/// Formate une taille de fichier stockee en OCTETS vers un libelle affichable a
/// l'eleve, en KILOOCTETS (ou MEGAOCTETS au-dela de 1024 Ko).
///
/// Pourquoi ici et pas inline dans le widget : la taille est STOCKEE en octets
/// (`ressource.taille_octets`, GLOSSAIRE §2) mais toujours AFFICHEE en Ko a
/// l'eleve — deux choses differentes. C'est une regle d'affichage pure et
/// testable sans Flutter, elle a donc sa place dans `core/`, pas melangee au
/// widget (point (i), etape 16).
///
/// Le seuil et le format (virgule decimale francaise, 1 chiffre apres la virgule
/// en Mo) reproduisent la fonction `koTxt` de la maquette V2.1, pour que l'app et
/// la maquette affichent la meme chose.
abstract final class TailleFichier {
  static const int _octetsParKo = 1024;
  static const int _koParMo = 1024;

  /// Le libelle affichable, ex. « 144 Ko » ou « 1,5 Mo ».
  ///
  /// Une taille nulle donne « 0 Ko ». Un fichier NON vide n'affiche jamais
  /// « 0 Ko » : on plancher a 1 Ko pour ne pas faire croire a un fichier vide.
  /// Une valeur negative (impossible en pratique) est traitee comme 0.
  static String enTexte(int octets) {
    final octetsSains = octets < 0 ? 0 : octets;
    if (octetsSains == 0) return '0 Ko';

    final ko = (octetsSains / _octetsParKo).round();
    final koAffiche = ko < 1 ? 1 : ko;
    if (koAffiche < _koParMo) return '$koAffiche Ko';

    final mo = octetsSains / (_octetsParKo * _koParMo);
    final texteMo = mo.toStringAsFixed(1).replaceAll('.', ',');
    return '$texteMo Mo';
  }
}

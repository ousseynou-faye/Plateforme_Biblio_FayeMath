/// La convention DETERMINISTE des chemins de fichiers telecharges, en un seul
/// endroit (etape 19, decision 5.3).
///
/// Un document telecharge est range dans un sous-dossier `telechargements/` de
/// l'espace PRIVE de l'application (fourni a l'execution par `path_provider` —
/// jamais un espace public partage du telephone, SECURITY.md §4). Son nom derive
/// UNIQUEMENT du `ressourceId` (un UUID, donc un nom de fichier sur) :
///
///   `<racine privee>/telechargements/<ressourceId>.pdf`         (fichier final)
///   `<racine privee>/telechargements/<ressourceId>.pdf.partiel` (transfert en cours)
///
/// Consequence assumee : la PRESENCE du fichier final sur le disque suffit a
/// repondre « telecharge ou non » — aucun chemin local n'est stocke en base
/// (ni colonne serveur, ni table Drift). Le `.partiel` sert au telechargement
/// ATOMIQUE : on ecrit dedans, puis on le renomme en `.pdf` seulement a la
/// reussite complete ; un `.partiel` orphelin = un transfert interrompu, a
/// nettoyer a la reouverture (contrat hors-ligne, regle 3 — reprise = nouvel
/// essai, pas reprise par octets, justifie par la taille des PDF ~44 Ko).
///
/// Fonctions PURES : elles prennent la racine privee en parametre (pas d'appel a
/// `path_provider` ici), donc testables sans plateforme. Les chemins sont assembles
/// avec `/`, comme la convention `assets/...` deja en place dans le lecteur :
/// la cible V1 est Android uniquement (CLAUDE.md §3).
abstract final class CheminsTelechargement {
  /// Le sous-dossier des documents telecharges, sous la racine privee de l'app.
  static const dossierRelatif = 'telechargements';

  static const _extension = '.pdf';
  static const _suffixePartiel = '.partiel';

  /// Le dossier `.../telechargements` sous la racine privee donnee.
  static String dossier(String racinePriveeApp) =>
      '$racinePriveeApp/$dossierRelatif';

  /// Le chemin du fichier FINAL (present seulement si le telechargement a reussi).
  static String fichierFinal(String racinePriveeApp, String ressourceId) =>
      '${dossier(racinePriveeApp)}/$ressourceId$_extension';

  /// Le chemin du fichier PARTIEL (transfert en cours ; renomme en final a la fin).
  static String fichierPartiel(String racinePriveeApp, String ressourceId) =>
      '${fichierFinal(racinePriveeApp, ressourceId)}$_suffixePartiel';

  /// Vrai si ce chemin Storage designe un PDF EMBARQUE dans l'app (prefixe
  /// `assets/`), lisible directement sans telechargement. Centralise la regle
  /// deja appliquee en ligne par le lecteur (etape 17), pour une seule source.
  static bool estAssetEmbarque(String? cheminStorage) =>
      cheminStorage != null && cheminStorage.startsWith('assets/');

  /// L'inverse de [fichierFinal] : le `ressourceId` porte par un NOM de fichier
  /// (sans dossier), ou `null` si ce nom n'est pas un PDF telecharge complet
  /// (etape 20, pour lister ce qui est sur l'appareil). Fonction PURE : le scan
  /// du dossier est fait ailleurs (couche `data/`), ici on ne fait que decoder
  /// un nom.
  ///
  /// Seuls les fichiers FINAUX comptent : un `<id>.pdf.partiel` (transfert
  /// interrompu) ne se termine pas par `.pdf`, il est donc ecarte — un partiel
  /// n'est pas « sur l'appareil » (ecriture atomique, contrat hors-ligne regle 3).
  static String? ressourceIdDepuisNomFichier(String nomFichier) {
    if (!nomFichier.endsWith(_extension)) return null;
    final id = nomFichier.substring(0, nomFichier.length - _extension.length);
    return id.isEmpty ? null : id;
  }
}

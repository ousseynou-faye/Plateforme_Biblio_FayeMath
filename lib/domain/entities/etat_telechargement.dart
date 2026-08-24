/// L'etat d'un document vis-a-vis de l'appareil, du point de vue du moteur de
/// telechargement (etape 19).
///
/// SPEC §2.4 fige HUIT etats possibles d'une ressource (`local`, `telechargeable`,
/// `en_file`, `en_cours`, `echec`, `indisponible`, `premium`, `obsolete`). Cette
/// etape n'en construit que le SOUS-ENSEMBLE que le moteur produit reellement ;
/// les quatre autres sont hors perimetre (voir la note ci-dessous), pour ne pas
/// coder des etats qu'aucun mecanisme ne peut encore atteindre.
///
/// Ces etats ne sont PAS persistes : la disponibilite locale se lit directement
/// sur le systeme de fichiers (presence du PDF telecharge), l'etat « en cours » /
/// « echec » ne vit qu'en memoire le temps d'une session (etat Riverpod). D'ou
/// l'absence de `valeurSql` ici, contrairement aux enums miroir du serveur
/// (cf. `etat_progression.dart`).
enum EtatTelechargement {
  /// Le document existe cote serveur mais n'est pas encore sur l'appareil : un
  /// tap explicite peut lancer le telechargement (contrat hors-ligne, regle 1).
  telechargeable,

  /// Un telechargement de ce document est en cours (progression 0.0 -> 1.0).
  enCours,

  /// Le document est present sur l'appareil : il s'ouvre dans le lecteur sans
  /// reseau (disponibilite LOCALE, jamais l'etat du reseau — GLOSSAIRE §6).
  local,

  /// Le dernier essai de telechargement a echoue (reseau coupe, stockage plein,
  /// refus serveur...). Etat transitoire : un nouvel essai le quitte.
  echec,

  // --- Hors perimetre de l'etape 19 (SPEC §2.4), volontairement absents -------
  // `en_file`     : suppose un moteur de file d'attente (etape 20).
  // `indisponible`: suppose la detection reseau generale (bandeau, Phase 3).
  // `premium`     : deja porte par le badge (etape 16) + la policy Storage.
  // `obsolete`    : suppose la comparaison de `version` (plus tard).
}

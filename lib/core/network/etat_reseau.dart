/// Les trois etats de reseau affiches par le bandeau du haut (maquette V2.1,
/// SPECIFICATIONS_V2 §2.3). C'est un fait TRANSVERSE (docs/ARCHITECTURE.md §2/§4 :
/// « la detection reseau » est une responsabilite de `core/`), volontairement
/// distinct de la disponibilite d'un document, qui s'affiche ligne par ligne
/// (docs/ARCHITECTURE.md §7, GLOSSAIRE §6). Ne jamais confondre les deux.
///
/// Dart pur : aucun libelle ni couleur ici — l'habillage (texte, teinte, region
/// live d'accessibilite) est du ressort de la couche `presentation/` (Lot D).
enum EtatReseau {
  /// Une interface reseau est active : telechargement possible, synchro active.
  enLigne,

  /// Aucune interface active : lecture locale seulement. Ce n'est PAS une erreur,
  /// c'est un mode de fonctionnement normal (CONVENTIONS §5, contrat hors-ligne).
  horsLigne,

  /// Transitoire : le reseau vient de revenir apres une coupure. Pendant l'etape
  /// 21, cet etat signifie seulement « une resynchronisation en arriere-plan est
  /// en cours » — il ne vide AUCUNE file d'attente d'ecriture (celle-ci n'existe
  /// qu'a l'etape 23). Voir TransitionReseau et DetecteurReseau.
  reconnexion,
}

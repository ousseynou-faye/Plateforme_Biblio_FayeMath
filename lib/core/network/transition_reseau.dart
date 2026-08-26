import 'package:fayemath_academy/core/network/etat_reseau.dart';

/// Deduit l'[EtatReseau] SUIVANT a partir de l'etat precedent et du fait brut
/// « une interface est-elle active ? » remonte par le plugin de connectivite.
///
/// Regle PURE (docs/ARCHITECTURE.md §9) : elle vit dans `core/`, se teste sans
/// Flutter, sans plugin ni minuteur, et centralise en un seul endroit la seule
/// subtilite de la machine a etats — le passage par « reconnexion ».
///
/// La regle :
///   - pas d'interface        -> hors_ligne (quel que soit l'etat precedent) ;
///   - interface, on etait hors_ligne -> reconnexion (transitoire, cf. ci-dessous) ;
///   - interface, on etait deja en ligne (ou en reconnexion) -> en_ligne.
///
/// Autrement dit, on ne retombe en « en_ligne » depuis « hors_ligne » qu'en
/// passant par le transitoire « reconnexion ». Ce transitoire est purge par un
/// minuteur cote [DetecteurReseau] (il n'est pas du ressort d'une regle pure de
/// gerer le temps) ; un nouvel evenement « connecte » recu pendant la reconnexion
/// promeut directement en « en_ligne » (le reseau se confirme).
///
/// ⚠️ L'etat INITIAL au lancement n'est PAS calcule ici : le detecteur amorce
/// directement en_ligne / hors_ligne pour ne pas afficher « Reconnexion... » a
/// chaque ouverture de l'app. Cette fonction ne sert qu'aux TRANSITIONS.
abstract final class TransitionReseau {
  static EtatReseau calculer({
    required EtatReseau precedent,
    required bool connecte,
  }) {
    if (!connecte) return EtatReseau.horsLigne;
    if (precedent == EtatReseau.horsLigne) return EtatReseau.reconnexion;
    return EtatReseau.enLigne;
  }
}

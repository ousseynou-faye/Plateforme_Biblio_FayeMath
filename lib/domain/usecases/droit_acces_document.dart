import 'package:fayemath_academy/domain/entities/abonnement.dart';

/// Ce que l'eleve peut faire d'UN document, ICI ET MAINTENANT. Trois issues
/// NOMMEES (pas un booleen) : le message et l'action a l'ecran ne sont pas les
/// memes pour un invite et pour un connecte sans abonnement — un `bool` obligerait
/// a re-deduire l'information a l'affichage, dans plusieurs ecrans, donc a la
/// re-deduire differemment un jour (decision etape 25, point 5.1).
enum AccesDocument {
  /// Le document est ouvrable/telechargeable : gratuit, ou premium couvert par un
  /// abonnement actif. C'est le seul etat sans cadenas.
  autorise,

  /// Il faut d'abord un COMPTE. Cas de l'invite (« continuer sans compte ») : la
  /// policy Storage (migration 06, `to authenticated`) refuse TOUT telechargement
  /// sans compte, gratuit compris. L'action a l'ecran est « Creer un compte » — le
  /// premium ne le concerne pas encore (reco Ousseynou, point 5.1 / question 3).
  compteRequis,

  /// Connecte, document PREMIUM, aucun abonnement actif. L'action est « Voir
  /// l'offre » (le comparatif riche = ecran 17, etape 26).
  abonnementRequis,
}

/// « Verrouiller les documents premium selon la regle du document 2 » (Feuille de
/// Route doc 04, etape 25). Repond a une seule question : *cet eleve peut-il ouvrir
/// CE document, maintenant ?*
///
/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : vit dans `domain/`, se teste sans
/// Flutter, sans Drift ni Supabase — elle ne recoit que des faits deja resolus par
/// les couches du dessus (le drapeau `premium`, l'etat d'authentification, et
/// l'abonnement local le cas echeant).
///
/// ## Ce qu'elle ne fait PAS
/// Elle ne RECALCULE jamais `premium`. Ce drapeau est derive cote SERVEUR par le
/// trigger `ressource_definir_premium()` (migration 02, `N = 2`, sortie anticipee
/// pour `sujet_examen`) ; l'app le LIT tel quel (CLAUDE.md §4, doc 02 §2.1).
/// Rejouer la regle des « 2 premiers chapitres » en Dart creerait une seconde
/// source de verite, donc un bug futur garanti.
///
/// ## La table de verite (3 profils)
///   - **Invite** (`estConnecte == false`) : `compteRequis` pour TOUT document,
///     gratuit compris — sans compte, rien n'est telechargeable (policy Storage).
///     Le compte est l'obstacle universel, avant meme la question du premium.
///   - **Connecte, document gratuit** : `autorise` — l'abonnement n'y change rien
///     (doc 02 §2.1 : cours/resume/revision gratuits sur tous les chapitres).
///   - **Connecte, document premium** : `autorise` SSI un abonnement couvre le jour
///     ([Abonnement.estActif]) ; sinon `abonnementRequis`.
///
/// ## Hors-ligne (decision point 5.3, patron etape 23)
/// [abonnement] est le dernier etat connu LOCALEMENT ; [maintenant] est l'horloge
/// de l'appareil. Un cache vide (`abonnement == null`) retombe sur « pas
/// d'abonnement » : le pire cas est de reproposer « Voir l'offre » a un abonne dont
/// la synchro n'a pas encore eu lieu — jamais de casser un fichier DEJA present
/// (ce n'est pas ici qu'on ouvre un fichier local : cf. lot E, decision 5.6). Le
/// serveur reste seul juge de la delivrance d'un fichier (defense en profondeur).
abstract final class DroitAccesDocument {
  static AccesDocument evaluer({
    required bool premium,
    required bool estConnecte,
    required Abonnement? abonnement,
    required DateTime maintenant,
  }) {
    // 1) Invite : le compte est l'obstacle universel (policy Storage).
    if (!estConnecte) return AccesDocument.compteRequis;

    // 2) Connecte + gratuit : toujours ouvrable.
    if (!premium) return AccesDocument.autorise;

    // 3) Connecte + premium : autorise seulement si un abonnement couvre le jour.
    final couvert = abonnement != null && abonnement.estActif(maintenant);
    return couvert ? AccesDocument.autorise : AccesDocument.abonnementRequis;
  }
}

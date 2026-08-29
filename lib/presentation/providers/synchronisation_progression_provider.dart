import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/network/limiteur_resynchro.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';

/// Declencheur AUTOMATIQUE de la synchronisation de la progression (etape 23) :
/// au retour du reseau — ou au moment ou l'eleve se connecte alors qu'il est deja
/// en ligne — il demande au repository de vider la file d'attente et de reconcilier
/// local/serveur, SANS que l'eleve n'ait rien a faire (« la file d'attente se vide
/// au retour du reseau », Feuille de Route doc 04).
///
/// C'est un `Provider<void>` « ecouteur » : il n'expose aucune valeur, il installe
/// deux `ref.listen`. On le maintient donc en vie en le `watch`ant UNE fois a la
/// racine (`app.dart`). On garde ainsi `DetecteurReseau` intact dans son seul role
/// (emettre l'etat, etape 21) : la logique de declenchement vit ici, testable,
/// separee de la glue du plugin natif.
///
/// Anti-rafale par [LimiteurResynchro] (60 s, meme brique que l'etape 21) : une
/// bascule reseau et une bascule d'auth rapprochees ne lancent qu'une synchro.
final synchronisationProgressionProvider = Provider<void>((ref) {
  final limiteur = LimiteurResynchro();

  void tenterSynchro() {
    // Reseau : on ne synchronise qu'en ligne (ou pendant la reconnexion). Tant que
    // le flux n'a pas emis (AsyncValue en chargement), `.value` est null -> on
    // s'abstient (c'est le cas des widget-tests, ou le flux reseau est vide).
    final reseau = ref.read(etatReseauProvider).value;
    if (reseau != EtatReseau.enLigne && reseau != EtatReseau.reconnexion) {
      return;
    }

    // Auth : seul un eleve connecte a une progression (RLS `to authenticated`).
    final auth = ref.read(etatAuthProvider);
    if (auth is! AuthConnecte) return;

    final utilisateurId = auth.session.utilisateurId;
    if (!limiteur.doitResynchroniser('progression:$utilisateurId')) return;

    // Best-effort, non bloquant : le repository avale un echec reseau en silence.
    ref
        .read(progressionRepositoryProvider)
        .synchroniser(utilisateurId: utilisateurId);
  }

  // Retour du reseau. `fireImmediately` couvre le lancement de l'app deja en ligne.
  ref.listen(
    etatReseauProvider,
    (_, _) => tenterSynchro(),
    fireImmediately: true,
  );
  // Connexion alors qu'on est deja en ligne (l'etat reseau, lui, ne change pas).
  ref.listen(etatAuthProvider, (_, _) => tenterSynchro());
});

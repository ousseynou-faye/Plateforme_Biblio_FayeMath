import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/core/network/autorisation_telechargement.dart';
import 'package:fayemath_academy/domain/entities/etat_telechargement.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/domain/usecases/resolution_etat_telechargement.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/reglages_provider.dart';

/// Fournit l'implementation du moteur de telechargement. Comme les autres
/// repositories : NON resolue ici (`presentation/` n'importe pas `data/`,
/// docs/ARCHITECTURE.md §3), injectee a la racine (`main.dart`), overridee par un
/// faux en test.
final telechargementRepositoryProvider = Provider<TelechargementRepository>(
  (ref) => throw UnimplementedError(
    'telechargementRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// La vue d'un document du point de vue du telechargement, pour l'ecran (Lot E).
/// L'[etat] expose n'est jamais fixe a la main : il est DERIVE de trois faits par
/// le resolveur du Lot A, pour que la priorite des etats vive en un seul endroit
/// teste.
class VueTelechargement {
  const VueTelechargement({
    this.estLocal = false,
    this.enCours = false,
    this.aEchoue = false,
    this.progression = 0,
    this.cause,
    this.cheminLocal,
    this.bloqueDonneesMobiles = false,
  });

  /// Le PDF telecharge est present sur l'appareil.
  final bool estLocal;

  /// Un transfert de ce document tourne en ce moment.
  final bool enCours;

  /// Le dernier essai a echoue.
  final bool aEchoue;

  /// Progression du transfert (0.0 -> 1.0), pertinente quand [enCours].
  final double progression;

  /// Cause de l'echec, renseignee quand [aEchoue] (choisit le message a l'ecran).
  final CauseTelechargement? cause;

  /// Chemin local du fichier, renseigne quand [estLocal] (le lecteur l'ouvre).
  final String? cheminLocal;

  /// Le dernier appui sur « Telecharger » a ete BLOQUE par le reglage « Wi-Fi
  /// uniquement » alors qu'on etait en donnees mobiles (lot « Qualite D »). N'est
  /// PAS un echec de transfert (aucun transfert n'a demarre) : l'etat reste
  /// `telechargeable`, ce drapeau dit juste a l'ecran d'afficher le message
  /// « passe en Wi-Fi ou change le reglage ». Efface au prochain essai reussi.
  final bool bloqueDonneesMobiles;

  /// L'etat unique, derive des trois faits (resolveur du Lot A). Le blocage
  /// « Wi-Fi uniquement » n'en fait pas partie (le document reste telechargeable).
  EtatTelechargement get etat => ResolutionEtatTelechargement.resoudre(
    estLocal: estLocal,
    enCours: enCours,
    aEchoue: aEchoue,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VueTelechargement &&
          other.estLocal == estLocal &&
          other.enCours == enCours &&
          other.aEchoue == aEchoue &&
          other.progression == progression &&
          other.cause == cause &&
          other.cheminLocal == cheminLocal &&
          other.bloqueDonneesMobiles == bloqueDonneesMobiles;

  @override
  int get hashCode => Object.hash(
    estLocal,
    enCours,
    aEchoue,
    progression,
    cause,
    cheminLocal,
    bloqueDonneesMobiles,
  );
}

/// L'etat des telechargements, une [VueTelechargement] par `ressourceId`. Un seul
/// notifier tient la table ; l'ecran lit SA ressource via [vueTelechargementProvider]
/// (qui ne le reconstruit que si SA vue change).
///
/// Rien ne se telecharge sans un appel EXPLICITE a [demarrer] (contrat hors-ligne,
/// regle 1) ; a la reouverture de l'app, l'etat repart de zero et une simple
/// verification disque dit ce qui est deja la — jamais un re-telechargement
/// automatique (regle 1 prime sur la « reprise » de la regle 3, decision 5.1).
class TelechargementNotifier extends Notifier<Map<String, VueTelechargement>> {
  final _abonnements = <String, StreamSubscription<double>>{};

  @override
  Map<String, VueTelechargement> build() {
    // Tout transfert en vol est coupe si le notifier disparait (rien en fond).
    ref.onDispose(() {
      for (final abonnement in _abonnements.values) {
        abonnement.cancel();
      }
      _abonnements.clear();
    });
    return const {};
  }

  VueTelechargement _de(String ressourceId) =>
      state[ressourceId] ?? const VueTelechargement();

  void _publier(String ressourceId, VueTelechargement vue) {
    state = {...state, ressourceId: vue};
  }

  /// Verifie si le document est deja sur l'appareil (lecture disque). Appelee par
  /// l'ecran a l'ouverture ; ne relance jamais un telechargement.
  Future<void> verifierPresence(String ressourceId) async {
    final actuel = _de(ressourceId);
    if (actuel.enCours || actuel.estLocal) return;
    final chemin = await ref
        .read(telechargementRepositoryProvider)
        .cheminLocalSiPresent(ressourceId);
    // Un telechargement a pu demarrer pendant la lecture disque : ne pas l'ecraser.
    if (_de(ressourceId).enCours) return;
    _publier(
      ressourceId,
      chemin != null
          ? VueTelechargement(estLocal: true, cheminLocal: chemin)
          : const VueTelechargement(),
    );
  }

  /// Lance le telechargement d'un document — action EXPLICITE de l'eleve. Sans
  /// effet si le document est deja la ou deja en cours.
  ///
  /// Verrou « Wi-Fi uniquement » (lot « Qualite D ») : si le reglage est actif et
  /// qu'on est en donnees mobiles, on NE demarre PAS — on publie un etat
  /// « bloque » pour que l'ecran invite a passer en Wi-Fi ou a changer le reglage.
  /// La lecture du type d'interface est asynchrone (d'ou le `Future`), mais
  /// l'appel reste « fire-and-forget » cote ecran (rien a attendre).
  Future<void> demarrer(Ressource ressource) async {
    final id = ressource.id;
    final actuel = _de(id);
    if (actuel.enCours || actuel.estLocal) return;

    // Verrou premium (etape 25) : refus LOCAL avant tout appel reseau. Un document
    // auquel l'eleve n'a pas droit (invite, ou premium sans abonnement actif) ne
    // consomme AUCUN octet — l'ecran affiche deja l'etat verrouille (« Voir
    // l'offre » / « Creer un compte »), ce garde-fou couvre les cas ou `demarrer`
    // serait appele quand meme. Le serveur (policy Storage) reste le filet en cas
    // de desynchronisation. Un document deja LOCAL est ouvert plus haut (decision
    // 5.6) : il n'atteint jamais ce point.
    if (ref.read(accesDocumentProvider(ressource.premium)) !=
        AccesDocument.autorise) {
      return;
    }

    final wifiSeulement = ref.read(telechargerEnWifiSeulementProvider);
    final interface = await ref.read(interfaceReseauProvider)();
    if (AutorisationTelechargement.decider(
          wifiSeulement: wifiSeulement,
          interface: interface,
        ) ==
        DecisionTelechargement.bloqueDonneesMobiles) {
      _publier(id, const VueTelechargement(bloqueDonneesMobiles: true));
      return;
    }
    // L'etat a pu changer pendant la lecture asynchrone de l'interface.
    final apres = _de(id);
    if (apres.enCours || apres.estLocal) return;

    _publier(id, const VueTelechargement(enCours: true));
    _abonnements[id] = ref
        .read(telechargementRepositoryProvider)
        .telecharger(ressource)
        .listen(
          (progression) => _publier(
            id,
            VueTelechargement(enCours: true, progression: progression),
          ),
          onError: (Object erreur) {
            _abonnements.remove(id);
            final cause = erreur is EchecTelechargement
                ? erreur.cause
                : CauseTelechargement.inattendu;
            _publier(id, VueTelechargement(aEchoue: true, cause: cause));
          },
          onDone: () {
            _abonnements.remove(id);
            unawaited(_finaliser(id));
          },
          // Une erreur termine le transfert : pas de onDone derriere qui
          // ecraserait la cause de l'echec.
          cancelOnError: true,
        );
  }

  /// A la fin du transfert, relit le disque pour recuperer le chemin final et
  /// passer a l'etat « local » (le fichier vient d'y etre renomme atomiquement).
  Future<void> _finaliser(String ressourceId) async {
    if (!_de(ressourceId).enCours) return; // annule / echec entre-temps
    final chemin = await ref
        .read(telechargementRepositoryProvider)
        .cheminLocalSiPresent(ressourceId);
    _publier(
      ressourceId,
      chemin != null
          ? VueTelechargement(estLocal: true, cheminLocal: chemin)
          : const VueTelechargement(
              aEchoue: true,
              cause: CauseTelechargement.inattendu,
            ),
    );
  }

  /// Annule un telechargement en cours (l'eleve renonce). Nettoie le fichier
  /// partiel via l'annulation du flux, et remet le document a « telechargeable ».
  void annuler(String ressourceId) {
    _abonnements.remove(ressourceId)?.cancel();
    _publier(ressourceId, const VueTelechargement());
  }
}

final telechargementProvider =
    NotifierProvider<TelechargementNotifier, Map<String, VueTelechargement>>(
      TelechargementNotifier.new,
    );

/// La vue d'UNE ressource, selectionnee dans la table. Un consommateur de
/// `vueTelechargementProvider(id)` n'est reconstruit que si SA vue change
/// (egalite de valeur sur [VueTelechargement]).
final vueTelechargementProvider = Provider.family<VueTelechargement, String>(
  (ref, ressourceId) =>
      ref.watch(telechargementProvider)[ressourceId] ??
      const VueTelechargement(),
);

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/network/transition_reseau.dart';
import 'package:fayemath_academy/core/network/type_interface_reseau.dart';

/// Lecture ONE-SHOT du type d'interface reseau courant (lot « Qualite D » :
/// decision « telecharger uniquement en Wi-Fi »), sans demarrer de flux. Vit dans
/// `core/` comme toute la detection reseau (docs/ARCHITECTURE.md §3/§4). Meme
/// limite assumee que [DetecteurReseau] : type d'interface, pas joignabilite.
Future<TypeInterfaceReseau> interfaceReseauCourante([
  Connectivity? connectivity,
]) async => TypeInterfaceReseau.depuis(
  await (connectivity ?? Connectivity()).checkConnectivity(),
);

/// Source de verite unique sur l'etat du reseau, exposee en un flux d'[EtatReseau]
/// (docs/ARCHITECTURE.md §2/§4 : « la detection reseau » vit dans `core/`).
///
/// C'est une glue MINCE autour de `connectivity_plus` : le plugin rapporte le TYPE
/// d'interface active (wifi / donnees mobiles / aucune), pas une vraie joignabilite
/// d'Internet — decision assumee pour la V1 (un wifi sans acces reel reste vu « en
/// ligne » ; ce cas residuel est de toute facon rattrape par l'echec silencieux de
/// chaque resynchro offline-first). Toute la logique testable est deportee dans
/// [TransitionReseau] ; ce fichier n'est verifie que sur appareil (comme `pdfx`),
/// car il depend d'un plugin natif.
class DetecteurReseau {
  DetecteurReseau({Connectivity? connectivity, Duration? dureeReconnexion})
    : _connectivity = connectivity ?? Connectivity(),
      _dureeReconnexion = dureeReconnexion ?? const Duration(seconds: 2);

  final Connectivity _connectivity;

  /// Duree pendant laquelle « Reconnexion... » reste affiche avant de basculer en
  /// « En ligne » si le reseau tient. Transitoire purement visuel (SPEC §2.3).
  final Duration _dureeReconnexion;

  late final StreamController<EtatReseau> _sortie =
      StreamController<EtatReseau>.broadcast(
        onListen: _demarrer,
        onCancel: _arreter,
      );

  StreamSubscription<List<ConnectivityResult>>? _abonnement;
  Timer? _minuteurReconnexion;
  EtatReseau _courant = EtatReseau.horsLigne;

  /// Le flux des etats reseau. La premiere valeur est l'etat courant amorce
  /// directement (jamais « reconnexion »), puis chaque changement d'interface.
  Stream<EtatReseau> get flux => _sortie.stream;

  Future<void> _demarrer() async {
    // Etat INITIAL sans passer par le transitoire : au lancement on affiche
    // directement en_ligne / hors_ligne (cf. TransitionReseau, note finale).
    final initial = await _connectivity.checkConnectivity();
    if (_sortie.isClosed) return;
    _courant = _estConnecte(initial)
        ? EtatReseau.enLigne
        : EtatReseau.horsLigne;
    _sortie.add(_courant);

    _abonnement = _connectivity.onConnectivityChanged.listen((resultats) {
      _appliquer(
        TransitionReseau.calculer(
          precedent: _courant,
          connecte: _estConnecte(resultats),
        ),
      );
    });
  }

  void _appliquer(EtatReseau suivant) {
    _minuteurReconnexion?.cancel();
    _courant = suivant;
    if (_sortie.isClosed) return;
    _sortie.add(suivant);

    if (suivant == EtatReseau.reconnexion) {
      // « Reconnexion... » est transitoire : apres un court delai, si le reseau
      // tient, on bascule en « En ligne ». Le vidage de la file d'attente
      // d'ecriture de la progression (etape 23) N'est PAS declenche ici : ce
      // detecteur garde son seul role (emettre l'etat, non testable car plugin
      // natif). C'est `synchronisationProgressionProvider` qui ecoute ce meme
      // retour de reseau et lance la synchro — logique deportee la ou elle est
      // testable (cf. le triptyque de l'etape 21).
      _minuteurReconnexion = Timer(_dureeReconnexion, () {
        if (_courant == EtatReseau.reconnexion && !_sortie.isClosed) {
          _courant = EtatReseau.enLigne;
          _sortie.add(EtatReseau.enLigne);
        }
      });
    }
  }

  void _arreter() {
    _abonnement?.cancel();
    _abonnement = null;
    _minuteurReconnexion?.cancel();
    _minuteurReconnexion = null;
  }

  /// Une interface est active des qu'un resultat n'est pas « aucune » (le plugin
  /// peut renvoyer plusieurs interfaces, ou une liste vide = hors_ligne).
  static bool _estConnecte(List<ConnectivityResult> resultats) =>
      resultats.any((resultat) => resultat != ConnectivityResult.none);

  /// Coupe l'ecoute et ferme le flux. Appele par le provider a la destruction.
  Future<void> liberer() async {
    _arreter();
    await _sortie.close();
  }
}

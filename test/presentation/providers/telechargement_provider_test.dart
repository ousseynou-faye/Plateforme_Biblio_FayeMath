import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/core/network/type_interface_reseau.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/etat_telechargement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/repositories/preferences_reglages_repository.dart';
import 'package:fayemath_academy/domain/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';
import 'package:fayemath_academy/presentation/providers/reglages_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';

/// Faux moteur : notre propre contrat, trivial a imiter. Un `StreamController`
/// joue le transfert, un champ mutable joue la presence sur le disque.
class _FauxTelechargementRepository implements TelechargementRepository {
  String? cheminSurDisque;
  final controleur = StreamController<double>.broadcast();

  @override
  Future<String?> cheminLocalSiPresent(String ressourceId) async =>
      cheminSurDisque;

  @override
  Stream<double> telecharger(Ressource ressource) => controleur.stream;

  // Non exercees par les tests de ce provider (liste/suppression = ecran 8).
  @override
  Future<List<Ressource>> listerPresents() async => const [];

  @override
  Future<void> supprimer(String ressourceId) async {}
}

/// Faux reglages en memoire (le verrou « Wi-Fi uniquement » lit ce contrat).
class _FauxReglages implements PreferencesReglagesRepository {
  _FauxReglages(this.wifiSeulement);

  bool wifiSeulement;

  @override
  Future<bool> telechargerEnWifiSeulement() async => wifiSeulement;

  @override
  Future<void> definirTelechargerEnWifiSeulement({required bool valeur}) async {
    wifiSeulement = valeur;
  }
}

/// Faux abonnement : renvoie l'abonnement fourni (ou null).
class _FauxAbonnementRepository implements AbonnementRepository {
  _FauxAbonnementRepository(this.abonnement);

  final Abonnement? abonnement;

  @override
  Stream<Abonnement?> observerAbonnement(String utilisateurId) =>
      Stream.value(abonnement);
}

/// Etat d'authentification fige (evite d'imiter tout le contrat AuthRepository).
class _EtatAuthFixe extends EtatAuthNotifier {
  _EtatAuthFixe(this._initial);

  final EtatAuth _initial;

  @override
  EtatAuth build() => _initial;
}

/// Une ressource minimale pour les tests (un cours de chapitre, gratuit).
Ressource _ressource(String id) => Ressource(
  id: id,
  chapitreId: 'c1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.cours,
  titre: 'Cours',
  tailleOctets: 44 * 1024,
  premium: false,
  version: 1,
  cheminStorage: '6e/mathematiques/01/cours.pdf',
  ordre: 1,
);

/// Une ressource premium (un corrige) pour les tests du verrou d'acces.
Ressource _ressourcePremium(String id) => Ressource(
  id: id,
  chapitreId: 'c1',
  classeId: null,
  matiereId: null,
  type: TypeRessource.corrige,
  titre: 'Corrige',
  tailleOctets: 60 * 1024,
  premium: true,
  version: 1,
  cheminStorage: '6e/mathematiques/01/corrige.pdf',
  ordre: 4,
);

Abonnement _abonnementActif() => Abonnement(
  id: 'a1',
  utilisateurId: 'u1',
  formule: FormuleAbonnement.mensuel,
  dateDebut: DateTime(2026, 1, 1),
  dateFin: DateTime.now().add(const Duration(days: 30)),
  referencePaiement: null,
);

/// Laisse tourner les microtaches pour que le flux / les futures delivrent.
Future<void> laisserDelivrer() => Future<void>.delayed(Duration.zero);

void main() {
  ProviderContainer creerContainer(
    TelechargementRepository repository, {
    bool wifiSeulement = false,
    TypeInterfaceReseau interface = TypeInterfaceReseau.wifi,
    // Verrou premium (etape 25) : par defaut un eleve CONNECTE sans abonnement.
    // Pour un document gratuit, cela donne « autorise » -> les tests existants
    // restent inchanges.
    EtatAuth etat = const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
    Abonnement? abonnement,
  }) {
    final container = ProviderContainer(
      overrides: [
        telechargementRepositoryProvider.overrideWithValue(repository),
        // Verrou « Wi-Fi uniquement » (lot « Qualite D ») : par defaut on ne
        // bloque pas (interface Wi-Fi), les tests existants restent inchanges.
        preferencesReglagesRepositoryProvider.overrideWithValue(
          _FauxReglages(wifiSeulement),
        ),
        interfaceReseauProvider.overrideWithValue(() async => interface),
        etatAuthProvider.overrideWith(() => _EtatAuthFixe(etat)),
        abonnementRepositoryProvider.overrideWithValue(
          _FauxAbonnementRepository(abonnement),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Garde la vue de r1 et le flux d'abonnement actifs pendant le test.
    container.listen(vueTelechargementProvider('r1'), (_, _) {});
    container.listen(abonnementPremiumProvider, (_, _) {});
    return container;
  }

  group('verifierPresence', () {
    test('disque vide -> telechargeable', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(faux);

      await container
          .read(telechargementProvider.notifier)
          .verifierPresence('r1');
      await laisserDelivrer();

      final vue = container.read(vueTelechargementProvider('r1'));
      expect(vue.etat, EtatTelechargement.telechargeable);
      expect(vue.cheminLocal, isNull);
    });

    test('fichier deja present -> local, avec le chemin', () async {
      final faux = _FauxTelechargementRepository()
        ..cheminSurDisque = '/prive/telechargements/r1.pdf';
      final container = creerContainer(faux);

      await container
          .read(telechargementProvider.notifier)
          .verifierPresence('r1');
      await laisserDelivrer();

      final vue = container.read(vueTelechargementProvider('r1'));
      expect(vue.etat, EtatTelechargement.local);
      expect(vue.cheminLocal, '/prive/telechargements/r1.pdf');
    });
  });

  group('demarrer', () {
    test('progresse puis passe local quand le fichier est arrive', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(faux);

      // demarrer est asynchrone (il lit d'abord le type d'interface pour le verrou
      // Wi-Fi) : on l'attend avant de verifier l'etat « en cours ».
      await container
          .read(telechargementProvider.notifier)
          .demarrer(_ressource('r1'));
      expect(
        container.read(vueTelechargementProvider('r1')).etat,
        EtatTelechargement.enCours,
      );

      faux.controleur.add(0.5);
      await laisserDelivrer();
      final enCours = container.read(vueTelechargementProvider('r1'));
      expect(enCours.etat, EtatTelechargement.enCours);
      expect(enCours.progression, 0.5);

      // Le transfert se termine : le fichier est desormais sur le disque.
      faux.cheminSurDisque = '/prive/telechargements/r1.pdf';
      await faux.controleur.close();
      await laisserDelivrer();
      await laisserDelivrer();

      final fini = container.read(vueTelechargementProvider('r1'));
      expect(fini.etat, EtatTelechargement.local);
      expect(fini.cheminLocal, '/prive/telechargements/r1.pdf');
    });

    test('une erreur du flux -> echec, avec la cause portee', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(faux);

      await container
          .read(telechargementProvider.notifier)
          .demarrer(_ressource('r1'));
      faux.controleur.addError(
        const EchecTelechargement(CauseTelechargement.reseau),
      );
      await laisserDelivrer();

      final vue = container.read(vueTelechargementProvider('r1'));
      expect(vue.etat, EtatTelechargement.echec);
      expect(vue.cause, CauseTelechargement.reseau);
    });

    test('reglage Wi-Fi actif + donnees mobiles : bloque, aucun transfert', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(
        faux,
        wifiSeulement: true,
        interface: TypeInterfaceReseau.donneesMobiles,
      );

      await container
          .read(telechargementProvider.notifier)
          .demarrer(_ressource('r1'));

      final vue = container.read(vueTelechargementProvider('r1'));
      // Bloque : pas d'echec de transfert, le document reste telechargeable, mais
      // le drapeau dit a l'ecran d'expliquer le blocage.
      expect(vue.bloqueDonneesMobiles, isTrue);
      expect(vue.etat, EtatTelechargement.telechargeable);
      // Le moteur n'a pas ete sollicite (aucun abonnement au flux).
      expect(faux.controleur.hasListener, isFalse);
    });

    test(
      'document premium sans abonnement : refuse localement, aucun transfert',
      () async {
        final faux = _FauxTelechargementRepository();
        final container = creerContainer(faux); // connecte, pas d'abonnement

        await container
            .read(telechargementProvider.notifier)
            .demarrer(_ressourcePremium('r1'));

        final vue = container.read(vueTelechargementProvider('r1'));
        expect(vue.etat, EtatTelechargement.telechargeable); // pas « en cours »
        expect(faux.controleur.hasListener, isFalse); // moteur jamais sollicite
      },
    );

    test(
      'document premium AVEC abonnement actif : le transfert demarre',
      () async {
        final faux = _FauxTelechargementRepository();
        final container = creerContainer(faux, abonnement: _abonnementActif());
        // Attendre la premiere emission de l'abonnement (sinon la vue est null).
        await container.read(abonnementPremiumProvider.future);

        await container
            .read(telechargementProvider.notifier)
            .demarrer(_ressourcePremium('r1'));

        expect(
          container.read(vueTelechargementProvider('r1')).etat,
          EtatTelechargement.enCours,
        );
      },
    );

    test('invite : refuse localement, aucun transfert', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(faux, etat: const AuthInvite());

      await container
          .read(telechargementProvider.notifier)
          .demarrer(_ressource('r1'));

      expect(
        container.read(vueTelechargementProvider('r1')).etat,
        EtatTelechargement.telechargeable,
      );
      expect(faux.controleur.hasListener, isFalse);
    });
  });

  group('annuler', () {
    test('remet un telechargement en cours a telechargeable', () async {
      final faux = _FauxTelechargementRepository();
      final container = creerContainer(faux);
      final notifier = container.read(telechargementProvider.notifier);

      await notifier.demarrer(_ressource('r1'));
      expect(
        container.read(vueTelechargementProvider('r1')).etat,
        EtatTelechargement.enCours,
      );

      notifier.annuler('r1');
      await laisserDelivrer();

      expect(
        container.read(vueTelechargementProvider('r1')).etat,
        EtatTelechargement.telechargeable,
      );
    });
  });
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/formulaire_auth_provider.dart';

/// Faux repository : notre propre contrat, trivial a imiter (au contraire de
/// `GoTrueClient`). Un `StreamController` joue le flux de session.
class _FauxAuthRepository implements AuthRepository {
  _FauxAuthRepository({this.echecASoulever, SessionAuth? sessionInitiale})
    : _courante = sessionInitiale;

  final EchecAuthentification? echecASoulever;
  final _controleur = StreamController<SessionAuth?>.broadcast();
  SessionAuth? _courante;

  @override
  SessionAuth? get sessionCourante => _courante;

  @override
  Stream<SessionAuth?> get changementsSession => _controleur.stream;

  @override
  Future<void> sInscrire({
    required String email,
    required String motDePasse,
  }) async {
    if (echecASoulever != null) throw echecASoulever!;
  }

  @override
  Future<void> seConnecter({
    required String email,
    required String motDePasse,
  }) async {
    if (echecASoulever != null) throw echecASoulever!;
    emettre(const SessionAuth(utilisateurId: 'u1'));
  }

  @override
  Future<void> seDeconnecter() async => emettre(null);

  void emettre(SessionAuth? session) {
    _courante = session;
    _controleur.add(session);
  }

  void fermer() => _controleur.close();
}

/// Laisse tourner la microtache pour que le flux delivre son evenement.
Future<void> laisserLeFluxDelivrer() => Future<void>.delayed(Duration.zero);

void main() {
  ProviderContainer creerContainer(AuthRepository repository) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    // Garde etatAuthProvider actif (donc abonne au flux) pendant le test.
    container.listen(etatAuthProvider, (_, _) {});
    return container;
  }

  group('etatAuthProvider', () {
    test('deconnecte au demarrage quand aucune session', () {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      expect(container.read(etatAuthProvider), isA<AuthDeconnecte>());
    });

    test('connecte au demarrage quand une session existe deja', () {
      final faux = _FauxAuthRepository(
        sessionInitiale: const SessionAuth(utilisateurId: 'u1'),
      );
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      expect(container.read(etatAuthProvider), isA<AuthConnecte>());
    });

    test('passe connecte quand le flux emet une session', () async {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      faux.emettre(const SessionAuth(utilisateurId: 'u1'));
      await laisserLeFluxDelivrer();

      expect(container.read(etatAuthProvider), isA<AuthConnecte>());
    });

    test('continuerSansCompte passe en mode invite', () {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      container.read(etatAuthProvider.notifier).continuerSansCompte();

      expect(container.read(etatAuthProvider), isA<AuthInvite>());
    });

    test('une emission null n\'ejecte pas un invite', () async {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      container.read(etatAuthProvider.notifier).continuerSansCompte();
      faux.emettre(null);
      await laisserLeFluxDelivrer();

      expect(container.read(etatAuthProvider), isA<AuthInvite>());
    });

    test('deconnexion (flux -> null) ramene a deconnecte', () async {
      final faux = _FauxAuthRepository(
        sessionInitiale: const SessionAuth(utilisateurId: 'u1'),
      );
      addTearDown(faux.fermer);
      final container = creerContainer(faux);
      expect(container.read(etatAuthProvider), isA<AuthConnecte>());

      faux.emettre(null);
      await laisserLeFluxDelivrer();

      expect(container.read(etatAuthProvider), isA<AuthDeconnecte>());
    });
  });

  group('formulaireAuthProvider', () {
    test('ouvre en mode inscription', () {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      expect(container.read(formulaireAuthProvider).mode, ModeAuth.inscription);
      expect(
        container.read(formulaireAuthProvider).statut,
        isA<SoumissionPrete>(),
      );
    });

    test('basculerMode alterne inscription et connexion', () {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);
      final notifier = container.read(formulaireAuthProvider.notifier);

      notifier.basculerMode();
      expect(container.read(formulaireAuthProvider).mode, ModeAuth.connexion);

      notifier.basculerMode();
      expect(container.read(formulaireAuthProvider).mode, ModeAuth.inscription);
    });

    test('inscription reussie -> InscriptionAConfirmer', () async {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);

      await container
          .read(formulaireAuthProvider.notifier)
          .soumettre(email: 'awa@example.com', motDePasse: 'motdepasse1');

      expect(
        container.read(formulaireAuthProvider).statut,
        isA<InscriptionAConfirmer>(),
      );
    });

    test('connexion en echec -> SoumissionEchouee porte l\'echec', () async {
      final faux = _FauxAuthRepository(
        echecASoulever: const IdentifiantsInvalides(),
      );
      addTearDown(faux.fermer);
      final container = creerContainer(faux);
      container
          .read(formulaireAuthProvider.notifier)
          .basculerMode(); // connexion

      await container
          .read(formulaireAuthProvider.notifier)
          .soumettre(email: 'awa@example.com', motDePasse: 'faux');

      final statut = container.read(formulaireAuthProvider).statut;
      expect(statut, isA<SoumissionEchouee>());
      expect((statut as SoumissionEchouee).echec, isA<IdentifiantsInvalides>());
    });

    test('connexion reussie -> formulaire relache (SoumissionPrete)', () async {
      final faux = _FauxAuthRepository();
      addTearDown(faux.fermer);
      final container = creerContainer(faux);
      container
          .read(formulaireAuthProvider.notifier)
          .basculerMode(); // connexion

      await container
          .read(formulaireAuthProvider.notifier)
          .soumettre(email: 'awa@example.com', motDePasse: 'motdepasse1');

      expect(
        container.read(formulaireAuthProvider).statut,
        isA<SoumissionPrete>(),
      );
    });
  });
}

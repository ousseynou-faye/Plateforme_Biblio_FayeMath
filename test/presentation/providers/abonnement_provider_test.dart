import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Faux repository : renvoie un abonnement fixe et retient l'id demande (pour
/// verifier que le provider n'interroge le repo QUE pour un compte connecte).
class _FauxAbonnementRepo implements AbonnementRepository {
  _FauxAbonnementRepo(this.abonnement);

  final Abonnement? abonnement;
  String? utilisateurDemande;

  @override
  Stream<Abonnement?> observerAbonnement(String utilisateurId) {
    utilisateurDemande = utilisateurId;
    return Stream.value(abonnement);
  }
}

/// Etat d'authentification fige, pour override sans passer par un vrai repo auth.
class _EtatAuthFixe extends EtatAuthNotifier {
  _EtatAuthFixe(this._initial);

  final EtatAuth _initial;

  @override
  EtatAuth build() => _initial;
}

void main() {
  Abonnement abonnement({required DateTime dateFin}) => Abonnement(
    id: 'a1',
    utilisateurId: 'u1',
    formule: FormuleAbonnement.mensuel,
    dateDebut: DateTime(2026, 1, 1),
    dateFin: dateFin,
    referencePaiement: null,
  );

  // Construit un container et ACTIVE le flux d'abonnement (un StreamProvider ne
  // s'abonne a sa source qu'avec un ecouteur, cf. auth_provider_test).
  ({ProviderContainer container, _FauxAbonnementRepo repo}) creer({
    required EtatAuth etat,
    Abonnement? abo,
  }) {
    final repo = _FauxAbonnementRepo(abo);
    final container = ProviderContainer(
      overrides: [
        etatAuthProvider.overrideWith(() => _EtatAuthFixe(etat)),
        abonnementRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    container.listen(abonnementPremiumProvider, (_, _) {});
    return (container: container, repo: repo);
  }

  group('abonnementPremiumProvider', () {
    test('invite -> null, le repository n\'est pas interroge', () async {
      // On fournit un abonnement : il ne doit PAS etre renvoye (repo jamais appele).
      final (:container, :repo) = creer(
        etat: const AuthInvite(),
        abo: abonnement(dateFin: DateTime(2026, 12, 31)),
      );

      final resultat = await container.read(abonnementPremiumProvider.future);
      expect(resultat, isNull);
      expect(repo.utilisateurDemande, isNull);
    });

    test('connecte -> interroge le repo avec l\'id de la session', () async {
      final abo = abonnement(dateFin: DateTime(2026, 12, 31));
      final (:container, :repo) = creer(
        etat: const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
        abo: abo,
      );

      final resultat = await container.read(abonnementPremiumProvider.future);
      expect(resultat, abo);
      expect(repo.utilisateurDemande, 'u1');
    });
  });

  group('accesDocumentProvider (branchement auth x abonnement x regle)', () {
    Future<AccesDocument> acces(
      ProviderContainer container, {
      required bool premium,
    }) async {
      // Force la premiere emission du flux d'abonnement avant la lecture
      // synchrone de la regle.
      await container.read(abonnementPremiumProvider.future);
      return container.read(accesDocumentProvider(premium));
    }

    test('invite + premium -> compteRequis', () async {
      final (:container, repo: _) = creer(etat: const AuthInvite());
      expect(await acces(container, premium: true), AccesDocument.compteRequis);
    });

    test('connecte + gratuit -> autorise', () async {
      final (:container, repo: _) = creer(
        etat: const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
      );
      expect(await acces(container, premium: false), AccesDocument.autorise);
    });

    test('connecte + premium, sans abonnement -> abonnementRequis', () async {
      final (:container, repo: _) = creer(
        etat: const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
      );
      expect(
        await acces(container, premium: true),
        AccesDocument.abonnementRequis,
      );
    });

    test('connecte + premium, abonnement actif -> autorise', () async {
      final (:container, repo: _) = creer(
        etat: const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
        abo: abonnement(dateFin: DateTime.now().add(const Duration(days: 30))),
      );
      expect(await acces(container, premium: true), AccesDocument.autorise);
    });

    test('connecte + premium, abonnement expire -> abonnementRequis', () async {
      final (:container, repo: _) = creer(
        etat: const AuthConnecte(SessionAuth(utilisateurId: 'u1')),
        abo: abonnement(
          dateFin: DateTime.now().subtract(const Duration(days: 2)),
        ),
      );
      expect(
        await acces(container, premium: true),
        AccesDocument.abonnementRequis,
      );
    });
  });
}

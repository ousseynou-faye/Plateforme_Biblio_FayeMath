import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/entities/session_auth.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/reinitialisation_provider.dart';

/// Faux repository d'auth : enregistre les appels du sous-flux et peut faire
/// echouer chaque etape (echec deja traduit, comme le ferait la couche data).
class _FauxAuthRepository implements AuthRepository {
  EchecAuthentification? echecDemander;
  EchecAuthentification? echecCode;
  EchecAuthentification? echecDefinir;
  final List<String> appels = [];

  @override
  SessionAuth? get sessionCourante => null;
  @override
  Stream<SessionAuth?> get changementsSession => const Stream.empty();
  @override
  Future<void> sInscrire({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seConnecter({
    required String email,
    required String motDePasse,
  }) async {}
  @override
  Future<void> seDeconnecter() async => appels.add('seDeconnecter');

  @override
  Future<void> demanderReinitialisation({required String email}) async {
    appels.add('demander');
    if (echecDemander != null) throw echecDemander!;
  }

  @override
  Future<void> verifierCodeReinitialisation({
    required String email,
    required String code,
  }) async {
    appels.add('verifier');
    if (echecCode != null) throw echecCode!;
  }

  @override
  Future<void> definirNouveauMotDePasse({required String motDePasse}) async {
    appels.add('definir');
    if (echecDefinir != null) throw echecDefinir!;
  }
}

void main() {
  ProviderContainer creerContainer(AuthRepository repository) {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    container.listen(reinitialisationProvider, (_, _) {});
    return container;
  }

  ReinitialisationNotifier notifier(ProviderContainer c) =>
      c.read(reinitialisationProvider.notifier);
  EtatReinit etat(ProviderContainer c) => c.read(reinitialisationProvider);

  group('reinitialisationProvider', () {
    test('inactif au demarrage', () {
      final c = creerContainer(_FauxAuthRepository());
      expect(etat(c).actif, isFalse);
      expect(etat(c).recuperationEnCours, isFalse);
    });

    test('ouvrir active le sous-flux et pre-remplit l\'e-mail', () {
      final c = creerContainer(_FauxAuthRepository());

      notifier(c).ouvrir('  awa@example.com  ');

      expect(etat(c).actif, isTrue);
      expect(etat(c).etape, EtapeReinit.demande);
      expect(etat(c).email, 'awa@example.com');
    });

    test('demander (succes) passe a l\'etape verification', () async {
      final c = creerContainer(_FauxAuthRepository());
      notifier(c).ouvrir('awa@example.com');

      await notifier(c).demander('awa@example.com');

      expect(etat(c).etape, EtapeReinit.verification);
      expect(etat(c).statut, isA<ReinitPrete>());
    });

    test('demander (echec) range l\'echec sans changer d\'etape', () async {
      final faux = _FauxAuthRepository()..echecDemander = const PanneReseau();
      final c = creerContainer(faux);
      notifier(c).ouvrir('awa@example.com');

      await notifier(c).demander('awa@example.com');

      expect(etat(c).etape, EtapeReinit.demande);
      expect(etat(c).statut, isA<ReinitEchouee>());
    });

    test('soumettreCode (succes) ouvre la recuperation et devoile le mdp',
        () async {
      final c = creerContainer(_FauxAuthRepository());
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');

      await notifier(c).soumettreCode('123456');

      expect(etat(c).codeVerifie, isTrue);
      // Drapeau lu par la redirection : la session de recuperation est ouverte.
      expect(etat(c).recuperationEnCours, isTrue);
      expect(etat(c).statut, isA<ReinitPrete>());
    });

    test('soumettreCode (code faux) rabaisse le drapeau de recuperation',
        () async {
      final faux = _FauxAuthRepository()
        ..echecCode = const CodeRecuperationInvalide();
      final c = creerContainer(faux);
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');

      await notifier(c).soumettreCode('000000');

      expect(etat(c).codeVerifie, isFalse);
      expect(etat(c).recuperationEnCours, isFalse);
      expect(etat(c).statut, isA<ReinitEchouee>());
    });

    test('definirMotDePasse (succes) deconnecte et signale le succes', () async {
      final faux = _FauxAuthRepository();
      final c = creerContainer(faux);
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');
      await notifier(c).soumettreCode('123456');

      await notifier(c).definirMotDePasse('nouveaumdp1');

      expect(etat(c).succes, isTrue);
      expect(etat(c).actif, isFalse);
      expect(etat(c).recuperationEnCours, isFalse);
      // La session de recuperation est bien fermee (l'eleve se reconnectera).
      expect(faux.appels, containsAllInOrder(['definir', 'seDeconnecter']));
    });

    test('definirMotDePasse (echec) reste dans le sous-flux', () async {
      final faux = _FauxAuthRepository()
        ..echecDefinir = const EchecAuthentificationInattendu('boom');
      final c = creerContainer(faux);
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');
      await notifier(c).soumettreCode('123456');

      await notifier(c).definirMotDePasse('nouveaumdp1');

      expect(etat(c).succes, isFalse);
      expect(etat(c).codeVerifie, isTrue);
      expect(etat(c).statut, isA<ReinitEchouee>());
    });

    test('annuler apres code verifie ferme la session et remet a zero', () async {
      final faux = _FauxAuthRepository();
      final c = creerContainer(faux);
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');
      await notifier(c).soumettreCode('123456');

      await notifier(c).annuler();

      expect(etat(c).actif, isFalse);
      expect(etat(c).recuperationEnCours, isFalse);
      expect(faux.appels, contains('seDeconnecter'));
    });

    test('accuserSucces efface le drapeau one-shot', () async {
      final c = creerContainer(_FauxAuthRepository());
      notifier(c).ouvrir('awa@example.com');
      await notifier(c).demander('awa@example.com');
      await notifier(c).soumettreCode('123456');
      await notifier(c).definirMotDePasse('nouveaumdp1');
      expect(etat(c).succes, isTrue);

      notifier(c).accuserSucces();

      expect(etat(c).succes, isFalse);
    });
  });
}

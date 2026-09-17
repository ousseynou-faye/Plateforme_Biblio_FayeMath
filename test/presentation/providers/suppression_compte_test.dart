import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/nettoyage_local_repository.dart';
import 'package:fayemath_academy/presentation/providers/suppression_compte_provider.dart';

/// Faux repository d'auth : ne cable que `supprimerMonCompte` (le reste via
/// noSuchMethod). Journalise l'appel, ou echoue si [erreur] est fournie.
class _FauxAuth implements AuthRepository {
  _FauxAuth(this._journal, {this.erreur});

  final List<String> _journal;
  final Object? erreur;

  @override
  Future<void> supprimerMonCompte() async {
    if (erreur != null) throw erreur!;
    _journal.add('serveur');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Faux nettoyage local : journalise son appel.
class _FauxNettoyage implements NettoyageLocalRepository {
  _FauxNettoyage(this._journal);

  final List<String> _journal;

  @override
  Future<void> viderDonneesEleve() async {
    _journal.add('local');
  }
}

void main() {
  test('executer : serveur PUIS local, dans cet ordre', () async {
    final journal = <String>[];
    final suppression = SuppressionCompte(
      authRepository: _FauxAuth(journal),
      nettoyageLocal: _FauxNettoyage(journal),
    );

    await suppression.executer();

    expect(journal, ['serveur', 'local']);
  });

  test(
    'executer : si le serveur echoue, la purge locale n\'a PAS lieu',
    () async {
      final journal = <String>[];
      final suppression = SuppressionCompte(
        authRepository: _FauxAuth(journal, erreur: const PanneReseau()),
        nettoyageLocal: _FauxNettoyage(journal),
      );

      await expectLater(
        suppression.executer(),
        throwsA(isA<PanneReseau>()),
      );
      // Ni le serveur (echoue avant de journaliser) ni le local n'ont ecrit.
      expect(journal, isEmpty);
    },
  );
}

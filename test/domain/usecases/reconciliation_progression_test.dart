import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/usecases/reconciliation_progression.dart';

void main() {
  // Deux instants reperes pour comparer les `dateMaj` sans ambiguite.
  final ancien = DateTime(2026, 8, 29, 10, 0);
  final recent = DateTime(2026, 8, 29, 12, 0);

  group('ReconciliationProgression.decider', () {
    group('aucune ligne locale', () {
      test('serveur present -> on adopte le serveur', () {
        expect(
          ReconciliationProgression.decider(
            local: null,
            serveurDateMaj: recent,
          ),
          DecisionReconciliation.adopterServeur,
        );
      });

      test('serveur absent -> rien a faire', () {
        expect(
          ReconciliationProgression.decider(
            local: null,
            serveurDateMaj: null,
          ),
          DecisionReconciliation.rienAFaire,
        );
      });
    });

    group('local EN ATTENTE (ecrit hors-ligne, pas encore pousse)', () {
      test('serveur absent -> on pousse le local', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: true),
            serveurDateMaj: null,
          ),
          DecisionReconciliation.pousserVersServeur,
        );
      });

      test('serveur plus ANCIEN -> le local gagne, on pousse', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: true),
            serveurDateMaj: ancien,
          ),
          DecisionReconciliation.pousserVersServeur,
        );
      });

      test('egalite de dateMaj -> le local en attente part quand meme', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: true),
            serveurDateMaj: recent,
          ),
          DecisionReconciliation.pousserVersServeur,
        );
      });

      test(
        'serveur plus RECENT (conflit 2 appareils) -> le serveur l\'emporte',
        () {
          expect(
            ReconciliationProgression.decider(
              local: (dateMaj: ancien, enAttente: true),
              serveurDateMaj: recent,
            ),
            DecisionReconciliation.adopterServeur,
          );
        },
      );
    });

    group('local DEJA SYNCHRONISE (pull simple)', () {
      test('serveur plus RECENT -> on adopte le serveur', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: ancien, enAttente: false),
            serveurDateMaj: recent,
          ),
          DecisionReconciliation.adopterServeur,
        );
      });

      test('serveur plus ANCIEN -> rien a faire (le local est deja bon)', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: false),
            serveurDateMaj: ancien,
          ),
          DecisionReconciliation.rienAFaire,
        );
      });

      test('egalite de dateMaj -> rien a faire', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: false),
            serveurDateMaj: recent,
          ),
          DecisionReconciliation.rienAFaire,
        );
      });

      test('serveur absent -> rien a faire (on ne supprime pas le local)', () {
        expect(
          ReconciliationProgression.decider(
            local: (dateMaj: recent, enAttente: false),
            serveurDateMaj: null,
          ),
          DecisionReconciliation.rienAFaire,
        );
      });
    });
  });
}

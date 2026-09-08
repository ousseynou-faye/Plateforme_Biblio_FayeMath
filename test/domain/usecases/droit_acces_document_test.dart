import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';

void main() {
  // Reference stable pour toutes les comparaisons a la journee.
  final maintenant = DateTime(2026, 9, 8, 10, 30);

  Abonnement abonnement({required DateTime dateFin}) => Abonnement(
    id: 'a-1',
    utilisateurId: 'u-1',
    formule: FormuleAbonnement.mensuel,
    dateDebut: DateTime(2026, 1, 1),
    dateFin: dateFin,
    referencePaiement: null,
  );

  final actif = abonnement(dateFin: DateTime(2026, 10, 8)); // dans le futur
  final expireHier = abonnement(dateFin: DateTime(2026, 9, 7)); // < aujourd'hui
  final finAujourdhui = abonnement(dateFin: DateTime(2026, 9, 8)); // borne incluse

  group('DroitAccesDocument.evaluer — invite (jamais connecte)', () {
    test('document gratuit -> compteRequis (compte requis pour tout)', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: false,
          estConnecte: false,
          abonnement: null,
          maintenant: maintenant,
        ),
        AccesDocument.compteRequis,
      );
    });

    test('document premium -> compteRequis (le compte prime sur le premium)', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: true,
          estConnecte: false,
          abonnement: null,
          maintenant: maintenant,
        ),
        AccesDocument.compteRequis,
      );
    });

    test(
      'un invite avec un abonnement fourni par erreur reste compteRequis',
      () {
        // Defense : l'etat d'auth prime, on ne « deverrouille » pas un invite.
        expect(
          DroitAccesDocument.evaluer(
            premium: true,
            estConnecte: false,
            abonnement: actif,
            maintenant: maintenant,
          ),
          AccesDocument.compteRequis,
        );
      },
    );
  });

  group('DroitAccesDocument.evaluer — connecte, document gratuit', () {
    test('sans abonnement -> autorise', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: false,
          estConnecte: true,
          abonnement: null,
          maintenant: maintenant,
        ),
        AccesDocument.autorise,
      );
    });

    test('avec abonnement actif -> autorise', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: false,
          estConnecte: true,
          abonnement: actif,
          maintenant: maintenant,
        ),
        AccesDocument.autorise,
      );
    });

    test('avec abonnement expire -> autorise (le gratuit ne depend pas de lui)', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: false,
          estConnecte: true,
          abonnement: expireHier,
          maintenant: maintenant,
        ),
        AccesDocument.autorise,
      );
    });
  });

  group('DroitAccesDocument.evaluer — connecte, document premium', () {
    test('sans abonnement -> abonnementRequis', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: true,
          estConnecte: true,
          abonnement: null,
          maintenant: maintenant,
        ),
        AccesDocument.abonnementRequis,
      );
    });

    test('abonnement actif -> autorise', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: true,
          estConnecte: true,
          abonnement: actif,
          maintenant: maintenant,
        ),
        AccesDocument.autorise,
      );
    });

    test('abonnement expire hier -> abonnementRequis (le verrou revient)', () {
      expect(
        DroitAccesDocument.evaluer(
          premium: true,
          estConnecte: true,
          abonnement: expireHier,
          maintenant: maintenant,
        ),
        AccesDocument.abonnementRequis,
      );
    });

    test(
      'abonnement finissant AUJOURD\'HUI -> autorise (borne du jour incluse)',
      () {
        // Coherent avec la regle serveur `date_fin >= current_date` et
        // Abonnement.estActif (comparaison a la journee).
        expect(
          DroitAccesDocument.evaluer(
            premium: true,
            estConnecte: true,
            abonnement: finAujourdhui,
            maintenant: maintenant,
          ),
          AccesDocument.autorise,
        );
      },
    );
  });
}

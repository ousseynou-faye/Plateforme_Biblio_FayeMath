import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';

void main() {
  group('Abonnement.estActif', () {
    Abonnement abonnementFinissantLe(DateTime fin) => Abonnement(
      id: 'a1',
      utilisateurId: 'u1',
      formule: FormuleAbonnement.mensuel,
      dateDebut: DateTime(2026, 1, 1),
      dateFin: fin,
      referencePaiement: null,
    );

    test('actif quand la date de fin est dans le futur', () {
      final abo = abonnementFinissantLe(DateTime(2026, 12, 31));
      expect(abo.estActif(DateTime(2026, 8, 4)), isTrue);
    });

    test('actif le jour meme de la fin (borne incluse, comme le serveur)', () {
      final abo = abonnementFinissantLe(DateTime(2026, 8, 4));
      // Meme avec une heure dans la journee, la comparaison se fait a la journee.
      expect(abo.estActif(DateTime(2026, 8, 4, 23, 59)), isTrue);
    });

    test('expire quand la date de fin est passee', () {
      final abo = abonnementFinissantLe(DateTime(2026, 8, 3));
      expect(abo.estActif(DateTime(2026, 8, 4)), isFalse);
    });
  });

  group('Ressource.rattachementCoherent', () {
    test('sujet_examen : classe + matiere, pas de chapitre -> coherent', () {
      const r = Ressource(
        id: 'r1',
        chapitreId: null,
        classeId: 'c1',
        matiereId: 'm1',
        type: TypeRessource.sujetExamen,
        titre: 'BFEM 2024',
        tailleOctets: 1000,
        premium: true,
        version: 1,
        cheminStorage: null,
        ordre: 1,
      );
      expect(r.rattachementCoherent, isTrue);
      expect(r.estSujetExamen, isTrue);
    });

    test('cours : chapitre, pas de classe/matiere propres -> coherent', () {
      const r = Ressource(
        id: 'r2',
        chapitreId: 'ch1',
        classeId: null,
        matiereId: null,
        type: TypeRessource.cours,
        titre: 'Les nombres entiers',
        tailleOctets: 2000,
        premium: false,
        version: 1,
        cheminStorage: null,
        ordre: 1,
      );
      expect(r.rattachementCoherent, isTrue);
      expect(r.estSujetExamen, isFalse);
    });

    test(
      'cours rattache a une classe au lieu d\'un chapitre -> incoherent',
      () {
        const r = Ressource(
          id: 'r3',
          chapitreId: null,
          classeId: 'c1',
          matiereId: 'm1',
          type: TypeRessource.cours,
          titre: 'Incoherent',
          tailleOctets: 500,
          premium: false,
          version: 1,
          cheminStorage: null,
          ordre: 1,
        );
        expect(r.rattachementCoherent, isFalse);
      },
    );
  });

  group('Egalite de valeur', () {
    test('deux Classe identiques sont egales et partagent leur hashCode', () {
      const a = Classe(id: 'c1', nom: '6e', cycle: Cycle.college, ordre: 1);
      const b = Classe(id: 'c1', nom: '6e', cycle: Cycle.college, ordre: 1);
      const c = Classe(id: 'c2', nom: '5e', cycle: Cycle.college, ordre: 2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });
}

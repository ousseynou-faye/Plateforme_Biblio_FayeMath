import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_par_strate.dart';

/// Fabrique un chapitre de test : seuls `ordre` et `strate` comptent pour le
/// regroupement ; le reste recoit des valeurs neutres.
Chapitre chap({required int ordre, String? strate}) => Chapitre(
  id: 'c-$ordre',
  classeId: 'classe-6e',
  matiereId: 'mat-maths',
  numero: ordre,
  titre: 'Chapitre $ordre',
  strate: strate,
  ordre: ordre,
);

void main() {
  group('RegroupementParStrate.de', () {
    test('liste vide -> aucun groupe', () {
      expect(RegroupementParStrate.de(const []), isEmpty);
    });

    test('trie par ordre avant de regrouper (entree en desordre)', () {
      final groupes = RegroupementParStrate.de([
        chap(ordre: 3, strate: 'Num'),
        chap(ordre: 1, strate: 'Num'),
        chap(ordre: 2, strate: 'Num'),
      ]);
      expect(groupes, hasLength(1));
      expect(groupes.single.strate, 'Num');
      expect(groupes.single.chapitres.map((c) => c.ordre), [1, 2, 3]);
    });

    test('regroupe en conservant l\'ordre d\'apparition des strates', () {
      final groupes = RegroupementParStrate.de([
        chap(ordre: 1, strate: 'Num'),
        chap(ordre: 2, strate: 'Num'),
        chap(ordre: 3, strate: 'Geo'),
        chap(ordre: 4, strate: 'Geo'),
      ]);
      expect(groupes.map((g) => g.strate), ['Num', 'Geo']);
      expect(groupes[0].chapitres.map((c) => c.ordre), [1, 2]);
      expect(groupes[1].chapitres.map((c) => c.ordre), [3, 4]);
    });

    test('l\'ordre des groupes suit le tri par ordre, pas l\'entree', () {
      // Geo a les ordres les plus petits -> Geo passe en premier, meme si Num
      // est fourni en tete de la liste d'entree.
      final groupes = RegroupementParStrate.de([
        chap(ordre: 5, strate: 'Num'),
        chap(ordre: 1, strate: 'Geo'),
        chap(ordre: 6, strate: 'Num'),
        chap(ordre: 2, strate: 'Geo'),
      ]);
      expect(groupes.map((g) => g.strate), ['Geo', 'Num']);
      expect(groupes[0].chapitres.map((c) => c.ordre), [1, 2]);
      expect(groupes[1].chapitres.map((c) => c.ordre), [5, 6]);
    });

    test('strate null forme un groupe a part entiere', () {
      final groupes = RegroupementParStrate.de([
        chap(ordre: 1, strate: 'Num'),
        chap(ordre: 2, strate: null),
        chap(ordre: 3, strate: 'Num'),
      ]);
      // Num apparait en 1er (ordre 1), le groupe sans strate ensuite (ordre 2) ;
      // le chapitre Num d'ordre 3 rejoint le groupe Num deja ouvert.
      expect(groupes.map((g) => g.strate), ['Num', null]);
      expect(groupes[0].chapitres.map((c) => c.ordre), [1, 3]);
      expect(groupes[1].chapitres.single.ordre, 2);
    });

    test('un seul groupe quand aucune strate n\'est renseignee', () {
      final groupes = RegroupementParStrate.de([
        chap(ordre: 1, strate: null),
        chap(ordre: 2, strate: null),
      ]);
      expect(groupes, hasLength(1));
      expect(groupes.single.strate, isNull);
      expect(groupes.single.chapitres.map((c) => c.ordre), [1, 2]);
    });
  });
}

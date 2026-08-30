import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';

Chapitre chap(String id, {required String matiereId, required int ordre}) =>
    Chapitre(
      id: id,
      classeId: 'c-6e',
      matiereId: matiereId,
      numero: ordre,
      titre: 'Chapitre $id',
      strate: null,
      ordre: ordre,
    );

void main() {
  group('AgregationProgression.calculer', () {
    test('aucun chapitre -> tout a zero, 0 %, par matiere vide', () {
      final a = AgregationProgression.calculer(chapitres: const [], etats: const {});
      expect(a.total, 0);
      expect(a.fait, 0);
      expect(a.pourcentageGlobal, 0);
      expect(a.parMatiere, isEmpty);
    });

    test('aucune progression enregistree -> tout « a faire »', () {
      final chapitres = [
        chap('ch1', matiereId: 'maths', ordre: 1),
        chap('ch2', matiereId: 'maths', ordre: 2),
      ];
      final a = AgregationProgression.calculer(chapitres: chapitres, etats: const {});
      expect(a.total, 2);
      expect(a.aFaire, 2);
      expect(a.fait, 0);
      expect(a.pourcentageGlobal, 0);
    });

    test('compte chaque etat + pourcentage global arrondi', () {
      final chapitres = [
        chap('ch1', matiereId: 'maths', ordre: 1),
        chap('ch2', matiereId: 'maths', ordre: 2),
        chap('ch3', matiereId: 'maths', ordre: 3),
      ];
      // 1 fait sur 3 -> 33 % (arrondi).
      final a = AgregationProgression.calculer(
        chapitres: chapitres,
        etats: {
          'ch1': EtatProgression.fait,
          'ch2': EtatProgression.enCours,
          // ch3 absent -> a faire
        },
      );
      expect(a.fait, 1);
      expect(a.enCours, 1);
      expect(a.aRevoir, 0);
      expect(a.aFaire, 1);
      expect(a.pourcentageGlobal, 33);
    });

    test('« fait » ne compte QUE fait, pas en cours ni a revoir', () {
      final chapitres = [
        chap('ch1', matiereId: 'maths', ordre: 1),
        chap('ch2', matiereId: 'maths', ordre: 2),
      ];
      final a = AgregationProgression.calculer(
        chapitres: chapitres,
        etats: {
          'ch1': EtatProgression.enCours,
          'ch2': EtatProgression.aRevoir,
        },
      );
      expect(a.fait, 0);
      expect(a.pourcentageGlobal, 0);
    });

    test('par matiere : regroupe par matiereId, ordre d\'apparition preserve', () {
      final chapitres = [
        chap('m1', matiereId: 'maths', ordre: 1),
        chap('p1', matiereId: 'pc', ordre: 2),
        chap('m2', matiereId: 'maths', ordre: 3),
        chap('p2', matiereId: 'pc', ordre: 4),
      ];
      final a = AgregationProgression.calculer(
        chapitres: chapitres,
        etats: {'m1': EtatProgression.fait, 'm2': EtatProgression.fait},
      );
      // maths apparait avant pc (ordre 1 < 2).
      expect(a.parMatiere, [
        const AvancementMatiere(matiereId: 'maths', fait: 2, total: 2),
        const AvancementMatiere(matiereId: 'pc', fait: 0, total: 2),
      ]);
      expect(a.parMatiere.first.pourcentage, 100);
      expect(a.parMatiere.last.pourcentage, 0);
    });

    test('l\'ordre d\'apparition suit `ordre`, pas l\'ordre de la liste', () {
      // Liste desordonnee : pc (ordre 5) avant maths (ordre 1).
      final chapitres = [
        chap('p1', matiereId: 'pc', ordre: 5),
        chap('m1', matiereId: 'maths', ordre: 1),
      ];
      final a = AgregationProgression.calculer(chapitres: chapitres, etats: const {});
      expect(a.parMatiere.map((m) => m.matiereId), ['maths', 'pc']);
    });
  });
}

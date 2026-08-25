import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';

void main() {
  // Fabriques minimales : seuls `id`/`chapitreId` comptent pour la regle.
  Chapitre chap(String id, int ordre) => Chapitre(
    id: id,
    classeId: 'c',
    matiereId: 'm',
    numero: ordre,
    titre: 'Chapitre $ordre',
    strate: null,
    ordre: ordre,
  );

  Ressource res(String id, String? chapitreId) => Ressource(
    id: id,
    chapitreId: chapitreId,
    classeId: null,
    matiereId: null,
    type: TypeRessource.cours,
    titre: 'Document $id',
    tailleOctets: 44000,
    premium: false,
    version: 1,
    cheminStorage: '6e/mathematiques/01/$id.pdf',
    ordre: 1,
  );

  group('DisponibiliteHorsLigne.calculer', () {
    test('sans chapitre -> 0 sur 0, fraction 0, aucun NaN', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: const [],
        ressourcesAccessibles: const [],
        idsPresents: const {},
      );
      expect(ratio.chapitresHorsLigne, 0);
      expect(ratio.chapitresTotal, 0);
      expect(ratio.fraction, 0);
      expect(ratio.pourcentage, 0);
    });

    test('des chapitres mais rien de telecharge -> 0 sur N', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1), chap('ch2', 2)],
        ressourcesAccessibles: [res('r1', 'ch1'), res('r2', 'ch2')],
        idsPresents: const {},
      );
      expect(ratio.chapitresHorsLigne, 0);
      expect(ratio.chapitresTotal, 2);
    });

    test('un chapitre dont TOUS les docs accessibles sont presents compte', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1)],
        ressourcesAccessibles: [res('r1', 'ch1'), res('r2', 'ch1')],
        idsPresents: const {'r1', 'r2'},
      );
      expect(ratio.chapitresHorsLigne, 1);
      expect(ratio.chapitresTotal, 1);
      expect(ratio.pourcentage, 100);
    });

    test('un seul doc accessible manquant -> le chapitre ne compte pas', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1)],
        ressourcesAccessibles: [res('r1', 'ch1'), res('r2', 'ch1')],
        idsPresents: const {'r1'},
      );
      expect(ratio.chapitresHorsLigne, 0);
    });

    test(
      'un doc premium hors de portee (absent des accessibles) ne penalise pas',
      () {
        // L'appelant ne passe QUE les documents accessibles (r1 gratuit) ; le
        // corrige premium (r2) n'est pas dans la liste, donc son absence sur le
        // disque ne rend pas le chapitre « incomplet ».
        final ratio = DisponibiliteHorsLigne.calculer(
          chapitres: [chap('ch1', 1)],
          ressourcesAccessibles: [res('r1', 'ch1')],
          idsPresents: const {'r1'},
        );
        expect(ratio.chapitresHorsLigne, 1);
      },
    );

    test('un chapitre sans aucun doc accessible ne compte pas (mais est dans Y)', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1), chap('ch2', 2)],
        ressourcesAccessibles: [res('r1', 'ch1')],
        idsPresents: const {'r1'},
      );
      expect(ratio.chapitresHorsLigne, 1);
      expect(ratio.chapitresTotal, 2);
    });

    test('les sujets d\'examen (chapitre_id null) sont hors du calcul', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1)],
        ressourcesAccessibles: [res('r1', 'ch1'), res('sujet', null)],
        idsPresents: const {'r1'},
      );
      expect(ratio.chapitresHorsLigne, 1);
    });

    test('le pourcentage est arrondi (1 chapitre sur 3 -> 33 %)', () {
      final ratio = DisponibiliteHorsLigne.calculer(
        chapitres: [chap('ch1', 1), chap('ch2', 2), chap('ch3', 3)],
        ressourcesAccessibles: [
          res('r1', 'ch1'),
          res('r2', 'ch2'),
          res('r3', 'ch3'),
        ],
        idsPresents: const {'r1'},
      );
      expect(ratio.chapitresHorsLigne, 1);
      expect(ratio.chapitresTotal, 3);
      expect(ratio.pourcentage, 33);
    });
  });
}

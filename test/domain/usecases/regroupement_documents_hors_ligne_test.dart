import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_documents_hors_ligne.dart';

void main() {
  Chapitre chap(String id, int ordre) => Chapitre(
    id: id,
    classeId: 'c',
    matiereId: 'm',
    numero: ordre,
    titre: 'Chapitre $ordre',
    strate: null,
    ordre: ordre,
  );

  Ressource res(String id, String? chapitreId, int ordre) => Ressource(
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
    ordre: ordre,
  );

  group('RegroupementDocumentsHorsLigne.de', () {
    test('sans document present -> aucun groupe', () {
      expect(
        RegroupementDocumentsHorsLigne.de(const [], [chap('ch1', 1)]),
        isEmpty,
      );
    });

    test('groupe les documents par chapitre', () {
      final groupes = RegroupementDocumentsHorsLigne.de(
        [res('r1', 'ch1', 1), res('r2', 'ch1', 2), res('r3', 'ch2', 1)],
        [chap('ch1', 1), chap('ch2', 2)],
      );
      expect(groupes.length, 2);
      expect(groupes[0].chapitre.id, 'ch1');
      expect(groupes[0].documents.map((r) => r.id), ['r1', 'r2']);
      expect(groupes[1].chapitre.id, 'ch2');
      expect(groupes[1].documents.map((r) => r.id), ['r3']);
    });

    test('les chapitres sont ordonnes par ordre (pas par ordre d\'arrivee)', () {
      final groupes = RegroupementDocumentsHorsLigne.de(
        [res('r2', 'ch2', 1), res('r1', 'ch1', 1)],
        [chap('ch1', 1), chap('ch2', 2)],
      );
      expect(groupes.map((g) => g.chapitre.id), ['ch1', 'ch2']);
    });

    test('les documents d\'un chapitre sont ordonnes par leur ordre interne', () {
      final groupes = RegroupementDocumentsHorsLigne.de(
        [res('corrige', 'ch1', 4), res('cours', 'ch1', 1)],
        [chap('ch1', 1)],
      );
      expect(groupes.single.documents.map((r) => r.id), ['cours', 'corrige']);
    });

    test('un chapitre sans document present n\'apparait pas', () {
      final groupes = RegroupementDocumentsHorsLigne.de(
        [res('r1', 'ch1', 1)],
        [chap('ch1', 1), chap('ch2', 2)],
      );
      expect(groupes.map((g) => g.chapitre.id), ['ch1']);
    });

    test('un document sans chapitre connu est ecarte', () {
      final groupes = RegroupementDocumentsHorsLigne.de(
        [res('r1', 'ch1', 1), res('orphelin', 'chX', 1), res('sujet', null, 1)],
        [chap('ch1', 1)],
      );
      expect(groupes.length, 1);
      expect(groupes.single.documents.map((r) => r.id), ['r1']);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/telechargement/chemins_telechargement.dart';

void main() {
  // Une racine privee factice : les fonctions sont PURES, aucun disque touche.
  const racine = '/data/app/prive';
  const id = 'a1b2c3d4-0000-4000-8000-000000000001';

  group('CheminsTelechargement', () {
    test(
      'le dossier est le sous-dossier telechargements de la racine privee',
      () {
        expect(
          CheminsTelechargement.dossier(racine),
          '/data/app/prive/telechargements',
        );
      },
    );

    test('le fichier final derive du seul ressourceId, extension .pdf', () {
      expect(
        CheminsTelechargement.fichierFinal(racine, id),
        '/data/app/prive/telechargements/$id.pdf',
      );
    });

    test('le fichier partiel est le fichier final suffixe .partiel', () {
      expect(
        CheminsTelechargement.fichierPartiel(racine, id),
        '/data/app/prive/telechargements/$id.pdf.partiel',
      );
    });

    test('final et partiel se distinguent par le seul suffixe .partiel', () {
      expect(
        CheminsTelechargement.fichierPartiel(racine, id),
        '${CheminsTelechargement.fichierFinal(racine, id)}.partiel',
      );
    });

    group('estAssetEmbarque', () {
      test('un chemin prefixe assets/ est un PDF embarque', () {
        expect(
          CheminsTelechargement.estAssetEmbarque('assets/bibliotheque/x.pdf'),
          isTrue,
        );
      });

      test('un chemin du bucket Storage n\'est pas embarque', () {
        expect(
          CheminsTelechargement.estAssetEmbarque(
            '6e/mathematiques/01/cours.pdf',
          ),
          isFalse,
        );
      });

      test('un chemin null n\'est pas embarque', () {
        expect(CheminsTelechargement.estAssetEmbarque(null), isFalse);
      });
    });

    group('ressourceIdDepuisNomFichier', () {
      test('un nom <id>.pdf rend l\'id', () {
        expect(
          CheminsTelechargement.ressourceIdDepuisNomFichier('$id.pdf'),
          id,
        );
      });

      test('c\'est l\'inverse exact de fichierFinal', () {
        final nom = CheminsTelechargement.fichierFinal(
          racine,
          id,
        ).split('/').last;
        expect(CheminsTelechargement.ressourceIdDepuisNomFichier(nom), id);
      });

      test('un fichier partiel (transfert interrompu) est ecarte', () {
        expect(
          CheminsTelechargement.ressourceIdDepuisNomFichier('$id.pdf.partiel'),
          isNull,
        );
      });

      test('un fichier non-.pdf est ecarte', () {
        expect(
          CheminsTelechargement.ressourceIdDepuisNomFichier('fayemath.sqlite'),
          isNull,
        );
      });

      test('un nom reduit a l\'extension (id vide) est ecarte', () {
        expect(CheminsTelechargement.ressourceIdDepuisNomFichier('.pdf'), isNull);
      });
    });
  });
}

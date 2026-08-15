import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/format/taille_fichier.dart';

void main() {
  group('TailleFichier.enTexte', () {
    test('une taille nulle donne « 0 Ko »', () {
      expect(TailleFichier.enTexte(0), '0 Ko');
    });

    test('un fichier non vide mais minuscule est plancher a 1 Ko', () {
      // 300 octets arrondiraient a 0 Ko : on ne veut jamais faire croire a un
      // fichier vide.
      expect(TailleFichier.enTexte(300), '1 Ko');
    });

    test('une valeur en Ko est arrondie au plus proche', () {
      expect(TailleFichier.enTexte(144 * 1024), '144 Ko');
      // 168 Ko : la fiche « Cours » de la maquette (KIT, ecran 6).
      expect(TailleFichier.enTexte(168 * 1024), '168 Ko');
      // Arrondi : 144,4 Ko -> 144 Ko ; 144,6 Ko -> 145 Ko.
      expect(TailleFichier.enTexte((144.4 * 1024).round()), '144 Ko');
      expect(TailleFichier.enTexte((144.6 * 1024).round()), '145 Ko');
    });

    test('reste en Ko juste en dessous de 1 Mo', () {
      expect(TailleFichier.enTexte(1023 * 1024), '1023 Ko');
    });

    test('bascule en Mo a 1024 Ko, virgule decimale francaise', () {
      expect(TailleFichier.enTexte(1024 * 1024), '1,0 Mo');
      expect(TailleFichier.enTexte((1.5 * 1024 * 1024).round()), '1,5 Mo');
    });

    test('une valeur negative est traitee comme nulle', () {
      expect(TailleFichier.enTexte(-42), '0 Ko');
    });
  });
}

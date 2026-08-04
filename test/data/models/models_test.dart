import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/core/errors/donnees_invalides.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/classe_model.dart';
import 'package:fayemath_academy/data/models/progression_model.dart';
import 'package:fayemath_academy/data/models/ressource_model.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/progression.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';

void main() {
  group('ClasseModel.depuisJson', () {
    test('lit une classe complete', () {
      final classe = ClasseModel.depuisJson({
        'id': 'c1',
        'nom': '6e',
        'cycle': 'college',
        'ordre': 1,
      });
      expect(
        classe,
        const Classe(id: 'c1', nom: '6e', cycle: Cycle.college, ordre: 1),
      );
    });

    test('un champ manquant leve DonneesInvalides', () {
      expect(
        () => ClasseModel.depuisJson({
          'id': 'c1',
          'nom': '6e',
          'cycle': 'college',
        }),
        throwsA(isA<DonneesInvalides>()),
      );
    });

    test('un cycle inconnu leve DonneesInvalides (pas ArgumentError brut)', () {
      expect(
        () => ClasseModel.depuisJson({
          'id': 'c1',
          'nom': '6e',
          'cycle': 'primaire',
          'ordre': 1,
        }),
        throwsA(isA<DonneesInvalides>()),
      );
    });
  });

  group('RessourceModel', () {
    const ressourceCours = Ressource(
      id: 'r1',
      chapitreId: 'ch1',
      classeId: null,
      matiereId: null,
      type: TypeRessource.cours,
      titre: 'Cours',
      tailleOctets: 2048,
      premium: false,
      version: 1,
      cheminStorage: null,
      ordre: 1,
    );

    test(
      'depuisJson conserve les nullables (chapitre sans classe/matiere)',
      () {
        final ressource = RessourceModel.depuisJson({
          'id': 'r1',
          'chapitre_id': 'ch1',
          'classe_id': null,
          'matiere_id': null,
          'type': 'cours',
          'titre': 'Cours',
          'taille_octets': 2048,
          'premium': false,
          'version': 1,
          'chemin_storage': null,
          'ordre': 1,
        });
        expect(ressource, ressourceCours);
      },
    );

    test('round-trip local : entite -> companion -> Drift -> entite', () async {
      final base = BaseLocale.avecExecuteur(NativeDatabase.memory());
      await base
          .into(base.ressources)
          .insert(RessourceModel.versCompanion(ressourceCours));
      final ligne = (await base.select(base.ressources).get()).single;
      expect(RessourceModel.depuisLigne(ligne), ressourceCours);
      await base.close();
    });
  });

  group('ProgressionModel', () {
    final progression = Progression(
      id: 'p1',
      utilisateurId: 'u1',
      chapitreId: 'ch1',
      etat: EtatProgression.fait,
      // Sans sous-seconde : Drift stocke les DateTime a la seconde par defaut.
      dateMaj: DateTime(2026, 8, 4, 10, 30),
    );

    test('round-trip JSON : depuisJson(versJson(p)) == p', () {
      expect(
        ProgressionModel.depuisJson(ProgressionModel.versJson(progression)),
        progression,
      );
    });

    test('versJson ecrit les cles snake_case du schema', () {
      final json = ProgressionModel.versJson(progression);
      expect(json['utilisateur_id'], 'u1');
      expect(json['etat'], 'fait');
    });

    test('round-trip local : entite -> Drift -> entite', () async {
      final base = BaseLocale.avecExecuteur(NativeDatabase.memory());
      await base
          .into(base.progressions)
          .insert(ProgressionModel.versCompanion(progression));
      final ligne = (await base.select(base.progressions).get()).single;
      expect(ProgressionModel.depuisLigne(ligne), progression);
      await base.close();
    });
  });
}

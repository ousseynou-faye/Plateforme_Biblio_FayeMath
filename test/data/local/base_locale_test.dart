import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';

void main() {
  test('la base locale ouvre, ecrit et relit une ligne', () async {
    // Base en memoire : pas de disque, pas de plugin, pas de path_provider.
    final base = BaseLocale.avecExecuteur(NativeDatabase.memory());

    await base
        .into(base.classes)
        .insert(
          ClassesCompanion.insert(
            id: 'c1',
            nom: '6e',
            cycle: 'college',
            ordre: 1,
          ),
        );

    final lignes = await base.select(base.classes).get();
    expect(lignes, hasLength(1));
    expect(lignes.single.nom, '6e');
    expect(lignes.single.cycle, 'college');

    await base.close();
  });

  test('createAll cree bien les 8 tables (une insertion par table)', () async {
    final base = BaseLocale.avecExecuteur(NativeDatabase.memory());

    // Si une des 8 tables manquait, l'insertion correspondante leverait.
    await base
        .into(base.matieres)
        .insert(MatieresCompanion.insert(id: 'm1', nom: 'Mathematiques'));
    await base
        .into(base.chapitres)
        .insert(
          ChapitresCompanion.insert(
            id: 'ch1',
            classeId: 'c1',
            matiereId: 'm1',
            numero: 1,
            titre: 'Les nombres entiers',
            ordre: 1,
          ),
        );
    await base
        .into(base.ressources)
        .insert(
          RessourcesCompanion.insert(
            id: 'r1',
            type: 'cours',
            titre: 'Cours',
            tailleOctets: 1000,
            premium: false,
            version: 1,
            ordre: 1,
            chapitreId: const Value('ch1'),
          ),
        );
    await base
        .into(base.utilisateurs)
        .insert(
          UtilisateursCompanion.insert(id: 'u1', creeLe: DateTime(2026, 8, 4)),
        );
    await base
        .into(base.progressions)
        .insert(
          ProgressionsCompanion.insert(
            id: 'p1',
            utilisateurId: 'u1',
            chapitreId: 'ch1',
            etat: 'a_faire',
            dateMaj: DateTime(2026, 8, 4),
          ),
        );
    await base
        .into(base.telechargements)
        .insert(
          TelechargementsCompanion.insert(
            id: 't1',
            utilisateurId: 'u1',
            ressourceId: 'r1',
            dateTelechargement: DateTime(2026, 8, 4),
          ),
        );
    await base
        .into(base.abonnements)
        .insert(
          AbonnementsCompanion.insert(
            id: 'a1',
            utilisateurId: 'u1',
            formule: 'mensuel',
            dateDebut: DateTime(2026, 8, 4),
            dateFin: DateTime(2026, 9, 4),
          ),
        );

    expect(await base.select(base.ressources).get(), hasLength(1));
    await base.close();
  });
}

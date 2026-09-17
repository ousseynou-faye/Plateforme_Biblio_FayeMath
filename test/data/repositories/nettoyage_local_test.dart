import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/repositories/nettoyage_local.dart';

/// Volet DETERMINISTE hors appareil : la purge du cache Drift. La suppression des
/// FICHIERS passe par path_provider (indisponible en test) : elle echoue en
/// silence (best-effort) et ne s'execute qu'APRES la purge Drift, qui reste donc
/// prouvee. Le volet fichiers est verifie sur appareil (DoD).
void main() {
  late BaseLocale base;
  late NettoyageLocalAppareil nettoyage;

  setUp(() {
    base = BaseLocale.avecExecuteur(NativeDatabase.memory());
    nettoyage = NettoyageLocalAppareil(base);
  });

  tearDown(() async {
    await base.close();
  });

  test(
    'viderDonneesEleve vide les tables PERSONNELLES et garde le catalogue',
    () async {
      // Catalogue public (non personnel, reconstructible) : ne doit PAS partir.
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

      // Donnees personnelles de l'eleve : doivent toutes partir.
      await base
          .into(base.utilisateurs)
          .insert(
            UtilisateursCompanion.insert(id: 'u1', creeLe: DateTime.now()),
          );
      await base
          .into(base.progressions)
          .insert(
            ProgressionsCompanion.insert(
              id: 'p1',
              utilisateurId: 'u1',
              chapitreId: 'ch1',
              etat: 'a_faire',
              dateMaj: DateTime.now(),
            ),
          );
      await base
          .into(base.telechargements)
          .insert(
            TelechargementsCompanion.insert(
              id: 't1',
              utilisateurId: 'u1',
              ressourceId: 'r1',
              dateTelechargement: DateTime.now(),
            ),
          );
      await base
          .into(base.abonnements)
          .insert(
            AbonnementsCompanion.insert(
              id: 'a1',
              utilisateurId: 'u1',
              formule: 'mensuel',
              dateDebut: DateTime.now(),
              dateFin: DateTime.now(),
            ),
          );

      await nettoyage.viderDonneesEleve();

      expect(await base.select(base.progressions).get(), isEmpty);
      expect(await base.select(base.telechargements).get(), isEmpty);
      expect(await base.select(base.abonnements).get(), isEmpty);
      expect(await base.select(base.utilisateurs).get(), isEmpty);
      // Le catalogue public reste intact.
      expect(await base.select(base.classes).get(), hasLength(1));
    },
  );
}

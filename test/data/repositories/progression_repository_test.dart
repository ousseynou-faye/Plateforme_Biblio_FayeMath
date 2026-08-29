import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/repositories/progression_repository.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/progression.dart';

/// Tests du volet LOCAL du repository (le seul deterministe hors appareil) :
/// lecture avec defaut `aFaire`, ecriture (id genere + date posee), et
/// reutilisation de l'id a la 2e modification (pas de doublon). La pousse
/// Supabase best-effort echoue ici (URL injoignable) et est ravalee : c'est
/// voulu, on n'affirme rien dessus (elle est prouvee sur appareil).
void main() {
  late BaseLocale base;
  late ProgressionRepositoryOfflineFirst repo;

  setUp(() {
    base = BaseLocale.avecExecuteur(NativeDatabase.memory());
    // Client vers une adresse injoignable : la pousse best-effort echouera vite
    // et sera ravalee (jamais remontee). Aucun reseau reel touche par les tests.
    final supabase = SupabaseClient('http://127.0.0.1:1', 'cle-de-test');
    repo = ProgressionRepositoryOfflineFirst(base, supabase);
  });

  tearDown(() async {
    await base.close();
  });

  test(
    'observerEtat : aucune ligne -> A faire (defaut, sans erreur)',
    () async {
      final etat = await repo
          .observerEtat(utilisateurId: 'u1', chapitreId: 'ch1')
          .first;
      expect(etat, EtatProgression.aFaire);
    },
  );

  test(
    'definirEtat : ecrit une ligne (id genere, date posee, etat correct)',
    () async {
      // Slack d'1 s : Drift stocke un DateTime en timestamp Unix a la SECONDE,
      // donc dateMaj relu est tronque et peut tomber juste avant `avant`.
      final avant = DateTime.now().subtract(const Duration(seconds: 1));
      await repo.definirEtat(
        utilisateurId: 'u1',
        chapitreId: 'ch1',
        etat: EtatProgression.enCours,
      );
      final apres = DateTime.now().add(const Duration(seconds: 1));

      final lignes = await base.select(base.progressions).get();
      expect(lignes, hasLength(1));
      final ligne = lignes.single;
      expect(ligne.utilisateurId, 'u1');
      expect(ligne.chapitreId, 'ch1');
      expect(ligne.etat, EtatProgression.enCours.valeurSql);
      expect(ligne.id, isNotEmpty);
      // dateMaj = heure de l'appareil au moment de l'action.
      expect(ligne.dateMaj.isAfter(avant), isTrue);
      expect(ligne.dateMaj.isBefore(apres), isTrue);
    },
  );

  test('observerEtat reflete l\'etat ecrit', () async {
    await repo.definirEtat(
      utilisateurId: 'u1',
      chapitreId: 'ch1',
      etat: EtatProgression.fait,
    );
    final etat = await repo
        .observerEtat(utilisateurId: 'u1', chapitreId: 'ch1')
        .first;
    expect(etat, EtatProgression.fait);
  });

  test(
    'definirEtat deux fois : meme ligne (id reutilise), pas de doublon',
    () async {
      await repo.definirEtat(
        utilisateurId: 'u1',
        chapitreId: 'ch1',
        etat: EtatProgression.enCours,
      );
      final premier = (await base.select(base.progressions).get()).single;

      await repo.definirEtat(
        utilisateurId: 'u1',
        chapitreId: 'ch1',
        etat: EtatProgression.aRevoir,
      );
      final lignes = await base.select(base.progressions).get();

      expect(
        lignes,
        hasLength(1),
        reason: 'une seule ligne par (eleve, chapitre)',
      );
      expect(
        lignes.single.id,
        premier.id,
        reason: 'id reutilise a la 2e modif',
      );
      expect(lignes.single.etat, EtatProgression.aRevoir.valeurSql);
    },
  );

  test(
    'observerEtats : correspondance chapitreId -> etat des seuls touches',
    () async {
      await repo.definirEtat(
        utilisateurId: 'u1',
        chapitreId: 'ch1',
        etat: EtatProgression.fait,
      );
      await repo.definirEtat(
        utilisateurId: 'u1',
        chapitreId: 'ch2',
        etat: EtatProgression.enCours,
      );
      // Un autre eleve : ne doit pas apparaitre dans la Map de u1.
      await repo.definirEtat(
        utilisateurId: 'u2',
        chapitreId: 'ch1',
        etat: EtatProgression.aRevoir,
      );

      final etats = await repo.observerEtats('u1').first;
      expect(etats, {
        'ch1': EtatProgression.fait,
        'ch2': EtatProgression.enCours,
      });
      // ch3 n'a pas de ligne -> absent de la Map (le consommateur applique aFaire).
      expect(etats.containsKey('ch3'), isFalse);
    },
  );

  // --- Etape 23 : file de synchro + plan de reconciliation --------------------

  test('definirEtat marque la ligne « en attente » de synchro', () async {
    await repo.definirEtat(
      utilisateurId: 'u1',
      chapitreId: 'ch1',
      etat: EtatProgression.enCours,
    );
    // La pousse best-effort echoue (Supabase injoignable) -> la ligne reste en
    // attente : c'est exactement l'etat d'une ecriture faite hors-ligne.
    final ligne = (await base.select(base.progressions).get()).single;
    expect(ligne.enAttenteSync, isTrue);
  });

  group('planifier (regle de reconciliation appliquee au snapshot)', () {
    // Deux instants reperes.
    final ancien = DateTime(2026, 8, 29, 10);
    final recent = DateTime(2026, 8, 29, 12);

    ProgressionLocale locale(
      String chapitreId, {
      required bool enAttente,
      required DateTime dateMaj,
      EtatProgression etat = EtatProgression.enCours,
    }) => ProgressionLocale(
      id: 'loc-$chapitreId',
      utilisateurId: 'u1',
      chapitreId: chapitreId,
      etat: etat.valeurSql,
      dateMaj: dateMaj,
      enAttenteSync: enAttente,
    );

    Progression serveur(
      String chapitreId, {
      required DateTime dateMaj,
      EtatProgression etat = EtatProgression.fait,
    }) => Progression(
      id: 'srv-$chapitreId',
      utilisateurId: 'u1',
      chapitreId: chapitreId,
      etat: etat,
      dateMaj: dateMaj,
    );

    test('local en attente, aucun serveur -> a pousser', () {
      final plan = ProgressionRepositoryOfflineFirst.planifier(
        locales: [locale('ch1', enAttente: true, dateMaj: recent)],
        serveur: const [],
      );
      expect(plan.aPousser.map((p) => p.chapitreId), ['ch1']);
      expect(plan.aAdopter, isEmpty);
    });

    test('serveur seul (rien en local) -> a adopter', () {
      final plan = ProgressionRepositoryOfflineFirst.planifier(
        locales: const [],
        serveur: [serveur('ch1', dateMaj: recent)],
      );
      expect(plan.aAdopter.map((p) => p.chapitreId), ['ch1']);
      expect(plan.aPousser, isEmpty);
    });

    test('local en attente mais serveur plus recent (conflit) -> a adopter', () {
      final plan = ProgressionRepositoryOfflineFirst.planifier(
        locales: [locale('ch1', enAttente: true, dateMaj: ancien)],
        serveur: [serveur('ch1', dateMaj: recent)],
      );
      expect(plan.aAdopter.map((p) => p.chapitreId), ['ch1']);
      expect(plan.aPousser, isEmpty);
    });

    test('local synchronise + serveur plus ancien -> rien des deux cotes', () {
      final plan = ProgressionRepositoryOfflineFirst.planifier(
        locales: [locale('ch1', enAttente: false, dateMaj: recent)],
        serveur: [serveur('ch1', dateMaj: ancien)],
      );
      expect(plan.aAdopter, isEmpty);
      expect(plan.aPousser, isEmpty);
    });

    test('plusieurs chapitres en un plan : chacun sa decision', () {
      final plan = ProgressionRepositoryOfflineFirst.planifier(
        locales: [
          locale('ch1', enAttente: true, dateMaj: recent), // pousser
          locale('ch2', enAttente: false, dateMaj: ancien), // serveur + recent
        ],
        serveur: [
          serveur('ch2', dateMaj: recent), // adopter
          serveur('ch3', dateMaj: recent), // serveur seul -> adopter
        ],
      );
      expect(plan.aPousser.map((p) => p.chapitreId), ['ch1']);
      expect(
        plan.aAdopter.map((p) => p.chapitreId).toSet(),
        {'ch2', 'ch3'},
      );
    });
  });

  group('appliquerAdoptions (ecriture locale des valeurs serveur)', () {
    Progression serveur(String id, String chapitreId, EtatProgression etat) =>
        Progression(
          id: id,
          utilisateurId: 'u1',
          chapitreId: chapitreId,
          etat: etat,
          dateMaj: DateTime(2026, 8, 29, 12),
        );

    test('serveur seul -> insere en local, NON en attente', () async {
      await repo.appliquerAdoptions([
        serveur('srv-ch1', 'ch1', EtatProgression.fait),
      ]);

      final ligne = (await base.select(base.progressions).get()).single;
      expect(ligne.id, 'srv-ch1');
      expect(ligne.etat, EtatProgression.fait.valeurSql);
      expect(ligne.enAttenteSync, isFalse);
    });

    test(
      'conflit 2 appareils (id local != id serveur) -> UNE seule ligne, id serveur',
      () async {
        // Une ligne locale « en attente » avec un id genere par cet appareil.
        await base
            .into(base.progressions)
            .insert(
              ProgressionsCompanion.insert(
                id: 'loc-ch1',
                utilisateurId: 'u1',
                chapitreId: 'ch1',
                etat: EtatProgression.enCours.valeurSql,
                dateMaj: DateTime(2026, 8, 29, 10),
              ),
            );

        // Le serveur, plus recent, porte un AUTRE id (autre appareil a cree la ligne).
        await repo.appliquerAdoptions([
          serveur('srv-ch1', 'ch1', EtatProgression.fait),
        ]);

        final lignes = await base.select(base.progressions).get();
        expect(lignes, hasLength(1), reason: 'pas de doublon (delete+insert)');
        expect(lignes.single.id, 'srv-ch1');
        expect(lignes.single.etat, EtatProgression.fait.valeurSql);
        expect(lignes.single.enAttenteSync, isFalse);
      },
    );

    test('liste vide -> aucune ecriture', () async {
      await repo.appliquerAdoptions(const []);
      expect(await base.select(base.progressions).get(), isEmpty);
    });
  });
}

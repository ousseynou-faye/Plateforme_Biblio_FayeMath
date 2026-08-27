import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/repositories/progression_repository.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';

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
}

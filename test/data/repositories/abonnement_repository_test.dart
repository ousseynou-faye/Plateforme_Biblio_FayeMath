import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/models/abonnement_model.dart';
import 'package:fayemath_academy/data/repositories/abonnement_repository.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';

/// Tests du volet LOCAL du repository (le seul deterministe hors appareil) : le
/// flux rend le cache Drift. La resynchro Supabase best-effort echoue ici (URL
/// injoignable) et est ravalee — voulu, on n'affirme rien dessus (prouve sur
/// appareil, comme les autres repos offline-first).
void main() {
  late BaseLocale base;
  late AbonnementRepositoryOfflineFirst repo;

  setUp(() {
    base = BaseLocale.avecExecuteur(NativeDatabase.memory());
    // Client vers une adresse injoignable : la resynchro echoue vite et est
    // ravalee (jamais remontee). Aucun reseau reel touche par les tests.
    final supabase = SupabaseClient('http://127.0.0.1:1', 'cle-de-test');
    repo = AbonnementRepositoryOfflineFirst(base, supabase);
  });

  tearDown(() async {
    await base.close();
  });

  Abonnement abonnement({
    required String id,
    required String utilisateurId,
    required DateTime dateFin,
    FormuleAbonnement formule = FormuleAbonnement.mensuel,
  }) => Abonnement(
    id: id,
    utilisateurId: utilisateurId,
    formule: formule,
    dateDebut: DateTime(2026, 1, 1),
    dateFin: dateFin,
    referencePaiement: null,
  );

  Future<void> semer(Abonnement a) =>
      base.into(base.abonnements).insert(AbonnementModel.versCompanion(a));

  test('aucun abonnement local -> le flux emet null', () async {
    final resultat = await repo.observerAbonnement('u1').first;
    expect(resultat, isNull);
  });

  test('un abonnement present -> renvoye tel quel', () async {
    final a = abonnement(
      id: 'a1',
      utilisateurId: 'u1',
      dateFin: DateTime(2026, 10, 8),
    );
    await semer(a);

    final resultat = await repo.observerAbonnement('u1').first;
    expect(resultat, isNotNull);
    expect(resultat!.id, 'a1');
    expect(resultat.dateFin, DateTime(2026, 10, 8));
  });

  test(
    'plusieurs abonnements -> le plus protecteur (date de fin la plus lointaine)',
    () async {
      // Un ancien expire + un courant : c'est le plus lointain qui doit sortir,
      // quel que soit l'ordre d'insertion (la regle d'activite est au lot A).
      await semer(
        abonnement(
          id: 'expire',
          utilisateurId: 'u1',
          dateFin: DateTime(2026, 3, 1),
        ),
      );
      await semer(
        abonnement(
          id: 'courant',
          utilisateurId: 'u1',
          dateFin: DateTime(2026, 12, 31),
        ),
      );

      final resultat = await repo.observerAbonnement('u1').first;
      expect(resultat!.id, 'courant');
    },
  );

  test('seul l\'abonnement de l\'eleve demande est pris en compte', () async {
    await semer(
      abonnement(
        id: 'a-u2',
        utilisateurId: 'u2',
        dateFin: DateTime(2027, 1, 1),
      ),
    );

    // u1 n'a rien -> null, malgre l'abonnement (plus lointain) de u2.
    final resultat = await repo.observerAbonnement('u1').first;
    expect(resultat, isNull);
  });
}

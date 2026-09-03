import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fayemath_academy/domain/repositories/preferences_reglages_repository.dart';
import 'package:fayemath_academy/presentation/providers/reglages_provider.dart';

/// Faux stockage en memoire : joue le role du coffre chiffre sans plugin natif.
class _FauxReglages implements PreferencesReglagesRepository {
  _FauxReglages(this.wifiSeulement);

  bool wifiSeulement;

  @override
  Future<bool> telechargerEnWifiSeulement() async => wifiSeulement;

  @override
  Future<void> definirTelechargerEnWifiSeulement({required bool valeur}) async {
    wifiSeulement = valeur;
  }
}

void main() {
  ProviderContainer creer(_FauxReglages faux) {
    final c = ProviderContainer(
      overrides: [
        preferencesReglagesRepositoryProvider.overrideWithValue(faux),
      ],
    );
    addTearDown(c.dispose);
    c.listen(telechargerEnWifiSeulementProvider, (_, _) {});
    return c;
  }

  test('defaut optimiste = true, puis la valeur disque (false) est chargee', () async {
    final c = creer(_FauxReglages(false));

    // Avant la fin de la lecture disque : defaut protecteur.
    expect(c.read(telechargerEnWifiSeulementProvider), isTrue);

    await Future<void>.delayed(Duration.zero);

    // La valeur reellement stockee a pris le relais.
    expect(c.read(telechargerEnWifiSeulementProvider), isFalse);
  });

  test('valeur stockee true reste true', () async {
    final c = creer(_FauxReglages(true));
    await Future<void>.delayed(Duration.zero);
    expect(c.read(telechargerEnWifiSeulementProvider), isTrue);
  });

  test('definir met a jour l\'etat et persiste', () async {
    final faux = _FauxReglages(true);
    final c = creer(faux);
    await Future<void>.delayed(Duration.zero);

    await c
        .read(telechargerEnWifiSeulementProvider.notifier)
        .definir(valeur: false);

    expect(c.read(telechargerEnWifiSeulementProvider), isFalse);
    expect(faux.wifiSeulement, isFalse);
  });
}

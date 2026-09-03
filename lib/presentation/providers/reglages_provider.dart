import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/repositories/preferences_reglages_repository.dart';

/// Fournit l'implementation du contrat de reglages. Comme les autres repos, NON
/// resolue ici : injectee a la racine (`main.dart`) via `overrideWith`, overridee
/// par un faux en test (`presentation/` n'importe pas `data/`).
final preferencesReglagesRepositoryProvider =
    Provider<PreferencesReglagesRepository>(
      (ref) => throw UnimplementedError(
        'preferencesReglagesRepositoryProvider doit etre override a la racine '
        '(main.dart).',
      ),
    );

/// Le reglage « telecharger uniquement en Wi-Fi », lu au demarrage puis modifiable
/// depuis le Profil (lot « Qualite D »).
///
/// On part de `true` (le defaut protecteur) le temps de lire le disque — comme le
/// notifier d'onboarding part de « indetermine ». La lecture disque est
/// asynchrone ; le telechargement n'a lieu que bien apres le demarrage (sur tap),
/// donc la vraie valeur est deja chargee au moment ou la decision compte.
class ReglageTelechargementWifiNotifier extends Notifier<bool> {
  @override
  bool build() {
    _charger();
    return true;
  }

  Future<void> _charger() async {
    state = await ref
        .read(preferencesReglagesRepositoryProvider)
        .telechargerEnWifiSeulement();
  }

  /// Bascule le reglage : mise a jour OPTIMISTE (la bascule reagit tout de suite),
  /// puis persistance dans le coffre.
  Future<void> definir({required bool valeur}) async {
    state = valeur;
    await ref
        .read(preferencesReglagesRepositoryProvider)
        .definirTelechargerEnWifiSeulement(valeur: valeur);
  }
}

final telechargerEnWifiSeulementProvider =
    NotifierProvider<ReglageTelechargementWifiNotifier, bool>(
      ReglageTelechargementWifiNotifier.new,
    );

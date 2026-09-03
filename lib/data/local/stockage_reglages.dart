import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fayemath_academy/domain/repositories/preferences_reglages_repository.dart';

/// Le meme coffre chiffre que les jetons de session et le drapeau d'onboarding
/// (`FlutterSecureStorage` est sans etat, toutes les instances partagent le
/// keystore Android). On y range un reglage NON sensible plutot que d'ajouter
/// `shared_preferences` pour un seul booleen (meme decision que
/// `StockageOnboarding` : zero dependance ajoutee).
const _coffre = FlutterSecureStorage();

/// Cle du reglage « Wi-Fi uniquement ». Prefixe `fayemath_` (meme convention que
/// `fayemath_session` / `fayemath_onboarding_vu`) pour eviter toute collision.
const _cleWifiSeulement = 'fayemath_telechargement_wifi_seulement';

/// Implementation du contrat [PreferencesReglagesRepository] adossee au coffre
/// chiffre du telephone. Injectee a la racine (`main.dart`), pour que
/// `presentation/` n'importe jamais `data/` (docs/ARCHITECTURE.md §3).
class StockageReglages implements PreferencesReglagesRepository {
  const StockageReglages();

  @override
  Future<bool> telechargerEnWifiSeulement() async {
    final valeur = await _coffre.read(key: _cleWifiSeulement);
    // Cle absente = jamais defini -> defaut protecteur (active). Sinon, egalite
    // stricte a 'true' : toute autre valeur = desactive.
    if (valeur == null) return true;
    return valeur == 'true';
  }

  @override
  Future<void> definirTelechargerEnWifiSeulement({required bool valeur}) =>
      _coffre.write(key: _cleWifiSeulement, value: valeur ? 'true' : 'false');
}

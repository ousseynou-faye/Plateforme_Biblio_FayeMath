import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:fayemath_academy/domain/repositories/preferences_onboarding_repository.dart';

/// Le meme coffre chiffre que les jetons de session (voir
/// `stockage_session_securise.dart`) : `FlutterSecureStorage` est sans etat, deux
/// instances partagent le meme keystore Android. On y range un drapeau NON
/// sensible (« l'eleve a vu l'onboarding »), decision du point 1 : reutiliser une
/// dependance deja presente et deja lue au demarrage a froid, plutot que d'en
/// ajouter une (shared_preferences) pour un seul booleen.
const _coffre = FlutterSecureStorage();

/// Cle de rangement du drapeau. Prefixe `fayemath_` pour ne pas entrer en
/// collision avec les cles d'une autre application (meme convention que la cle de
/// session `fayemath_session`).
const _cleOnboardingVu = 'fayemath_onboarding_vu';

/// Valeur ecrite quand l'onboarding est vu. On teste l'egalite stricte a cette
/// chaine : une cle absente (`read` -> null) ou toute autre valeur = « pas vu ».
const _valeurVu = 'true';

/// Implementation du contrat [PreferencesOnboardingRepository] adossee au coffre
/// chiffre du telephone. Injectee a la racine de composition (`main.dart`), pour
/// que `presentation/` n'importe jamais `data/` (docs/ARCHITECTURE.md §3).
class StockageOnboarding implements PreferencesOnboardingRepository {
  const StockageOnboarding();

  @override
  Future<bool> onboardingVu() async =>
      await _coffre.read(key: _cleOnboardingVu) == _valeurVu;

  @override
  Future<void> marquerOnboardingVu() =>
      _coffre.write(key: _cleOnboardingVu, value: _valeurVu);

  @override
  Future<void> reinitialiserOnboarding() =>
      _coffre.delete(key: _cleOnboardingVu);
}

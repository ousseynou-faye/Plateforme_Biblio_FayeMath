import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Le coffre chiffre du telephone. Sur Android, flutter_secure_storage v11
/// range les valeurs sous une cle AES-GCM elle-meme enveloppee par une cle RSA
/// du Keystore materiel (defaut du paquet, API 24+ — notre `minSdk`). Partage
/// par les deux adaptateurs ci-dessous.
const _coffre = FlutterSecureStorage();

/// Cle de rangement de la session. Prefixe `fayemath_` pour ne pas entrer en
/// collision avec les cles d'une autre bibliotheque presente sur le telephone.
const _cleSession = 'fayemath_session';

/// Persiste la SESSION Supabase (jeton d'acces + jeton de rafraichissement)
/// dans le coffre chiffre, au lieu de `SharedPreferences` en clair — exigence
/// de SECURITY.md §2. Branche a `Supabase.initialize` via
/// `FlutterAuthClientOptions.localStorage`.
///
/// Point critique de SYMETRIE : [accessToken] doit rendre EXACTEMENT la chaine
/// ecrite par [persistSession]. Toute divergence empeche Supabase de retrouver
/// la session au demarrage — l'eleve serait deconnecte au lieu de voir son
/// jeton rafraichi (le risque signale par Ousseynou pour ce lot).
class StockageSessionSecurise extends LocalStorage {
  const StockageSessionSecurise();

  @override
  Future<void> initialize() async {
    // Rien a preparer : le coffre s'ouvre a la premiere lecture ou ecriture.
  }

  @override
  Future<bool> hasAccessToken() => _coffre.containsKey(key: _cleSession);

  @override
  Future<String?> accessToken() => _coffre.read(key: _cleSession);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _coffre.write(key: _cleSession, value: persistSessionString);

  @override
  Future<void> removePersistedSession() => _coffre.delete(key: _cleSession);
}

/// Persiste le verifieur PKCE — un secret de courte duree qu'utilise le lien de
/// confirmation e-mail — dans le meme coffre chiffre, pour ne pas le laisser en
/// clair non plus. Branche via `FlutterAuthClientOptions.pkceAsyncStorage`.
/// Les cles sont fournies par gotrue ; on ne fait que les stocker au chaud.
class StockagePkceSecurise extends GotrueAsyncStorage {
  const StockagePkceSecurise();

  @override
  Future<String?> getItem({required String key}) => _coffre.read(key: key);

  @override
  Future<void> setItem({required String key, required String value}) =>
      _coffre.write(key: key, value: value);

  @override
  Future<void> removeItem({required String key}) => _coffre.delete(key: key);
}

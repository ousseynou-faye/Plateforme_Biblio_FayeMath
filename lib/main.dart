import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/app.dart';
import 'package:fayemath_academy/core/env/env.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/local/stockage_session_securise.dart';
import 'package:fayemath_academy/data/repositories/auth_repository.dart';
import 'package:fayemath_academy/data/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/data/repositories/profil_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';

Future<void> main() async {
  // Necessaire avant d'appeler un plugin (secure storage / supabase_flutter)
  // depuis main(), donc avant runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // L'app est adossee a Supabase (auth) : sans les secrets injectes au build via
  // --dart-define-from-file=config/dev.json (SECURITY.md §1), elle ne peut rien
  // authentifier. Plutot qu'une page d'erreur cryptique, on affiche un ecran
  // clair qui rappelle le flag a passer.
  if (!Env.estConfigure) {
    if (kDebugMode) {
      debugPrint(
        '[Supabase] NON initialise : relance avec '
        '--dart-define-from-file=config/dev.json',
      );
    }
    runApp(const AppNonConfiguree());
    return;
  }

  // Initialisation du client Supabase. On utilise la cle ANON (dite
  // "publishable" depuis que Supabase a renomme `anonKey` -> `publishableKey` ;
  // meme valeur), jamais la cle service_role.
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
    // Jetons de session (et verifieur PKCE) ranges dans le coffre CHIFFRE du
    // telephone, pas dans SharedPreferences en clair (SECURITY.md §2, etape 13).
    authOptions: const FlutterAuthClientOptions(
      localStorage: StockageSessionSecurise(),
      pkceAsyncStorage: StockagePkceSecurise(),
    ),
  );
  if (kDebugMode) {
    // On journalise l'URL du projet (non secrete) pour confirmer la cible ;
    // jamais la valeur de la cle (SECURITY.md §5).
    debugPrint('[Supabase] client initialise — projet: ${Env.supabaseUrl}');
  }

  // Base locale Drift, ouverte UNE fois et partagee par les repositories
  // offline-first (catalogue, profil). Brique du contrat hors-ligne.
  final baseLocale = BaseLocale();
  final client = Supabase.instance.client;

  runApp(
    ProviderScope(
      overrides: [
        // Injection des implementations `data/` des contrats du domaine, faite
        // ICI (racine de composition) pour que `presentation/` n'importe jamais
        // `data/` (docs/ARCHITECTURE.md §3). On n'arrive ici que si la config
        // est presente, donc Supabase.instance est pret.
        authRepositoryProvider.overrideWith(
          (ref) => AuthRepositorySupabase(client.auth),
        ),
        catalogueRepositoryProvider.overrideWith(
          (ref) => CatalogueRepositoryOfflineFirst(baseLocale, client),
        ),
        profilRepositoryProvider.overrideWith(
          (ref) => ProfilRepositoryOfflineFirst(baseLocale, client),
        ),
      ],
      child: const FayeMathApp(),
    ),
  );
}

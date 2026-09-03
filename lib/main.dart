import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/app.dart';
import 'package:fayemath_academy/core/env/env.dart';
import 'package:fayemath_academy/data/local/base_locale.dart';
import 'package:fayemath_academy/data/local/stockage_onboarding.dart';
import 'package:fayemath_academy/data/local/stockage_reglages.dart';
import 'package:fayemath_academy/data/local/stockage_session_securise.dart';
import 'package:fayemath_academy/data/remote/telechargeur_fichier.dart';
import 'package:fayemath_academy/data/repositories/auth_repository.dart';
import 'package:fayemath_academy/data/repositories/catalogue_repository.dart';
import 'package:fayemath_academy/data/repositories/chapitre_repository.dart';
import 'package:fayemath_academy/data/repositories/profil_repository.dart';
import 'package:fayemath_academy/data/repositories/progression_repository.dart';
import 'package:fayemath_academy/data/repositories/ressource_repository.dart';
import 'package:fayemath_academy/data/repositories/telechargement_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/onboarding_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/providers/reglages_provider.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';

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

  // Client HTTP du moteur de telechargement (Phase 3, etape 19). Un seul `dio`
  // partage ; le transfert reel des PDF passe par lui (progression, annulation,
  // ecriture flux vers disque), l'URL signee est fabriquee cote Supabase.
  final telechargeur = TelechargeurFichier(Dio());

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
        // Memoire de l'onboarding (lot « Qualite et experience eleve ») : un
        // simple drapeau « deja vu » dans le coffre chiffre du telephone (aucune
        // dependance ajoutee). Purement local, aucun cote serveur.
        preferencesOnboardingRepositoryProvider.overrideWith(
          (ref) => const StockageOnboarding(),
        ),
        // Reglages non sensibles de l'appareil (lot « Qualite D ») : aujourd'hui
        // « telecharger uniquement en Wi-Fi ». Meme coffre chiffre, aucune
        // dependance ajoutee ; disponible aussi pour un invite (lie a l'appareil).
        preferencesReglagesRepositoryProvider.overrideWith(
          (ref) => const StockageReglages(),
        ),
        catalogueRepositoryProvider.overrideWith(
          (ref) => CatalogueRepositoryOfflineFirst(baseLocale, client),
        ),
        // Chapitres & ressources : repos offline-first reels (cache Drift +
        // rafraichissement Supabase). Depuis l'etape 18, ils lisent le vrai
        // contenu de 6e Maths ; le catalogue (classes/matieres) reste reel aussi.
        chapitreRepositoryProvider.overrideWith(
          (ref) => ChapitreRepositoryOfflineFirst(baseLocale, client),
        ),
        ressourceRepositoryProvider.overrideWith(
          (ref) => RessourceRepositoryOfflineFirst(baseLocale, client),
        ),
        profilRepositoryProvider.overrideWith(
          (ref) => ProfilRepositoryOfflineFirst(baseLocale, client),
        ),
        // Suivi de progression (etape 22) : ecriture LOCALE d'abord (Drift) +
        // pousse Supabase best-effort. Meme base locale partagee.
        progressionRepositoryProvider.overrideWith(
          (ref) => ProgressionRepositoryOfflineFirst(baseLocale, client),
        ),
        // Moteur de telechargement hors-ligne (etape 19) : URL signee Supabase +
        // transfert dio + trace en base. Ecrit le PDF dans l'espace prive de
        // l'appareil pour que le lecteur ouvre le vrai document.
        telechargementRepositoryProvider.overrideWith(
          (ref) =>
              TelechargementRepositoryStorage(baseLocale, client, telechargeur),
        ),
      ],
      child: const FayeMathApp(),
    ),
  );
}

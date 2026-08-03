import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fayemath_academy/app.dart';
import 'package:fayemath_academy/core/env/env.dart';

Future<void> main() async {
  // Necessaire avant d'appeler un plugin (shared_preferences via supabase_flutter)
  // depuis main(), donc avant runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation du client Supabase (Lot E). Les secrets viennent de
  // config/dev.json, injectes au build (--dart-define-from-file), jamais en dur
  // dans le code (SECURITY.md §1). On utilise la cle ANON (dite "publishable"
  // depuis que Supabase a renomme le parametre `anonKey` -> `publishableKey` ;
  // la valeur est la meme), jamais la cle service_role.
  if (Env.estConfigure) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabaseAnonKey,
    );
    if (kDebugMode) {
      // On journalise l'URL du projet (non secrete) pour confirmer la cible ;
      // jamais la valeur de la cle (SECURITY.md §5).
      debugPrint('[Supabase] client initialise — projet: ${Env.supabaseUrl}');
    }
  } else if (kDebugMode) {
    debugPrint(
      '[Supabase] NON initialise : relance avec '
      '--dart-define-from-file=config/dev.json',
    );
  }

  runApp(const FayeMathApp());
}

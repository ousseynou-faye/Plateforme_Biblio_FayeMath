import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs.dart';
import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/core/theme/typographie.dart';

/// Assemble le [ThemeData] unique de l'application a partir de la palette auditee
/// ([Couleurs]) et de la typographie Poppins ([Typographie]).
///
/// Le [ColorScheme] est construit A LA MAIN, pas via `ColorScheme.fromSeed` : les
/// paires couleur/fond ont ete auditees AA une par une le 28/07/2026 (maquette
/// V2.1) ; laisser Material deriver des teintes casserait ces contrastes
/// verifies (CLAUDE.md §5, decision de l'etape 11).
abstract final class ThemeApplication {
  /// Le theme clair — le seul en V1.
  static ThemeData get clair {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      // Indigo de marque.
      primary: Couleurs.indigo,
      onPrimary: Couleurs.blanc,
      primaryContainer: Couleurs.fondIndigoLeger,
      onPrimaryContainer: Couleurs.indigo,
      // Ocre fonctionnel (boutons, accents textuels).
      secondary: Couleurs.ocreBouton,
      onSecondary: Couleurs.blanc,
      secondaryContainer: Couleurs.fondOcreLeger,
      onSecondaryContainer: Couleurs.ocreTexte,
      // Le dore #C9A15A n'a pas d'usage audite a cette etape ; faute de role
      // assigne, `tertiary` est aligne sur l'ocre (CLAUDE.md §5, etape 11).
      tertiary: Couleurs.ocreBouton,
      onTertiary: Couleurs.blanc,
      // Erreur = rouge du statut « a revoir » (paire audite).
      error: Couleurs.erreur,
      onError: Couleurs.blanc,
      errorContainer: Couleurs.fondErreur,
      onErrorContainer: Couleurs.erreur,
      // Surfaces et neutres.
      surface: Couleurs.surface,
      onSurface: Couleurs.texte,
      surfaceContainerLowest: Couleurs.blanc,
      surfaceContainerLow: Couleurs.fondApplication,
      surfaceContainer: Couleurs.fondNeutre,
      onSurfaceVariant: Couleurs.texteAdouci,
      outline: Couleurs.icone,
      outlineVariant: Couleurs.bordure,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Couleurs.fondApplication,
      fontFamily: Typographie.famille,
      textTheme: Typographie.textTheme,
      // Les tokens sans role Material standard (ocre decoratif, statut succes).
      extensions: const <ThemeExtension<dynamic>>[CouleursMarque.clair],
      appBarTheme: const AppBarTheme(
        backgroundColor: Couleurs.indigo,
        foregroundColor: Couleurs.blanc,
        elevation: 0,
        centerTitle: false,
      ),
      // Cible tactile >= 48 px garantie au niveau du theme (accessibilite §5.2),
      // avant meme d'ecrire le moindre composant.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          textStyle: Typographie.textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          textStyle: Typographie.textTheme.labelLarge,
          side: const BorderSide(color: Couleurs.icone, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Couleurs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Couleurs.bordure),
        ),
      ),
    );
  }
}

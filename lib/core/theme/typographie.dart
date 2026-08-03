import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs.dart';

/// Typographie de l'application : Poppins, embarquee en local (cf. pubspec.yaml,
/// section `fonts:`), pas via le paquet `google_fonts` — l'app est offline-first
/// et ne doit jamais telecharger sa police au premier lancement (CLAUDE.md §5).
///
/// Contrainte d'accessibilite (02 - Contenu et Experience.pdf §5.2) : aucune
/// taille sous 11 points. Les tailles ci-dessous vont de 11 ([labelSmall]) a 32.
/// Chaque `fontWeight` correspond a l'un des 4 fichiers Poppins embarques
/// (Regular 400, Medium 500, SemiBold 600, Bold 700) : ne pas demander une
/// graisse non embarquee, Flutter la synthetiserait de facon degradee.
abstract final class Typographie {
  static const String famille = 'Poppins';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      height: 1.2,
      color: Couleurs.texte,
    ),
    displayMedium: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 1.2,
      color: Couleurs.texte,
    ),
    displaySmall: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 1.25,
      color: Couleurs.texte,
    ),
    headlineLarge: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 24,
      height: 1.3,
      color: Couleurs.texte,
    ),
    headlineMedium: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      height: 1.3,
      color: Couleurs.texte,
    ),
    headlineSmall: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 1.3,
      color: Couleurs.texte,
    ),
    titleLarge: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.3,
      color: Couleurs.texte,
    ),
    titleMedium: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.4,
      color: Couleurs.texte,
    ),
    titleSmall: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 1.4,
      color: Couleurs.texte,
    ),
    bodyLarge: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.5,
      color: Couleurs.texte,
    ),
    bodyMedium: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.5,
      color: Couleurs.texte,
    ),
    bodySmall: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.45,
      color: Couleurs.texteAdouci,
    ),
    labelLarge: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      height: 1.2,
      color: Couleurs.texte,
    ),
    labelMedium: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      height: 1.2,
      color: Couleurs.texteAdouci,
    ),
    labelSmall: TextStyle(
      fontFamily: famille,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      height: 1.2,
      color: Couleurs.texteAdouci,
    ),
  );
}

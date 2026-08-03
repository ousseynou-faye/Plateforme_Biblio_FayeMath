import 'package:flutter/material.dart';

/// Palette de la marque FayeMath Academy, auditee AA le 28/07/2026.
///
/// Source de verite : le bloc `:root` de la maquette V2.1
/// (`FayeMath_Maquettes_Ecrans_V2.html`) et le tableau palette de
/// `SPECIFICATIONS_V2_Plateforme.md`. Chaque valeur porte son ratio de contraste
/// verifie ; ne jamais introduire une couleur hors de cette liste
/// (docs/CONVENTIONS.md §4 ; core/theme est zone orange, docs/ZONES-PROTEGEES.md §3).
///
/// Ces constantes ne sont consommees QUE par le theme ([ThemeApplication]) : un
/// widget ne lit jamais `Couleurs.xxx` en dur, il passe par `Theme.of(context)`.
abstract final class Couleurs {
  // --- Indigo de marque ---
  /// Indigo de marque — texte et surfaces principales. 15,89:1 sur blanc.
  static const Color indigo = Color(0xFF16213E);

  /// Indigo clair — reserve aux degrades.
  static const Color indigoClair = Color(0xFF1F2D52);

  // --- Ocre : trois declinaisons selon l'usage (audit AA) ---
  /// Ocre de marque, surfaces NON textuelles uniquement (anneaux, barres,
  /// pastilles). Ne jamais poser de texte dessus : blanc = 4,35:1 (echec AA).
  static const Color ocreDecoratif = Color(0xFFB8622F);

  /// Ocre des boutons et de toute icone/texte fonctionnel. 6,06:1 sous blanc.
  static const Color ocreBouton = Color(0xFF96501F);

  /// Ocre pour du texte pose sur fond ocre clair. 5,45:1 sur [fondOcreLeger].
  static const Color ocreTexte = Color(0xFF8A4A22);

  // --- Neutres ---
  /// Corps de texte principal.
  static const Color texte = Color(0xFF1B1F2A);

  /// Texte secondaire (gris). >=5,09:1 sur tous nos fonds.
  static const Color texteAdouci = Color(0xFF585E6B);

  /// Icones non textuelles et contours. 3,12:1 (seuil graphique AA).
  static const Color icone = Color(0xFF8B92A1);

  /// Bordure decorative — jamais seule porteuse d'information.
  static const Color bordure = Color(0xFFE3E5EC);

  // --- Fonds ---
  static const Color fondApplication = Color(0xFFF4F5F9);
  static const Color fondNeutre = Color(0xFFEEF0F3);
  static const Color surface = Color(0xFFFFFFFF);

  /// Fond indigo tres leger — pastilles d'icone du catalogue.
  static const Color fondIndigoLeger = Color(0xFFE7EAF2);

  /// Fond ocre tres leger — porte [ocreTexte].
  static const Color fondOcreLeger = Color(0xFFF3E3D8);

  // --- Statuts semantiques (audites par paire couleur/fond) ---
  /// Vert du statut « fait ». 5,76:1 sur [fondSucces].
  static const Color succes = Color(0xFF236547);
  static const Color fondSucces = Color(0xFFDCEEE6);

  /// Rouge du statut « a revoir » et des erreurs. 6,14:1 sur [fondErreur].
  static const Color erreur = Color(0xFF992727);
  static const Color fondErreur = Color(0xFFF6DEDE);

  static const Color blanc = Color(0xFFFFFFFF);
}

import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs.dart';

/// Couleurs de marque qui n'ont pas de role standard dans [ColorScheme].
///
/// Material modelise `primary`, `secondary`, `error`... mais pas une couleur
/// « decorative non textuelle » (l'ocre des anneaux de progression) ni le statut
/// de succes (le vert « fait »). Ces tokens vivent donc dans une ThemeExtension,
/// le canal officiel Flutter pour enrichir le theme sans qu'un widget lise une
/// couleur en dur (docs/CONVENTIONS.md §4).
///
/// Acces depuis un widget :
/// `Theme.of(context).extension<CouleursMarque>()!`.
@immutable
class CouleursMarque extends ThemeExtension<CouleursMarque> {
  const CouleursMarque({
    required this.ocreDecoratif,
    required this.succes,
    required this.fondSucces,
  });

  /// Ocre de marque reserve aux surfaces NON textuelles (audit du 28/07) :
  /// anneaux de progression, barres, pastille « en cours ». Jamais sous du texte.
  final Color ocreDecoratif;

  /// Vert du statut « fait » (chapitre dont la fiche de revision est validee).
  final Color succes;

  /// Fond clair associe a [succes] pour les bandeaux de statut.
  final Color fondSucces;

  /// Jeu de valeurs pour le theme clair (le seul en V1).
  static const CouleursMarque clair = CouleursMarque(
    ocreDecoratif: Couleurs.ocreDecoratif,
    succes: Couleurs.succes,
    fondSucces: Couleurs.fondSucces,
  );

  @override
  CouleursMarque copyWith({
    Color? ocreDecoratif,
    Color? succes,
    Color? fondSucces,
  }) {
    return CouleursMarque(
      ocreDecoratif: ocreDecoratif ?? this.ocreDecoratif,
      succes: succes ?? this.succes,
      fondSucces: fondSucces ?? this.fondSucces,
    );
  }

  @override
  CouleursMarque lerp(covariant CouleursMarque? other, double t) {
    if (other == null) return this;
    return CouleursMarque(
      ocreDecoratif: Color.lerp(ocreDecoratif, other.ocreDecoratif, t)!,
      succes: Color.lerp(succes, other.succes, t)!,
      fondSucces: Color.lerp(fondSucces, other.fondSucces, t)!,
    );
  }
}

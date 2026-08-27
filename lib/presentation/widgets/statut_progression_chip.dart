import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';

/// Pastille d'un etat de progression (maquette V2.1, `statutChip` — ecrans 5 et
/// 6). Le sens est porte par TROIS canaux : icone + texte + couleur, jamais la
/// seule couleur (SPEC §6.2, accessibilite). Les couleurs viennent de la palette
/// auditee via le theme (paires couleur/fond validees AA le 28/07), jamais en dur.
class StatutProgressionChip extends StatelessWidget {
  const StatutProgressionChip({super.key, required this.etat});

  final EtatProgression etat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = couleursStatut(context, etat);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: couleurs.fond,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconeStatut(etat), size: 13, color: couleurs.premier),
            const SizedBox(width: 4),
            Text(
              etat.libelleAffichage,
              style: theme.textTheme.labelMedium?.copyWith(
                color: couleurs.premier,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icone associee a chaque etat (maquette `STMAP`). Choix de PRESENTATION (elle
/// importe Flutter), donc ici et pas dans l'enum du domaine (reste Dart pur).
IconData iconeStatut(EtatProgression etat) => switch (etat) {
  EtatProgression.aFaire => Icons.schedule,
  EtatProgression.enCours => Icons.play_arrow,
  EtatProgression.fait => Icons.check,
  EtatProgression.aRevoir => Icons.refresh,
};

/// Couleur de premier plan (texte + icone) et de fond d'un etat, prises dans la
/// palette auditee via le theme. Paires validees AA : « fait » vert/`fondSucces`,
/// « a revoir » = `error`/`errorContainer`, « en cours » = ocre `secondary`, « a
/// faire » = neutre.
({Color premier, Color fond}) couleursStatut(
  BuildContext context,
  EtatProgression etat,
) {
  final scheme = Theme.of(context).colorScheme;
  final marque = Theme.of(context).extension<CouleursMarque>()!;
  return switch (etat) {
    EtatProgression.aFaire => (
      premier: scheme.onSurfaceVariant,
      fond: scheme.surfaceContainerHighest,
    ),
    EtatProgression.enCours => (
      premier: scheme.onSecondaryContainer,
      fond: scheme.secondaryContainer,
    ),
    EtatProgression.fait => (premier: marque.succes, fond: marque.fondSucces),
    EtatProgression.aRevoir => (
      premier: scheme.onErrorContainer,
      fond: scheme.errorContainer,
    ),
  };
}

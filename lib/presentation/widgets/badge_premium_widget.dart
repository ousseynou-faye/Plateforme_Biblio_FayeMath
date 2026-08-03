import 'package:flutter/material.dart';

/// Badge indiquant si une ressource est gratuite ou premium.
///
/// Applique la regle « aucune information portee par la seule couleur »
/// (SPEC §6.2) : le statut porte a la fois une COULEUR, une ICONE et un TEXTE.
/// L'ensemble est annonce d'un bloc au lecteur d'ecran (« Premium » / « Gratuit »)
/// et l'icone, redondante avec le texte, est exclue de la semantique pour eviter
/// une double lecture. Composant purement informatif : il n'est pas une cible
/// tactile, la contrainte des 48 px ne s'y applique donc pas.
class BadgePremiumWidget extends StatelessWidget {
  const BadgePremiumWidget({super.key, required this.premium});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final couleurFond = premium
        ? colorScheme.secondaryContainer
        : colorScheme.primaryContainer;
    final couleurTexte = premium
        ? colorScheme.onSecondaryContainer
        : colorScheme.onPrimaryContainer;
    final icone = premium ? Icons.lock_outline : Icons.check_circle_outline;
    final libelle = premium ? 'Premium' : 'Gratuit';

    return Semantics(
      label: libelle,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(icone, size: 15, color: couleurTexte),
              ),
              const SizedBox(width: 5),
              Text(
                libelle,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: couleurTexte,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

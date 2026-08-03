import 'package:flutter/material.dart';

/// Bouton d'action principal de l'application (le CTA « Valider », « Commencer »...).
///
/// S'appuie entierement sur le theme (docs/CONVENTIONS.md §4) : couleur ocre
/// fonctionnelle `secondary` (#96501F, 6,06:1 sous blanc — SPEC §6.1), hauteur
/// minimale 48 px et forme heritees du `filledButtonTheme`. Passer
/// `onPressed: null` desactive le bouton (grise, non focusable) : c'est l'etat
/// « pas encore pret » du CTA de l'ecran choix classe/serie/matiere.
class BoutonPrimaireWidget extends StatelessWidget {
  const BoutonPrimaireWidget({
    super.key,
    required this.libelle,
    required this.onPressed,
    this.icone,
    this.pleineLargeur = true,
  });

  final String libelle;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool pleineLargeur;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = FilledButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      // Pleine largeur par defaut (CTA de bas d'ecran) ; sinon ajuste au contenu,
      // en gardant la hauteur 48 px du theme.
      minimumSize: pleineLargeur
          ? const Size.fromHeight(48)
          : const Size(0, 48),
    );

    if (icone != null) {
      // L'icone est redondante avec le libelle : Flutter ne l'annonce pas seule,
      // le texte suffit au lecteur d'ecran.
      return FilledButton.icon(
        onPressed: onPressed,
        style: style,
        icon: Icon(icone),
        label: Text(libelle),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: style,
      child: Text(libelle),
    );
  }
}

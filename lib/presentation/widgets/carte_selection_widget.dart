import 'package:flutter/material.dart';

/// Carte de selection reutilisable — la brique de l'ecran choix
/// classe / serie / matiere (etape 14) et de tout choix a options.
///
/// C'est un VRAI bouton (retour d'audit : « cartes devenues de vrais boutons ») :
/// cible tactile >= 48 px, focusable, et l'etat selectionne ne repose PAS que sur
/// la couleur — il porte une coche explicite (SPEC §6.2, regle « aucune
/// information par la seule couleur »). L'ensemble est annonce au lecteur d'ecran
/// via `Semantics(button:, selected:, label:)` ; les icones, redondantes, en sont
/// exclues.
class CarteSelectionWidget extends StatelessWidget {
  const CarteSelectionWidget({
    super.key,
    required this.titre,
    required this.selectionnee,
    required this.onTap,
    this.sousTitre,
    this.icone,
  });

  final String titre;
  final bool selectionnee;
  final VoidCallback? onTap;
  final String? sousTitre;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Accessibilite : si l'utilisateur a demande a reduire les animations, on
    // supprime l'effet d'encre au toucher (MediaQuery.disableAnimations).
    final reduireMouvement = MediaQuery.of(context).disableAnimations;

    final couleurBordure = selectionnee
        ? colorScheme.primary
        : colorScheme.outlineVariant;
    final couleurFond = selectionnee
        ? colorScheme.primaryContainer
        : colorScheme.surface;

    return Semantics(
      button: true,
      selected: selectionnee,
      label: sousTitre == null ? titre : '$titre, $sousTitre',
      child: Material(
        color: couleurFond,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: couleurBordure,
                width: selectionnee ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (icone != null) ...[
                  ExcludeSemantics(
                    child: Icon(icone, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: _Libelles(titre: titre, sousTitre: sousTitre),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: Icon(
                    selectionnee ? Icons.check_circle : Icons.chevron_right,
                    color: selectionnee
                        ? colorScheme.primary
                        : colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bloc titre + sous-titre optionnel de la carte.
class _Libelles extends StatelessWidget {
  const _Libelles({required this.titre, this.sousTitre});

  final String titre;
  final String? sousTitre;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(titre, style: textTheme.titleMedium),
        if (sousTitre != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(sousTitre!, style: textTheme.bodySmall),
          ),
      ],
    );
  }
}

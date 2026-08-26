import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/network/etat_reseau.dart';
import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/presentation/providers/etat_reseau_provider.dart';

/// Bandeau d'etat du reseau, en haut de chaque ecran de contenu (SPEC §2.2/2.3).
/// UNE seule source ([etatReseauProvider]) : aucun ecran n'ecrit son statut en
/// dur. Volontairement distinct de la disponibilite d'un document, qui s'affiche
/// ligne par ligne (ARCHITECTURE §7, GLOSSAIRE §6) — deux notions, jamais melangees.
///
/// Accessibilite (SPEC §6.2) :
///  - l'etat n'est JAMAIS porte par la seule couleur : « Hors-ligne » et
///    « Reconnexion... » ont la MEME teinte ambre et ne se distinguent que par le
///    LIBELLE texte + un point colore ;
///  - region live : tout changement d'etat est annonce au lecteur d'ecran.
///
/// Couleurs : palette auditee AA uniquement (couleurs.dart interdit tout ajout).
/// L'« ambre » de la maquette -> `ocreDecoratif`, le token exact des pastilles NON
/// textuelles (jamais sous du texte) ; le vert -> `succes`. Le point ne porte pas
/// de texte, son contraste graphique suffit. Le « clignotant » de reconnexion
/// (SPEC §2.3) est rendu STATIQUEMENT : le libelle distinct le differencie deja, et
/// on evite ainsi une animation imposee (reduction de mouvement) — ecart assume,
/// une pulsation gardee par `disableAnimations` pourra etre ajoutee plus tard.
class BandeauReseauWidget extends ConsumerWidget {
  const BandeauReseauWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // `.value` est null tant que l'etat n'est pas connu (1re lecture) ou en test
    // sans plugin : on n'affiche RIEN plutot qu'un statut par defaut trompeur.
    final etat = ref.watch(etatReseauProvider).value;
    if (etat == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final marque = theme.extension<CouleursMarque>()!;

    final (String libelle, Color couleurPoint) = switch (etat) {
      EtatReseau.enLigne => ('En ligne', marque.succes),
      EtatReseau.horsLigne => ('Hors-ligne', marque.ocreDecoratif),
      EtatReseau.reconnexion => ('Reconnexion...', marque.ocreDecoratif),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      label: 'Etat du reseau : $libelle',
      // Le visuel est exclu de la semantique : l'annonce vient du seul `label`
      // ci-dessus, pas d'une relecture du point + texte (evite le doublon).
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: couleurPoint),
                const SizedBox(width: 8),
                Text(
                  libelle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
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

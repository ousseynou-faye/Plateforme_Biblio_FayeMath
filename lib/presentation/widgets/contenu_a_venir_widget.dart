import 'package:flutter/material.dart';

/// Corps « a venir » partage par les onglets encore vides (Accueil / Profil,
/// etape 20) : cercle + titre + explication, sans action. On annonce clairement
/// qu'une fonctionnalite arrive plutot que d'afficher un ecran vide ou faux.
///
/// Le [titre] est volontairement distinct de l'etat vide de la liste des chapitres
/// (« Bientot disponible ») pour ne pas creer d'ambiguite a l'ecran.
class ContenuAVenirWidget extends StatelessWidget {
  const ContenuAVenirWidget({
    super.key,
    required this.icone,
    required this.titre,
    required this.texte,
  });

  final IconData icone;
  final String titre;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              child: Icon(icone, size: 32, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 14),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              texte,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

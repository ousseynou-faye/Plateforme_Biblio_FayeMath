import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';

/// Onglet « Accueil » de la barre du bas (maquette V2.1, ecran 4 « Tableau de
/// bord »), etape 24. Version MINIMALE : une carte de progression compacte (anneau
/// + « X chapitres sur Y ») qui MENE a l'ecran « Ma progression » (ecran 9), le
/// detail complet. Remplace le placeholder de l'etape 20.
///
/// DIFFERE (maquette ecran 4, hors perimetre etape 24) : la carte « Seance avec ton
/// tuteur » (ecran 20, non construit) et « Reprendre les exercices » avec duree
/// estimee (pas de notion de duree ni de « chapitre en cours de lecture » modelisee).
/// Pas de « Bonjour {prenom} » : le champ nom a ete retire a l'etape 13.
class TableauBordScreen extends ConsumerWidget {
  const TableauBordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avancementAsync = ref.watch(avancementProgressionProvider);
    final bib = ref.watch(bibliothequeCouranteProvider).value;
    final sousTitre = bib == null
        ? ''
        : '${bib.classe.nom} · ${bib.matiere.nom}';

    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _TitreSection('Ta progression'),
            switch (avancementAsync) {
              AsyncData(:final value) => _CarteProgression(
                avancement: value,
                sousTitre: sousTitre,
              ),
              AsyncError() => const _CarteIndisponible(),
              _ => const _CarteChargement(),
            },
          ],
        ),
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Text(
        texte,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Carte compacte de progression, TAPPABLE : anneau + « X chapitres sur Y » +
/// classe/matiere, avec un chevron. Le tap ouvre « Ma progression » (ecran 9).
/// Vrai bouton accessible (>= 48 px, Semantics).
class _CarteProgression extends StatelessWidget {
  const _CarteProgression({required this.avancement, required this.sousTitre});

  final AvancementProgression avancement;
  final String sousTitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pct = avancement.pourcentageGlobal;
    return Semantics(
      button: true,
      label: 'Ma progression, $pct pour cent. '
          '${avancement.fait} chapitres sur ${avancement.total}.',
      excludeSemantics: true,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          // Route racine (empilee au-dessus des onglets), litteral car
          // `presentation/` n'importe pas `routing/` (ARCHITECTURE §3).
          onTap: () => context.pushNamed('ma-progression'),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _AnneauCompact(pourcentage: pct),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ma progression',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${avancement.fait} chapitres sur ${avancement.total}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (sousTitre.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          sousTitre,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Petit anneau (l'arc est decoratif ; le pourcentage est porte par le texte).
class _AnneauCompact extends StatelessWidget {
  const _AnneauCompact({required this.pourcentage});

  final int pourcentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final marque = theme.extension<CouleursMarque>()!;
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: pourcentage / 100,
              strokeWidth: 7,
              backgroundColor: theme.colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(marque.ocreDecoratif),
            ),
          ),
          Text(
            '$pourcentage %',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CarteChargement extends StatelessWidget {
  const _CarteChargement();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _CarteIndisponible extends StatelessWidget {
  const _CarteIndisponible();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off, size: 22, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ta progression n\'est pas disponible pour le moment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

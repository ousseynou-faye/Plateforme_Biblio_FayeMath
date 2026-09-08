import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';
import 'package:fayemath_academy/presentation/widgets/statut_progression_chip.dart';

/// Ecran « Ma progression » (maquette V2.1, ecran 9), etape 24 — derniere etape de
/// la Phase 3. Affiche l'avancement GLOBAL (anneau) ET PAR MATIERE (barres), plus
/// le detail par etat (4 mini-stats) et la carte « Ta prochaine action » (le
/// chapitre a revoir). Tout se derive de [avancementProgressionProvider] (reactif).
///
/// Ecran EMPILE (fleche retour), atteint depuis le tableau de bord (onglet Accueil,
/// ecran 4) — il n'a pas la barre d'onglets. La « regularite hebdomadaire » de la
/// maquette est DIFFEREE (elle exige une donnee d'activite par semaine non encore
/// modelisee ; ecart assume, Journal etape 24).
class MaProgressionScreen extends ConsumerWidget {
  const MaProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avancementAsync = ref.watch(avancementProgressionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ma progression')),
      body: SafeArea(
        child: Column(
          children: [
            // Route racine (empilee au-dessus des onglets) : le bandeau reseau
            // est ajoute a la main, comme le detail et le lecteur (etape 21), la
            // coquille a onglets ne le porte pas ici.
            const BandeauReseauWidget(),
            Expanded(
              child: switch (avancementAsync) {
                AsyncData(:final value) => _Corps(avancement: value),
                AsyncError() => const _EtatErreur(),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Corps extends ConsumerWidget {
  const _Corps({required this.avancement});

  final AvancementProgression avancement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bib = ref.watch(bibliothequeCouranteProvider).value;
    final matieres = ref.watch(matieresProvider).value ?? const <Matiere>[];
    final nomParId = {for (final m in matieres) m.id: m.nom};
    final aRevoir = ref.watch(prochainChapitreARevoirProvider);

    final sousTitre = bib == null
        ? ''
        : '${bib.classe.nom} · ${bib.matiere.nom}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CarteAnneau(avancement: avancement, sousTitre: sousTitre),
        const SizedBox(height: 12),
        _RangeeMiniStats(avancement: avancement),
        const SizedBox(height: 14),
        const _CalloutFait(),
        if (aRevoir != null) ...[
          const SizedBox(height: 14),
          const _SectionTitre('Ta prochaine action'),
          _CarteProchaineAction(chapitre: aRevoir),
        ],
        if (avancement.parMatiere.isNotEmpty) ...[
          const SizedBox(height: 14),
          const _SectionTitre('Par matiere'),
          for (final matiere in avancement.parMatiere) ...[
            _BarreMatiere(
              avancement: matiere,
              nom: nomParId[matiere.matiereId] ?? 'Matiere',
            ),
            const SizedBox(height: 9),
          ],
        ],
        const SizedBox(height: 4),
        _NotePhysiqueChimie(classeNom: bib?.classe.nom ?? 'ta classe'),
      ],
    );
  }
}

/// Carte du haut : le grand anneau de progression globale + classe/matiere + le
/// rappel « X chapitres sur Y ».
class _CarteAnneau extends StatelessWidget {
  const _CarteAnneau({required this.avancement, required this.sousTitre});

  final AvancementProgression avancement;
  final String sousTitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _Anneau(pourcentage: avancement.pourcentageGlobal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sousTitre.isNotEmpty)
                  Text(
                    sousTitre,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  avancement.fait == 1
                      ? '1 chapitre sur ${avancement.total}'
                      : '${avancement.fait} chapitres sur ${avancement.total}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// L'anneau lui-meme : arc ocre decoratif + pourcentage au centre. Le sens est
/// porte par le TEXTE (« X % · termine ») et un libelle Semantics ; l'arc n'est
/// que decoratif (jamais la seule couleur, SPEC §6.2).
class _Anneau extends StatelessWidget {
  const _Anneau({required this.pourcentage});

  final int pourcentage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final marque = theme.extension<CouleursMarque>()!;
    return Semantics(
      label: 'Progression $pourcentage pour cent',
      excludeSemantics: true,
      child: SizedBox(
        width: 82,
        height: 82,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 82,
              height: 82,
              child: CircularProgressIndicator(
                value: pourcentage / 100,
                strokeWidth: 8,
                backgroundColor: theme.colorScheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  marque.ocreDecoratif,
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pourcentage %',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'termine',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Les 4 mini-stats (fait / en cours / a revoir / a faire), memes couleurs que la
/// pastille de statut (palette auditee), le nombre ET le libelle portant le sens.
class _RangeeMiniStats extends StatelessWidget {
  const _RangeeMiniStats({required this.avancement});

  final AvancementProgression avancement;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            nombre: avancement.fait,
            libelle: 'fait',
            etat: EtatProgression.fait,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _MiniStat(
            nombre: avancement.enCours,
            libelle: 'en cours',
            etat: EtatProgression.enCours,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _MiniStat(
            nombre: avancement.aRevoir,
            libelle: 'a revoir',
            etat: EtatProgression.aRevoir,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _MiniStat(
            nombre: avancement.aFaire,
            libelle: 'a faire',
            etat: EtatProgression.aFaire,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.nombre,
    required this.libelle,
    required this.etat,
  });

  final int nombre;
  final String libelle;
  final EtatProgression etat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final couleurs = couleursStatut(context, etat);
    return Semantics(
      label: '$nombre $libelle',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: couleurs.fond,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Text(
              '$nombre',
              style: theme.textTheme.titleMedium?.copyWith(
                color: couleurs.premier,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              libelle,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: couleurs.premier,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rappel du sens metier de « fait » (GLOSSAIRE §5) : valide != ouvert.
class _CalloutFait extends StatelessWidget {
  const _CalloutFait();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ce que veut dire « fait »',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Un chapitre est marque « fait » quand sa fiche de revision '
                  'est validee, pas seulement quand le cours a ete ouvert.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Titre de section (« Ta prochaine action », « Par matiere »).
class _SectionTitre extends StatelessWidget {
  const _SectionTitre(this.texte);

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

/// Carte « Ta prochaine action » : propose de revoir le chapitre marque « a
/// revoir ». Vrai bouton accessible (>= 48 px) ; le tap ouvre le detail du chapitre
/// (ecran 6), comme depuis la liste.
class _CarteProchaineAction extends StatelessWidget {
  const _CarteProchaineAction({required this.chapitre});

  final Chapitre chapitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final couleursRevoir = couleursStatut(context, EtatProgression.aRevoir);
    return Semantics(
      button: true,
      label: 'Revoir le chapitre ${chapitre.numero}, ${chapitre.titre}',
      excludeSemantics: true,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.pushNamed(
            'chapitre',
            pathParameters: {'chapitreId': chapitre.id},
            extra: chapitre,
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(color: theme.extension<CouleursMarque>()!.ocreDecoratif),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: couleursRevoir.fond,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    iconeStatut(EtatProgression.aRevoir),
                    size: 18,
                    color: couleursRevoir.premier,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Revoir : ${chapitre.titre}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chapitre ${chapitre.numero}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Une matiere : nom + pourcentage + barre de progression + « X chapitres sur Y ».
class _BarreMatiere extends StatelessWidget {
  const _BarreMatiere({required this.avancement, required this.nom});

  final AvancementMatiere avancement;
  final String nom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final marque = theme.extension<CouleursMarque>()!;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  nom,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${avancement.pourcentage} %',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: marque.ocreDecoratif,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Semantics(
            label: '$nom : ${avancement.pourcentage} pour cent',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: avancement.pourcentage / 100,
                minHeight: 8,
                backgroundColor: scheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(marque.ocreDecoratif),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            avancement.fait == 1
                ? '1 chapitre sur ${avancement.total}'
                : '${avancement.fait} chapitres sur ${avancement.total}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Note de bas d'ecran : la physique-chimie apparaitra quand sa bibliotheque
/// existera (maquette ecran 9). Pas de carte fantome pour une matiere absente.
class _NotePhysiqueChimie extends StatelessWidget {
  const _NotePhysiqueChimie({required this.classeNom});

  final String classeNom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'La physique-chimie apparaitra ici des que sa bibliotheque de '
      '$classeNom sera disponible.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.45,
      ),
    );
  }
}

/// Etat d'erreur (agregation impossible : catalogue/chapitres injoignables ET cache
/// vide). Rare — la progression est locale ; ne survient que si la bibliotheque
/// courante ne se resout pas.
class _EtatErreur extends StatelessWidget {
  const _EtatErreur();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger ta progression.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/format/taille_fichier.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/mes_telechargements_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';

/// Ecran « Mes telechargements » (maquette V2.1, ecran 8 « Mes documents
/// hors-ligne »). Liste ce qui est REELLEMENT sur l'appareil, groupe par chapitre,
/// et coiffe la liste d'un anneau de couverture (« X chapitres sur Y hors-ligne »).
///
/// Par construction, tout ce que cet ecran affiche EST disponible localement : il
/// ne parle donc que de DISPONIBILITE (« sur l'appareil »), jamais d'etat reseau —
/// deux notions a ne jamais confondre (docs/GLOSSAIRE.md §6). Il reste utilisable
/// hors-ligne, ce qui est tout l'interet.
///
/// Perimetre de ce lot (B) : l'affichage. La suppression par ligne (ecran 16
/// individuel) arrive au Lot D ; le bouton « Gerer tout mon espace hors-ligne »
/// (suppression groupee, ecran 16) au Lot E. L'entree via la barre d'onglets vient
/// au Lot C — ici l'ecran est autonome (un Scaffold a lui seul), teste isolement.
class MesTelechargementsScreen extends ConsumerWidget {
  const MesTelechargementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes telechargements')),
      body: SafeArea(child: _corps(ref)),
    );
  }

  Widget _corps(WidgetRef ref) {
    final biblio = ref.watch(bibliothequeCouranteProvider);
    return switch (biblio) {
      AsyncError() => const _EtatErreur(),
      AsyncData(:final value) when value != null => _ApercuAsync(cle: value.cle),
      // Chargement, ou aucune bibliotheque resolue (la redirection s'en charge).
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

/// Lit l'apercu (liste + anneau) une fois la bibliotheque connue, et gere les trois
/// etats de l'`AsyncValue`.
class _ApercuAsync extends ConsumerWidget {
  const _ApercuAsync({required this.cle});

  final ({String classeId, String matiereId}) cle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apercuAsync = ref.watch(apercuHorsLigneProvider(cle));
    final apercu = apercuAsync.value;

    if (apercu == null) {
      if (apercuAsync.hasError) {
        return _EtatErreur(
          onReessayer: () => ref.invalidate(apercuHorsLigneProvider(cle)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (apercu.estVide) return const _EtatVide();
    return _Liste(
      apercu: apercu,
      onSupprimer: (ressource) => _confirmerEtSupprimer(context, ref, ressource),
    );
  }

  /// Supprime un document APRES une confirmation explicite : symetrique de la
  /// regle 1 du contrat hors-ligne (rien ne se telecharge sans action explicite —
  /// rien ne s'efface non plus). Seul le FICHIER local est supprime ; la ligne
  /// `telechargement` n'est jamais touchee (le disque est la seule source de verite
  /// de la presence locale). L'invalidation relit disque + catalogue : la ligne
  /// disparait et l'anneau de couverture se recalcule.
  Future<void> _confirmerEtSupprimer(
    BuildContext context,
    WidgetRef ref,
    Ressource ressource,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce document ?'),
        content: const Text(
          'Il ne sera plus lisible hors connexion. Tu pourras le retelecharger '
          'quand tu veux.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirme != true) return;

    await ref.read(telechargementRepositoryProvider).supprimer(ressource.id);
    ref.invalidate(apercuHorsLigneProvider(cle));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Document supprime')));
  }
}

/// La liste chargee : l'anneau de couverture, puis un en-tete par chapitre suivi de
/// ses documents telecharges.
class _Liste extends StatelessWidget {
  const _Liste({required this.apercu, required this.onSupprimer});

  final ApercuHorsLigne apercu;

  /// Appele quand l'eleve demande la suppression d'un document (via sa poubelle).
  final void Function(Ressource ressource) onSupprimer;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _EnteteCompletion(ratio: apercu.ratio),
        for (final groupe in apercu.groupes) ...[
          _EnteteChapitre(
            numero: groupe.chapitre.numero,
            titre: groupe.chapitre.titre,
          ),
          for (final document in groupe.documents)
            _LigneDocument(
              ressource: document,
              onSupprimer: () => onSupprimer(document),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

/// L'anneau de couverture (maquette ecran 8) : « X % des chapitres hors-ligne »
/// et « X chapitres sur Y disponibles hors-ligne ». C'est une COUVERTURE de
/// contenu, jamais un espace disque ni un quota (SPEC §4.3).
class _EnteteCompletion extends StatelessWidget {
  const _EnteteCompletion({required this.ratio});

  final RatioHorsLigne ratio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = ratio.chapitresTotal;
    final faits = ratio.chapitresHorsLigne;
    // Formulation correcte pour toute valeur (« 0 sur 19 », « 1 sur 2 »), sans
    // piege de singulier/pluriel.
    final texteCompte = '$faits sur $total chapitres disponibles hors-ligne';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          // L'anneau + le pourcentage, decrits d'une seule voix aux lecteurs
          // d'ecran (l'anneau seul ne dit rien).
          Semantics(
            label: '${ratio.pourcentage} pour cent des chapitres '
                'disponibles hors-ligne',
            child: SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: ratio.fraction,
                      strokeWidth: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Text(
                    '${ratio.pourcentage} %',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disponible hors-ligne',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  texteCompte,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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

/// En-tete d'un chapitre (« Chapitre N · Titre »), au-dessus de ses documents.
class _EnteteChapitre extends StatelessWidget {
  const _EnteteChapitre({required this.numero, required this.titre});

  final int numero;
  final String titre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        'Chapitre $numero · $titre',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Une ligne de document telecharge : icone du type + libelle + taille, et une
/// poubelle pour le retirer de l'appareil (cible tactile de 48 px, libelle lu par
/// les lecteurs d'ecran via le tooltip).
class _LigneDocument extends StatelessWidget {
  const _LigneDocument({required this.ressource, required this.onSupprimer});

  final Ressource ressource;
  final VoidCallback onSupprimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primaryContainer,
            ),
            child: Icon(
              _iconePourType(ressource.type),
              size: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ressource.type.libelleAffichage,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            TailleFichier.enTexte(ressource.tailleOctets),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Supprimer ce document',
            color: colorScheme.onSurfaceVariant,
            onPressed: onSupprimer,
          ),
        ],
      ),
    );
  }

  // Meme correspondance type -> icone que l'ecran de detail (ecran 6), pour qu'un
  // document garde la meme icone d'un ecran a l'autre.
  static IconData _iconePourType(TypeRessource type) => switch (type) {
    TypeRessource.cours => Icons.description_outlined,
    TypeRessource.resume => Icons.summarize_outlined,
    TypeRessource.exercices => Icons.edit_outlined,
    TypeRessource.corrige => Icons.fact_check_outlined,
    TypeRessource.revision => Icons.sticky_note_2_outlined,
    TypeRessource.evaluation => Icons.assignment_outlined,
    TypeRessource.corrigeEvaluation => Icons.assignment_turned_in_outlined,
    TypeRessource.sujetExamen => Icons.school_outlined,
  };
}

/// Etat vide : rien n'a encore ete telecharge. Meme structure que les autres etats
/// vides (cercle + titre + texte), avec un texte qui explique comment en obtenir.
class _EtatVide extends StatelessWidget {
  const _EtatVide();

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
              child: Icon(
                Icons.cloud_download_outlined,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Aucun document hors-ligne',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Telecharge un document depuis un chapitre pour le retrouver ici, '
              'lisible sans reseau.',
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

/// Etat d'erreur (bibliotheque ou apercu injoignable ET cache vide) : message clair
/// et, si une relecture est possible, un bouton pour reessayer.
class _EtatErreur extends StatelessWidget {
  const _EtatErreur({this.onReessayer});

  final VoidCallback? onReessayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Impossible d\'afficher tes telechargements.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (onReessayer != null) ...[
              const SizedBox(height: 16),
              TextButton(
                style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
                onPressed: onReessayer,
                child: const Text('Reessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

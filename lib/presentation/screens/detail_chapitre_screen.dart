import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/format/taille_fichier.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/widgets/badge_premium_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// Detail d'un chapitre (maquette V2.1, ecran 6) : le titre, un statut de
/// progression, puis « Les N documents du chapitre » — chaque document avec son
/// type, sa taille et son badge gratuit/premium.
///
/// Perimetre volontairement reduit (valide avec Ousseynou, etape 16) :
///  - le statut de progression est TOUJOURS « A faire » et le bouton « Modifier »
///    est un placeholder : aucun `ProgressionRepository` n'existe encore
///    (affichage seulement — voir Journal etape 16) ;
///  - la ligne d'un document n'affiche PAS d'etat de telechargement : les 8 etats
///    de SPEC §2.4 supposent un moteur de telechargement / une detection reseau
///    inexistants. On AFFICHE, on ne telecharge pas (etape 17 / Phase 3) ; le tap
///    reste un placeholder, comme la ligne de chapitre a l'etape 15 ;
///  - le bandeau hors-ligne est omis (detection reseau = Phase 3).
///
/// Tant qu'aucune ressource reelle n'existe en base (contenu = etape 18), l'ecran
/// affiche son ETAT VIDE — comportement attendu, pas une erreur.
class DetailChapitreScreen extends ConsumerWidget {
  const DetailChapitreScreen({super.key, required this.chapitre});

  final Chapitre chapitre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ressourcesAsync = ref.watch(ressourcesProvider(chapitre.id));
    final ressources = ressourcesAsync.value;

    return Scaffold(
      appBar: AppBar(title: Text('Chapitre ${chapitre.numero}')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (ressources == null) {
              if (ressourcesAsync.hasError) {
                return _EtatErreur(
                  onReessayer: () =>
                      ref.invalidate(ressourcesProvider(chapitre.id)),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }
            return _Corps(chapitre: chapitre, ressources: ressources);
          },
        ),
      ),
    );
  }
}

/// Le corps une fois les ressources connues : entete (titre + statut) toujours
/// visible, puis la liste des documents ou l'etat vide.
class _Corps extends StatelessWidget {
  const _Corps({required this.chapitre, required this.ressources});

  final Chapitre chapitre;
  final List<Ressource> ressources;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Entete(chapitre: chapitre),
        const SizedBox(height: 16),
        if (ressources.isEmpty)
          const _DocumentsIndisponibles()
        else ...[
          _TitreSection(nombre: ressources.length),
          const SizedBox(height: 8),
          for (final ressource in ressources)
            _LigneDocument(ressource: ressource, chapitre: chapitre),
          const SizedBox(height: 8),
          const _NoteBasDePage(),
        ],
      ],
    );
  }
}

/// Titre du chapitre + ligne de statut de progression (affichage seulement).
class _Entete extends StatelessWidget {
  const _Entete({required this.chapitre});

  final Chapitre chapitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chapitre.titre,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Statut :',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            // Toujours « A faire » a cette etape : aucune progression enregistree.
            const _StatutChip(etat: EtatProgression.aFaire),
            const Spacer(),
            const _BoutonModifierStatut(),
          ],
        ),
      ],
    );
  }
}

/// La pastille de statut. Le sens est porte par le TEXTE (jamais la seule
/// couleur, SPEC §6.2) ; le libelle vient de l'enum (`libelleAffichage`).
class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.etat});

  final EtatProgression etat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          etat.libelleAffichage,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// « Modifier » le statut : placeholder tant que la progression n'existe pas
/// (meme motif que « Mot de passe oublie ? » a l'etape 13). Cible tactile 48 px.
class _BoutonModifierStatut extends StatelessWidget {
  const _BoutonModifierStatut();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
      onPressed: () => _afficherBientot(
        context,
        'Le suivi de progression arrive bientot.',
      ),
      child: const Text('Modifier'),
    );
  }
}

/// « Les N documents du chapitre » — N est COMPTE (jamais « 4 » en dur, point (d)).
class _TitreSection extends StatelessWidget {
  const _TitreSection({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    final libelle = nombre == 1
        ? '1 document du chapitre'
        : 'Les $nombre documents du chapitre';
    return Text(
      libelle,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

/// Une ligne de document : icone du type, libelle, taille, badge gratuit/premium.
/// Vrai bouton accessible (>= 48 px, Semantics). Le tap OUVRE le lecteur (ecran 7,
/// etape 17) via une navigation imperative (`pushNamed('document', ...)`).
class _LigneDocument extends StatelessWidget {
  const _LigneDocument({required this.ressource, required this.chapitre});

  final Ressource ressource;
  final Chapitre chapitre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    final taille = TailleFichier.enTexte(ressource.tailleOctets);
    final statut = ressource.premium ? 'Premium' : 'Gratuit';

    return Semantics(
      button: true,
      label: '${ressource.type.libelleAffichage}, $taille, $statut',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(11),
            splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
            // Ouvre le lecteur (ecran 7). On EMPILE l'ecran pour que « retour »
            // revienne au detail. La Ressource ET le Chapitre (deja charges)
            // voyagent ENSEMBLE en `extra` (record) ; les id vont en parametres
            // de route (URL /chapitre/<id>/document/<id>). Le nom « document » est
            // defini dans routing/ (nomRouteDocument) ; `presentation/` ne peut
            // pas importer `routing/` (ARCHITECTURE §3), d'ou le litteral.
            onTap: () => context.pushNamed(
              'document',
              pathParameters: {
                'chapitreId': chapitre.id,
                'ressourceId': ressource.id,
              },
              extra: (ressource: ressource, chapitre: chapitre),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  _IconeType(type: ressource.type),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ressource.type.libelleAffichage,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          taille,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  BadgePremiumWidget(premium: ressource.premium),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// La vignette d'icone du type. L'icone est un choix de PRESENTATION (elle
/// importe Flutter), donc cablee ici et pas dans l'enum du domaine (point (h)).
/// Fond neutre uniforme : c'est le badge qui porte gratuit/premium, pas l'icone.
class _IconeType extends StatelessWidget {
  const _IconeType({required this.type});

  final TypeRessource type;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(_iconePour(type), size: 18, color: colorScheme.onPrimaryContainer),
    );
  }

  static IconData _iconePour(TypeRessource type) => switch (type) {
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

/// La note de bas de page de la maquette (sans accents, CONVENTIONS §1).
class _NoteBasDePage extends StatelessWidget {
  const _NoteBasDePage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'La taille est indiquee avant le telechargement : tu sais toujours ce que '
      'ca coute en forfait. Le corrige detaille fait partie de l\'offre Premium.',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.55,
      ),
    );
  }
}

/// Etat vide : le chapitre existe mais n'a encore aucun document en ligne (cas
/// normal jusqu'a l'etape 18). Meme structure que l'etat vide de l'ecran 5.
class _DocumentsIndisponibles extends StatelessWidget {
  const _DocumentsIndisponibles();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 28),
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
              Icons.folder_open_outlined,
              size: 32,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Documents bientot disponibles',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Les documents de ce chapitre ne sont pas encore en ligne. '
            'Reviens bientot !',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etat d'erreur (ressources injoignables ET cache vide) : message clair + bouton
/// pour reessayer. Calque sur l'etat d'erreur de l'ecran 5.
class _EtatErreur extends StatelessWidget {
  const _EtatErreur({required this.onReessayer});

  final VoidCallback onReessayer;

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
              'Impossible de charger les documents.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Verifie ta connexion, puis reessaie.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            BoutonPrimaireWidget(
              libelle: 'Reessayer',
              onPressed: onReessayer,
              pleineLargeur: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// Un placeholder homogene : les actions pas encore construites (ouvrir un
/// document, modifier la progression) le disent clairement plutot que de ne rien
/// faire. A remplacer par la vraie action a l'etape correspondante.
void _afficherBientot(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

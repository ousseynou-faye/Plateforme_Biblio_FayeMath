import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/format/taille_fichier.dart';
import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/progression_provider.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/widgets/badge_premium_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';
import 'package:fayemath_academy/presentation/widgets/statut_progression_chip.dart';

/// Detail d'un chapitre (maquette V2.1, ecran 6) : le titre, un statut de
/// progression, puis « Les N documents du chapitre » — chaque document avec son
/// type, sa taille et son badge gratuit/premium.
///
/// Depuis l'etape 22, le statut de progression est REEL : la pastille reflete
/// l'etat enregistre (defaut « A faire »), et « Modifier » ouvre le selecteur des
/// 4 etats — modifiable meme hors-ligne (ecriture locale d'abord). Pour un invite
/// (progression liee au compte), « Modifier » invite a creer un compte.
///
/// La ligne d'un document n'affiche PAS d'etat de telechargement (decision etape
/// 16, toujours en vigueur : ni « a telecharger », ni « en cours »...) — seulement
/// type + taille + badge. Depuis l'etape 25 elle porte en plus le VERROU premium :
/// selon le droit d'acces (invite / connecte sans abonnement / abonne), le tap
/// ouvre le lecteur (ecran 7), invite a creer un compte, ou mene a « Voir l'offre »
/// (cf. [_LigneDocument]). Le verrou est cote application EN PLUS du garde-fou
/// serveur (policy Storage) : aucun octet n'est consomme pour dire « non ».
///
/// Depuis l'etape 21, un [BandeauReseauWidget] coiffe l'ecran (SPEC §2.2 : bandeau
/// haut de CHAQUE ecran de contenu) — distinct de la disponibilite d'un document.
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
        child: Column(
          children: [
            const BandeauReseauWidget(),
            Expanded(
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
          ],
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

/// Titre du chapitre + ligne de statut de progression REELLE (etape 22). Lit
/// l'etat via [etatChapitreProvider] (defaut « A faire ») et se rafraichit tout
/// seul apres une modification (flux `.watch()`). « Modifier » ouvre le selecteur.
class _Entete extends ConsumerWidget {
  const _Entete({required this.chapitre});

  final Chapitre chapitre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final etat =
        ref.watch(etatChapitreProvider(chapitre.id)).value ??
        EtatProgression.aFaire;
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
            StatutProgressionChip(etat: etat),
            const Spacer(),
            // Cible tactile 48 px (comme « Mot de passe oublie ? », etape 13).
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
              onPressed: () => _modifierStatut(context, ref, chapitre.id, etat),
              child: const Text('Modifier'),
            ),
          ],
        ),
      ],
    );
  }
}

/// Ouvre le selecteur des 4 etats et enregistre le choix (ecriture locale
/// d'abord, meme hors-ligne). Un invite ne peut pas persister de progression
/// (RLS `to authenticated`) : on l'invite a creer un compte plutot que de laisser
/// une action sans effet. Un retour est confirme par un SnackBar (SPEC : toute
/// action donne un retour a l'eleve).
Future<void> _modifierStatut(
  BuildContext context,
  WidgetRef ref,
  String chapitreId,
  EtatProgression etatActuel,
) async {
  if (ref.read(etatAuthProvider) is! AuthConnecte) {
    _afficherMessage(context, 'Cree un compte pour suivre ta progression.');
    return;
  }
  final choisi = await showModalBottomSheet<EtatProgression>(
    context: context,
    showDragHandle: true,
    builder: (context) => _SelecteurStatut(etatActuel: etatActuel),
  );
  if (choisi == null || choisi == etatActuel) return;
  await ref
      .read(suiviProgressionProvider)
      .definirEtat(chapitreId: chapitreId, etat: choisi);
  if (context.mounted) {
    _afficherMessage(context, 'Statut : ${choisi.libelleAffichage}');
  }
}

/// Le selecteur des 4 etats (feuille du bas). Chaque option porte icone + libelle
/// + couleur ; l'etat courant porte une COCHE (la selection ne repose jamais sur
/// la seule couleur, SPEC §6.2). L'option « Fait » rappelle la regle metier
/// (GLOSSAIRE §5) : un chapitre est « fait » quand sa fiche de revision est
/// validee — le choix reste manuel a cette etape (pas encore de moteur de
/// correction), d'ou ce rappel affiche au moment de choisir.
class _SelecteurStatut extends StatelessWidget {
  const _SelecteurStatut({required this.etatActuel});

  final EtatProgression etatActuel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Text(
              'Ou en es-tu ?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final etat in EtatProgression.values)
            _OptionStatut(etat: etat, selectionne: etat == etatActuel),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Une option du selecteur : icone coloree + libelle, coche si c'est l'etat
/// courant. « Fait » ajoute la regle metier en sous-titre.
class _OptionStatut extends StatelessWidget {
  const _OptionStatut({required this.etat, required this.selectionne});

  final EtatProgression etat;
  final bool selectionne;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      selected: selectionne,
      leading: Icon(
        iconeStatut(etat),
        color: couleursStatut(context, etat).premier,
      ),
      title: Text(etat.libelleAffichage),
      subtitle: etat == EtatProgression.fait
          ? Text(
              'Fait signifie que tu as valide ta fiche de revision.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: selectionne
          ? Icon(Icons.check, color: theme.colorScheme.primary)
          : null,
      onTap: () => Navigator.of(context).pop(etat),
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

/// Une ligne de document : icone du type, libelle, taille, badge gratuit/premium,
/// et — selon le DROIT d'acces (etape 25) — un chevron (ouvrable) ou un cadenas
/// (verrouille). Le droit vient de [accesDocumentProvider] (auth x abonnement x
/// `premium`), jamais recalcule ici. Vrai bouton accessible (>= 48 px), dont le
/// `Semantics` annonce le verrou et l'action possible.
///
/// Le tap depend du droit :
///  - [AccesDocument.autorise]         -> ouvre le lecteur (ecran 7) ;
///  - [AccesDocument.compteRequis]     -> invite a creer un compte (un invite ne
///    peut rien telecharger, policy Storage `to authenticated`) ;
///  - [AccesDocument.abonnementRequis] -> « Voir l'offre ». La route + l'ecran
///    minimal de l'offre arrivent au lot F ; d'ici la, un message clair (aucun
///    octet consomme, aucun lecteur ouvert).
///
/// Le badge Gratuit/Premium est CONSERVE : il decrit la RESSOURCE (les droits sont
/// visibles sur chaque document, SPEC §8.2). Le DROIT de l'eleve s'exprime a part,
/// par l'icone d'action en bout de ligne (decision 5.8).
class _LigneDocument extends ConsumerWidget {
  const _LigneDocument({required this.ressource, required this.chapitre});

  final Ressource ressource;
  final Chapitre chapitre;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    final taille = TailleFichier.enTexte(ressource.tailleOctets);
    final statut = ressource.premium ? 'Premium' : 'Gratuit';
    final acces = ref.watch(accesDocumentProvider(ressource.premium));
    final verrouille = acces != AccesDocument.autorise;

    return Semantics(
      button: true,
      label:
          '${ressource.type.libelleAffichage}, $taille, $statut, '
          '${_actionSemantique(acces)}',
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
            onTap: () => _ouvrir(context, ref, acces),
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
                  // Chevron si ouvrable, cadenas ocre si verrouille (SPEC §2.4).
                  verrouille
                      ? Icon(
                          Icons.lock_outline,
                          color: theme
                              .extension<CouleursMarque>()!
                              .ocreDecoratif,
                        )
                      : Icon(
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

  /// Le fragment de libelle lu par un lecteur d'ecran apres « type, taille,
  /// statut » : il annonce le verrou et ce que le tap fera (SPEC §6.2).
  static String _actionSemantique(AccesDocument acces) => switch (acces) {
    AccesDocument.autorise => 'ouvrir',
    AccesDocument.compteRequis => 'verrouille, cree un compte pour ouvrir',
    AccesDocument.abonnementRequis => 'verrouille, voir l\'offre',
  };

  void _ouvrir(BuildContext context, WidgetRef ref, AccesDocument acces) {
    switch (acces) {
      case AccesDocument.autorise:
        // Ouvre le lecteur (ecran 7). On EMPILE l'ecran pour que « retour »
        // revienne au detail. La Ressource ET le Chapitre (deja charges) voyagent
        // ENSEMBLE en `extra` (record) ; les id vont en parametres de route. Le
        // nom « document » est defini dans routing/ ; `presentation/` ne peut pas
        // importer `routing/` (ARCHITECTURE §3), d'ou le litteral.
        context.pushNamed(
          'document',
          pathParameters: {
            'chapitreId': chapitre.id,
            'ressourceId': ressource.id,
          },
          extra: (ressource: ressource, chapitre: chapitre),
        );
      case AccesDocument.compteRequis:
        // Un invite ne peut rien telecharger : on lui propose de creer un compte
        // plutot qu'une action sans effet. « Creer un compte » quitte le mode
        // invite -> la redirection go_router mene a l'authentification.
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Cree un compte pour ouvrir ce document.'),
              action: SnackBarAction(
                label: 'Creer un compte',
                onPressed: () =>
                    ref.read(etatAuthProvider.notifier).quitterModeInvite(),
              ),
            ),
          );
      case AccesDocument.abonnementRequis:
        // « Voir l'offre » : la route + l'ecran minimal arrivent au lot F.
        _afficherMessage(
          context,
          'Ce document fait partie de l\'offre Premium.',
        );
    }
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
      child: Icon(
        _iconePour(type),
        size: 18,
        color: colorScheme.onPrimaryContainer,
      ),
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
            Icon(
              Icons.cloud_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
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

/// Un retour bref a l'eleve (confirmation d'un changement de statut, ou invitation
/// a creer un compte). Remplace tout SnackBar hidden en cours par le nouveau.
void _afficherMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

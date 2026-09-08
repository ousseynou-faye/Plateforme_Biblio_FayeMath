import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:fayemath_academy/core/constants/contact_tuteur.dart';
import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/domain/entities/abonnement.dart';
import 'package:fayemath_academy/domain/entities/formule_abonnement.dart';
import 'package:fayemath_academy/domain/usecases/resume_abonnement.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/formule_selectionnee_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// Ecran « Voir l'offre » (maquette V2.1, ecran 17 « Comparatif Gratuit /
/// Premium »), version MINIMALE de l'etape 25. Atteint depuis les trois points ou
/// un document premium est verrouille (detail, lecteur, carte du Profil) : il
/// explique ce que Premium change et ANNONCE les tarifs, sans permettre encore
/// d'acheter.
///
/// ## Ce qu'il fait (decisions de l'etape 25, point 5.5)
///  - Il AFFICHE les tarifs : ils sont verrouilles depuis le 31/07/2026 (CLAUDE.md
///    §6). Le « Tarif : a definir » de la maquette datait d'avant cette decision.
///  - Il n'a AUCUN bouton d'achat, aucun champ de paiement, aucune date : une seule
///    ligne factuelle (« la souscription sera disponible prochainement »). Le
///    paiement est l'etape 27 ; le comparatif riche (conditions, restauration) est
///    l'ecran 17 complet, etape 26.
///  - La matrice est celle du DOCUMENT 2 §2.1 (Tableau 3, la source de verite), pas
///    la version simplifiee de la maquette §4.2 : les exercices sont gratuits
///    seulement sur les 2 premiers chapitres, et 1 sujet d'examen est gratuit par
///    classe (deux points que la maquette masquait).
///  - Il ne reprend PAS la promesse « de la 6e a la Terminale » (carte du Profil) :
///    au lancement seule la 6e Mathematiques existe. Annoncer un prix sous une
///    promesse qu'on ne tient pas serait un risque commercial (la reformulation de
///    la carte du Profil elle-meme est un point de l'etape 26).
///
/// Route RACINE (au-dessus des onglets, comme le detail / le lecteur / Ma
/// progression) : elle ne beneficie donc pas du [BandeauReseauWidget] de la
/// coquille a onglets — on l'insere ICI a la main, comme le font le detail, le
/// lecteur et Ma progression (etape 21). Sinon aucun avertissement hors-ligne sur
/// cet ecran.
///
/// Trois etats (etape 26, decision 5.1), pilotes par [abonnementPremiumProvider]
/// + [Abonnement.estActif] :
///  - **abonne actif** : en-tete « Premium actif » (formule + echeance), la
///    matrice reste (elle rappelle les droits), le bloc tarif disparait ;
///  - **connecte sans abonnement** / **invite** : l'argumentaire complet + le
///    bloc tarif. L'abonnement vient du cache LOCAL (etape 25, point 5.3) : s'il
///    n'a jamais ete synchronise il est `null` -> on retombe sur l'argumentaire,
///    sans jamais ecrire une phrase qui deviendrait fausse hors-ligne.
class OffrePremiumScreen extends ConsumerWidget {
  const OffrePremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final abonnement = ref.watch(abonnementPremiumProvider).value;
    final estAbonne = abonnement != null && abonnement.estActif(DateTime.now());

    return Scaffold(
      // Barre du haut = « Premium » + fleche retour automatique (l'ecran est
      // atteint depuis plusieurs endroits : le retour contextuel vaut mieux qu'un
      // « Revenir a mon profil » fige comme dans la maquette).
      appBar: AppBar(title: const Text('Premium')),
      body: SafeArea(
        child: Column(
          children: [
            const BandeauReseauWidget(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                children: [
                  if (estAbonne)
                    _EnteteActif(abonnement)
                  else
                    const _Entete(),
                  const SizedBox(height: 16),
                  const _Matrice(),
                  const SizedBox(height: 14),
                  const _CalloutHorsLigne(),
                  // Un abonne n'a plus rien a acheter : pas de bloc tarif, pas de
                  // canal de souscription, pas de conditions.
                  if (!estAbonne) ...const [
                    SizedBox(height: 16),
                    _CarteTarifs(),
                    SizedBox(height: 16),
                    _ContactTuteur(),
                    SizedBox(height: 14),
                    _Conditions(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tete de l'etat « abonne actif » : une carte positive (coche verte NON
/// textuelle + texte neutre) rappelant la formule et l'echeance. Remplace
/// l'argumentaire promotionnel : un abonne n'a pas besoin qu'on lui vende Premium.
class _EnteteActif extends StatelessWidget {
  const _EnteteActif(this.abonnement);

  final Abonnement abonnement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final succes = theme.extension<CouleursMarque>()!.succes;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // La coche est un ornement non textuel -> le vert « succes » y est
          // autorise (le sens reste porte par le texte a cote).
          Icon(Icons.verified, size: 26, color: succes),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium actif',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ResumeAbonnement.echeance(abonnement),
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

/// La couronne de marque + le titre + une phrase de cadrage HONNETE du perimetre
/// (« les matieres deja disponibles »), qui remplace la promesse « 6e a la
/// Terminale ».
class _Entete extends StatelessWidget {
  const _Entete();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // La couronne est un ornement NON textuel : l'ocre de marque y est autorise
    // (audit du 28/07, seuil 3:1), contrairement au texte.
    final ocre = theme.extension<CouleursMarque>()!.ocreDecoratif;
    return Column(
      children: [
        Icon(Icons.workspace_premium, size: 34, color: ocre),
        const SizedBox(height: 8),
        Text(
          'Ce que change Premium',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Le gratuit reste utile toute l\'annee. Premium debloque tous les '
          'documents payants des matieres deja disponibles.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Une cellule de la matrice : incluse (coche), non incluse (croix), ou nuancee
/// (texte court, ex. « 2 premiers chapitres »). Le texte porte tout le sens ; la
/// couleur n'est jamais seule a le porter (SPEC §6.2).
sealed class _Cellule {
  const _Cellule();
}

class _Oui extends _Cellule {
  const _Oui();
}

class _Non extends _Cellule {
  const _Non();
}

class _Detail extends _Cellule {
  const _Detail(this.texte);
  final String texte;
}

/// Une ligne de la matrice : un libelle + la valeur gratuite + la valeur premium.
class _LigneMatrice {
  const _LigneMatrice(this.libelle, this.gratuit, this.premium);
  final String libelle;
  final _Cellule gratuit;
  final _Cellule premium;
}

/// La matrice gratuit / premium, FIDELE au document 2 §2.1 (Tableau 3). Les deux
/// ecarts corriges par rapport a la maquette §4.2 : les exercices ne sont gratuits
/// que sur les 2 premiers chapitres, et 1 sujet d'examen est gratuit par classe.
class _Matrice extends StatelessWidget {
  const _Matrice();

  static const _lignes = [
    _LigneMatrice('Cours et fiches de revision', _Oui(), _Oui()),
    _LigneMatrice(
      'Series d\'exercices',
      _Detail('2 premiers chapitres'),
      _Oui(),
    ),
    _LigneMatrice('Corriges detailles', _Non(), _Oui()),
    _LigneMatrice('Evaluations et leurs corriges', _Non(), _Oui()),
    _LigneMatrice(
      'Sujets d\'examen BFEM et BAC',
      _Detail('1 par classe'),
      _Oui(),
    ),
    _LigneMatrice('Lecture hors-ligne', _Oui(), _Oui()),
    _LigneMatrice('Suivi de progression', _Oui(), _Oui()),
    _LigneMatrice('Contact du tuteur', _Oui(), _Oui()),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // En-tete des colonnes.
          Container(
            color: scheme.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                _EnteteColonne('Gratuit'),
                _EnteteColonne('Premium'),
              ],
            ),
          ),
          for (var i = 0; i < _lignes.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                border: i < _lignes.length - 1
                    ? Border(
                        bottom: BorderSide(color: scheme.outlineVariant),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _lignes[i].libelle,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  _CelluleValeur(cellule: _lignes[i].gratuit, offre: 'gratuit'),
                  _CelluleValeur(cellule: _lignes[i].premium, offre: 'Premium'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EnteteColonne extends StatelessWidget {
  const _EnteteColonne(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 76,
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Rend une cellule de valeur, avec un libelle de lecteur d'ecran explicite (le
/// sens ne repose jamais sur la seule coche/couleur).
class _CelluleValeur extends StatelessWidget {
  const _CelluleValeur({required this.cellule, required this.offre});

  final _Cellule cellule;

  /// « gratuit » ou « Premium », pour construire le libelle d'accessibilite.
  final String offre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final succes = theme.extension<CouleursMarque>()!.succes;

    final (Widget contenu, String semantique) = switch (cellule) {
      _Oui() => (
        Icon(Icons.check_circle, size: 18, color: succes),
        'inclus dans $offre',
      ),
      _Non() => (
        Icon(Icons.remove, size: 18, color: scheme.onSurfaceVariant),
        'non inclus dans $offre',
      ),
      _Detail(:final texte) => (
        Text(
          texte,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        '$offre : $texte',
      ),
    };

    return SizedBox(
      width: 76,
      child: Semantics(
        label: semantique,
        excludeSemantics: true,
        child: Center(child: contenu),
      ),
    );
  }
}

/// Rappel du cadrage : le hors-ligne est identique dans les deux offres (doc 2
/// §2.2). Fond neutre + point ocre non textuel (jamais l'ocre sous du texte).
class _CalloutHorsLigne extends StatelessWidget {
  const _CalloutHorsLigne();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Le hors-ligne est identique dans les deux offres',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ce que Premium ajoute, ce sont des documents en plus, pas un '
                  'mode hors-ligne different. Aucun quota d\'espace n\'est '
                  'impose : la seule limite est celle de ton telephone.',
                  style: theme.textTheme.bodySmall?.copyWith(
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

/// Les trois montants et periodes, verrouilles le 31/07/2026 (CLAUDE.md §6). Le
/// booleen = « a mettre en avant » (annee scolaire, document 2 tableau 4).
const _formulesOffre = <(FormuleAbonnement, String, String, bool)>[
  (FormuleAbonnement.mensuel, '1 000 FCFA', 'par mois', false),
  (FormuleAbonnement.trimestriel, '2 500 FCFA', 'par trimestre', false),
  (FormuleAbonnement.anneeScolaire, '6 000 FCFA', 'par annee scolaire', true),
];

/// La carte des tarifs (etape 26, point 5.3). Les trois formules sont
/// SELECTIONNABLES — la selection est du pur affichage, lue par l'etape 27 via
/// [formuleSelectionneeProvider]. « Annee scolaire » est presel. par defaut (la
/// formule a mettre en avant). Toujours AUCUN bouton d'achat : le choix ne
/// declenche rien ici. Fond neutre : l'ocre de marque n'est pas pose sous du texte.
class _CarteTarifs extends ConsumerWidget {
  const _CarteTarifs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selection = ref.watch(formuleSelectionneeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choisis ta formule',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          for (final (formule, montant, periode, recommande) in _formulesOffre)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FormuleSelectionnable(
                montant: montant,
                periode: periode,
                recommande: recommande,
                selectionne: formule == selection,
                onTap: () => ref
                    .read(formuleSelectionneeProvider.notifier)
                    .choisir(formule),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Offert aux eleves inscrits au tutorat a domicile — demande a ton '
            'tuteur.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Une formule choisissable : indicateur radio (la forme, pas la seule couleur —
/// SPEC §6.2) + montant + periode, et un liosere « Recommande » pour l'annee
/// scolaire. Cible tactile >= 48 px ; l'etat selectionne est aussi porte par la
/// semantique (`selected`).
class _FormuleSelectionnable extends StatelessWidget {
  const _FormuleSelectionnable({
    required this.montant,
    required this.periode,
    required this.recommande,
    required this.selectionne,
    required this.onTap,
  });

  final String montant;
  final String periode;
  final bool recommande;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selectionne,
      label: '$montant $periode'
          '${recommande ? ', recommande' : ''}',
      excludeSemantics: true,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selectionne ? scheme.primary : scheme.outlineVariant,
                width: selectionne ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selectionne
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selectionne ? scheme.primary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  montant,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    periode,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (recommande)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Recommande',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
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

/// Le canal de souscription (etape 26, point 5.4) tant que le paiement en ligne
/// n'existe pas (etape 27) : ecrire au tuteur sur WhatsApp, ou l'appeler. Les
/// numeros sont AFFICHES en clair (repli hors-ligne : meme si l'ouverture echoue,
/// l'eleve les lit) et proviennent d'une source UNIQUE ([ContactTuteur]).
class _ContactTuteur extends StatelessWidget {
  const _ContactTuteur();

  Future<void> _ouvrir(BuildContext context, Uri lien, String replSnack) async {
    try {
      final ok = await launchUrl(lien, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _snack(context, replSnack);
    } on Exception {
      if (context.mounted) _snack(context, replSnack);
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passer a Premium',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Le paiement en ligne arrive bientot. En attendant, ecris ou appelle '
            'ton tuteur pour activer Premium.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          BoutonPrimaireWidget(
            libelle: 'Ecrire au tuteur (WhatsApp)',
            icone: Icons.chat_outlined,
            onPressed: () => _ouvrir(
              context,
              ContactTuteur.whatsApp,
              'Impossible d\'ouvrir WhatsApp. Appelle le '
                  '${ContactTuteur.numeros.first.affichage}.',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'ou appelle :',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (final numero in ContactTuteur.numeros)
            _LigneAppel(
              affichage: numero.affichage,
              onTap: () => _ouvrir(
                context,
                ContactTuteur.appel(numero.e164),
                'Impossible d\'ouvrir le clavier d\'appel. Compose le '
                    '${numero.affichage}.',
              ),
            ),
        ],
      ),
    );
  }
}

/// Un numero appelable : icone + numero, cible tactile >= 48 px. Le numero reste
/// LISIBLE meme si l'appel ne peut pas s'ouvrir (repli hors-ligne).
class _LigneAppel extends StatelessWidget {
  const _LigneAppel({required this.affichage, required this.onTap});

  final String affichage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: 'Appeler le $affichage',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Icon(Icons.call_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              Text(
                affichage,
                style: theme.textTheme.bodyMedium?.copyWith(
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

/// Les conditions (etape 26, point 5.5) : quatre phrases factuelles, pas un
/// contrat. Elles evitent toute promesse fausse et repondent explicitement a la
/// « restauration d'achat » (le 4e point : l'abonnement suit le compte).
class _Conditions extends StatelessWidget {
  const _Conditions();

  static const _lignes = <(String, String)>[
    (
      'Duree',
      'L\'abonnement couvre la periode que tu choisis, sans reconduction '
          'automatique.',
    ),
    (
      'A l\'echeance',
      'L\'acces aux documents premium s\'arrete, mais les documents deja '
          'telecharges restent lisibles.',
    ),
    (
      'Aucun prelevement recurrent',
      'Le paiement est ponctuel : il n\'y a rien a resilier.',
    ),
    (
      'Changement de telephone',
      'Ton abonnement est attache a ton compte, pas a l\'appareil : il suffit '
          'de te reconnecter.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conditions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final (titre, texte) in _lignes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    texte,
                    style: theme.textTheme.bodySmall?.copyWith(
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

import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';

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
class OffrePremiumScreen extends StatelessWidget {
  const OffrePremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                children: const [
                  _Entete(),
                  SizedBox(height: 16),
                  _Matrice(),
                  SizedBox(height: 14),
                  _CalloutHorsLigne(),
                  SizedBox(height: 16),
                  _CarteTarifs(),
                ],
              ),
            ),
          ],
        ),
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

/// La carte des tarifs (etape 25, point 5.5). Les trois formules sont verrouillees
/// depuis le 31/07/2026 (CLAUDE.md §6). Aucun bouton d'achat : une seule ligne
/// factuelle annonce que la souscription arrive. Fond neutre : l'ocre de marque
/// n'est pas pose sous du texte (audit du 28/07).
class _CarteTarifs extends StatelessWidget {
  const _CarteTarifs();

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
            'Tarif',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _Formule(montant: '1 000 FCFA', periode: 'par mois'),
          const SizedBox(height: 8),
          const _Formule(montant: '2 500 FCFA', periode: 'par trimestre'),
          const SizedBox(height: 8),
          const _Formule(montant: '6 000 FCFA', periode: 'par annee scolaire'),
          const SizedBox(height: 12),
          Text(
            'Offert aux eleves inscrits au tutorat a domicile.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: scheme.outlineVariant),
          const SizedBox(height: 12),
          Text(
            'La souscription sera disponible prochainement. Aucun paiement n\'est '
            'possible pour le moment.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Une ligne de tarif : le montant (en avant) + la periode.
class _Formule extends StatelessWidget {
  const _Formule({required this.montant, required this.periode});

  final String montant;
  final String periode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
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
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

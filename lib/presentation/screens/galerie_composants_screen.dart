import 'package:flutter/material.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/presentation/widgets/badge_premium_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';
import 'package:fayemath_academy/presentation/widgets/carte_selection_widget.dart';

/// Ecran-galerie TEMPORAIRE (etape 11) : affiche la charte et les premiers
/// composants dans leurs differents etats, pour verifier a l'oeil et au doigt,
/// sur les deux appareils, que le theme et les widgets se comportent bien.
///
/// Il sert d'accueil provisoire jusqu'a l'etape 14 (premier vrai ecran, choix
/// classe / serie / matiere), qui le remplacera. Purement presentationnel :
/// chaque composant est montre dans ses etats cote a cote, donc aucun etat a
/// gerer ici (pas de tension avec « Riverpod partout », les onTap sont des
/// no-op de demonstration).
class GalerieComposantsScreen extends StatelessWidget {
  const GalerieComposantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Charte & composants')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Section(titre: 'Typographie', enfant: _ApercuTypographie()),
          _Section(titre: 'Bouton principal', enfant: _ApercuBoutons()),
          _Section(titre: 'Cartes de selection', enfant: _ApercuCartes()),
          _Section(titre: 'Badges de ressource', enfant: _ApercuBadges()),
          _Section(
            titre: 'Couleurs de marque',
            enfant: _ApercuCouleursMarque(),
          ),
        ],
      ),
    );
  }
}

/// Titre de section + contenu, avec l'espacement standard de la galerie.
class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.enfant});

  final String titre;
  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          enfant,
        ],
      ),
    );
  }
}

class _ApercuTypographie extends StatelessWidget {
  const _ApercuTypographie();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Titre display', style: t.displaySmall),
        Text('Titre de section', style: t.titleLarge),
        Text('Corps de texte courant en Poppins.', style: t.bodyLarge),
        Text('Texte secondaire adouci.', style: t.bodySmall),
        Text('LIBELLE 11 PT (plancher)', style: t.labelSmall),
      ],
    );
  }
}

class _ApercuBoutons extends StatelessWidget {
  const _ApercuBoutons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BoutonPrimaireWidget(libelle: 'Valider', onPressed: () {}),
        const SizedBox(height: 12),
        BoutonPrimaireWidget(
          libelle: 'Continuer',
          icone: Icons.arrow_forward,
          onPressed: () {},
        ),
        const SizedBox(height: 12),
        // onPressed null = etat desactive (« pas encore pret »).
        const BoutonPrimaireWidget(
          libelle: 'Valider (desactive)',
          onPressed: null,
        ),
      ],
    );
  }
}

class _ApercuCartes extends StatelessWidget {
  const _ApercuCartes();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarteSelectionWidget(
          titre: 'Sixieme',
          sousTitre: 'Cycle moyen',
          icone: Icons.school_outlined,
          selectionnee: true,
          onTap: () {},
        ),
        const SizedBox(height: 12),
        CarteSelectionWidget(
          titre: 'Cinquieme',
          sousTitre: 'Cycle moyen',
          icone: Icons.school_outlined,
          selectionnee: false,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ApercuBadges extends StatelessWidget {
  const _ApercuBadges();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        BadgePremiumWidget(premium: false),
        SizedBox(width: 12),
        BadgePremiumWidget(premium: true),
      ],
    );
  }
}

/// Montre l'acces aux tokens de la ThemeExtension [CouleursMarque] : l'ocre
/// decoratif (surfaces non textuelles) et le vert du statut « fait ».
class _ApercuCouleursMarque extends StatelessWidget {
  const _ApercuCouleursMarque();

  @override
  Widget build(BuildContext context) {
    final marque = Theme.of(context).extension<CouleursMarque>()!;
    return Row(
      children: [
        _Pastille(couleur: marque.ocreDecoratif, libelle: 'Ocre decoratif'),
        const SizedBox(width: 16),
        _Pastille(couleur: marque.succes, libelle: 'Statut « fait »'),
      ],
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.couleur, required this.libelle});

  final Color couleur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(libelle, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

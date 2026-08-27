import 'package:flutter/material.dart';

import 'package:fayemath_academy/presentation/widgets/contenu_a_venir_widget.dart';

/// Onglet « Accueil » de la barre du bas (maquette V2.1, ecran 4 « Tableau de
/// bord »). PLACEHOLDER : le vrai tableau de bord (progression globale, reprise de
/// lecture) releve de l'etape 24 (« Ma progression »), pas de l'etape 22 qui ne
/// construit que le suivi d'etat par chapitre. On l'annonce clairement plutot que
/// d'afficher un ecran vide ou faux.
class TableauBordScreen extends StatelessWidget {
  const TableauBordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const ContenuAVenirWidget(
        icone: Icons.dashboard_outlined,
        titre: 'Tableau de bord',
        texte:
            'Ton tableau de bord (progression globale, reprise de lecture) '
            'arrivera bientot.',
      ),
    );
  }
}

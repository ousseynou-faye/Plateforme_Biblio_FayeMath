import 'package:flutter/material.dart';

import 'package:fayemath_academy/presentation/widgets/contenu_a_venir_widget.dart';

/// Onglet « Accueil » de la barre du bas (maquette V2.1, ecran 4 « Tableau de
/// bord »). PLACEHOLDER a l'etape 20 : le vrai tableau de bord depend du suivi de
/// progression (etape 22), inexistant a ce jour. On l'annonce clairement plutot
/// que d'afficher un ecran vide ou faux.
class TableauBordScreen extends StatelessWidget {
  const TableauBordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: const ContenuAVenirWidget(
        icone: Icons.dashboard_outlined,
        titre: 'Tableau de bord',
        texte: 'Ton tableau de bord (progression, reprise de lecture) arrivera '
            'avec le suivi de progression.',
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:fayemath_academy/presentation/widgets/contenu_a_venir_widget.dart';

/// Onglet « Profil » de la barre du bas (maquette V2.1). PLACEHOLDER a l'etape 20 :
/// l'ecran de profil (dont la deconnexion, aujourd'hui provisoirement dans la barre
/// du haut de la liste des chapitres) n'a pas encore son etape dediee. On l'annonce
/// clairement plutot que d'afficher un ecran vide.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: const ContenuAVenirWidget(
        icone: Icons.person_outline,
        titre: 'Ton profil',
        texte: 'Ton compte, ta classe et la deconnexion seront regroupes ici '
            'prochainement.',
      ),
    );
  }
}

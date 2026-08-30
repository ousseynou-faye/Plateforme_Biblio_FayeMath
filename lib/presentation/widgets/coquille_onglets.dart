import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';

/// La coquille a onglets de l'app (maquette V2.1, barre du bas a 4 onglets :
/// Accueil / Cours / Hors-ligne / Profil). Introduite a l'etape 20 : c'est la
/// premiere fois que l'app a une navigation a onglets a etat conserve.
///
/// Recoit le [navigationShell] de `StatefulShellRoute.indexedStack` (go_router) :
/// chaque onglet garde sa PROPRE pile de navigation, et changer d'onglet ne la
/// reconstruit pas. Les ecrans plein-ecran (detail d'un chapitre, lecteur) sont
/// pousses AU-DESSUS de cette coquille (routes racine), donc sans barre d'onglets —
/// fidele a la maquette (ecrans 6/7 n'en ont pas).
///
/// L'onglet « Profil » est encore un placeholder (son etape n'existe pas). Depuis
/// l'etape 24, l'onglet d'ARRIVEE est « Accueil » = le tableau de bord (ecran 4),
/// qui donne acces a « Ma progression » (ecran 9) ; l'onglet « Cours » (la liste
/// des chapitres) reste a un tap sur la barre.
class CoquilleOnglets extends StatelessWidget {
  const CoquilleOnglets({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _allerOnglet(int index) {
    // `initialLocation: true` quand on re-tape l'onglet actif : on revient a sa
    // racine (comportement standard d'une barre d'onglets).
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bandeau reseau en tete des 4 onglets (SPEC §2.2 : « une seule fois dans le
      // bandeau haut de chaque ecran »). `SafeArea(top)` consomme l'encoche : le
      // bandeau se pose sous la barre systeme, et les AppBar des ecrans d'onglet
      // s'affichent juste en dessous sans double marge.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const BandeauReseauWidget(),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _allerOnglet,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Cours',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download),
            label: 'Hors-ligne',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

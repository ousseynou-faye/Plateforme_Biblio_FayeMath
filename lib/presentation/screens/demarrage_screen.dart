import 'package:flutter/material.dart';

/// Ecran de demarrage NEUTRE, affiche le temps de trancher la destination quand
/// elle depend d'une lecture (le profil de l'eleve connecte : a-t-il deja choisi
/// sa classe ?). Transitoire par nature — la redirection (app_router.dart) le
/// remplace des que le profil est resolu. Volontairement minimal : il ne doit ni
/// clignoter ni ressembler a un ecran de contenu.
class DemarrageScreen extends StatelessWidget {
  const DemarrageScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

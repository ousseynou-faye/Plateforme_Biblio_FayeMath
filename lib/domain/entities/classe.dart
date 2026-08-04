import 'package:fayemath_academy/domain/entities/cycle.dart';

/// Une classe (niveau scolaire), de la 6e a la Terminale.
///
/// Miroir de la table `classe` (migration 01). Porte son [cycle] (college /
/// lycee) et son [ordre] d'affichage. La regle « quelle serie et quelles
/// matieres selon la classe » (GLOSSAIRE §2) n'est PAS ici : elle vit dans
/// l'ecran de choix (etape 14), pour ne pas la deduire d'un nom de classe.
class Classe {
  const Classe({
    required this.id,
    required this.nom,
    required this.cycle,
    required this.ordre,
  });

  final String id;
  final String nom;
  final Cycle cycle;
  final int ordre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Classe &&
          other.id == id &&
          other.nom == nom &&
          other.cycle == cycle &&
          other.ordre == ordre;

  @override
  int get hashCode => Object.hash(id, nom, cycle, ordre);
}

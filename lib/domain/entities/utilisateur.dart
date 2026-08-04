import 'package:fayemath_academy/domain/entities/serie.dart';

/// Le profil de l'eleve, adosse au compte d'authentification Supabase.
///
/// Miroir de la table `utilisateur` (migration 01). [id] = l'identifiant du
/// compte auth. [classeId] est nullable : l'eleve peut ne pas encore avoir choisi
/// sa classe (etape 14). [serie] est nullable : demandee seulement en 1ere /
/// Terminale (GLOSSAIRE §2), absente sinon.
class Utilisateur {
  const Utilisateur({
    required this.id,
    required this.classeId,
    required this.serie,
    required this.creeLe,
  });

  final String id;
  final String? classeId;
  final Serie? serie;
  final DateTime creeLe;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Utilisateur &&
          other.id == id &&
          other.classeId == classeId &&
          other.serie == serie &&
          other.creeLe == creeLe;

  @override
  int get hashCode => Object.hash(id, classeId, serie, creeLe);
}

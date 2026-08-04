import 'package:fayemath_academy/domain/entities/etat_progression.dart';

/// L'etat d'un chapitre pour un eleve donne (un des 4 [EtatProgression]).
///
/// Miroir de la table `progression` (migration 01). Une seule ligne par couple
/// (eleve, chapitre). [dateMaj] sert a la resolution « la modification la plus
/// recente l'emporte » de la synchronisation — dont la mecanique complete releve
/// de la Phase 3, hors de cette etape.
class Progression {
  const Progression({
    required this.id,
    required this.utilisateurId,
    required this.chapitreId,
    required this.etat,
    required this.dateMaj,
  });

  final String id;
  final String utilisateurId;
  final String chapitreId;
  final EtatProgression etat;
  final DateTime dateMaj;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Progression &&
          other.id == id &&
          other.utilisateurId == utilisateurId &&
          other.chapitreId == chapitreId &&
          other.etat == etat &&
          other.dateMaj == dateMaj;

  @override
  int get hashCode => Object.hash(id, utilisateurId, chapitreId, etat, dateMaj);
}

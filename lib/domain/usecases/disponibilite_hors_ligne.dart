import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';

/// La part de chapitres reellement disponibles hors-ligne, pour l'anneau de
/// completion de l'ecran « Mes telechargements » (maquette ecran 8 : « X chapitres
/// sur Y hors-ligne », « X % des chapitres hors-ligne »).
///
/// C'est une mesure de couverture du contenu, PAS un espace disque en Mo face a un
/// quota — FayeMath n'impose aucun quota (SPEC §4.3). Le total en Ko/Mo reste
/// affiche ligne par ligne, jamais agrege en jauge.
class RatioHorsLigne {
  const RatioHorsLigne({
    required this.chapitresHorsLigne,
    required this.chapitresTotal,
  });

  /// Nombre de chapitres entierement disponibles hors-ligne.
  final int chapitresHorsLigne;

  /// Nombre total de chapitres de la bibliotheque courante (classe, matiere).
  final int chapitresTotal;

  /// Fraction `0.0` -> `1.0` pour l'anneau. Vaut `0` sans chapitre (aucune
  /// division par zero, aucun `NaN` a l'affichage).
  double get fraction =>
      chapitresTotal == 0 ? 0 : chapitresHorsLigne / chapitresTotal;

  /// Le pourcentage entier affiche a cote de l'anneau.
  int get pourcentage => (fraction * 100).round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RatioHorsLigne &&
          other.chapitresHorsLigne == chapitresHorsLigne &&
          other.chapitresTotal == chapitresTotal;

  @override
  int get hashCode => Object.hash(chapitresHorsLigne, chapitresTotal);
}

/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : elle vit dans `domain/`, se teste
/// sans Flutter, sans disque ni reseau.
///
/// Definition retenue (cadrage etape 20, point 5-a) : un chapitre est « disponible
/// hors-ligne » quand TOUS les documents que l'eleve peut ouvrir sont deja sur
/// l'appareil. « Que l'eleve peut ouvrir » = deja filtre par l'appelant dans
/// [ressourcesAccessibles] (gratuit, ou premium avec abonnement actif) : un corrige
/// premium hors de portee ne fait donc pas passer un chapitre pour « incomplet ».
/// Lecture la plus honnete vis-a-vis de la promesse hors-ligne : on ne dit pas
/// « dispo » a un eleve a qui il manque un document qu'il pourrait lire.
abstract final class DisponibiliteHorsLigne {
  static RatioHorsLigne calculer({
    required List<Chapitre> chapitres,
    required List<Ressource> ressourcesAccessibles,
    required Set<String> idsPresents,
  }) {
    // Regrouper les ressources accessibles par chapitre. Les `sujet_examen`
    // (chapitre_id null) ne relevent d'aucun chapitre : hors de ce calcul.
    final parChapitre = <String, List<Ressource>>{};
    for (final ressource in ressourcesAccessibles) {
      final chapitreId = ressource.chapitreId;
      if (chapitreId == null) continue;
      (parChapitre[chapitreId] ??= []).add(ressource);
    }

    var horsLigne = 0;
    for (final chapitre in chapitres) {
      final accessibles = parChapitre[chapitre.id];
      // Un chapitre sans aucun document accessible ne peut pas etre rendu
      // disponible hors-ligne : il ne compte pas comme « fait ».
      if (accessibles == null || accessibles.isEmpty) continue;
      if (accessibles.every((r) => idsPresents.contains(r.id))) horsLigne++;
    }

    return RatioHorsLigne(
      chapitresHorsLigne: horsLigne,
      chapitresTotal: chapitres.length,
    );
  }
}

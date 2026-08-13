import 'package:fayemath_academy/domain/entities/chapitre.dart';

/// Un groupe de chapitres partageant la meme strate d'affichage (« Activites
/// Numeriques », « Activites Geometriques »... GLOSSAIRE §2). [strate] vaut
/// `null` pour les chapitres sans strate (colonne nullable au schema) : c'est un
/// groupe a part entiere, jamais silencieusement ecarte.
class GroupeStrate {
  const GroupeStrate({required this.strate, required this.chapitres});

  final String? strate;
  final List<Chapitre> chapitres;
}

/// Regroupe des chapitres par strate pour l'affichage de la liste (maquette
/// ecran 5, etape 15). Regle METIER PURE : elle vit dans `domain/`, pas dans un
/// ecran (docs/ARCHITECTURE.md §9), et se teste sans Flutter ni Supabase.
///
/// Le regroupement est PILOTE PAR LA DONNEE, jamais une liste de strates codee
/// en dur comme dans la maquette (`["Num","Geo"]`). On trie d'abord par `ordre`
/// croissant — la contrainte serveur `unique(classe_id, matiere_id, ordre)`
/// (migration 01) garantit un ordre continu sur toute la matiere, donc les
/// strates s'y regroupent naturellement — puis on regroupe en CONSERVANT l'ordre
/// d'apparition des valeurs de strate. Le tri est fait ici (et non delegue au
/// repository) pour que la fonction soit TOTALE et testable seule.
abstract final class RegroupementParStrate {
  static List<GroupeStrate> de(List<Chapitre> chapitres) {
    final tries = [...chapitres]..sort((a, b) => a.ordre.compareTo(b.ordre));

    // `ordreApparition` fige l'ordre des groupes ; `parStrate` accumule leurs
    // chapitres. La cle peut etre `null` (strate absente) — un groupe legitime.
    final ordreApparition = <String?>[];
    final parStrate = <String?, List<Chapitre>>{};
    for (final chapitre in tries) {
      final groupe = parStrate.putIfAbsent(chapitre.strate, () {
        ordreApparition.add(chapitre.strate);
        return <Chapitre>[];
      });
      groupe.add(chapitre);
    }

    return [
      for (final strate in ordreApparition)
        GroupeStrate(strate: strate, chapitres: parStrate[strate]!),
    ];
  }
}

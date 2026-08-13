import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';

/// La regle du programme officiel senegalais (SPECIFICATIONS_V2 §3.2, GLOSSAIRE
/// §2) : pour une classe donnee, demande-t-on une serie, et quelles matieres
/// sont au programme ? C'est une regle METIER PURE — elle vit dans `domain/`,
/// pas dans un ecran (docs/ARCHITECTURE.md §9), et se teste sans Flutter ni
/// Supabase.
///
/// Elle ne parle PAS de disponibilite de contenu : « 4e a de la physique-chimie
/// AU PROGRAMME » est vrai meme si la bibliotheque n'existe pas encore. Le fait
/// qu'une bibliotheque soit produite ou non (« bientot disponible ») est un
/// autre sujet, porte par `core/constants/bibliotheques_pretes.dart`.
abstract final class ProgrammeScolaire {
  // Noms figes des matieres (GLOSSAIRE §2), identiques aux `nom` inseres en base
  // par la migration 07. `domain/` ne peut pas importer `core/` (ARCHITECTURE
  // §3), d'ou ces constantes locales plutot qu'un partage avec `core/constants`.
  static const nomMathematiques = 'Mathématiques';
  static const nomPhysiqueChimie = 'Physique-chimie';

  // Le programme officiel, clef = nom fige de la classe. Reproduit exactement la
  // table SPECIFICATIONS_V2 §3.2 (et la liste `CLASSES` de la maquette).
  static const Map<String, List<String>> _matieresDeBase = {
    '6e': [nomMathematiques],
    '5e': [nomMathematiques],
    '4e': [nomMathematiques, nomPhysiqueChimie],
    '3e': [nomMathematiques, nomPhysiqueChimie],
    '2nde': [nomMathematiques, nomPhysiqueChimie],
    '1ère': [nomMathematiques, nomPhysiqueChimie],
    'Terminale': [nomMathematiques, nomPhysiqueChimie],
  };

  // Les seules classes ou une serie est demandee, toujours AVANT les matieres.
  static const Set<String> _classesAvecSerie = {'1ère', 'Terminale'};

  /// Vrai si la classe demande une serie (1ere / Terminale). Leve une
  /// `ArgumentError` si le nom de classe n'est pas au programme fige (parsing
  /// STRICT, comme les enums du domaine : une derive de nom se voit tout de
  /// suite au lieu de produire un ecran vide).
  static bool serieRequise(Classe classe) {
    _verifierClasseConnue(classe);
    return _classesAvecSerie.contains(classe.nom);
  }

  /// Les matieres (parmi [catalogue]) au programme de [classe] pour [serie].
  ///
  /// - classe sans serie : [serie] est ignoree ;
  /// - classe a serie et [serie] == null : renvoie `[]` (indetermine tant que la
  ///   serie n'est pas choisie — l'ecran affiche « choisis d'abord ta serie ») ;
  /// - serie L : la physique-chimie est retiree (reservee a S1/S2, §3.2).
  ///
  /// L'ordre du programme est respecte (mathematiques avant physique-chimie).
  /// Une matiere du programme absente du [catalogue] est ignoree ; une matiere
  /// du catalogue hors programme n'est jamais proposee.
  static List<Matiere> matieresAutorisees({
    required Classe classe,
    required Serie? serie,
    required List<Matiere> catalogue,
  }) {
    _verifierClasseConnue(classe);

    if (serieRequise(classe) && serie == null) return const <Matiere>[];

    var noms = _matieresDeBase[classe.nom]!;
    if (serie == Serie.serieL) {
      noms = noms.where((nom) => nom != nomPhysiqueChimie).toList();
    }

    return [
      for (final nom in noms)
        ...catalogue.where((matiere) => matiere.nom == nom),
    ];
  }

  static void _verifierClasseConnue(Classe classe) {
    if (!_matieresDeBase.containsKey(classe.nom)) {
      throw ArgumentError.value(
        classe.nom,
        'classe.nom',
        'Classe hors du programme fige (attendu : '
            '${_matieresDeBase.keys.join(', ')})',
      );
    }
  }
}

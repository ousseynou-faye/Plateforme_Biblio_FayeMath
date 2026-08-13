import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';

/// La selection EN COURS sur l'ecran de choix (etape 14) : la classe, la serie
/// eventuelle, les matieres cochees (par id), et si le choix a ete valide.
///
/// Etat LOCAL d'ecran. Il n'est pas persiste tel quel : pour un eleve connecte,
/// la persistance passe par `profilProvider.enregistrerChoix` a la validation ;
/// pour un invite (Decision A, aucun compte), ce choix reste purement local et
/// [valide] est le seul signal « il a fini de choisir » que la redirection peut
/// lire (l'invite n'a pas de profil serveur).
class ChoixClasse {
  const ChoixClasse({
    this.classe,
    this.serie,
    this.matieresSelectionnees = const {},
    this.valide = false,
  });

  final Classe? classe;
  final Serie? serie;

  /// Les `id` des matieres cochees.
  final Set<String> matieresSelectionnees;

  /// Vrai quand l'eleve a valide son choix (utilise par la redirection INVITE).
  final bool valide;
}

class ChoixClasseNotifier extends Notifier<ChoixClasse> {
  @override
  ChoixClasse build() => const ChoixClasse();

  /// Choisir une classe repart de zero : la serie et les matieres dependent
  /// d'elle (maquette ecran 3). L'ecran passe la 1ere matiere autorisee dans
  /// [matieresParDefaut] (auto-selection fidele a la maquette) ; il la connait
  /// car il a le catalogue et la regle `ProgrammeScolaire` sous la main.
  void choisirClasse(
    Classe classe, {
    Set<String> matieresParDefaut = const {},
  }) => state = ChoixClasse(
    classe: classe,
    matieresSelectionnees: matieresParDefaut,
  );

  /// Choisir une serie recalcule les matieres autorisees : on repart avec la 1ere
  /// matiere autorisee pre-selectionnee ([matieresParDefaut]).
  void choisirSerie(Serie serie, {Set<String> matieresParDefaut = const {}}) =>
      state = ChoixClasse(
        classe: state.classe,
        serie: serie,
        matieresSelectionnees: matieresParDefaut,
      );

  /// Coche / decoche une matiere (pour une classe qui en propose plusieurs).
  void basculerMatiere(String matiereId) {
    final selection = {...state.matieresSelectionnees};
    if (!selection.remove(matiereId)) selection.add(matiereId);
    state = ChoixClasse(
      classe: state.classe,
      serie: state.serie,
      matieresSelectionnees: selection,
    );
  }

  /// Marque le choix comme valide (parcours INVITE). Conserve classe / serie /
  /// matieres ; c'est ce que la redirection lit pour mener a l'accueil.
  void confirmer() => state = ChoixClasse(
    classe: state.classe,
    serie: state.serie,
    matieresSelectionnees: state.matieresSelectionnees,
    valide: true,
  );
}

final choixClasseProvider = NotifierProvider<ChoixClasseNotifier, ChoixClasse>(
  ChoixClasseNotifier.new,
);

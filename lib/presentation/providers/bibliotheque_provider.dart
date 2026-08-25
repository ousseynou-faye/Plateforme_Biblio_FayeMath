import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/usecases/programme_scolaire.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';

/// La « bibliotheque » que l'eleve consulte : sa (classe, matiere) courante.
class BibliothequeCourante {
  const BibliothequeCourante({required this.classe, required this.matiere});

  final Classe classe;
  final Matiere matiere;

  /// La cle de cache de `chapitresProvider` (egalite structurelle du record).
  CibleChapitres get cle => (classeId: classe.id, matiereId: matiere.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibliothequeCourante &&
          other.classe == classe &&
          other.matiere == matiere;

  @override
  int get hashCode => Object.hash(classe, matiere);
}

/// La (classe, matiere) courante, resolue en UN SEUL endroit pour tous les ecrans
/// qui en ont besoin (liste des chapitres, « Mes telechargements », et la coquille
/// a onglets a venir). Extrait de `liste_chapitres_screen` a l'etape 20 pour ne pas
/// dupliquer la regle « derive la matiere » (option 1, etape 15).
///
/// La classe vient de l'eleve : profil serveur s'il est connecte, choix local s'il
/// est invite. La MATIERE n'est stockee nulle part (Constat A, etape 14 :
/// `utilisateur` n'a pas de colonne matiere) : on prend la 1re matiere AU PROGRAMME
/// (`ProgrammeScolaire`, toujours Mathematiques vu l'ordre du programme), meme chemin
/// connecte et invite. A REVOIR des qu'une 2e bibliotheque aura du contenu reel
/// (persister la matiere, ou offrir un selecteur).
///
/// Renvoie un [AsyncValue] : `loading` tant que la classe/le catalogue n'est pas
/// tranche, `error` si le catalogue est injoignable ET absent du cache, `data` avec
/// la bibliotheque une fois resolue (ou `data(null)` dans un etat neutre — un
/// deconnecte n'atterrit ici que le temps que la redirection le renvoie).
final bibliothequeCouranteProvider = Provider<AsyncValue<BibliothequeCourante?>>((
  ref,
) {
  final matieresAsync = ref.watch(matieresProvider);
  final matieres = matieresAsync.value;
  if (matieres == null) {
    return matieresAsync.hasError
        ? AsyncError(matieresAsync.error!, matieresAsync.stackTrace!)
        : const AsyncLoading();
  }

  Classe? classe;
  Serie? serie;
  switch (ref.watch(etatAuthProvider)) {
    case AuthInvite():
      final choix = ref.watch(choixClasseProvider);
      classe = choix.classe;
      serie = choix.serie;
    case AuthConnecte():
      final profil = ref.watch(profilProvider);
      if (profil is! ProfilResolu) return const AsyncData(null);
      final classeId = profil.profil?.classeId;
      if (classeId == null) return const AsyncData(null);
      serie = profil.profil?.serie;
      final classesAsync = ref.watch(classesProvider);
      final classes = classesAsync.value;
      if (classes == null) {
        return classesAsync.hasError
            ? AsyncError(classesAsync.error!, classesAsync.stackTrace!)
            : const AsyncLoading();
      }
      final trouvees = classes.where((c) => c.id == classeId);
      classe = trouvees.isEmpty ? null : trouvees.first;
    case AuthDeconnecte():
      // La redirection ne laisse pas atterrir ici deconnecte ; etat neutre le
      // temps que l'auth se stabilise.
      return const AsyncData(null);
  }

  if (classe == null) return const AsyncData(null);

  final autorisees = ProgrammeScolaire.matieresAutorisees(
    classe: classe,
    serie: serie,
    catalogue: matieres,
  );
  if (autorisees.isEmpty) return const AsyncData(null);

  return AsyncData(
    BibliothequeCourante(classe: classe, matiere: autorisees.first),
  );
});

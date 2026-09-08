import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_documents_hors_ligne.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/ressource_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';

/// Ce que l'ecran « Mes telechargements » affiche : l'anneau de completion
/// ([ratio]) et la liste des documents presents groupes par chapitre ([groupes]).
class ApercuHorsLigne {
  const ApercuHorsLigne({required this.ratio, required this.groupes});

  final RatioHorsLigne ratio;
  final List<GroupeTelechargements> groupes;

  bool get estVide => groupes.isEmpty;

  /// Nombre de documents REELLEMENT presents sur l'appareil (somme des documents
  /// de tous les groupes). Sert la seconde ligne factuelle de l'anneau (« N
  /// documents sur l'appareil »), a cote de la couverture par chapitre COMPLET
  /// (report de l'etape 24 : un chapitre incomplet mais avec des documents ne
  /// doit pas se traduire par un decourageant « 0 document »).
  int get nombrePresents =>
      groupes.fold(0, (total, groupe) => total + groupe.documents.length);
}

/// L'apercu « Mes telechargements » d'une bibliotheque (classe, matiere).
/// `family` keyee par la meme cle que `chapitresProvider` : un cache par
/// bibliotheque. Lecture 100 % locale (disque + cache Drift), c'est le propre du
/// hors-ligne.
///
/// Deux mesures distinctes ici, a ne pas confondre :
///   - la LISTE = ce qui est reellement sur le disque ([listerPresents]), groupe
///     par chapitre — la verite de « present hors-ligne » est le disque ;
///   - l'ANNEAU = la couverture, soit la part de chapitres dont TOUS les documents
///     accessibles a l'eleve sont deja la ([DisponibiliteHorsLigne], point 5-a).
final apercuHorsLigneProvider = FutureProvider.family<ApercuHorsLigne, CibleChapitres>((
  ref,
  cle,
) async {
  final chapitres = await ref.watch(chapitresProvider(cle).future);

  final presents = await ref
      .watch(telechargementRepositoryProvider)
      .listerPresents();
  final idsPresents = presents.map((r) => r.id).toSet();

  // Anneau : toutes les ressources ACCESSIBLES de la bibliotheque. Depuis
  // l'etape 25, « accessible » = le vrai DROIT d'acces ([DroitAccesDocument], via
  // [accesDocumentProvider]) et non plus « non premium » : un abonne y gagne ses
  // corriges/evaluations, donc le DENOMINATEUR augmente (le pourcentage peut
  // baisser — c'est la definition honnete de la couverture, decision point 5.7).
  // Deux etats de droit seulement (gratuit / premium) : deux lectures suffisent.
  final accesGratuit = ref.watch(accesDocumentProvider(false));
  final accesPremium = ref.watch(accesDocumentProvider(true));
  bool estAccessible(bool premium) =>
      (premium ? accesPremium : accesGratuit) == AccesDocument.autorise;

  final repo = ref.watch(ressourceRepositoryProvider);
  // Lecture PONCTUELLE par chapitre : `.first` prend la premiere emission du
  // flux offline-first (le cache local, ou la 1re synchro si le cache est
  // vide) puis se termine — meme semantique que l'ancienne lecture Future,
  // retiree a l'etape 21 au profit des seuls flux reactifs.
  final parChapitre = await Future.wait(
    chapitres.map(
      (c) => repo.observerRessourcesDuChapitre(chapitreId: c.id).first,
    ),
  );
  final accessibles = [
    for (final liste in parChapitre)
      for (final ressource in liste)
        if (estAccessible(ressource.premium)) ressource,
  ];
  final ratio = DisponibiliteHorsLigne.calculer(
    chapitres: chapitres,
    ressourcesAccessibles: accessibles,
    idsPresents: idsPresents,
  );

  return ApercuHorsLigne(
    ratio: ratio,
    groupes: RegroupementDocumentsHorsLigne.de(presents, chapitres),
  );
});

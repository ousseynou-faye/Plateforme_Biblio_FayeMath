import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/usecases/disponibilite_hors_ligne.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_documents_hors_ligne.dart';
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

  // Anneau : toutes les ressources ACCESSIBLES de la bibliotheque. « Accessible »
  // = non premium en V1 (aucun abonnement encore ; le filtre par abonnement
  // actif arrivera avec le paiement, V2). Chaque chapitre est lu en cache local.
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
        if (!ressource.premium) ressource,
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

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/repositories/progression_repository.dart';
import 'package:fayemath_academy/domain/usecases/agregation_progression.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';

/// Fournit l'implementation du contrat de progression. Comme les autres
/// repositories : NON resolue ici (`presentation/` n'importe pas `data/`,
/// docs/ARCHITECTURE.md §3), injectee a la racine (`main.dart`), overridee par un
/// faux en test.
final progressionRepositoryProvider = Provider<ProgressionRepository>(
  (ref) => throw UnimplementedError(
    'progressionRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// L'etat de progression d'UN chapitre pour l'eleve connecte, REACTIF (etape 21) :
/// `StreamProvider.family` keyee par `chapitreId`. Sert au statut de l'ecran de
/// detail (maquette ecran 6), en remplacement du chip statique « A faire ».
///
/// Invite ou deconnecte : pas de progression possible (RLS `to authenticated`
/// seul) -> on emet `aFaire`, sans jamais interroger le repo. Le type expose reste
/// `AsyncValue`, donc l'ecran garde ses `.when`.
final etatChapitreProvider = StreamProvider.family<EtatProgression, String>((
  ref,
  chapitreId,
) {
  final etatAuth = ref.watch(etatAuthProvider);
  if (etatAuth is! AuthConnecte) {
    return Stream.value(EtatProgression.aFaire);
  }
  return ref
      .watch(progressionRepositoryProvider)
      .observerEtat(
        utilisateurId: etatAuth.session.utilisateurId,
        chapitreId: chapitreId,
      );
});

/// La progression de TOUS les chapitres deja touches par l'eleve connecte, en
/// flux reactif : une correspondance `chapitreId -> EtatProgression`. UN seul
/// abonnement pour toute la liste des chapitres (maquette ecran 5) : pastille de
/// statut par ligne + compteur « X termines », sans N abonnements separes.
///
/// Un chapitre absent de la Map est « A faire » (le consommateur applique ce
/// defaut). Invite / deconnecte : Map vide (pas de progression) -> tout « A faire ».
final etatsChapitresProvider = StreamProvider<Map<String, EtatProgression>>((
  ref,
) {
  final etatAuth = ref.watch(etatAuthProvider);
  if (etatAuth is! AuthConnecte) {
    return Stream.value(const <String, EtatProgression>{});
  }
  return ref
      .watch(progressionRepositoryProvider)
      .observerEtats(etatAuth.session.utilisateurId);
});

/// Action de modification de la progression, centralisant la resolution de
/// l'eleve courant (l'ecran n'a pas a la refaire). L'ecriture est LOCALE d'abord
/// (le flux `.watch()` rafraichit l'ecran tout seul) ; la pousse serveur est
/// best-effort dans le repository. Pour un invite / deconnecte, il n'y a pas de
/// progression a enregistrer : l'appel est sans effet (l'ecran, lui, propose de
/// creer un compte — lot D).
class SuiviProgression {
  const SuiviProgression(this._ref);

  final Ref _ref;

  Future<void> definirEtat({
    required String chapitreId,
    required EtatProgression etat,
  }) async {
    final etatAuth = _ref.read(etatAuthProvider);
    if (etatAuth is! AuthConnecte) return;
    await _ref
        .read(progressionRepositoryProvider)
        .definirEtat(
          utilisateurId: etatAuth.session.utilisateurId,
          chapitreId: chapitreId,
          etat: etat,
        );
  }
}

final suiviProgressionProvider = Provider<SuiviProgression>(
  SuiviProgression.new,
);

/// L'avancement agrege de l'eleve (anneau global + par matiere + mini-stats par
/// etat), REACTIF : il combine les chapitres de la bibliotheque courante et la
/// progression, et se recalcule des que l'un ou l'autre change. Alimente l'ecran
/// « Ma progression » (ecran 9) et le tableau de bord (ecran 4), etape 24.
///
/// V1 : une seule bibliotheque (Maths), donc un seul groupe « par matiere » — mais
/// la regle pure [AgregationProgression] groupe par `matiereId`, prete pour une 2e
/// bibliotheque. Le detail loading/erreur suit exactement `bibliothequeCourante`
/// (memes checks `AsyncValue` explicites, pas de `.when` a re-emballer).
final avancementProgressionProvider =
    Provider<AsyncValue<AvancementProgression>>((ref) {
      final bibAsync = ref.watch(bibliothequeCouranteProvider);
      final bib = bibAsync.value;
      if (bib == null) {
        if (bibAsync.hasError) {
          return AsyncError(bibAsync.error!, bibAsync.stackTrace!);
        }
        if (bibAsync.isLoading) return const AsyncLoading();
        // data(null) : etat neutre (deconnecte/transitoire) -> agregation vide.
        return AsyncData(
          AgregationProgression.calculer(chapitres: const [], etats: const {}),
        );
      }

      final chapitresAsync = ref.watch(chapitresProvider(bib.cle));
      final chapitres = chapitresAsync.value;
      if (chapitres == null) {
        return chapitresAsync.hasError
            ? AsyncError(chapitresAsync.error!, chapitresAsync.stackTrace!)
            : const AsyncLoading();
      }

      final etatsAsync = ref.watch(etatsChapitresProvider);
      final etats = etatsAsync.value;
      if (etats == null) {
        return etatsAsync.hasError
            ? AsyncError(etatsAsync.error!, etatsAsync.stackTrace!)
            : const AsyncLoading();
      }

      return AsyncData(
        AgregationProgression.calculer(chapitres: chapitres, etats: etats),
      );
    });

/// Le premier chapitre (par `ordre`) actuellement « a revoir », ou `null` s'il n'y
/// en a pas (ou tant que les donnees chargent). Alimente la carte « Ta prochaine
/// action » de l'ecran « Ma progression » (ecran 9, SPEC FAQ Q5 : une action unique,
/// mise en avant, propose le chapitre a revoir). `null` = pas de carte, jamais une
/// erreur.
final prochainChapitreARevoirProvider = Provider<Chapitre?>((ref) {
  final bib = ref.watch(bibliothequeCouranteProvider).value;
  if (bib == null) return null;
  final chapitres = ref.watch(chapitresProvider(bib.cle)).value;
  if (chapitres == null) return null;
  final etats = ref.watch(etatsChapitresProvider).value;
  if (etats == null) return null;

  final tries = [...chapitres]..sort((a, b) => a.ordre.compareTo(b.ordre));
  for (final chapitre in tries) {
    if (etats[chapitre.id] == EtatProgression.aRevoir) return chapitre;
  }
  return null;
});

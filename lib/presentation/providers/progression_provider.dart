import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/etat_progression.dart';
import 'package:fayemath_academy/domain/repositories/progression_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

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

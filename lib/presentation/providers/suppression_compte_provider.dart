import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/repositories/auth_repository.dart';
import 'package:fayemath_academy/domain/repositories/nettoyage_local_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Fournit l'implementation du nettoyage local. NON resolue ici : injectee a la
/// racine (`main.dart`) via `overrideWith`, overridee par un faux en test
/// (`presentation/` n'importe pas `data/`, docs/ARCHITECTURE.md §3).
final nettoyageLocalRepositoryProvider = Provider<NettoyageLocalRepository>(
  (ref) => throw UnimplementedError(
    'nettoyageLocalRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// Orchestre la suppression COMPLETE du compte : cote serveur (RTBF, cascade)
/// PUIS purge de l'appareil. Assemble deux contrats du domaine en un seul geste.
final suppressionCompteProvider = Provider<SuppressionCompte>(
  (ref) => SuppressionCompte(
    authRepository: ref.read(authRepositoryProvider),
    nettoyageLocal: ref.read(nettoyageLocalRepositoryProvider),
  ),
);

/// Le geste « supprimer mon compte », en un seul point testable.
class SuppressionCompte {
  SuppressionCompte({
    required AuthRepository authRepository,
    required NettoyageLocalRepository nettoyageLocal,
  }) : _auth = authRepository,
       _nettoyage = nettoyageLocal;

  final AuthRepository _auth;
  final NettoyageLocalRepository _nettoyage;

  /// 1) Supprime le compte cote serveur et ferme la session. 2) Purge les
  /// donnees locales de l'appareil.
  ///
  /// L'ORDRE importe : si (1) echoue (leve un `EchecAuthentification`), (2) n'a
  /// PAS lieu — rien n'est efface en local, l'eleve garde son acces. La purge
  /// locale est best-effort (le compte est deja parti cote serveur) : elle ne
  /// leve pas, donc `executer()` ne remonte que l'echec serveur de l'etape (1).
  Future<void> executer() async {
    await _auth.supprimerMonCompte();
    await _nettoyage.viderDonneesEleve();
  }
}

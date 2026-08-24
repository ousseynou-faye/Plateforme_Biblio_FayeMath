import 'package:fayemath_academy/domain/entities/etat_telechargement.dart';

/// Deduit l'[EtatTelechargement] d'un document a partir de trois faits observes
/// par la couche `presentation/` (etat Riverpod, etape 19, Lot D) :
///   - [estLocal]  : le PDF telecharge est present sur l'appareil ;
///   - [enCours]   : un telechargement de ce document tourne en ce moment ;
///   - [aEchoue]   : le dernier essai s'est solde par un echec.
///
/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : elle vit dans `domain/`, se teste
/// sans Flutter, sans disque ni reseau, et centralise la PRIORITE des etats en un
/// seul endroit plutot que de la disperser dans les widgets.
///
/// Priorite (du plus fort au plus faible) :
///   1. `enCours`      — un transfert en cours prime sur tout le reste ;
///   2. `local`        — sinon, un fichier deja present prime sur un echec passe ;
///   3. `echec`        — sinon, un echec recent est signale a l'eleve ;
///   4. `telechargeable` — sinon, rien n'a encore ete tente.
abstract final class ResolutionEtatTelechargement {
  static EtatTelechargement resoudre({
    required bool estLocal,
    required bool enCours,
    required bool aEchoue,
  }) {
    if (enCours) return EtatTelechargement.enCours;
    if (estLocal) return EtatTelechargement.local;
    if (aEchoue) return EtatTelechargement.echec;
    return EtatTelechargement.telechargeable;
  }
}

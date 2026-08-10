import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Le mode de l'ecran d'authentification unique (maquette V2.1, ecran 2) : il
/// bascule sur place entre creer un compte et se connecter.
enum ModeAuth { inscription, connexion }

/// Statut de la soumission du formulaire — ce que l'ecran affiche pendant et
/// apres l'envoi.
sealed class StatutSoumission {
  const StatutSoumission();
}

/// Rien en cours : saisie possible.
class SoumissionPrete extends StatutSoumission {
  const SoumissionPrete();
}

/// Envoi en cours : bouton en attente, champs verrouilles.
class SoumissionEnCours extends StatutSoumission {
  const SoumissionEnCours();
}

/// Echec metier a afficher (message derive du type, jamais l'exception brute).
class SoumissionEchouee extends StatutSoumission {
  const SoumissionEchouee(this.echec);

  final EchecAuthentification echec;
}

/// Inscription acceptee : la confirmation e-mail etant activee (decision 5.8),
/// aucune session n'est ouverte -> l'ecran affiche « verifie ta boite mail ».
class InscriptionAConfirmer extends StatutSoumission {
  const InscriptionAConfirmer();
}

/// L'etat complet du formulaire : le mode courant et le statut d'envoi.
class EtatFormulaireAuth {
  const EtatFormulaireAuth({required this.mode, required this.statut});

  final ModeAuth mode;
  final StatutSoumission statut;

  EtatFormulaireAuth copyWith({ModeAuth? mode, StatutSoumission? statut}) =>
      EtatFormulaireAuth(
        mode: mode ?? this.mode,
        statut: statut ?? this.statut,
      );
}

/// Pilote le formulaire d'authentification : bascule de mode et soumission.
/// La connexion reussie ne change pas d'etat ici — c'est le flux de session
/// ([etatAuthProvider]) et la redirection go_router qui prennent le relais.
class FormulaireAuthNotifier extends Notifier<EtatFormulaireAuth> {
  @override
  EtatFormulaireAuth build() => const EtatFormulaireAuth(
    // La maquette ouvre sur « Creer mon compte ».
    mode: ModeAuth.inscription,
    statut: SoumissionPrete(),
  );

  /// Bascule inscription <-> connexion, et efface un eventuel message d'echec.
  void basculerMode() {
    final nouveau = state.mode == ModeAuth.inscription
        ? ModeAuth.connexion
        : ModeAuth.inscription;
    state = EtatFormulaireAuth(mode: nouveau, statut: const SoumissionPrete());
  }

  /// Soumet le formulaire selon le mode courant. Ne leve jamais : les echecs
  /// metier sont ranges dans l'etat ([SoumissionEchouee]) pour affichage.
  Future<void> soumettre({
    required String email,
    required String motDePasse,
  }) async {
    state = state.copyWith(statut: const SoumissionEnCours());
    final repository = ref.read(authRepositoryProvider);
    try {
      if (state.mode == ModeAuth.connexion) {
        await repository.seConnecter(email: email, motDePasse: motDePasse);
        // Succes : la redirection suit le flux de session, on relache le
        // formulaire.
        state = state.copyWith(statut: const SoumissionPrete());
      } else {
        await repository.sInscrire(email: email, motDePasse: motDePasse);
        state = state.copyWith(statut: const InscriptionAConfirmer());
      }
    } on EchecAuthentification catch (echec) {
      state = state.copyWith(statut: SoumissionEchouee(echec));
    }
  }
}

final formulaireAuthProvider =
    NotifierProvider<FormulaireAuthNotifier, EtatFormulaireAuth>(
      FormulaireAuthNotifier.new,
    );

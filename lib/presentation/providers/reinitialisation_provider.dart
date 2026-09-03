import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Le sous-flux « mot de passe oublie » (lot « Qualite B », flux OTP a 6
/// chiffres), pilote a part du formulaire connexion/inscription
/// ([formulaireAuthProvider]) pour ne pas alourdir son etat.
///
/// Deux etapes visibles ([EtapeReinit]) : d'abord la DEMANDE (saisir l'e-mail,
/// recevoir un code), puis la VERIFICATION (saisir le code, puis le nouveau mot
/// de passe une fois le code valide).
enum EtapeReinit { demande, verification }

/// Statut d'une action du sous-flux (envoi de la demande, verification du code,
/// pose du mot de passe) : ce que l'ecran montre pendant et apres l'envoi.
sealed class StatutReinit {
  const StatutReinit();
}

class ReinitPrete extends StatutReinit {
  const ReinitPrete();
}

class ReinitEnCours extends StatutReinit {
  const ReinitEnCours();
}

class ReinitEchouee extends StatutReinit {
  const ReinitEchouee(this.echec);

  final EchecAuthentification echec;
}

/// L'etat complet du sous-flux de reinitialisation.
class EtatReinit {
  const EtatReinit({
    this.actif = false,
    this.etape = EtapeReinit.demande,
    this.email = '',
    this.codeVerifie = false,
    this.recuperationEnCours = false,
    this.succes = false,
    this.statut = const ReinitPrete(),
  });

  /// L'ecran d'auth affiche le sous-flux de reinitialisation (au lieu du
  /// formulaire connexion/inscription).
  final bool actif;

  /// Etape courante du sous-flux.
  final EtapeReinit etape;

  /// L'e-mail saisi a l'etape demande (pre-rempli depuis le champ de connexion).
  final String email;

  /// Le code a ete verifie : une session de recuperation est ouverte, l'ecran
  /// montre le champ « nouveau mot de passe ».
  final bool codeVerifie;

  /// ⚠️ Drapeau lu par la REDIRECTION go_router : tant qu'il est vrai, une
  /// session de recuperation est (ou peut etre) ouverte et le routeur RETIENT
  /// l'eleve sur l'ecran d'auth — sinon `verifierCodeReinitialisation`, qui
  /// ouvre une vraie session, ferait filer la navigation vers le contenu avant
  /// que le nouveau mot de passe soit pose (contrat du lot B).
  final bool recuperationEnCours;

  /// Vrai une seule fois, juste apres la pose reussie du nouveau mot de passe et
  /// la deconnexion : l'ecran affiche une confirmation puis appelle
  /// [ReinitialisationNotifier.accuserSucces].
  final bool succes;

  /// Statut de l'action en cours (prete / en cours / echouee).
  final StatutReinit statut;

  EtatReinit copyWith({
    bool? actif,
    EtapeReinit? etape,
    String? email,
    bool? codeVerifie,
    bool? recuperationEnCours,
    bool? succes,
    StatutReinit? statut,
  }) => EtatReinit(
    actif: actif ?? this.actif,
    etape: etape ?? this.etape,
    email: email ?? this.email,
    codeVerifie: codeVerifie ?? this.codeVerifie,
    recuperationEnCours: recuperationEnCours ?? this.recuperationEnCours,
    succes: succes ?? this.succes,
    statut: statut ?? this.statut,
  );
}

/// Pilote le sous-flux de reinitialisation. Aucune methode ne LEVE : les echecs
/// metier sont ranges dans l'etat ([ReinitEchouee]) pour affichage, comme le
/// formulaire d'auth.
class ReinitialisationNotifier extends Notifier<EtatReinit> {
  @override
  EtatReinit build() => const EtatReinit();

  /// Ouvre le sous-flux (« Mot de passe oublie ? »), en pre-remplissant l'e-mail
  /// avec celui deja saisi cote connexion.
  void ouvrir(String emailPreRempli) {
    state = EtatReinit(actif: true, email: emailPreRempli.trim());
  }

  /// Ferme le sous-flux et revient au formulaire d'auth normal. Si une session
  /// de recuperation etait ouverte (code deja verifie), on la ferme proprement.
  Future<void> annuler() async {
    if (state.codeVerifie) {
      await ref.read(authRepositoryProvider).seDeconnecter();
    }
    state = const EtatReinit();
  }

  /// Etape demande : envoie le code a [email]. Reponse NEUTRE (le repository ne
  /// leve jamais « e-mail inconnu ») -> en cas de succes on passe a l'etape
  /// verification quoi qu'il arrive cote existence du compte.
  Future<void> demander(String email) async {
    final e = email.trim();
    state = state.copyWith(email: e, statut: const ReinitEnCours());
    try {
      await ref.read(authRepositoryProvider).demanderReinitialisation(email: e);
      state = state.copyWith(
        etape: EtapeReinit.verification,
        statut: const ReinitPrete(),
      );
    } on EchecAuthentification catch (echec) {
      state = state.copyWith(statut: ReinitEchouee(echec));
    }
  }

  /// Etape verification : verifie le [code]. On leve le drapeau
  /// [EtatReinit.recuperationEnCours] AVANT l'appel : si le code est bon, une
  /// session s'ouvre pendant l'await et le routeur doit deja retenir la
  /// navigation. En cas d'echec (code faux), on rabaisse le drapeau (aucune
  /// session ouverte).
  Future<void> soumettreCode(String code) async {
    state = state.copyWith(
      statut: const ReinitEnCours(),
      recuperationEnCours: true,
    );
    try {
      await ref
          .read(authRepositoryProvider)
          .verifierCodeReinitialisation(email: state.email, code: code.trim());
      state = state.copyWith(codeVerifie: true, statut: const ReinitPrete());
    } on EchecAuthentification catch (echec) {
      state = state.copyWith(
        statut: ReinitEchouee(echec),
        recuperationEnCours: false,
      );
    }
  }

  /// Etape verification (2e temps) : pose le nouveau mot de passe pour la session
  /// de recuperation, puis DECONNECTE (l'eleve se reconnecte avec son nouveau mot
  /// de passe, conforme a la DoD). Succes -> etat neutre + drapeau [succes].
  Future<void> definirMotDePasse(String motDePasse) async {
    state = state.copyWith(statut: const ReinitEnCours());
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.definirNouveauMotDePasse(motDePasse: motDePasse);
      // Ferme la session de recuperation : l'eleve se reconnectera avec le
      // nouveau mot de passe. La deconnexion rabaisse aussi recuperationEnCours.
      await repo.seDeconnecter();
      state = const EtatReinit(succes: true);
    } on EchecAuthentification catch (echec) {
      state = state.copyWith(statut: ReinitEchouee(echec));
    }
  }

  /// L'ecran a affiche la confirmation de succes : on efface le drapeau one-shot.
  void accuserSucces() {
    if (state.succes) state = const EtatReinit();
  }
}

final reinitialisationProvider =
    NotifierProvider<ReinitialisationNotifier, EtatReinit>(
      ReinitialisationNotifier.new,
    );

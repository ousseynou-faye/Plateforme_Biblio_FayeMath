import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';
import 'package:fayemath_academy/domain/repositories/profil_repository.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';

/// Fournit l'implementation du contrat de profil. Meme principe que
/// `catalogueRepositoryProvider` : injectee a la racine (`main.dart`), overridee
/// par un faux en test.
final profilRepositoryProvider = Provider<ProfilRepository>(
  (ref) => throw UnimplementedError(
    'profilRepositoryProvider doit etre override a la racine (main.dart).',
  ),
);

/// L'etat du profil de l'eleve connecte, du point de vue de la navigation
/// (lot F). Type SCELLE : le `switch` de redirection sera exhaustif.
sealed class EtatProfil {
  const EtatProfil();
}

/// Personne de connecte (deconnecte ou invite) : pas de profil serveur a lire.
class ProfilHorsSujet extends EtatProfil {
  const ProfilHorsSujet();
}

/// Lecture du profil en cours (cache local puis serveur). La redirection ne
/// tranche pas encore tant qu'on est dans cet etat.
class ProfilEnChargement extends EtatProfil {
  const ProfilEnChargement();
}

/// Profil resolu. [profil] peut etre `null` si l'eleve n'a pas encore de ligne
/// lisible ; [classeChoisie] dit si une classe est deja enregistree — c'est ce
/// que la redirection regarde pour envoyer (ou non) vers l'ecran de choix.
class ProfilResolu extends EtatProfil {
  const ProfilResolu(this.profil);

  final Utilisateur? profil;

  bool get classeChoisie => profil?.classeId != null;
}

/// Derive [EtatProfil] de l'etat d'authentification : lit le profil quand un
/// eleve est connecte, et le remet a jour apres l'enregistrement d'un choix.
class ProfilNotifier extends Notifier<EtatProfil> {
  @override
  EtatProfil build() {
    final etatAuth = ref.watch(etatAuthProvider);
    if (etatAuth is! AuthConnecte) return const ProfilHorsSujet();

    // Lecture offline-first en arriere-plan ; on part de « en chargement » pour
    // que la redirection attende un verdict plutot que de supposer.
    unawaited(_charger(etatAuth.session.utilisateurId));
    return const ProfilEnChargement();
  }

  Future<void> _charger(String utilisateurId) async {
    final profil = await ref
        .read(profilRepositoryProvider)
        .profilCourant(utilisateurId);
    _publierSiActuel(utilisateurId, ProfilResolu(profil));
  }

  /// Enregistre le choix de classe / serie de l'eleve connecte, puis met l'etat
  /// a jour pour que la redirection quitte l'ecran de choix.
  ///
  /// Pour un invite (non connecte), il n'y a pas de profil serveur : le choix
  /// reste purement local (choixClasseProvider), rien a persister ici. Une
  /// panne d'ecriture remonte en `EchecEnregistrement` (l'ecran l'affiche).
  Future<void> enregistrerChoix({
    required String classeId,
    required Serie? serie,
  }) async {
    final etatAuth = ref.read(etatAuthProvider);
    if (etatAuth is! AuthConnecte) return;

    final utilisateurId = etatAuth.session.utilisateurId;
    final repo = ref.read(profilRepositoryProvider);
    await repo.definirClasseEtSerie(
      utilisateurId: utilisateurId,
      classeId: classeId,
      serie: serie,
    );
    // Relit le profil (le cache local vient d'etre resynchronise par l'ecriture)
    // pour refleter la classe fraichement choisie.
    final frais = await repo.profilCourant(utilisateurId);
    _publierSiActuel(utilisateurId, ProfilResolu(frais));
  }

  /// Ne publie que si l'eleve connecte est TOUJOURS le meme : une lecture en vol
  /// lancee pour un compte precedent ne doit pas ecraser l'etat du nouveau.
  void _publierSiActuel(String utilisateurId, EtatProfil nouvel) {
    final etatAuth = ref.read(etatAuthProvider);
    if (etatAuth is AuthConnecte &&
        etatAuth.session.utilisateurId == utilisateurId) {
      state = nouvel;
    }
  }
}

final profilProvider = NotifierProvider<ProfilNotifier, EtatProfil>(
  ProfilNotifier.new,
);

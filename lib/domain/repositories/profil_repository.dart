import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/entities/utilisateur.dart';

/// Le contrat du profil de l'eleve connecte : lire son profil (pour savoir s'il
/// a deja choisi sa classe) et enregistrer son choix de classe / serie.
///
/// Ne concerne QUE l'eleve courant : le RLS de `utilisateur` (migration 03,
/// section B) n'autorise que la lecture et la mise a jour de SA propre ligne
/// (`auth.uid() = id`). Il n'y a donc ni acces a un autre profil, ni INSERT :
/// la ligne existe deja, creee par le trigger a l'inscription (etape 13).
abstract interface class ProfilRepository {
  /// Le profil de l'eleve [utilisateurId], ou `null` s'il est inconnu (ni en
  /// cache local ni joignable sur le serveur).
  ///
  /// Offline-first : lit le cache Drift d'abord, se rafraichit depuis Supabase
  /// ensuite. Sert notamment a la redirection (un connecte dont `classeId` est
  /// encore `null` doit arriver sur l'ecran de choix, etape 14).
  Future<Utilisateur?> profilCourant(String utilisateurId);

  /// Enregistre le choix de classe (et de serie) de l'eleve : UPDATE de sa
  /// propre ligne via la policy `utilisateur_maj_de_soi`, JAMAIS d'INSERT. Met
  /// aussi a jour le cache local pour que la redirection en tienne compte au
  /// prochain lancement.
  ///
  /// [serie] doit valoir `null` pour une classe sans serie (college, 2nde) et
  /// une valeur (L / S1 / S2) pour la 1ere / Terminale — la coherence est
  /// garantie par la regle de programme (usecases/programme_scolaire.dart), pas
  /// ici. Ecriture : contrairement aux lectures, elle EXIGE le reseau ; une
  /// panne est traduite en echec metier par l'implementation (`data/`).
  Future<void> definirClasseEtSerie({
    required String utilisateurId,
    required String classeId,
    required Serie? serie,
  });
}

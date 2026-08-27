import 'package:fayemath_academy/domain/entities/etat_progression.dart';

/// Le contrat du suivi de progression de l'eleve connecte : lire l'etat d'un
/// chapitre (ou de tous), et le modifier — MEME HORS-LIGNE (etape 22, Feuille de
/// Route doc 04, Phase 3). Le domaine DECLARE le besoin, `data/` s'y plie
/// (inversion de dependance, docs/ARCHITECTURE.md §3).
///
/// Ne concerne QUE l'eleve courant : le RLS `progression_acces_de_soi`
/// (migration 03) donne l'acces complet (SELECT/INSERT/UPDATE/DELETE) a
/// `authenticated` sur ses propres lignes (`auth.uid() = utilisateur_id`), et
/// RIEN a `anon` — un invite n'a pas de progression. Une seule ligne par couple
/// (eleve, chapitre) : `unique(utilisateur_id, chapitre_id)`.
///
/// TROISIEME pattern d'ecriture du projet (les deux premiers : lecture
/// offline-first, et ecriture-qui-exige-le-reseau du telechargement). Ici
/// l'ecriture est LOCALE D'ABORD (GLOSSAIRE §6, regle 5 du contrat hors-ligne :
/// « la progression est enregistree en local d'abord, puis synchronisee au
/// retour du reseau ») : on ecrit dans Drift immediatement, l'ecran se met a
/// jour, PUIS on tente Supabase en best-effort — sans jamais faire echouer
/// l'action ressentie par l'eleve si le reseau manque. La reconciliation « la
/// modification la plus recente l'emporte » releve de l'etape 23, pas d'ici.
abstract interface class ProgressionRepository {
  /// L'etat du chapitre [chapitreId] pour l'eleve [utilisateurId], en FLUX
  /// REACTIF (etape 21) : emet immediatement l'etat en cache, puis re-emet tout
  /// seul apres chaque ecriture locale ou resynchro (ARCHITECTURE §7).
  ///
  /// Absence de ligne = [EtatProgression.aFaire], SANS erreur : un chapitre
  /// jamais touche est « A faire » par defaut (aucune insertion en masse a la
  /// selection de classe). Sert au statut de l'ecran de detail (maquette ecran
  /// 6), en remplacement du chip statique « A faire » de l'etape 16.
  Stream<EtatProgression> observerEtat({
    required String utilisateurId,
    required String chapitreId,
  });

  /// Les etats de TOUS les chapitres deja touches par l'eleve [utilisateurId],
  /// en flux reactif : une correspondance `chapitreId -> EtatProgression`. Seuls
  /// les chapitres AYANT une ligne y figurent ; un chapitre absent de la Map est
  /// « A faire » (le consommateur applique ce defaut). Un seul abonnement pour
  /// toute la liste des chapitres (maquette ecran 5) : pastille de statut par
  /// ligne + compteur « X termines », sans N abonnements separes.
  Stream<Map<String, EtatProgression>> observerEtats(String utilisateurId);

  /// Modifie l'etat du chapitre [chapitreId] pour l'eleve [utilisateurId].
  /// Ecriture LOCALE d'abord (immediate, jamais bloquee par le reseau), puis
  /// tentative Supabase en best-effort. Ne retourne rien et ne LEVE PAS d'echec
  /// de synchronisation : l'absence de reseau est normale et attendue (contrat
  /// hors-ligne), a la difference d'une ecriture qui exige le reseau (le choix
  /// de classe leve un `EchecEnregistrement`, pas ici). L'implementation trace
  /// un echec de la tentative serveur en debug, sans le remonter a l'ecran.
  Future<void> definirEtat({
    required String utilisateurId,
    required String chapitreId,
    required EtatProgression etat,
  });
}

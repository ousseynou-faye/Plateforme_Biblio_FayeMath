import 'package:fayemath_academy/domain/entities/ressource.dart';

/// Le contrat du moteur de telechargement hors-ligne (etape 19) : copier un
/// document du bucket Storage vers l'espace prive de l'appareil, pour que le
/// lecteur (ecran 7) ouvre enfin le vrai PDF. Le domaine DECLARE le besoin,
/// `data/` fournit la mecanique (dio + Supabase Storage + path_provider) —
/// inversion de dependance (docs/ARCHITECTURE.md §3).
///
/// A la difference des repositories de LECTURE (chapitres, ressources), un
/// telechargement n'est PAS offline-first : c'est une ECRITURE sur disque qui
/// EXIGE le reseau. Son echec est un vrai echec, traduit en [EchecTelechargement]
/// par l'implementation (docs/CONVENTIONS.md §5). Le contrat n'impose que le
/// resultat, jamais la mecanique.
///
/// Contrat hors-ligne respecte (GLOSSAIRE §6) : rien ne se telecharge sans un
/// appel EXPLICITE a [telecharger] (regle 1) ; la taille est deja annoncee avant,
/// a l'ecran (regle 2, depuis l'etape 16) ; l'ecriture est ATOMIQUE, donc une
/// interruption ne laisse jamais de demi-fichier lisible (regle 3) ; un echec sur
/// un document n'affecte aucun autre (regle 4).
abstract interface class TelechargementRepository {
  /// Le chemin local du PDF si — et seulement si — il est deja present sur
  /// l'appareil (telechargement termine). `null` sinon (jamais telecharge, ou
  /// transfert interrompu laissant un fichier partiel). Sert au lecteur pour
  /// decider s'il ouvre le document ou affiche l'etat « pas encore sur l'appareil ».
  Future<String?> cheminLocalSiPresent(String ressourceId);

  /// Telecharge [ressource] vers l'espace prive de l'appareil, de facon atomique.
  ///
  /// Emet la progression du transfert (de `0.0` a `1.0`), puis se termine
  /// normalement quand le fichier final est en place. En cas de probleme, le flux
  /// se termine par une erreur [EchecTelechargement] (jamais une exception brute).
  /// Annuler l'abonnement au flux annule le transfert et nettoie le fichier
  /// partiel — rien ne se telecharge en arriere-plan sans qu'on l'ecoute.
  Stream<double> telecharger(Ressource ressource);

  /// Les ressources dont le PDF est PRESENT sur l'appareil (etape 20, ecran
  /// « Mes telechargements »). Source de verite = le DISQUE : on scanne le dossier
  /// des telechargements, puis on joint chaque fichier au catalogue en cache local
  /// pour retrouver son titre/type/taille. Un fichier sans ressource connue en
  /// cache est ignore (rien a afficher pour lui).
  ///
  /// Lecture 100 % locale, sans reseau (c'est le propre du hors-ligne). L'ordre
  /// n'est pas garanti : l'ecran regroupe par chapitre et ordonne lui-meme.
  Future<List<Ressource>> listerPresents();

  /// Supprime le fichier PDF telecharge de [ressourceId] sur l'appareil. Best-effort
  /// et idempotent : sans effet si le fichier n'est pas la.
  ///
  /// Ne touche JAMAIS la ligne `telechargement` en base (decision etape 20) : la
  /// disponibilite hors-ligne se lit exclusivement sur le disque ([cheminLocalSiPresent]),
  /// la ligne reste comme trace/historique. Rien ne se supprime sans une action
  /// EXPLICITE de l'eleve (symetrique de la regle 1 du contrat hors-ligne).
  Future<void> supprimer(String ressourceId);
}

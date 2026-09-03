/// Les echecs metier de l'authentification.
///
/// La couche `data/` attrape les exceptions techniques de Supabase
/// (`AuthException`, coupure reseau) et les TRADUIT en un de ces types ; la
/// couche `presentation/` n'en voit jamais l'origine brute et sait quel message
/// afficher (docs/CONVENTIONS.md §5, regle §8 du prompt etape 13). C'est la
/// suite annoncee par `core/errors/donnees_invalides.dart`, limitee ici a ce
/// dont l'authentification a besoin — pas une liste speculative.
///
/// Type SCELLE (`sealed`) : le `switch` d'affichage cote presentation est
/// exhaustif. Le jour ou l'on ajoute un cas, tout `switch` qui l'oublie devient
/// une erreur de compilation, pas un bug silencieux decouvert sur le telephone
/// d'un eleve.
sealed class EchecAuthentification implements Exception {
  const EchecAuthentification([this.diagnostic]);

  /// Detail technique NON sensible, utile a la journalisation. Ne contient
  /// JAMAIS d'e-mail, de mot de passe ni de jeton (SECURITY.md §5). Souvent
  /// `null` — renseigne surtout pour [EchecAuthentificationInattendu].
  final String? diagnostic;

  @override
  String toString() =>
      '$runtimeType${diagnostic == null ? '' : ' : $diagnostic'}';
}

/// Connexion refusee : e-mail inconnu OU mot de passe faux. Volontairement
/// indistinct — ne pas reveler si l'e-mail existe deja (bonne pratique
/// securite, evite l'enumeration de comptes).
class IdentifiantsInvalides extends EchecAuthentification {
  const IdentifiantsInvalides([super.diagnostic]);
}

/// Inscription avec un e-mail deja associe a un compte.
class CompteExistant extends EchecAuthentification {
  const CompteExistant([super.diagnostic]);
}

/// Connexion tentee avant d'avoir clique le lien de confirmation recu par
/// e-mail (la confirmation est activee cote Supabase, decision du 10/08/2026).
class EmailNonConfirme extends EchecAuthentification {
  const EmailNonConfirme([super.diagnostic]);
}

/// Pas de reseau au moment de l'appel Auth.
///
/// NB : hors authentification, l'absence de reseau n'est PAS une erreur — c'est
/// le mode normal du contrat offline-first (docs/CONVENTIONS.md §5). Mais
/// s'inscrire et se connecter exigent, elles, une connexion : ici le reseau
/// coupe est bien un echec a signaler a l'eleve.
class PanneReseau extends EchecAuthentification {
  const PanneReseau([super.diagnostic]);
}

/// Code de recuperation (recu par e-mail) faux ou expire, saisi a l'ecran
/// « mot de passe oublie » (flux OTP, lot « Qualite B »). Distinct de
/// [IdentifiantsInvalides] (echec de CONNEXION) : ici l'eleve a un compte, il se
/// trompe (ou tarde) sur le code a 6 chiffres.
class CodeRecuperationInvalide extends EchecAuthentification {
  const CodeRecuperationInvalide([super.diagnostic]);
}

/// Trop de demandes rapprochees (limite d'envoi d'e-mails / de requetes cote
/// Supabase). Frequent avec le SMTP par defaut (debit bride) : on invite l'eleve
/// a patienter plutot que d'afficher un message generique d'erreur.
class TropDeTentatives extends EchecAuthentification {
  const TropDeTentatives([super.diagnostic]);
}

/// Tout autre echec non prevu individuellement. Fourre-tout TRACABLE (jamais
/// silencieux) : on journalise son [diagnostic] non sensible et on affiche a
/// l'eleve un message generique.
class EchecAuthentificationInattendu extends EchecAuthentification {
  const EchecAuthentificationInattendu([super.diagnostic]);
}

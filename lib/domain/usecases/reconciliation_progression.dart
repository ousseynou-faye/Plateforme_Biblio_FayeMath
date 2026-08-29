/// Vue MINIMALE d'une ligne de progression cote LOCAL, pour la reconciliation :
/// sa date de derniere modification et si elle est encore « en attente » (ecrite
/// hors-ligne, pas encore confirmee cote serveur). C'est un record (Dart 3) : un
/// petit tuple nomme, sans classe a declarer — juste ce dont la regle a besoin,
/// sans tirer ni Drift ni l'entite `Progression`.
typedef VueLocaleProgression = ({DateTime dateMaj, bool enAttente});

/// La decision prise par [ReconciliationProgression.decider] pour UN chapitre.
enum DecisionReconciliation {
  /// La modification locale l'emporte : on la POUSSE vers le serveur (puis on la
  /// marquera « synchronisee »). Cas de l'ecriture faite hors-ligne.
  pousserVersServeur,

  /// La valeur du serveur l'emporte : on l'ECRIT en local (elle comble un
  /// chapitre absent, ou remplace une valeur locale plus ancienne).
  adopterServeur,

  /// Le local reflete deja la verite : aucune ecriture d'aucun cote.
  rienAFaire,
}

/// « La version la plus recente l'emporte » (Feuille de Route doc 04, etape 23 ;
/// 03 - Technique et Pilotage.pdf §1.7), appliquee chapitre par chapitre entre le
/// cache LOCAL et le SERVEUR au retour du reseau.
///
/// Regle METIER PURE (docs/ARCHITECTURE.md §9) : vit dans `domain/`, se teste sans
/// Flutter, sans Drift ni Supabase (elle ne recoit que des dates et un booleen).
/// La couche `data/` (lot C) construit les deux vues, appelle [decider], puis
/// execute la decision (push, ecriture locale, ou rien).
///
/// ## Politique retenue (decision Ousseynou, 29/08/2026 — « local en attente gagne »)
///   1. **Local en attente** (ecrit hors-ligne, pas encore pousse) : il l'emporte
///      — c'est l'intention la plus recente de l'eleve sur CET appareil — SAUF si
///      le serveur porte une version STRICTEMENT plus recente (seul vrai conflit :
///      le meme chapitre modifie depuis un autre appareil). Dans ce cas, `dateMaj`
///      departage et le plus recent (serveur) l'emporte.
///   2. **Local deja synchronise** : simple relecture serveur -> local ; le plus
///      recent l'emporte (le serveur ne gagne que s'il est strictement plus recent).
///   3. **Pas de ligne locale** : on adopte la valeur du serveur si elle existe.
///
/// En cas d'EGALITE de `dateMaj`, le local est conserve (on ne re-ecrit rien
/// inutilement, et une ecriture locale en attente part quand meme au serveur).
/// `dateMaj` est l'heure de l'appareil : arbitre volontairement simple pour la V1
/// quasi mono-appareil ; le risque d'une horloge mal reglee est un residuel assume
/// (documente au Journal), non un cas courant.
abstract final class ReconciliationProgression {
  static DecisionReconciliation decider({
    required VueLocaleProgression? local,
    required DateTime? serveurDateMaj,
  }) {
    final serveurExiste = serveurDateMaj != null;

    // Aucune ligne locale : on prend le serveur s'il a quelque chose, sinon rien.
    if (local == null) {
      return serveurExiste
          ? DecisionReconciliation.adopterServeur
          : DecisionReconciliation.rienAFaire;
    }

    // « Strictement » plus recent (isAfter) : a egalite, le serveur ne prend pas
    // la main — le local est conserve / pousse.
    final serveurPlusRecent =
        serveurExiste && serveurDateMaj.isAfter(local.dateMaj);

    if (local.enAttente) {
      // Le local en attente gagne, sauf conflit ou le serveur est plus recent.
      return serveurPlusRecent
          ? DecisionReconciliation.adopterServeur
          : DecisionReconciliation.pousserVersServeur;
    }

    // Local deja synchronise : le pull ne remplace que si le serveur est plus recent.
    return serveurPlusRecent
        ? DecisionReconciliation.adopterServeur
        : DecisionReconciliation.rienAFaire;
  }
}

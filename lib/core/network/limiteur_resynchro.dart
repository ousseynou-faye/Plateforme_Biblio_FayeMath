/// Garde ANTI-RAFALE des resynchronisations offline-first (etape 21, Point 6).
///
/// Avec les flux reactifs (Drift `.watch()`, Lot B), chaque (re)abonnement d'un
/// ecran relance une resynchro en arriere-plan. Un ecran rouvert plusieurs fois
/// en quelques secondes multiplierait donc les appels Supabase — or la donnee
/// mobile chere est une contrainte fondatrice du projet (CLAUDE.md §3).
///
/// Ce limiteur repond « doit-on resynchroniser cette cle maintenant ? » : oui si
/// elle ne l'a pas ete depuis plus de [_intervalle], non sinon. Volontairement
/// SIMPLE (docs/CONVENTIONS.md, esprit V1) : une table en memoire, rien de
/// persiste — l'etat repart de zero a chaque lancement de l'app, ce qui est le
/// comportement voulu (un nouveau lancement doit pouvoir resynchroniser).
///
/// L'horloge est injectable pour le test ; par defaut c'est l'heure systeme.
class LimiteurResynchro {
  LimiteurResynchro({Duration? intervalle, DateTime Function()? horloge})
    : _intervalle = intervalle ?? const Duration(seconds: 60),
      _horloge = horloge ?? DateTime.now;

  final Duration _intervalle;
  final DateTime Function() _horloge;
  final Map<String, DateTime> _dernierePar = {};

  /// Vrai si [cle] n'a pas ete resynchronisee depuis plus de [_intervalle]. Quand
  /// elle autorise, elle ENREGISTRE l'instant courant (effet de bord assume : le
  /// prochain appel dans la fenetre sera refuse). Une cle jamais vue est toujours
  /// autorisee (premier abonnement).
  bool doitResynchroniser(String cle) {
    final maintenant = _horloge();
    final precedent = _dernierePar[cle];
    if (precedent != null && maintenant.difference(precedent) < _intervalle) {
      return false;
    }
    _dernierePar[cle] = maintenant;
    return true;
  }
}

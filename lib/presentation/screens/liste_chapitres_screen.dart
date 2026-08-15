import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/usecases/programme_scolaire.dart';
import 'package:fayemath_academy/domain/usecases/regroupement_par_strate.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/chapitre_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// Liste des chapitres d'une (classe, matiere), regroupes par strate (maquette
/// V2.1, ecran 5). Premier ecran de contenu reel (etape 15).
///
/// Perimetre volontairement reduit a cette etape (valide avec Ousseynou) : on
/// AFFICHE le numero + le titre, groupes par strate, avec « N chapitres ». On
/// OMET, faute de brique existante et sans consommateur defini : le compteur
/// « X termines » et la pastille de statut (pas de `ProgressionRepository`),
/// l'indicateur « sur l'appareil / indisponible hors-ligne » (Phase 3), les
/// boutons Filtrer / Recherche (ecran 19). Les lignes sont de vrais boutons
/// accessibles qui ouvrent l'ecran de detail du chapitre (ecran 6, etape 16).
///
/// Tant qu'aucun chapitre reel n'existe en base (le contenu arrive a l'etape 18),
/// l'ecran affiche son ETAT VIDE — comportement attendu, pas une erreur.
class ListeChapitresScreen extends ConsumerWidget {
  const ListeChapitresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolution = _resoudreCible(ref);
    final titre = switch (resolution) {
      _CibleResolue(:final cible) => '${cible.matiere.nom} · ${cible.classe.nom}',
      _ => 'Chapitres',
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(titre),
        actions: [
          // Bouton de deconnexion PROVISOIRE : l'emplacement definitif est
          // l'onglet « Profil » de la barre du bas (maquette V2.1, non encore
          // construit). Present ici pour ne pas perdre l'acquis teste a l'etape 13
          // (la galerie qui le portait a ete retiree a l'etape 15) et permettre le
          // test « se deconnecter / se reconnecter » de la Definition of Done.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se deconnecter',
            onPressed: () => _quitter(ref),
          ),
        ],
      ),
      body: SafeArea(
        child: switch (resolution) {
          _CibleEnChargement() => const Center(child: CircularProgressIndicator()),
          _CibleErreur() => _EtatErreur(onReessayer: () => _rechargerCatalogue(ref)),
          _CibleResolue(:final cible) => _CorpsChapitres(cible: cible),
        },
      ),
    );
  }

  void _rechargerCatalogue(WidgetRef ref) {
    ref.invalidate(classesProvider);
    ref.invalidate(matieresProvider);
  }

  /// Deconnexion provisoire (voir le commentaire du bouton). Un invite revient
  /// simplement a l'ecran d'authentification ; un compte connecte est deconnecte
  /// cote serveur, puis le flux de session ramene lui aussi a cet ecran. Un echec
  /// de deconnexion serveur n'a rien a afficher ici : la sortie locale suit.
  Future<void> _quitter(WidgetRef ref) async {
    final etat = ref.read(etatAuthProvider);
    if (etat is AuthInvite) {
      ref.read(etatAuthProvider.notifier).quitterModeInvite();
      return;
    }
    try {
      await ref.read(authRepositoryProvider).seDeconnecter();
    } on EchecAuthentification {
      // La deconnexion locale suit de toute facon ; rien a afficher ici.
    }
  }

  /// Determine la (classe, matiere) a afficher.
  ///
  /// La classe vient de l'eleve : profil serveur s'il est connecte, choix local
  /// s'il est invite. La MATIERE, elle, n'est stockee nulle part (Constat A,
  /// etape 14 : `utilisateur` n'a pas de colonne matiere).
  ///
  /// SIMPLIFICATION ASSUMEE (option 1, decision Ousseynou 13/08/2026) : on ne
  /// demande rien et on prend la 1re matiere AU PROGRAMME
  /// (`ProgrammeScolaire`, toujours Mathematiques vu l'ordre du programme), MEME
  /// chemin pour le connecte et l'invite. Tant que seule la 6e Maths a du contenu
  /// (`BibliothequesPretes`), « deriver la matiere » et « honorer le choix
  /// invite » sont indistinguables a l'observation : le double chemin ne se
  /// justifierait par rien de verifiable. A REVOIR des qu'une 2e bibliotheque
  /// (ex. Physique-chimie) aura du contenu reel — il faudra alors persister la
  /// matiere choisie ou offrir un selecteur (meme esprit que le « a l'etape 18 »
  /// de bibliotheques_pretes.dart).
  _Resolution _resoudreCible(WidgetRef ref) {
    final matieresAsync = ref.watch(matieresProvider);
    final matieres = matieresAsync.value;
    if (matieres == null) {
      return matieresAsync.hasError
          ? const _CibleErreur()
          : const _CibleEnChargement();
    }

    Classe? classe;
    Serie? serie;
    switch (ref.watch(etatAuthProvider)) {
      case AuthInvite():
        final choix = ref.watch(choixClasseProvider);
        classe = choix.classe;
        serie = choix.serie;
      case AuthConnecte():
        final profil = ref.watch(profilProvider);
        if (profil is! ProfilResolu) return const _CibleEnChargement();
        final classeId = profil.profil?.classeId;
        if (classeId == null) return const _CibleEnChargement();
        serie = profil.profil?.serie;
        final classesAsync = ref.watch(classesProvider);
        final classes = classesAsync.value;
        if (classes == null) {
          return classesAsync.hasError
              ? const _CibleErreur()
              : const _CibleEnChargement();
        }
        final trouvees = classes.where((c) => c.id == classeId);
        classe = trouvees.isEmpty ? null : trouvees.first;
      case AuthDeconnecte():
        // La redirection empeche d'atterrir ici deconnecte ; on ne devine pas :
        // etat neutre le temps que l'auth se stabilise.
        return const _CibleEnChargement();
    }

    if (classe == null) return const _CibleEnChargement();

    final autorisees = ProgrammeScolaire.matieresAutorisees(
      classe: classe,
      serie: serie,
      catalogue: matieres,
    );
    if (autorisees.isEmpty) return const _CibleEnChargement();

    return _CibleResolue(_Cible(classe: classe, matiere: autorisees.first));
  }
}

/// Le couple resolu a afficher, plus sa cle de cache pour `chapitresProvider`.
class _Cible {
  const _Cible({required this.classe, required this.matiere});

  final Classe classe;
  final Matiere matiere;

  CibleChapitres get cle => (classeId: classe.id, matiereId: matiere.id);
}

/// Resultat de la resolution (classe, matiere) : chargement, erreur, ou pret.
sealed class _Resolution {
  const _Resolution();
}

class _CibleEnChargement extends _Resolution {
  const _CibleEnChargement();
}

class _CibleErreur extends _Resolution {
  const _CibleErreur();
}

class _CibleResolue extends _Resolution {
  const _CibleResolue(this.cible);

  final _Cible cible;
}

/// Le corps une fois la (classe, matiere) connue : lit les chapitres offline-first
/// et gere les trois etats de l'`AsyncValue` (chargement / donnees / erreur).
class _CorpsChapitres extends ConsumerWidget {
  const _CorpsChapitres({required this.cible});

  final _Cible cible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapitresAsync = ref.watch(chapitresProvider(cible.cle));
    final chapitres = chapitresAsync.value;

    if (chapitres == null) {
      if (chapitresAsync.hasError) {
        return _EtatErreur(
          onReessayer: () => ref.invalidate(chapitresProvider(cible.cle)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (chapitres.isEmpty) {
      return _EtatVide(matiere: cible.matiere);
    }
    return _ListeGroupee(chapitres: chapitres);
  }
}

/// La liste chargee : « N chapitres » puis un en-tete par strate suivi de ses
/// lignes. Le regroupement est la regle pure [RegroupementParStrate].
class _ListeGroupee extends StatelessWidget {
  const _ListeGroupee({required this.chapitres});

  final List<Chapitre> chapitres;

  @override
  Widget build(BuildContext context) {
    final groupes = RegroupementParStrate.de(chapitres);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _SousEntete(nombre: chapitres.length),
        for (final groupe in groupes) ...[
          if (groupe.strate != null) _EnteteStrate(groupe.strate!),
          for (final chapitre in groupe.chapitres)
            _LigneChapitre(chapitre: chapitre),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Rappel du nombre de chapitres (« 1 chapitre » / « N chapitres »). Le compteur
/// « X termines » de la maquette est omis a cette etape (pas de progression).
class _SousEntete extends StatelessWidget {
  const _SousEntete({required this.nombre});

  final int nombre;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final libelle = nombre == 1 ? '1 chapitre' : '$nombre chapitres';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Text(
        libelle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// En-tete de strate (« Activites numeriques »...). Le libelle vient de la donnee
/// (`chapitre.strate`), jamais d'une liste codee en dur (point ouvert 4).
class _EnteteStrate extends StatelessWidget {
  const _EnteteStrate(this.strate);

  final String strate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        strate.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Une ligne de chapitre : numero + titre, vrai bouton accessible (>= 48 px de
/// haut, Semantics). Le tap ouvre l'ecran de detail (ecran 6) via une navigation
/// imperative (premiere de l'app — voir [_ouvrir]).
class _LigneChapitre extends StatelessWidget {
  const _LigneChapitre({required this.chapitre});

  final Chapitre chapitre;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      label: 'Chapitre ${chapitre.numero}, ${chapitre.titre}',
      excludeSemantics: true,
      child: Material(
        color: colorScheme.surface,
        child: InkWell(
          onTap: () => _ouvrir(context),
          splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${chapitre.numero}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chapitre.titre,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _ouvrir(BuildContext context) {
    // Premiere navigation imperative de l'app : on EMPILE l'ecran de detail
    // (ecran 6) pour que la fleche « retour » ramene a la liste. On passe l'objet
    // Chapitre en `extra` (deja charge) et son id en parametre de route
    // (URL /chapitre/<id>). Le nom de route « chapitre » est defini dans
    // routing/app_router.dart (nomRouteChapitre) ; `presentation/` ne peut pas
    // importer `routing/` (regle de dependance, ARCHITECTURE §3), d'ou le litteral.
    context.pushNamed(
      'chapitre',
      pathParameters: {'chapitreId': chapitre.id},
      extra: chapitre,
    );
  }
}

/// Etat vide : aucune bibliotheque pour cette (classe, matiere). Aucun des 20
/// ecrans ne couvre exactement ce cas ; on reprend la STRUCTURE du composant
/// `emptyState` de l'ecran 11 (cercle + titre + texte, sans action) avec un texte
/// adapte. Distinct du « contenu indisponible » dynamique de la Phase 3.
class _EtatVide extends StatelessWidget {
  const _EtatVide({required this.matiere});

  final Matiere matiere;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 32,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Bientot disponible',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'La bibliotheque de ${matiere.nom} n\'est pas encore disponible '
              'pour ta classe. Reviens bientot !',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Etat d'erreur (catalogue ou chapitres injoignables ET cache vide) : message
/// clair + bouton pour reessayer. Calque sur l'etat d'erreur de l'ecran de choix.
class _EtatErreur extends StatelessWidget {
  const _EtatErreur({required this.onReessayer});

  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les chapitres.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Verifie ta connexion, puis reessaie.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            BoutonPrimaireWidget(
              libelle: 'Reessayer',
              onPressed: onReessayer,
              pleineLargeur: false,
            ),
          ],
        ),
      ),
    );
  }
}

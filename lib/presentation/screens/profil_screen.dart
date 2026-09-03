import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fayemath_academy/core/errors/echecs_authentification.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/bibliotheque_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/modification_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';

/// Onglet « Profil » de la barre du bas (maquette V2.1, ecran 10 « Profil et
/// abonnement »), lot Qualite C. Remplace le placeholder de l'etape 20.
///
/// FIDELE a la maquette, adapte aux realites du modele de donnees :
///  - PAS de prenom ni de ville : le champ nom a ete retire a l'etape 13 et la
///    ville n'est jamais collectee. L'avatar porte une icone generique et la carte
///    d'identite affiche la CLASSE (+ serie) et la matiere, seules infos reelles.
///  - Chip « Compte gratuit » STATIQUE : le paiement est la Phase 4 (pas encore
///    branche). En V1 tout compte est gratuit.
///  - « Se deconnecter » vit desormais ICI (deplace depuis la barre du haut de la
///    liste des chapitres, ou il etait provisoire depuis l'etape 15).
///
/// PLACEHOLDERS (ecrans non construits) : « Classe, serie et matieres » (branche a
/// l'ecran de choix au lot C2), « Parametres et notifications », « Aide et
/// contact » et « Decouvrir Premium » (comparatif = ecran 17, Phase 4) annoncent
/// « bientot disponible » plutot que d'ouvrir un ecran vide ou faux.
class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estInvite = ref.watch(etatAuthProvider) is AuthInvite;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _CarteIdentite(),
            const SizedBox(height: 14),
            const _TitreSection('Mon compte'),
            _SectionCompte(
              lignes: [
                _Reglage(
                  icone: Icons.school_outlined,
                  libelle: 'Classe, serie et matieres',
                  onTap: () => _ouvrirModificationClasse(context, ref),
                ),
                _Reglage(
                  icone: Icons.settings_outlined,
                  libelle: 'Parametres et notifications',
                  onTap: () => _bientot(context, 'Les parametres'),
                ),
                _Reglage(
                  icone: Icons.help_outline,
                  libelle: 'Aide et contact',
                  onTap: () => _bientot(context, "L'aide et le contact"),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const _TitreSection('Aller plus loin'),
            _CartePremium(
              onTap: () => _bientot(context, "L'offre Premium"),
            ),
            const SizedBox(height: 14),
            _CarteDeconnexion(
              estInvite: estInvite,
              onDeconnecter: () => _deconnecter(ref),
            ),
            const SizedBox(height: 14),
            Text(
              'FayeMath Academy · version de demonstration',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Deconnexion, deplacee depuis `liste_chapitres_screen` (etape 13, DoD
  /// « se deconnecter / se reconnecter »). Un invite quitte simplement le mode
  /// invite (pas de session serveur) ; un compte connecte est deconnecte cote
  /// serveur, puis le flux de session ramene a l'ecran d'authentification. Un
  /// echec de deconnexion serveur n'a rien a afficher : la sortie locale suit.
  Future<void> _deconnecter(WidgetRef ref) async {
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
}

/// Ouvre l'ecran de choix classe / serie / matiere (ecran 3) pour MODIFIER.
///
/// On leve d'abord le drapeau [modificationClasseProvider] : sans lui, la
/// redirection go_router renverrait aussitot un eleve ayant deja une classe vers
/// l'accueil. Chemin ecrit en litteral car `presentation/` n'importe pas
/// `routing/` (docs/ARCHITECTURE.md §3), comme le tap « Ma progression » du
/// tableau de bord. L'ecran de choix baisse le drapeau une fois le choix
/// enregistre (ou a sa fermeture), et la redirection ejecte alors vers l'accueil.
void _ouvrirModificationClasse(BuildContext context, WidgetRef ref) {
  ref.read(modificationClasseProvider.notifier).demarrer();
  context.go('/choix-classe');
}

/// Message d'attente partage par les lignes encore sans ecran dedie : on annonce
/// clairement qu'une fonctionnalite arrive plutot que d'ouvrir un ecran vide.
void _bientot(BuildContext context, String quoi) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text('$quoi : bientot disponible.')),
    );
}

/// Carte d'en-tete : avatar generique + identite reelle (classe/serie/matiere) +
/// chip d'abonnement + crayon « Modifier ». Adapte a l'absence de prenom/ville.
class _CarteIdentite extends ConsumerWidget {
  const _CarteIdentite();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final etatAuth = ref.watch(etatAuthProvider);
    final estInvite = etatAuth is AuthInvite;
    final bib = ref.watch(bibliothequeCouranteProvider).value;

    // La serie n'est pas portee par [BibliothequeCourante] : on la lit a sa source
    // (profil serveur si connecte, choix local si invite), comme le fait deja
    // `bibliothequeCouranteProvider` pour la classe.
    Serie? serie;
    if (estInvite) {
      serie = ref.watch(choixClasseProvider).serie;
    } else {
      final profil = ref.watch(profilProvider);
      if (profil is ProfilResolu) serie = profil.profil?.serie;
    }

    final classeSerie = bib == null
        ? ''
        : '${bib.classe.nom}${serie == null ? '' : ' ${serie.valeurSql}'}';
    final matiere = bib?.matiere.nom ?? '';

    final (titre, sousLigne) = estInvite
        ? ('Mode invite', [classeSerie, matiere].where((s) => s.isNotEmpty).join(' · '))
        : (classeSerie.isEmpty ? 'Mon compte' : classeSerie, matiere);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.primary,
            ),
            child: Icon(
              estInvite ? Icons.person_outline : Icons.person,
              color: scheme.onPrimary,
              size: 26,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (sousLigne.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sousLigne,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _Pastille(
                  texte: estInvite ? 'Sans compte' : 'Compte gratuit',
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: scheme.onSurfaceVariant,
            tooltip: 'Modifier mes informations',
            onPressed: () => _ouvrirModificationClasse(context, ref),
          ),
        ],
      ),
    );
  }
}

/// Petite pastille d'etat (abonnement). Texte muet sur fond neutre — jamais
/// porteuse d'information par la seule couleur (elle est libellee).
class _Pastille extends StatelessWidget {
  const _Pastille({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
      child: Text(
        texte,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// La carte « Mon compte » : une liste de lignes de reglage separees par un filet.
class _SectionCompte extends StatelessWidget {
  const _SectionCompte({required this.lignes});

  final List<_Reglage> lignes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var i = 0; i < lignes.length; i++) ...[
            lignes[i],
            if (i < lignes.length - 1)
              Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

/// Une ligne de reglage : icone + libelle + chevron. Vrai bouton accessible
/// (>= 52 px, comme la maquette).
class _Reglage extends StatelessWidget {
  const _Reglage({
    required this.icone,
    required this.libelle,
    required this.onTap,
  });

  final IconData icone;
  final String libelle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      child: Semantics(
        button: true,
        label: libelle,
        excludeSemantics: true,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Row(
            children: [
              Icon(icone, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 11),
              Expanded(
                child: Text(libelle, style: theme.textTheme.bodyMedium),
              ),
              Icon(Icons.chevron_right, size: 18, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grande carte indigo « Decouvrir Premium ». Mene (Phase 4) au comparatif
/// Gratuit/Premium (ecran 17, non construit) : placeholder pour l'instant.
///
/// Ecart assume a la maquette : degrade indigo rendu en aplat (seul l'indigo
/// principal est un token de theme ; l'indigo clair du degrade n'est pas expose)
/// et couronne en blanc (le dore #F0C05A de la maquette n'a aucun role dans la
/// palette auditee — couleurs.dart interdit d'en ajouter).
class _CartePremium extends StatelessWidget {
  const _CartePremium({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: 'Decouvrir Premium. Voir ce que ca change.',
      excludeSemantics: true,
      child: Material(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.workspace_premium, size: 18, color: scheme.onPrimary),
                    const SizedBox(width: 7),
                    Text(
                      'Decouvrir Premium',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tous les corriges detailles et la bibliotheque complete, '
                  'de la 6e a la Terminale.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Voir ce que ca change',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.chevron_right, size: 15, color: scheme.onPrimary),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La carte « Se deconnecter » (rouge). Pour un invite, le libelle devient
/// « Quitter le mode invite » : il n'a pas de compte a proprement deconnecter.
class _CarteDeconnexion extends StatelessWidget {
  const _CarteDeconnexion({
    required this.estInvite,
    required this.onDeconnecter,
  });

  final bool estInvite;
  final VoidCallback onDeconnecter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final libelle = estInvite ? 'Quitter le mode invite' : 'Se deconnecter';
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onDeconnecter,
        child: Semantics(
          button: true,
          label: libelle,
          excludeSemantics: true,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: scheme.error),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    libelle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

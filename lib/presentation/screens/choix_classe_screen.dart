import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/constants/bibliotheques_pretes.dart';
import 'package:fayemath_academy/core/errors/echec_enregistrement.dart';
import 'package:fayemath_academy/domain/entities/classe.dart';
import 'package:fayemath_academy/domain/entities/cycle.dart';
import 'package:fayemath_academy/domain/entities/matiere.dart';
import 'package:fayemath_academy/domain/entities/serie.dart';
import 'package:fayemath_academy/domain/usecases/programme_scolaire.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/choix_classe_provider.dart';
import 'package:fayemath_academy/presentation/providers/profil_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// Ecran de choix classe / serie / matiere (maquette V2.1, ecran 3).
///
/// Ordre de collecte impose (SPECIFICATIONS_V2 §3.3) : classe -> serie (si lycee
/// 1ere/Tle) -> matieres autorisees -> validation. Les matieres proposees sont
/// la REGLE DE PROGRAMME pure ([ProgrammeScolaire]) ; « bientot disponible » est
/// un badge statique de lancement ([BibliothequesPretes]) qui ne bloque rien.
///
/// Ecart assume a la maquette (valide avec Ousseynou) : aucune classe n'est
/// pre-selectionnee (la maquette pre-cochait « 6e ») — pour ne pas enregistrer
/// par megarde une classe que l'eleve n'a pas choisie ; « Valider » reste donc
/// desactive tant qu'aucune classe n'est prise.
class ChoixClasseScreen extends ConsumerStatefulWidget {
  const ChoixClasseScreen({super.key});

  @override
  ConsumerState<ChoixClasseScreen> createState() => _ChoixClasseScreenState();
}

class _ChoixClasseScreenState extends ConsumerState<ChoixClasseScreen> {
  bool _enregistrementEnCours = false;

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(classesProvider);
    final matieresAsync = ref.watch(matieresProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ta classe')),
      body: SafeArea(child: _corps(classesAsync, matieresAsync)),
    );
  }

  Widget _corps(
    AsyncValue<List<Classe>> classesAsync,
    AsyncValue<List<Matiere>> matieresAsync,
  ) {
    final classes = classesAsync.value;
    final matieres = matieresAsync.value;

    if (classes == null || matieres == null) {
      if (classesAsync.hasError || matieresAsync.hasError) {
        return _EtatErreur(onReessayer: _rechargerCatalogue);
      }
      return const Center(child: CircularProgressIndicator());
    }
    if (classes.isEmpty) {
      return _EtatErreur(onReessayer: _rechargerCatalogue);
    }
    return _Formulaire(
      classes: classes,
      matieres: matieres,
      enregistrementEnCours: _enregistrementEnCours,
      onValider: _valider,
    );
  }

  void _rechargerCatalogue() {
    ref.invalidate(classesProvider);
    ref.invalidate(matieresProvider);
  }

  Future<void> _valider(Classe classe, Serie? serie) async {
    final etatAuth = ref.read(etatAuthProvider);

    if (etatAuth is! AuthConnecte) {
      // Invite : rien a persister (Decision A). On confirme localement ; la
      // redirection (lot F) mene alors a l'accueil.
      ref.read(choixClasseProvider.notifier).confirmer();
      return;
    }

    // Connecte : on persiste (UPDATE de son profil). En cas de succes, l'etat du
    // profil change et la redirection quitte cet ecran toute seule.
    setState(() => _enregistrementEnCours = true);
    try {
      await ref
          .read(profilProvider.notifier)
          .enregistrerChoix(classeId: classe.id, serie: serie);
    } on EchecEnregistrement catch (echec) {
      if (mounted) _afficherEchec(echec);
    } finally {
      if (mounted) setState(() => _enregistrementEnCours = false);
    }
  }

  void _afficherEchec(EchecEnregistrement echec) {
    final message = echec.reseau
        ? 'Pas de connexion : reconnecte-toi pour enregistrer ton choix.'
        : 'Impossible d\'enregistrer ton choix. Reessaie.';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Le corps complet une fois le catalogue charge : sections classe / serie /
/// matieres + bouton Valider. Consomme la selection en cours et compose les
/// gestes (auto-selection de la 1ere matiere autorisee au choix classe/serie).
class _Formulaire extends ConsumerWidget {
  const _Formulaire({
    required this.classes,
    required this.matieres,
    required this.enregistrementEnCours,
    required this.onValider,
  });

  final List<Classe> classes;
  final List<Matiere> matieres;
  final bool enregistrementEnCours;
  final void Function(Classe classe, Serie? serie) onValider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final choix = ref.watch(choixClasseProvider);
    final notifier = ref.read(choixClasseProvider.notifier);
    final classe = choix.classe;

    void choisirClasse(Classe c) {
      final autorisees = ProgrammeScolaire.matieresAutorisees(
        classe: c,
        serie: null,
        catalogue: matieres,
      );
      notifier.choisirClasse(c, matieresParDefaut: _premiere(autorisees));
    }

    void choisirSerie(Serie s) {
      final autorisees = ProgrammeScolaire.matieresAutorisees(
        classe: classe!,
        serie: s,
        catalogue: matieres,
      );
      notifier.choisirSerie(s, matieresParDefaut: _premiere(autorisees));
    }

    final serieRequise =
        classe != null && ProgrammeScolaire.serieRequise(classe);
    final besoinSerie = serieRequise && choix.serie == null;
    final pret =
        classe != null &&
        !besoinSerie &&
        choix.matieresSelectionnees.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _SectionClasses(
          classes: classes,
          selection: classe,
          onChoisir: choisirClasse,
        ),
        if (serieRequise) ...[
          const SizedBox(height: 20),
          _SectionSerie(selection: choix.serie, onChoisir: choisirSerie),
        ],
        if (classe != null) ...[
          const SizedBox(height: 20),
          if (besoinSerie)
            const _CalloutSerie()
          else
            _SectionMatieres(
              classe: classe,
              serie: choix.serie,
              autorisees: ProgrammeScolaire.matieresAutorisees(
                classe: classe,
                serie: choix.serie,
                catalogue: matieres,
              ),
              selection: choix.matieresSelectionnees,
              onBasculer: notifier.basculerMatiere,
            ),
        ],
        const SizedBox(height: 24),
        _BoutonValider(
          enCours: enregistrementEnCours,
          onPressed: pret && !enregistrementEnCours
              ? () => onValider(classe, choix.serie)
              : null,
        ),
      ],
    );
  }

  Set<String> _premiere(List<Matiere> autorisees) =>
      autorisees.isEmpty ? const {} : {autorisees.first.id};
}

/// La grille des classes, groupees par cycle (College / Lycee), comme la maquette.
class _SectionClasses extends StatelessWidget {
  const _SectionClasses({
    required this.classes,
    required this.selection,
    required this.onChoisir,
  });

  final List<Classe> classes;
  final Classe? selection;
  final void Function(Classe) onChoisir;

  @override
  Widget build(BuildContext context) {
    final college = classes.where((c) => c.cycle == Cycle.college).toList();
    final lycee = classes.where((c) => c.cycle == Cycle.lycee).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SousTitre('College'),
        _GrilleClasses(
          classes: college,
          selection: selection,
          onChoisir: onChoisir,
        ),
        const SizedBox(height: 12),
        _SousTitre('Lycee'),
        _GrilleClasses(
          classes: lycee,
          selection: selection,
          onChoisir: onChoisir,
        ),
      ],
    );
  }
}

class _GrilleClasses extends StatelessWidget {
  const _GrilleClasses({
    required this.classes,
    required this.selection,
    required this.onChoisir,
  });

  final List<Classe> classes;
  final Classe? selection;
  final void Function(Classe) onChoisir;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final classe in classes)
          _BoutonChoix(
            libelle: classe.nom,
            selectionne: classe == selection,
            onTap: () => onChoisir(classe),
          ),
      ],
    );
  }
}

/// La section serie (uniquement 1ere / Terminale), demandee AVANT les matieres.
class _SectionSerie extends StatelessWidget {
  const _SectionSerie({required this.selection, required this.onChoisir});

  final Serie? selection;
  final void Function(Serie) onChoisir;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitreSection('Ta serie'),
        _Aide('Elle determine les matieres auxquelles tu as acces.'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final serie in Serie.values)
              _BoutonChoix(
                libelle: 'Serie ${serie.valeurSql}',
                selectionne: serie == selection,
                onTap: () => onChoisir(serie),
              ),
          ],
        ),
      ],
    );
  }
}

/// La section matieres : titre adaptatif, tuiles selectionnables avec badge
/// « bientot disponible » (non bloquant) et note serie L le cas echeant.
class _SectionMatieres extends StatelessWidget {
  const _SectionMatieres({
    required this.classe,
    required this.serie,
    required this.autorisees,
    required this.selection,
    required this.onBasculer,
  });

  final Classe classe;
  final Serie? serie;
  final List<Matiere> autorisees;
  final Set<String> selection;
  final void Function(String matiereId) onBasculer;

  @override
  Widget build(BuildContext context) {
    final seule = autorisees.length == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TitreSection(seule ? 'Ta matiere' : 'Tes matieres'),
        _Aide(
          seule
              ? 'Une seule matiere est disponible pour cette classe.'
              : 'Tu peux en choisir une ou les deux.',
        ),
        const SizedBox(height: 10),
        for (final matiere in autorisees)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _TuileMatiere(
              matiere: matiere,
              classeNom: classe.nom,
              selectionnee: selection.contains(matiere.id),
              // Une seule matiere : deja auto-selectionnee, non basculable
              // (maquette : `if (a.length === 1) return;`).
              onTap: seule ? null : () => onBasculer(matiere.id),
            ),
          ),
        if (serie == Serie.serieL)
          _Aide(
            'En serie L, la physique-chimie n\'est pas proposee : elle est '
            'reservee aux series S1 et S2.',
          ),
      ],
    );
  }
}

/// Petit bouton selectionnable (classe ou serie). Vrai bouton : cible >= 48 px,
/// etat selectionne porte par la couleur ET une coche (jamais la couleur seule),
/// annonce au lecteur d'ecran via Semantics (icone exclue, redondante).
class _BoutonChoix extends StatelessWidget {
  const _BoutonChoix({
    required this.libelle,
    required this.selectionne,
    required this.onTap,
  });

  final String libelle;
  final bool selectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    final couleurFond = selectionne ? colorScheme.primary : colorScheme.surface;
    final couleurAvant = selectionne
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final couleurBordure = selectionne
        ? colorScheme.primary
        : colorScheme.outline;

    return Semantics(
      button: true,
      selected: selectionne,
      label: libelle,
      excludeSemantics: true,
      child: Material(
        color: couleurFond,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: couleurBordure,
                width: selectionne ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectionne) ...[
                  Icon(Icons.check, size: 16, color: couleurAvant),
                  const SizedBox(width: 6),
                ],
                Text(
                  libelle,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: couleurAvant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tuile de matiere : icone + libelle, etat selectionne (coche), et badge
/// « bientot disponible » quand la bibliotheque n'est pas encore produite.
class _TuileMatiere extends StatelessWidget {
  const _TuileMatiere({
    required this.matiere,
    required this.classeNom,
    required this.selectionnee,
    required this.onTap,
  });

  final Matiere matiere;
  final String classeNom;
  final bool selectionnee;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    final prete = BibliothequesPretes.estPrete(
      classeNom: classeNom,
      matiereNom: matiere.nom,
    );
    final couleurFond = selectionnee
        ? colorScheme.primary
        : colorScheme.surface;
    final couleurAvant = selectionnee
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final couleurBordure = selectionnee
        ? colorScheme.primary
        : colorScheme.outline;

    return Semantics(
      button: onTap != null,
      selected: selectionnee,
      label: prete ? matiere.nom : '${matiere.nom}, bientot disponible',
      excludeSemantics: true,
      child: Material(
        color: couleurFond,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: couleurBordure,
                width: selectionnee ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(_icone(matiere.nom), color: couleurAvant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        matiere.nom,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: couleurAvant),
                      ),
                      if (!prete) _BadgeBientot(surSelection: selectionnee),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selectionnee
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: selectionnee ? couleurAvant : colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _icone(String matiereNom) => switch (matiereNom) {
    ProgrammeScolaire.nomMathematiques => Icons.calculate_outlined,
    ProgrammeScolaire.nomPhysiqueChimie => Icons.science_outlined,
    _ => Icons.menu_book_outlined,
  };
}

/// Le petit badge « bientot disponible ». Purement informatif, ne bloque pas la
/// selection. Sa couleur s'adapte au fond de la tuile (selectionnee ou non).
class _BadgeBientot extends StatelessWidget {
  const _BadgeBientot({required this.surSelection});

  final bool surSelection;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final couleur = surSelection
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: couleur),
          const SizedBox(width: 4),
          Text(
            'Bientot disponible',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: couleur),
          ),
        ],
      ),
    );
  }
}

/// L'encadre affiche quand la serie est requise mais pas encore choisie.
class _CalloutSerie extends StatelessWidget {
  const _CalloutSerie();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choisis d\'abord ta serie',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Les matieres disponibles dependent de la serie : en serie L, '
                  'la physique-chimie n\'est pas au programme.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BoutonValider extends StatelessWidget {
  const _BoutonValider({required this.enCours, required this.onPressed});

  final bool enCours;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BoutonPrimaireWidget(
      libelle: enCours ? 'Enregistrement...' : 'Valider',
      icone: Icons.arrow_forward,
      onPressed: onPressed,
    );
  }
}

/// Titre de section (« Ta serie », « Tes matieres »).
class _TitreSection extends StatelessWidget {
  const _TitreSection(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Text(texte, style: Theme.of(context).textTheme.titleMedium);
  }
}

/// Sous-titre de groupe (« College », « Lycee »).
class _SousTitre extends StatelessWidget {
  const _SousTitre(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texte,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Texte d'aide secondaire.
class _Aide extends StatelessWidget {
  const _Aide(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        texte,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Etat d'erreur / catalogue vide : message clair + bouton pour reessayer.
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
            Icon(
              Icons.cloud_off,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de charger les classes.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Verifie ta connexion, puis reessaie.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
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

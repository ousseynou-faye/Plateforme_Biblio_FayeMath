import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fayemath_academy/core/theme/couleurs_marque.dart';
import 'package:fayemath_academy/presentation/providers/onboarding_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// L'ecran d'accueil au premier lancement (maquette V2.1, ecran 1 « Onboarding »).
///
/// Hors des 38 etapes officielles : lot « Qualite et experience eleve ». Trois
/// diapositives sur fond indigo, avec « Passer » (vrai bouton 48 px) et un CTA
/// « Suivant » / « Commencer ». Ni « Passer » ni « Commencer » ne navigue en dur :
/// tous deux appellent [EtatOnboardingNotifier.marquerVu] — la redirection
/// go_router fait le reste (AuthDeconnecte + OnboardingVu -> ecran de connexion),
/// exactement comme « Continuer sans compte » cote authentification. `presentation/`
/// n'importe donc jamais `routing/` (docs/ARCHITECTURE.md §3).
///
/// Libelles retranscrits SANS accents (docs/CONVENTIONS.md §1), comme partout dans
/// l'app, la maquette servant de reference de contenu et de disposition.
///
/// Correctifs d'audit (bloc `fix:` de la maquette, persona Sam SPEC §8.3) : CTA et
/// « Passer » a 48 px, ocre fonctionnel du theme (jamais l'ocre decoratif sous du
/// texte), pulsation limitee a 3 cycles ET supprimee si le systeme demande de
/// reduire les animations (`MediaQuery.disableAnimations`).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controleurPages = PageController();
  int _page = 0;

  static const _nombreDiapos = 3;

  @override
  void dispose() {
    _controleurPages.dispose();
    super.dispose();
  }

  void _allerA(int page, {required bool animer}) {
    if (animer) {
      _controleurPages.animateToPage(
        page,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _controleurPages.jumpToPage(page);
    }
  }

  /// Fin de l'onboarding (« Passer » ou « Commencer ») : on note qu'il est vu ;
  /// la redirection quitte alors cet ecran vers l'authentification.
  void _terminer() => ref.read(etatOnboardingProvider.notifier).marquerVu();

  void _suivant({required bool reduireAnimations}) {
    if (_page < _nombreDiapos - 1) {
      _allerA(_page + 1, animer: !reduireAnimations);
    } else {
      _terminer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Persona Sam (SPEC §8.3) : si le systeme demande de reduire les animations,
    // on coupe la pulsation ET les transitions de page.
    final reduireAnimations = MediaQuery.of(context).disableAnimations;
    final estDerniere = _page == _nombreDiapos - 1;

    return Scaffold(
      // Fond indigo de marque = `primary` ; le texte pose dessus est `onPrimary`
      // (blanc), jamais une couleur en dur (docs/CONVENTIONS.md §4).
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            _BarreHaut(
              // « Passer » visible tant qu'on n'est pas sur la derniere diapo
              // (ou le CTA « Commencer » joue deja ce role) — fidele a la maquette.
              afficherPasser: !estDerniere,
              onPasser: _terminer,
            ),
            Expanded(
              child: PageView(
                controller: _controleurPages,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _DiapoMarque(),
                  _DiapoHorsLigne(),
                  _DiapoHumaine(),
                ],
              ),
            ),
            _IndicateurPages(page: _page, total: _nombreDiapos),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              child: _BoutonBas(
                estDerniere: estDerniere,
                pulser: estDerniere && !reduireAnimations,
                onPresse: () => _suivant(reduireAnimations: reduireAnimations),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre du haut : logo textue + nom de marque a gauche, « Passer » a droite.
class _BarreHaut extends StatelessWidget {
  const _BarreHaut({required this.afficherPasser, required this.onPasser});

  final bool afficherPasser;
  final VoidCallback onPasser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surIndigo = colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 0),
      child: Row(
        children: [
          Icon(Icons.menu_book_outlined, size: 18, color: surIndigo),
          const SizedBox(width: 6),
          Text(
            'FayeMath Academy',
            style: textTheme.bodySmall?.copyWith(
              color: surIndigo.withValues(alpha: 0.85),
            ),
          ),
          const Spacer(),
          // Un VRAI bouton de 48 px (correctif d'audit), pas un simple texte.
          if (afficherPasser)
            TextButton(
              onPressed: onPasser,
              style: TextButton.styleFrom(
                foregroundColor: surIndigo,
                minimumSize: const Size(48, 48),
              ),
              child: const Text('Passer'),
            )
          else
            // Reserve la meme hauteur pour que les diapos ne « sautent » pas
            // quand « Passer » disparait sur la derniere.
            const SizedBox(height: 48),
        ],
      ),
    );
  }
}

/// Squelette commun d'une diapositive : cercle d'icone, titre, corps, et un
/// bloc « extra » optionnel (badges de marque, carte d'apercu). Centre, texte
/// blanc, jamais de couleur en dur.
class _CorpsDiapo extends StatelessWidget {
  const _CorpsDiapo({
    required this.icone,
    required this.titre,
    required this.corps,
    this.tag,
    this.extra,
  });

  final IconData icone;
  final String titre;
  final String corps;
  final String? tag;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surIndigo = colorScheme.onPrimary;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Halo ocre translucide autour de l'icone (surface non textuelle) :
              // on part de l'ocre decoratif du theme, jamais d'un hex.
              color: Theme.of(
                context,
              ).extension<CouleursMarque>()!.ocreDecoratif.withValues(alpha: 0.22),
            ),
            child: Icon(icone, size: 44, color: surIndigo),
          ),
          const SizedBox(height: 18),
          Text(
            titre,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(color: surIndigo),
          ),
          if (tag != null) ...[
            const SizedBox(height: 12),
            _Etiquette(texte: tag!),
          ],
          const SizedBox(height: 14),
          Text(
            corps,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: surIndigo.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          if (extra != null) ...[const SizedBox(height: 18), extra!],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Etiquette pilule (« La reussite se construit a domicile »).
class _Etiquette extends StatelessWidget {
  const _Etiquette({required this.texte});

  final String texte;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surIndigo = colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: surIndigo.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        textAlign: TextAlign.center,
        style: textTheme.labelMedium?.copyWith(color: surIndigo),
      ),
    );
  }
}

/// Diapo 1 — marque : tag, titre, accroche, et trois badges de perimetre.
class _DiapoMarque extends StatelessWidget {
  const _DiapoMarque();

  @override
  Widget build(BuildContext context) {
    return const _CorpsDiapo(
      icone: Icons.menu_book_outlined,
      tag: 'La reussite se construit a domicile',
      titre: 'FayeMath Academy',
      corps:
          'Les maths et la physique-chimie du college au lycee, dans ta poche.',
      extra: _BadgesMarque(),
    );
  }
}

/// Les trois badges de la premiere diapo (perimetre en un coup d'oeil).
class _BadgesMarque extends StatelessWidget {
  const _BadgesMarque();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _Badge(icone: Icons.school_outlined, texte: '6e a Terminale')),
        SizedBox(width: 8),
        Expanded(child: _Badge(icone: Icons.menu_book_outlined, texte: '2 matieres')),
        SizedBox(width: 8),
        Expanded(
          child: _Badge(icone: Icons.wifi_off_outlined, texte: '100 % hors-ligne'),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icone, required this.texte});

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surIndigo = colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: surIndigo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icone, size: 18, color: surIndigo),
          const SizedBox(height: 5),
          Text(
            texte,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(color: surIndigo, height: 1.25),
          ),
        ],
      ),
    );
  }
}

/// Diapo 2 — hors-ligne.
class _DiapoHorsLigne extends StatelessWidget {
  const _DiapoHorsLigne();

  @override
  Widget build(BuildContext context) {
    return const _CorpsDiapo(
      icone: Icons.wifi_off_outlined,
      titre: 'Fonctionne sans connexion',
      corps:
          'Tu telecharges une fois, tu revises partout — meme sans reseau ni forfait.',
    );
  }
}

/// Diapo 3 — humaine : un apercu CONCRET (carte de progression) plutot qu'une
/// icone abstraite (correctif d'audit). Les chiffres sont ILLUSTRATIFS — l'eleve
/// n'a pas encore de compte ici ; ils montrent a quoi ressemble le suivi, ils ne
/// pretendent pas etre sa progression. Total 19 = les 19 chapitres reels de 6e
/// Maths (etape 18), pour rester credible.
class _DiapoHumaine extends StatelessWidget {
  const _DiapoHumaine();

  @override
  Widget build(BuildContext context) {
    return const _CorpsDiapo(
      icone: Icons.school_outlined,
      titre: 'Un vrai professeur derriere l\'application',
      corps:
          'Ta progression est suivie chapitre par chapitre, et ton tuteur '
          'FayeMath reste joignable.',
      extra: _CarteApercu(),
    );
  }
}

/// Carte d'apercu de la diapo 3 : une ligne de document « sur l'appareil » + une
/// barre de progression. Purement illustrative (voir [_DiapoHumaine]).
class _CarteApercu extends StatelessWidget {
  const _CarteApercu();

  static const _fait = 4;
  static const _total = 19;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final surIndigo = colorScheme.onPrimary;
    // Barre de progression = surface NON textuelle -> ocre decoratif du theme.
    final ocreDecoratif = Theme.of(
      context,
    ).extension<CouleursMarque>()!.ocreDecoratif;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surIndigo.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, size: 16, color: surIndigo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cours — Le cercle',
                  style: textTheme.bodySmall?.copyWith(color: surIndigo),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: surIndigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'sur l\'appareil',
                  style: textTheme.labelSmall?.copyWith(color: surIndigo),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _fait / _total,
              minHeight: 7,
              backgroundColor: surIndigo.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(ocreDecoratif),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_fait chapitres termines sur $_total',
            style: textTheme.labelSmall?.copyWith(
              color: surIndigo.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Points de progression + region live « Etape X sur 3 » (SPEC §6.2 : le lecteur
/// d'ecran annonce le changement de diapo, pas seulement la couleur des points).
class _IndicateurPages extends StatelessWidget {
  const _IndicateurPages({required this.page, required this.total});

  final int page;
  final int total;

  @override
  Widget build(BuildContext context) {
    final surIndigo = Theme.of(context).colorScheme.onPrimary;

    return Semantics(
      liveRegion: true,
      label: 'Etape ${page + 1} sur $total',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final actif = i == page;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: actif ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: surIndigo.withValues(alpha: actif ? 1 : 0.38),
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

/// Le CTA de bas d'ecran : « Suivant » sur les deux premieres diapos,
/// « Commencer » (avec fleche + pulsation limitee) sur la derniere.
class _BoutonBas extends StatelessWidget {
  const _BoutonBas({
    required this.estDerniere,
    required this.pulser,
    required this.onPresse,
  });

  final bool estDerniere;
  final bool pulser;
  final VoidCallback onPresse;

  @override
  Widget build(BuildContext context) {
    final bouton = BoutonPrimaireWidget(
      libelle: estDerniere ? 'Commencer' : 'Suivant',
      icone: estDerniere ? Icons.arrow_forward : null,
      onPressed: onPresse,
    );
    if (!pulser) return bouton;
    // Cle dediee : la pulsation est identifiee sans ambiguite en test (plusieurs
    // ScaleTransition existent dans l'arbre, dont celui de la transition de route).
    return _Pulsation(key: const ValueKey('cta-pulsant'), child: bouton);
  }
}

/// Enveloppe pulsante limitee a 3 cycles (correctif d'audit). Ne pulse JAMAIS si
/// [MediaQuery.disableAnimations] est vrai — le parent ne la construit alors pas.
class _Pulsation extends StatefulWidget {
  const _Pulsation({super.key, required this.child});

  final Widget child;

  @override
  State<_Pulsation> createState() => _PulsationState();
}

class _PulsationState extends State<_Pulsation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controleur;
  late final Animation<double> _echelle;

  static const _cycles = 3;
  static const _dureeCycle = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    // Un seul controleur qui joue 3 aller-retours 1.0 -> 1.04 -> 1.0 puis s'arrete.
    _controleur = AnimationController(
      vsync: this,
      duration: _dureeCycle * _cycles,
    );
    _echelle = TweenSequence<double>([
      for (var i = 0; i < _cycles; i++) ...[
        TweenSequenceItem(
          tween: Tween<double>(begin: 1, end: 1.04)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 1.04, end: 1)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1,
        ),
      ],
    ]).animate(_controleur);
    _controleur.forward();
  }

  @override
  void dispose() {
    _controleur.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _echelle, child: widget.child);
}

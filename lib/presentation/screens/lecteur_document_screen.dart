import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';

import 'package:fayemath_academy/core/errors/echec_telechargement.dart';
import 'package:fayemath_academy/core/format/taille_fichier.dart';
import 'package:fayemath_academy/core/telechargement/chemins_telechargement.dart';
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/etat_telechargement.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/usecases/droit_acces_document.dart';
import 'package:fayemath_academy/presentation/providers/abonnement_provider.dart';
import 'package:fayemath_academy/presentation/providers/auth_provider.dart';
import 'package:fayemath_academy/presentation/providers/catalogue_provider.dart';
import 'package:fayemath_academy/presentation/providers/telechargement_provider.dart';
import 'package:fayemath_academy/presentation/widgets/bandeau_reseau_widget.dart';
import 'package:fayemath_academy/presentation/widgets/bouton_primaire_widget.dart';

/// Lecteur de document (maquette V2.1, ecran 7). Depuis le detail d'un chapitre
/// (ecran 6), l'ouverture d'un document l'affiche ici : sous-bandeau (titre du
/// document dans la barre + titre du chapitre + « Chapitre N · Matiere Classe »),
/// corps defilant qui rend le PDF, et une barre basse qui indique la
/// DISPONIBILITE LOCALE du document (« sur l'appareil ») — jamais l'etat du
/// reseau (deux notions distinctes, docs/GLOSSAIRE.md §6).
///
/// Source du fichier (offline-first, docs/ARCHITECTURE.md §7) : on n'ouvre QUE ce
/// qui est deja sur l'appareil. Regle simple : un [Ressource.cheminStorage]
/// prefixe `assets/` designe un PDF EMBARQUE, lisible directement ; tout autre
/// cas — un chemin du bucket Storage non encore telecharge (cas du vrai contenu
/// mis en ligne a l'etape 18), ou `null` — signifie « pas encore sur l'appareil »
/// : le moteur de telechargement relevera de la Phase 3 (etape 19). Rien n'est
/// jamais telecharge ici.
///
/// `pdfx` (`PdfViewPinch`) n'est pas supporte sous Windows (il leve
/// `UnimplementedError`) : c'est sans effet sur la cible Android, mais cela
/// interdit de monter la zone PDF dans un test widget (qui tourne sur l'hote). Le
/// rendu reel se verifie donc sur appareil ; les tests couvrent le sous-bandeau et
/// l'etat « pas encore sur l'appareil » (documents sans PDF local).
class LecteurDocumentScreen extends ConsumerStatefulWidget {
  const LecteurDocumentScreen({
    super.key,
    required this.ressource,
    required this.chapitre,
  });

  final Ressource ressource;
  final Chapitre chapitre;

  @override
  ConsumerState<LecteurDocumentScreen> createState() =>
      _LecteurDocumentScreenState();
}

class _LecteurDocumentScreenState extends ConsumerState<LecteurDocumentScreen> {
  /// Le controleur du PDF, cree UNIQUEMENT si le document est lisible localement.
  /// Reste `null` quand le document n'est pas encore sur l'appareil : dans ce cas
  /// on n'ouvre aucun PDF et on affiche l'etat dedie.
  PdfControllerPinch? _controller;

  /// Nombre de pages, connu une fois le document charge (`onDocumentLoaded`).
  int? _total;

  /// Cle de la zone de rendu : sert a connaitre la taille du viewport au moment
  /// du zoom (pour zoomer autour de son centre, pas du coin).
  final GlobalKey _cleZone = GlobalKey();

  /// Niveaux de zoom cycles par le bouton « taille du texte ». Un PDF rendu est
  /// une image de page : le controle est une ECHELLE de page, pas un reflow de
  /// texte (SPEC §10.2). Le pincer-pour-zoomer natif reste disponible en plus ;
  /// le bouton en donne un equivalent discret et accessible (sans geste fin).
  static const _niveauxZoom = [1.0, 1.5, 2.0];
  int _iZoom = 0;

  /// Vrai si le PDF est EMBARQUE dans l'app (prefixe `assets/`) : lisible
  /// directement, sans passer par le telechargement. Sinon, c'est un document du
  /// bucket, ouvrable seulement une fois telecharge sur l'appareil (etape 19).
  late final bool _estAsset;

  @override
  void initState() {
    super.initState();
    final chemin = widget.ressource.cheminStorage;
    _estAsset = CheminsTelechargement.estAssetEmbarque(chemin);
    if (_estAsset) {
      _controller = PdfControllerPinch(
        document: PdfDocument.openAsset(chemin!),
      );
    } else {
      // Document du bucket : on VERIFIE seulement s'il est deja sur l'appareil
      // (lecture disque). Aucun telechargement n'est lance ici — il faut une
      // action explicite de l'eleve (contrat hors-ligne, regle 1).
      Future.microtask(
        () => ref
            .read(telechargementProvider.notifier)
            .verifierPresence(widget.ressource.id),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Passe au niveau de zoom suivant (puis reboucle), en zoomant autour du CENTRE
  /// du viewport pour ne pas perdre l'endroit lu. `PdfControllerPinch` est un
  /// `TransformationController` : on compose une transformation d'echelle sur sa
  /// matrice courante (translate au centre -> echelle -> translate inverse).
  void _cyclerZoom() {
    final controller = _controller;
    if (controller == null) return;
    final rendu = _cleZone.currentContext?.findRenderObject();
    if (rendu is! RenderBox) return;

    _iZoom = (_iZoom + 1) % _niveauxZoom.length;
    final actuel = controller.zoomRatio; // = matrice.row0[0]
    if (actuel <= 0) return;
    final facteur = _niveauxZoom[_iZoom] / actuel;

    // Zoom autour du centre : T(centre) . S(facteur) . T(-centre), puis applique
    // a la matrice courante. On compose via translationValues/diagonal3Values
    // (les helpers translate()/scale() de Matrix4 sont deprecies).
    final centre = rendu.size.center(Offset.zero);
    final transformation = Matrix4.translationValues(centre.dx, centre.dy, 0)
      ..multiply(Matrix4.diagonal3Values(facteur, facteur, 1))
      ..multiply(Matrix4.translationValues(-centre.dx, -centre.dy, 0));
    controller.value = transformation.multiplied(controller.value);
  }

  @override
  Widget build(BuildContext context) {
    final ressource = widget.ressource;

    // Sous-titre « Chapitre N · Matiere Classe » : les libelles Matiere/Classe
    // sont DERIVES du catalogue (meme source que l'ecran 5) via les id du
    // chapitre. Degradation propre en « Chapitre N » seul si le catalogue n'est
    // pas encore charge (jamais de « · null »).
    String? classeNom;
    final classes = ref.watch(classesProvider).value;
    if (classes != null) {
      for (final c in classes) {
        if (c.id == widget.chapitre.classeId) {
          classeNom = c.nom;
          break;
        }
      }
    }
    String? matiereNom;
    final matieres = ref.watch(matieresProvider).value;
    if (matieres != null) {
      for (final m in matieres) {
        if (m.id == widget.chapitre.matiereId) {
          matiereNom = m.nom;
          break;
        }
      }
    }

    // Etat du telechargement (un asset embarque est toujours « local »). On lit
    // aussi le DROIT d'acces (etape 25) : selon le profil (invite / premium sans
    // abonnement / ayant droit), la zone propose de creer un compte, de voir
    // l'offre, ou le telechargement — plutot qu'un bouton qui echouerait au reseau.
    final vue = _estAsset
        ? null
        : ref.watch(vueTelechargementProvider(ressource.id));
    final acces = ref.watch(accesDocumentProvider(ressource.premium));

    // Ouvre le PDF des que le fichier telecharge est disponible localement : le
    // controleur passe le relais de l'etat d'attente au rendu (une seule fois).
    if (!_estAsset &&
        _controller == null &&
        vue!.etat == EtatTelechargement.local &&
        vue.cheminLocal != null) {
      _controller = PdfControllerPinch(
        document: PdfDocument.openFile(vue.cheminLocal!),
      );
    }

    return Scaffold(
      // Barre du haut = le type du document (« Cours »...), + retour automatique.
      appBar: AppBar(title: Text(ressource.type.libelleAffichage)),
      body: SafeArea(
        child: Column(
          children: [
            // Bandeau reseau (SPEC §2.2) : l'ETAT DU RESEAU, a ne pas confondre
            // avec la disponibilite locale du document affichee plus bas.
            const BandeauReseauWidget(),
            _SousBandeau(
              titre: widget.chapitre.titre,
              sousTitre: LibellesLecteur.sousTitre(
                numero: widget.chapitre.numero,
                matiere: matiereNom,
                classe: classeNom,
              ),
              // Zoom et Partage n'ont de sens qu'avec un document ouvert : les
              // deux boutons sont desactives dans l'etat « pas sur l'appareil ».
              onZoom: _controller == null ? null : _cyclerZoom,
              partageActif: _controller != null,
            ),
            Expanded(child: _corps(vue, acces)),
          ],
        ),
      ),
    );
  }

  Widget _corps(VueTelechargement? vue, AccesDocument acces) {
    final controller = _controller;
    if (controller == null) {
      // Pas de PDF ouvert : on montre l'etat du telechargement (a proposer / en
      // cours / echec) OU, selon le droit, l'invitation a creer un compte ou a
      // voir l'offre Premium.
      return _ZoneTelechargement(
        vue: vue ?? const VueTelechargement(),
        tailleTexte: TailleFichier.enTexte(widget.ressource.tailleOctets),
        premium: widget.ressource.premium,
        acces: acces,
        onTelecharger: () => unawaited(
          ref
              .read(telechargementProvider.notifier)
              .demarrer(widget.ressource),
        ),
        onAnnuler: () => ref
            .read(telechargementProvider.notifier)
            .annuler(widget.ressource.id),
        onCreerCompte: () =>
            ref.read(etatAuthProvider.notifier).quitterModeInvite(),
        // « Voir l'offre » : ecran 17 minimal (etape 25, lot F). On EMPILE la
        // route racine `offre` (litteral : `presentation/` n'importe pas
        // `routing/`, ARCHITECTURE §3).
        onVoirOffre: () => context.pushNamed('offre'),
      );
    }
    // Le PDF remplit la zone ; la barre basse FLOTTE au-dessus (maquette).
    return Stack(
      children: [
        Positioned.fill(
          child: _ZonePdf(
            key: _cleZone,
            controller: controller,
            onTotal: (n) {
              if (mounted) setState(() => _total = n);
            },
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: _BarreBasse(controller: controller, total: _total),
        ),
      ],
    );
  }
}

/// Libelles PURS du lecteur (testables sans monter l'ecran).
abstract final class LibellesLecteur {
  /// « Chapitre 1 · Mathematiques 6e ». Si les libelles du catalogue manquent
  /// encore (chargement), « Chapitre 1 » seul — jamais « · null ». Le nom complet
  /// de la matiere (« Mathematiques ») est celui qu'affichent DEJA la maquette
  /// ecran 7 (`MATLABEL.maths`) et l'ecran 5 — aucun ecart.
  static String sousTitre({
    required int numero,
    String? matiere,
    String? classe,
  }) {
    if (matiere != null && classe != null) {
      return 'Chapitre $numero · $matiere $classe';
    }
    return 'Chapitre $numero';
  }

  /// « Page 3 sur 6 ». Tant que le total est inconnu (document en cours
  /// d'ouverture), « Page 3 ».
  static String pagination({required int page, int? total}) =>
      total == null ? 'Page $page' : 'Page $page sur $total';
}

/// Le bandeau sous la barre du haut : titre du chapitre + « Chapitre N · Matiere
/// Classe », et les deux outils a droite. Les outils sont DESCENDUS ici (et pas
/// dans la barre du haut) car dans 300 px de large ils ecraseraient le titre
/// (maquette, meme raison).
class _SousBandeau extends StatelessWidget {
  const _SousBandeau({
    required this.titre,
    required this.sousTitre,
    required this.onZoom,
    required this.partageActif,
  });

  final String titre;
  final String sousTitre;

  /// Action du bouton « taille du texte » ; `null` desactive le bouton (aucun PDF
  /// ouvert a agrandir).
  final VoidCallback? onZoom;

  /// Vrai si un document est ouvert : sinon le bouton Partager est desactive (on
  /// ne partage pas un document qui n'est pas encore sur l'appareil).
  final bool partageActif;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sousTitre,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // Reglage de la taille (« zoom ») : cycle les niveaux d'echelle.
          _OutilIcone(
            icon: Icons.format_size,
            tooltip: 'Modifier la taille du texte',
            onTap: onZoom,
          ),
          // Partager : placeholder assume (comme « Modifier » a l'etape 16) — un
          // vrai partage suppose un fichier local partageable, qui arrivera avec
          // le moteur de telechargement (Phase 3). Desactive tant qu'aucun
          // document n'est ouvert (rien a partager).
          _OutilIcone(
            icon: Icons.share_outlined,
            tooltip: 'Partager le document',
            onTap: partageActif
                ? () => _bientot(
                    context,
                    'Le partage arrivera avec le telechargement des documents.',
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Un bouton-outil accessible : cible tactile de 48 px (defaut `IconButton`) et
/// libelle via `tooltip` (lu par les lecteurs d'ecran).
class _OutilIcone extends StatelessWidget {
  const _OutilIcone({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;

  /// `null` => bouton desactive (cas du zoom sans document ouvert).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: 22,
      tooltip: tooltip,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      onPressed: onTap,
    );
  }
}

/// La zone de rendu du PDF (defilement vertical + pincer-pour-zoomer natifs de
/// `PdfViewPinch`). Le fond gris neutre entoure la page blanche (maquette).
class _ZonePdf extends StatelessWidget {
  const _ZonePdf({super.key, required this.controller, required this.onTotal});

  final PdfControllerPinch controller;
  final ValueChanged<int> onTotal;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      // Gris neutre de la maquette (ecran 7), derriere la page blanche.
      color: const Color(0xFFE4E7EE),
      child: PdfViewPinch(
        controller: controller,
        onDocumentLoaded: (doc) => onTotal(doc.pagesCount),
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error) => const _ErreurOuverture(),
        ),
      ),
    );
  }
}

/// Regles PURES de navigation entre pages (testables sans monter le PDF). Les
/// fleches ne s'activent qu'une fois le document charge (`total` connu) : avant,
/// la derniere page est inconnue et un saut hors limites ferait planter `pdfx`.
abstract final class NavigationPage {
  static bool precedentePossible({required int page, int? total}) =>
      total != null && page > 1;

  static bool suivantePossible({required int page, int? total}) =>
      total != null && page < total;
}

/// La barre basse flottante (maquette) : fleche precedente, indicateur « Page X
/// sur N · sur l'appareil », fleche suivante. « Page X sur N » suit le defilement
/// (`controller.pageListenable`) ET les sauts par les fleches.
class _BarreBasse extends StatelessWidget {
  const _BarreBasse({required this.controller, required this.total});

  final PdfControllerPinch controller;
  final int? total;

  /// Duree du saut de page, nulle si l'utilisateur a demande moins d'animations.
  Duration _duree(bool animationsReduites) =>
      animationsReduites ? Duration.zero : const Duration(milliseconds: 250);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animationsReduites = MediaQuery.of(context).disableAnimations;
    return ValueListenableBuilder<int>(
      valueListenable: controller.pageListenable,
      builder: (context, page, _) {
        final peutPrecedente = NavigationPage.precedentePossible(
          page: page,
          total: total,
        );
        final peutSuivante = NavigationPage.suivantePossible(
          page: page,
          total: total,
        );
        return DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x59000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                _FlechePage(
                  icone: Icons.chevron_left,
                  actif: peutPrecedente,
                  semantique: peutPrecedente
                      ? 'Page precedente'
                      : 'Page precedente (indisponible, tu es a la premiere page)',
                  onTap: peutPrecedente
                      ? () => controller.previousPage(
                          duration: _duree(animationsReduites),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
                Expanded(
                  child: _Indicateur(page: page, total: total),
                ),
                _FlechePage(
                  icone: Icons.chevron_right,
                  actif: peutSuivante,
                  semantique: peutSuivante
                      ? 'Page suivante'
                      : 'Page suivante (indisponible, tu es a la derniere page)',
                  onTap: peutSuivante
                      ? () => controller.nextPage(
                          duration: _duree(animationsReduites),
                          curve: Curves.easeInOut,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// « Page X sur N · sur l'appareil » : l'icone + le texte portent la DISPONIBILITE
/// LOCALE du document, jamais l'etat du reseau (GLOSSAIRE §6).
class _Indicateur extends StatelessWidget {
  const _Indicateur({required this.page, required this.total});

  final int page;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texte = LibellesLecteur.pagination(page: page, total: total);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.smartphone, size: 14, color: Color(0xFF8FE0B0)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '$texte · sur l\'appareil',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// Une fleche de la barre basse : cible tactile de 48 px, `Semantics` explicite.
/// L'etat DESACTIVE est porte par la COULEUR (gris `#6E7691`), jamais par la seule
/// opacite (maquette + SPEC §6.2). `onTap` null => non tappable.
class _FlechePage extends StatelessWidget {
  const _FlechePage({
    required this.icone,
    required this.actif,
    required this.semantique,
    required this.onTap,
  });

  final IconData icone;
  final bool actif;
  final String semantique;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduireMouvement = MediaQuery.of(context).disableAnimations;
    // Blanc si actif, gris solide si desactive (contraste, pas d'opacite).
    final couleur = actif ? Colors.white : const Color(0xFF6E7691);
    return Semantics(
      button: true,
      enabled: actif,
      label: semantique,
      excludeSemantics: true,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashFactory: reduireMouvement ? NoSplash.splashFactory : null,
            child: Center(child: Icon(icone, size: 20, color: couleur)),
          ),
        ),
      ),
    );
  }
}

/// Libelles PURS de la zone de telechargement (testables sans monter l'ecran).
abstract final class LibellesTelechargement {
  /// Le message d'echec montre a l'eleve, choisi par la [cause]. Sans accents
  /// (CONVENTIONS §1). [premium] affine le cas d'un refus serveur.
  static String messageEchec({
    required CauseTelechargement? cause,
    required bool premium,
  }) => switch (cause) {
    CauseTelechargement.reseau =>
      'Pas de connexion. Verifie ton reseau, puis reessaie.',
    CauseTelechargement.stockagePlein =>
      'Stockage plein. Libere de l\'espace, puis reessaie.',
    CauseTelechargement.nonAutorise =>
      premium
          ? 'Ce document fait partie de l\'offre Premium.'
          : 'Tu dois etre connecte pour telecharger ce document.',
    CauseTelechargement.introuvable =>
      'Document introuvable pour le moment. Reessaie plus tard.',
    CauseTelechargement.inattendu ||
    null => 'Le telechargement a echoue. Reessaie.',
  };
}

/// La zone affichee quand aucun PDF n'est ouvert : selon l'etat du telechargement
/// (a proposer / en cours / echec) et selon que l'eleve est connecte. Le fond gris
/// neutre est le meme que celui du rendu PDF (maquette ecran 7).
class _ZoneTelechargement extends StatelessWidget {
  const _ZoneTelechargement({
    required this.vue,
    required this.tailleTexte,
    required this.premium,
    required this.acces,
    required this.onTelecharger,
    required this.onAnnuler,
    required this.onCreerCompte,
    required this.onVoirOffre,
  });

  final VueTelechargement vue;
  final String tailleTexte;
  final bool premium;

  /// Le droit d'acces (etape 25), qui choisit l'invite du bas quand aucun PDF
  /// n'est ouvert : telecharger / creer un compte / voir l'offre.
  final AccesDocument acces;
  final VoidCallback onTelecharger;
  final VoidCallback onAnnuler;
  final VoidCallback onCreerCompte;
  final VoidCallback onVoirOffre;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFE4E7EE),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (vue.etat) {
            EtatTelechargement.enCours => _EnCours(
              progression: vue.progression,
              onAnnuler: onAnnuler,
            ),
            EtatTelechargement.echec => _Echec(
              cause: vue.cause,
              premium: premium,
              onReessayer: onTelecharger,
            ),
            // `local` n'arrive jamais ici (le PDF s'affiche alors) ; sinon on
            // branche selon le DROIT d'acces (etape 25) : ayant droit -> proposer
            // le telechargement ; premium sans abonnement -> voir l'offre ;
            // invite -> creer un compte (aucun octet consomme pour dire « non »).
            _ => switch (acces) {
              AccesDocument.autorise => _AProposer(
                tailleTexte: tailleTexte,
                onTelecharger: onTelecharger,
                bloqueDonneesMobiles: vue.bloqueDonneesMobiles,
              ),
              AccesDocument.abonnementRequis => _VerrouPremium(
                onVoirOffre: onVoirOffre,
              ),
              AccesDocument.compteRequis => _InviteCompte(
                onCreerCompte: onCreerCompte,
              ),
            },
          },
        ),
      ),
    );
  }
}

/// La pastille ronde d'entete, reprise de la maquette (ecran 7).
class _Pastille extends StatelessWidget {
  const _Pastille({required this.icone});

  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: Icon(icone, size: 32, color: colorScheme.onPrimaryContainer),
    );
  }
}

/// Document telechargeable (eleve connecte) : titre de DISPONIBILITE + bouton qui
/// annonce la taille (regle 2 du contrat hors-ligne : on sait ce que ca coute).
class _AProposer extends StatelessWidget {
  const _AProposer({
    required this.tailleTexte,
    required this.onTelecharger,
    this.bloqueDonneesMobiles = false,
  });

  final String tailleTexte;
  final VoidCallback onTelecharger;

  /// Le dernier appui a ete bloque par le reglage « Wi-Fi uniquement » en donnees
  /// mobiles (lot « Qualite D ») : on l'explique sous le bouton, qui reste
  /// disponible (l'eleve peut passer en Wi-Fi puis reessayer).
  final bool bloqueDonneesMobiles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Pastille(icone: Icons.cloud_download_outlined),
        const SizedBox(height: 14),
        Text(
          'Document pas encore sur l\'appareil',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Telecharge-le pour le lire hors connexion, meme sans reseau.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        BoutonPrimaireWidget(
          libelle: 'Telecharger ($tailleTexte)',
          onPressed: onTelecharger,
          pleineLargeur: false,
        ),
        if (bloqueDonneesMobiles) ...[
          const SizedBox(height: 14),
          _NoteWifiSeulement(),
        ],
      ],
    );
  }
}

/// Message affiche quand un telechargement est bloque par le reglage « Wi-Fi
/// uniquement » en donnees mobiles. Statut porte par le texte ET l'icone (jamais
/// la seule couleur, SPEC §6.2) ; couleurs = palette auditee (fond/texte d'info).
class _NoteWifiSeulement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wifi_off_outlined, size: 20, color: scheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Reglage « Wi-Fi uniquement » actif. Active le Wi-Fi pour '
              'telecharger, ou change ce reglage dans ton Profil.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Invite (« continuer sans compte ») : aucun telechargement possible (policy
/// Storage), on propose de creer un compte. Meme titre que [_AProposer].
class _InviteCompte extends StatelessWidget {
  const _InviteCompte({required this.onCreerCompte});

  final VoidCallback onCreerCompte;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Pastille(icone: Icons.cloud_download_outlined),
        const SizedBox(height: 14),
        Text(
          'Document pas encore sur l\'appareil',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Cree un compte pour telecharger et lire ce document hors connexion.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        BoutonPrimaireWidget(
          libelle: 'Creer un compte',
          onPressed: onCreerCompte,
          pleineLargeur: false,
        ),
      ],
    );
  }
}

/// Document premium, eleve connecte SANS abonnement actif : on ne propose PAS le
/// telechargement (aucun octet consomme), on mene a l'offre. Un document premium
/// DEJA sur l'appareil reste lisible (decision 5.6) et n'atteint pas cette zone
/// (son PDF s'ouvre directement).
class _VerrouPremium extends StatelessWidget {
  const _VerrouPremium({required this.onVoirOffre});

  final VoidCallback onVoirOffre;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Pastille(icone: Icons.lock_outline),
        const SizedBox(height: 14),
        Text(
          'Document Premium',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Ce document fait partie de l\'offre Premium. Passe a Premium pour le '
          'telecharger et le lire hors connexion.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        BoutonPrimaireWidget(
          libelle: 'Voir l\'offre',
          onPressed: onVoirOffre,
          pleineLargeur: false,
        ),
      ],
    );
  }
}

/// Telechargement en cours : barre de progression + pourcentage + Annuler.
class _EnCours extends StatelessWidget {
  const _EnCours({required this.progression, required this.onAnnuler});

  final double progression;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pourcent = (progression.clamp(0.0, 1.0) * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Telechargement en cours',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progression.clamp(0.0, 1.0),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$pourcent %',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: onAnnuler,
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

/// Echec du telechargement : message choisi par la cause + Reessayer.
class _Echec extends StatelessWidget {
  const _Echec({
    required this.cause,
    required this.premium,
    required this.onReessayer,
  });

  final CauseTelechargement? cause;
  final bool premium;
  final VoidCallback onReessayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Pastille(icone: Icons.error_outline),
        const SizedBox(height: 14),
        Text(
          'Le telechargement a echoue',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          LibellesTelechargement.messageEchec(cause: cause, premium: premium),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        BoutonPrimaireWidget(
          libelle: 'Reessayer',
          onPressed: onReessayer,
          pleineLargeur: false,
        ),
      ],
    );
  }
}

/// Le PDF existe localement mais ne s'ouvre pas (fichier illisible). Rare — mais
/// on le dit clairement plutot que d'afficher l'erreur brute de `pdfx`.
class _ErreurOuverture extends StatelessWidget {
  const _ErreurOuverture();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible d\'ouvrir ce document.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder homogene (comme a l'etape 16) : une action pas encore construite
/// le dit clairement plutot que de ne rien faire.
void _bientot(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

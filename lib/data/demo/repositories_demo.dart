import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/domain/entities/ressource.dart';
import 'package:fayemath_academy/domain/entities/type_ressource.dart';
import 'package:fayemath_academy/domain/repositories/chapitre_repository.dart';
import 'package:fayemath_academy/domain/repositories/ressource_repository.dart';

/// DEMO TEMPORAIRE (etape 17, Lot A) — A RETIRER a l'etape 18 (contenu reel) et,
/// au plus tard, avant le test ferme Play Store (etape 33).
///
/// La base est vide jusqu'a l'etape 18 : rien a ouvrir dans le lecteur PDF
/// (ecran 7). Pour PROUVER le lecteur sur appareil, ce fichier fournit un
/// chapitre et ses documents EN MEMOIRE, injectes a la racine (`main.dart`)
/// UNIQUEMENT quand `Env.modeDemo` est vrai (cle `MODE_DEMO` de `config/dev.json`,
/// gitignore, donc jamais commitee ni embarquee en production).
///
/// Pourquoi en memoire, et pas un seed dans Drift : les repositories
/// offline-first (`ChapitreRepositoryOfflineFirst` / `RessourceRepositoryOfflineFirst`)
/// PURGENT le cache local avec ce que Supabase renvoie pour le perimetre lu. Un
/// seed ecrit dans Drift serait donc efface a la resynchro suivante (Supabase est
/// vide). Court-circuiter la synchro avec des repos en memoire est la seule facon
/// de garder la demo stable — sans aucune ecriture dans la vraie base.

/// UUID reels du catalogue (migration 07) : la demo se rattache a la 6e /
/// Mathematiques, pour apparaitre dans la liste d'un eleve de 6e (seule
/// bibliotheque « prete », `BibliothequesPretes`).
const _classe6e = 'c1a55e00-0000-0000-0000-000000000006';
const _matiereMaths = 'ba71e2e0-0000-0000-0000-000000000001';
const _chapitreDemoId = 'deac0000-0000-0000-0000-000000000001';

/// Chemin de l'ASSET embarque (bloc `assets:` temporaire de `pubspec.yaml`). En
/// mode demo, le lecteur (Lot B) interprete un `cheminStorage` prefixe `assets/`
/// comme un PDF embarque a ouvrir ; un document sans PDF (`cheminStorage` null)
/// affiche l'etat « document indisponible » (Lot E). C'est un DETOURNEMENT assume
/// et temporaire du champ (normalement un chemin du bucket Storage), limite a la
/// demo.
const _pdfCoursDemo =
    'assets/bibliotheque/6e-maths/01 - Activités Numériques/'
    'Chap 01 - Nombres décimaux arithmétiques/01 - Cours/'
    'Cours - Chap 01 - Nombres décimaux arithmétiques.pdf';

/// Le chapitre de demonstration (donnee de CONTENU : titre reel avec accents,
/// comme le seront les vrais chapitres de l'etape 18).
const chapitreDemo = Chapitre(
  id: _chapitreDemoId,
  classeId: _classe6e,
  matiereId: _matiereMaths,
  numero: 1,
  titre: 'Nombres décimaux arithmétiques',
  strate: 'Activités numériques',
  ordre: 1,
);

/// Les documents du chapitre de demo. Le Cours porte le PDF embarque (il s'ouvre
/// dans le lecteur) ; les autres n'ont pas de PDF (`cheminStorage` null) et
/// prouvent l'etat « document indisponible ». Un corrige premium demontre en plus
/// le badge Premium (regle gratuit/premium, CLAUDE.md §4 : cours/resume/exercices
/// gratuits sur le chapitre 1, corrige toujours premium).
const _ressourcesDemo = <Ressource>[
  Ressource(
    id: 'deac0000-0000-0000-0000-0000000000c1',
    chapitreId: _chapitreDemoId,
    classeId: null,
    matiereId: null,
    type: TypeRessource.cours,
    titre: 'Cours - Nombres décimaux arithmétiques',
    tailleOctets: 59631,
    premium: false,
    version: 1,
    cheminStorage: _pdfCoursDemo,
    ordre: 1,
  ),
  Ressource(
    id: 'deac0000-0000-0000-0000-0000000000c2',
    chapitreId: _chapitreDemoId,
    classeId: null,
    matiereId: null,
    type: TypeRessource.resume,
    titre: 'Fiche methode - Nombres décimaux arithmétiques',
    tailleOctets: 24518,
    premium: false,
    version: 1,
    cheminStorage: null,
    ordre: 2,
  ),
  Ressource(
    id: 'deac0000-0000-0000-0000-0000000000c3',
    chapitreId: _chapitreDemoId,
    classeId: null,
    matiereId: null,
    type: TypeRessource.exercices,
    titre: 'Exercices - Nombres décimaux arithmétiques',
    tailleOctets: 41230,
    premium: false,
    version: 1,
    cheminStorage: null,
    ordre: 3,
  ),
  Ressource(
    id: 'deac0000-0000-0000-0000-0000000000c4',
    chapitreId: _chapitreDemoId,
    classeId: null,
    matiereId: null,
    type: TypeRessource.corrige,
    titre: 'Corrige - Nombres décimaux arithmétiques',
    tailleOctets: 68042,
    premium: true,
    version: 1,
    cheminStorage: null,
    ordre: 4,
  ),
];

/// Repository de chapitres EN MEMOIRE (mode demo). Ne sert que la (classe,
/// matiere) de la demo ; renvoie une liste vide ailleurs, comme le vrai
/// repository pour une bibliotheque sans contenu.
class ChapitreRepositoryDemo implements ChapitreRepository {
  const ChapitreRepositoryDemo();

  @override
  Future<List<Chapitre>> chapitresDe({
    required String classeId,
    required String matiereId,
  }) async {
    if (classeId == chapitreDemo.classeId &&
        matiereId == chapitreDemo.matiereId) {
      return const [chapitreDemo];
    }
    return const [];
  }
}

/// Repository de ressources EN MEMOIRE (mode demo). Ne sert que les documents du
/// chapitre de demo ; liste vide pour tout autre chapitre.
class RessourceRepositoryDemo implements RessourceRepository {
  const RessourceRepositoryDemo();

  @override
  Future<List<Ressource>> ressourcesDuChapitre({
    required String chapitreId,
  }) async {
    if (chapitreId == chapitreDemo.id) return _ressourcesDemo;
    return const [];
  }
}

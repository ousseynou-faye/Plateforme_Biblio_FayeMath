# ARCHITECTURE.md — Comment le code est rangé

**Projet :** FayeMath Academy — application mobile
**Créé le :** 1er août 2026
**Source de vérité amont :** `01 - Documents de Référence\03 - Technique et Pilotage.pdf`, §1.2 (les quatre étages) et §2.2 (les huit tables)
**Statut :** contrat d'architecture. On l'exécute, on ne l'improvise pas.

Ce document répond à une seule question, mais il y répond complètement : **« je crée un nouveau fichier — où est-ce que je le mets, et qu'est-ce qu'il a le droit d'importer ? »**

---

## 1. Pourquoi des couches (en une minute)

Le code est rangé en quatre étages, chacun avec **un seul rôle**. Chaque étage ignore comment les autres fonctionnent en interne ; il sait seulement quoi leur demander.

L'intérêt n'est pas théorique. Il est écrit noir sur blanc dans le document 3 du cadrage :

> Le jour où il faudra changer de serveur, ou remplacer la base de données locale, **seul l'étage « Données » sera touché**. Les écrans et les règles du métier ne bougeront pas.

C'est très concret pour ce projet : Supabase est le choix d'aujourd'hui, l'application vivra des années. Si les couches sont respectées, un changement de backend coûte quelques jours. Si elles ne le sont pas, il coûte une réécriture.

---

## 2. Les quatre couches, en clair

| Couche | Son rôle | Exemple concret dans CE projet | Ce qui n'y va **jamais** |
|---|---|---|---|
| `presentation/` | Ce que l'élève voit et touche | L'écran « Liste des chapitres » | Une requête SQL, une URL Supabase, un calcul de règle métier |
| `domain/` | Les règles du métier, indépendantes de tout | « Un chapitre est *fait* quand la révision est validée » | `import 'package:flutter/...'`, Drift, Supabase, dio — **rien de technique** |
| `data/` | Aller chercher et enregistrer l'information | Lire la table Drift locale, appeler Supabase | Un `Widget`, une couleur, un libellé d'écran |
| `core/` | Les outils communs, transverses | La palette de la marque, la gestion d'erreur, la détection réseau | Quoi que ce soit de spécifique à un écran ou à un chapitre |

Plus un cinquième dossier, technique et à part : `routing/` — la navigation `go_router`, qui relie les écrans entre eux.

---

## 3. La règle de dépendance — LA règle à ne jamais casser

```
        ┌──────────────────┐
        │  presentation/   │  écrans, widgets, providers Riverpod
        └────────┬─────────┘
                 │ importe
                 ▼
        ┌──────────────────┐
        │     domain/      │  entités + contrats (interfaces)
        └────────▲─────────┘
                 │ implémente
        ┌────────┴─────────┐
        │      data/       │  Drift, Supabase, dio
        └──────────────────┘

        core/  ← utilisable par les trois, n'importe aucune des trois
        routing/ ← importe presentation/ uniquement
```

**Les 4 interdits, formulés pour être vérifiables :**

1. `domain/` **n'importe rien** du projet, sauf d'autres fichiers de `domain/`. Aucun `import 'package:flutter/material.dart'`. Aucun `drift`, aucun `supabase_flutter`, aucun `dio`. C'est du Dart pur.
2. `presentation/` **n'importe jamais** `data/`. Il passe par les interfaces déclarées dans `domain/`.
3. `data/` **n'importe jamais** `presentation/`.
4. `core/` **n'importe** aucune des trois autres couches. Il est en dessous de tout le monde.

> **Comment on vérifie.** Le test est mécanique, pas subjectif : ouvre n'importe quel fichier de `domain/`, regarde ses `import`. S'il y a autre chose que `dart:` ou un autre fichier de `domain/`, la règle est cassée.

**Le point qui surprend au début — l'inversion de dépendance.** L'interface `ChapitreRepository` (le *contrat* : « je sais te donner la liste des chapitres ») vit dans `domain/`, alors que son *implémentation* (« je vais les chercher dans Drift puis dans Supabase ») vit dans `data/`. C'est volontaire : le métier déclare ce dont il a besoin, la technique s'y plie. L'inverse rendrait le métier prisonnier de Supabase.

---

## 4. L'arborescence cible de `lib/` — étape 8

C'est la structure à créer. Les dossiers qui ne contiennent pas encore de code reçoivent un fichier `.gitkeep` vide, sinon Git ne les enregistre pas.

```
lib/
├── main.dart                  point d'entrée : runApp() et rien d'autre
├── app.dart                   le widget racine MaterialApp + thème + router
│
├── core/
│   ├── theme/                 couleurs de la marque, typographie, thème Material
│   ├── constants/             valeurs fixes (N=2 chapitres gratuits, clés de config)
│   ├── errors/                types d'échec (Panne réseau, Non autorisé, Introuvable)
│   ├── network/               détection connecté / non connecté
│   └── utils/                 helpers vraiment génériques (formats de taille, dates)
│
├── domain/
│   ├── entities/              Classe, Matiere, Chapitre, Ressource, Progression,
│   │                          Telechargement, Abonnement, Utilisateur
│   ├── repositories/          les CONTRATS (classes abstraites), pas le code réel
│   └── usecases/              règles métier nommées (ex. calculer la progression)
│
├── data/
│   ├── local/                 Drift : base locale, tables, requêtes
│   ├── remote/                Supabase + dio : appels serveur
│   ├── models/                traduction JSON/SQL ↔ entités du domaine
│   └── repositories/          les IMPLÉMENTATIONS des contrats du domaine
│
├── presentation/
│   ├── screens/               un dossier par écran (20 écrans à terme)
│   ├── widgets/               composants réutilisables (carte chapitre, badge premium)
│   └── providers/             les providers Riverpod
│
└── routing/
    └── app_router.dart        la configuration go_router
```

**Une précision sur `usecases/`.** En V1 la logique métier reste simple ; certains projets s'en passent. On garde le dossier parce que la règle « un chapitre est fait quand la révision est validée » est exactement ce genre de calcul, et qu'elle ne doit vivre ni dans un écran ni dans un repository.

---

## 5. Où ranger un nouveau fichier — arbre de décision

Pose-toi les questions **dans cet ordre**, et arrête-toi à la première qui répond oui :

1. **Est-ce que ça s'affiche à l'écran ?** → `presentation/`
   (un `Widget`, un écran, un provider qui alimente un écran)
2. **Est-ce que ça parle à SQLite, à Supabase, à Internet ou au disque ?** → `data/`
3. **Est-ce une règle du métier, vraie même si l'application était un site web ?** → `domain/`
   (« un chapitre est fait quand… », « ce document est premium si… »)
4. **Est-ce utile partout et spécifique à nulle part ?** → `core/`
5. **Est-ce une route de navigation ?** → `routing/`

**Si deux réponses semblent possibles, c'est que le fichier fait deux choses — il faut le couper en deux.** C'est le signal le plus fiable d'un mauvais découpage.

---

## 6. Les 8 tables du serveur → les entités du domaine

Le modèle de données est fixé par le cadrage (`03 - Technique et Pilotage.pdf`, §2.2). Chaque table donne une entité dans `domain/entities/`. **Ne pas en inventer une neuvième sans passer par Ousseynou.**

| Table (Supabase) | Entité (`domain/entities/`) | Ce qu'elle porte |
|---|---|---|
| Utilisateur | `Utilisateur` | Identifiant de l'élève, sa classe, son statut d'abonnement |
| Classe | `Classe` | De la 6e à la Terminale, avec son cycle et sa série éventuelle |
| Matière | `Matiere` | Mathématiques, physique-chimie |
| Chapitre | `Chapitre` | Le chapitre officiel, son numéro et son ordre |
| Ressource | `Ressource` | Un document : type, titre, taille, gratuit ou premium, version |
| Progression | `Progression` | L'état d'un chapitre pour un élève donné, et sa date |
| Téléchargement | `Telechargement` | Ce qu'un élève a enregistré sur son téléphone |
| Abonnement | `Abonnement` | Formule, dates de début et de fin, référence de paiement |

Les 8 valeurs du champ `Ressource.type` et la règle gratuit/premium sont figées dans `CLAUDE.md` §4. Le vocabulaire exact est dans [`GLOSSAIRE.md`](GLOSSAIRE.md).

---

## 7. Le pattern offline-first — à appliquer partout, sans exception

C'est le cœur technique du produit, et le cadrage est catégorique (`03 - Technique et Pilotage.pdf`, §1.4) :

> L'application ne demande jamais au serveur ce qu'elle peut trouver sur le téléphone.

Traduit en code, tout repository de `data/repositories/` suit **la même séquence**, toujours :

```
1. Lire la base locale (Drift) et renvoyer le résultat IMMÉDIATEMENT
2. En arrière-plan, demander au serveur s'il existe plus récent
3. Si oui : mettre à jour la base locale, l'écran se rafraîchit tout seul
4. Si le réseau est absent : on s'arrête à l'étape 1, sans erreur affichée
```

**L'élève ne voit jamais une roue qui tourne en attendant le réseau.** Un écran qui affiche un `CircularProgressIndicator` en attendant Supabase est un écran à corriger, pas un écran normal.

Corollaire, écrit dans le contrat hors-ligne (`02 - Contenu et Experience.pdf`, §4.5) : **l'état du réseau et la disponibilité d'un document sont deux choses différentes.** Le réseau s'affiche une seule fois, dans le bandeau du haut. La disponibilité s'affiche sur chaque ligne de document. Ne jamais confondre les deux dans le code — ce sont deux notions distinctes, pas deux affichages de la même variable.

---

## 8. Les erreurs d'architecture les plus courantes

À relire avant chaque revue de code. Ce sont celles qui coûtent cher plus tard.

| Erreur | Pourquoi c'est grave | Ce qu'il faut faire |
|---|---|---|
| Un appel Supabase directement dans un écran | L'écran devient impossible à tester et à réutiliser ; le hors-ligne est court-circuité | Passer par un provider → un repository |
| Une règle métier dans un `Widget` | Elle sera dupliquée dans le prochain écran qui en a besoin, et les deux copies divergeront | La mettre dans `domain/` |
| `import 'package:flutter/material.dart'` dans `domain/` | Le domaine devient dépendant de l'interface graphique — la couche perd tout son intérêt | Sortir le type Flutter, utiliser du Dart pur |
| Un modèle de base de données utilisé tel quel dans un écran | Un changement de schéma Supabase casse l'interface | Traduire en entité via `data/models/` |
| Deux façons de gérer l'état dans le projet | Explicitement identifié comme « l'une des erreurs les plus coûteuses » dans le cadrage §1.3 | **Riverpod partout, sans exception** |
| Un dossier `utils/` fourre-tout | Il grossit jusqu'à ce que plus personne ne sache ce qu'il contient | Si ça a un métier, ça va dans `domain/` |

---

## 9. Ce que ce document ne décide pas

- Le **nommage** précis des fichiers et des classes → [`CONVENTIONS.md`](CONVENTIONS.md)
- Le **vocabulaire** métier à employer → [`GLOSSAIRE.md`](GLOSSAIRE.md)
- Ce qu'on n'a **pas le droit de modifier** sans demander → [`ZONES-PROTEGEES.md`](ZONES-PROTEGEES.md)
- L'apparence des écrans → maquette V2.1 + `SPECIFICATIONS_V2_Plateforme.md` (OneDrive)

---

*FayeMath Academy — La réussite se construit à domicile*

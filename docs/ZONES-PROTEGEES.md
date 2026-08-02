# ZONES-PROTEGEES.md — Ce qu'on ne casse pas

**Projet :** FayeMath Academy — application mobile
**Créé le :** 1er août 2026
**Statut :** règle de sécurité du projet. **À lire avant toute modification de fichier existant.**

Ce document existe pour une raison précise : Ousseynou écrit le code avec l'assistance de Claude Code, et **relit chaque diff avant de valider** (mode de travail choisi le 1er août 2026). Ce document dit à Claude Code ce qu'il n'a pas le droit de toucher tout seul, et dit à Ousseynou ce qu'il doit regarder en priorité dans un diff.

**Le principe, en une phrase : on ne dégrade jamais un travail déjà validé pour faire avancer le suivant.**

---

## 1. Les trois zones

| Zone | Signification | Ce que fait Claude Code |
|---|---|---|
| 🔴 **ROUGE** | Décision verrouillée ou travail déjà validé | **Il ne modifie pas.** Il s'arrête et demande à Ousseynou, en expliquant pourquoi il pense qu'un changement serait nécessaire. |
| 🟠 **ORANGE** | Modifiable, mais avec conséquences | **Il annonce d'abord** ce qu'il va changer et pourquoi, puis attend l'accord. |
| 🟢 **VERT** | Zone de travail normale | Il modifie librement, dans le respect d'[`ARCHITECTURE.md`](ARCHITECTURE.md) et [`CONVENTIONS.md`](CONVENTIONS.md). |

---

## 2. 🔴 ZONE ROUGE — ne jamais modifier sans accord explicite

### 2.1 Identité de l'application

| Élément | Où | Pourquoi c'est rouge |
|---|---|---|
| `applicationId` = `com.fayemathacademy.fayemath_academy` | `android/app/build.gradle.kts` | **Irréversible après la première publication Play Store.** Le changer signifierait publier une application différente, sans aucun moyen de migrer les utilisateurs existants. |
| `namespace` | même fichier | Doit rester cohérent avec l'`applicationId` |
| `name: fayemath_academy` | `pubspec.yaml` | Tous les `import 'package:fayemath_academy/...'` en dépendent |

### 2.2 Secrets et sécurité

| Élément | Règle |
|---|---|
| `config/dev.json` (et tout `config/*.json` sauf l'exemple) | **Ne doit jamais apparaître dans un commit.** Vérifié par `.gitignore`. Si un diff le montre : **arrêt immédiat**. |
| `SECURITY.md` | Se lit et s'applique. Ne se modifie pas au fil de l'eau — c'est un document de référence. |
| Les règles de `.gitignore` concernant `config/`, `*.jks`, `*.keystore` | Suppression = fuite de secret ou de clé de signature |
| Toute clé, jeton, URL Supabase, mot de passe | **Jamais en dur dans le code.** Convention : `--dart-define-from-file=config/dev.json` |
| La clé `service_role` de Supabase | **Jamais côté application**, en aucune circonstance |

### 2.3 Le contenu pédagogique

| Élément | Pourquoi c'est rouge |
|---|---|
| `assets/bibliotheque/6e-maths/` (77 PDF) | Copie de la bibliothèque de référence qui vit dans OneDrive (`03 - CONTENU PÉDAGOGIQUE`). **Question ouverte non tranchée** : ces fichiers doivent-ils rester dans le dépôt Git, alors que le cadrage prévoit un contenu servi par Supabase Storage ? Décision reportée à l'étape 9. **Ne rien y modifier, renommer ni supprimer d'ici là.** |
| `manifests/manifeste_6e_maths.csv` | 77 lignes de métadonnées produites une fois. Se régénère, ne se corrige pas à la main. |
| L'arborescence des dossiers dans `assets/` | Elle reproduit exactement la bibliothèque source. La casser rendrait le manifeste faux. |

### 2.4 Les décisions figées du cadrage

Listées dans `CLAUDE.md` §3 et §4. En particulier :

- **La stack** : Flutter + Supabase + Riverpod + go_router + **Drift** (pas Isar) + dio
- **Riverpod partout, sans exception** — le cadrage identifie explicitement le mélange de deux approches d'état comme « l'une des erreurs les plus coûteuses en développement »
- **Android uniquement en V1** (`--platforms=android`)
- **Offline-first** : local d'abord, serveur ensuite, toujours
- **Les 8 types de ressource** et la règle gratuit/premium — notamment `revision` = **gratuit**
- **Les 4 états de progression**, et la définition de « fait » (révision validée)
- **Les 5 règles du contrat hors-ligne**
- **Le tarif** 1 000 / 2 500 / 6 000 FCFA, verrouillé le 31/07/2026

Si l'une de ces décisions semble poser problème en cours de développement : **on le signale, on ne contourne pas.** Un contournement silencieux crée une application qui ne correspond plus à son propre cadrage.

### 2.5 Ce qui est déjà validé et ne doit pas régresser

| Acquis | Depuis | Comment on vérifie qu'il tient |
|---|---|---|
| L'environnement (étape 7) | 28/07, re-vérifié le 31/07 | `flutter doctor -v` sans problème |
| L'application se lance sur **émulateur Pixel_7** | 31/07 | `flutter run` |
| L'application se lance sur **téléphone SM-G9650** | 31/07 | `flutter run` sur l'appareil physique |
| Le dépôt Git et son remote privé | 31/07 | `git status` propre, `git remote -v` |

**L'application de démonstration doit rester fonctionnelle pendant toute la restructuration de l'étape 8.** On ne casse pas le build « le temps de finir » : on valide avec `flutter run` après chaque changement significatif.

---

## 3. 🟠 ZONE ORANGE — annoncer avant de changer

| Élément | Ce qu'il faut annoncer |
|---|---|
| `pubspec.yaml` | Toute dépendance ajoutée : laquelle, pourquoi, et si elle est activement maintenue. Le projet a déjà écarté Isar pour cette raison. |
| `.gitignore`, `.gitattributes` | Toute règle ajoutée ou retirée |
| `analysis_options.yaml` | Désactiver une règle de lint doit être justifié — le plus souvent, c'est le code qu'il faut corriger |
| `android/` (manifeste, build.gradle.kts) | Permissions, `minSdk`, configuration de build : impact direct sur les téléphones compatibles |
| `lib/main.dart` et `lib/app.dart` | Points d'entrée : une erreur ici casse tout |
| `core/theme/` | La charte graphique vient de la marque, pas d'un choix de développement |
| Le **Journal de Développement** (OneDrive) | On y **ajoute** une entrée datée. On ne réécrit jamais une entrée passée — c'est un journal, pas un document vivant. |
| `CLAUDE.md` | Se met à jour quand l'état du projet change réellement, pas à chaque session |

---

## 4. 🟢 ZONE VERTE — travail normal

- Tout ce qui est sous `lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/`, `lib/routing/` (hors `main.dart` / `app.dart`)
- `test/`
- Les documents de `docs/` — ils sont faits pour grandir avec le projet

Dans cette zone, la seule contrainte est de respecter [`ARCHITECTURE.md`](ARCHITECTURE.md) et [`CONVENTIONS.md`](CONVENTIONS.md).

---

## 5. Le rituel de relecture de diff

Mode de travail retenu : **Claude Code écrit, Ousseynou relit chaque diff avant validation.** Ce rituel n'a de valeur que s'il est réellement appliqué — un diff survolé ne protège de rien.

### Ce que Claude Code doit fournir avant chaque validation

1. **Ce qui a changé**, fichier par fichier, en une ligne chacun.
2. **Pourquoi**, en reliant à une décision du cadrage ou à une demande explicite.
3. **Ce qui a été touché en zone rouge ou orange** — et s'il n'y en a pas, le dire.
4. **Comment vérifier que ça marche** : la commande à lancer et le résultat attendu.

### Ce qu'Ousseynou regarde dans le diff, dans cet ordre

```bash
git diff                 # ce qui est modifié mais pas encore indexé
git diff --staged        # ce qui est prêt à être commité
git status               # les fichiers nouveaux ou supprimés
```

| # | Question | Signal d'alarme |
|---|---|---|
| 1 | **Y a-t-il une clé, un jeton, une URL Supabase ?** | Un fichier `config/*.json` dans le diff, une longue chaîne de caractères aléatoire |
| 2 | **Un fichier a-t-il été supprimé ou renommé sans que je le sache ?** | Des lignes `deleted:` ou `renamed:` dans `git status` |
| 3 | **La zone rouge a-t-elle été touchée ?** | `applicationId`, `assets/`, `pubspec.yaml` `name:`, `.gitignore` |
| 4 | **Les couches sont-elles respectées ?** | Un `import` de `data/` dans un fichier de `presentation/` · un `import 'package:flutter/...'` dans `domain/` |
| 5 | **Le diff est-il relisible ?** | Plus de ~15 fichiers ou 400 lignes : demander un découpage en plusieurs commits |
| 6 | **Ça compile et ça tourne ?** | `flutter analyze` doit dire « No issues found! », l'app doit se lancer sur les deux appareils |

> **Si tu ne comprends pas une ligne du diff, ne valide pas** — demande l'explication. C'est précisément l'intérêt de cette méthode : tu ne signes que ce que tu comprends. Un « je verrai plus tard » sur du code que tu n'as pas compris est exactement ce que ce document cherche à empêcher.

---

## 6. En cas de doute — l'ordre de priorité des sources

Quand deux sources se contredisent, voici qui l'emporte :

1. **Ousseynou**, interrogé directement — toujours en premier
2. Les **4 documents de cadrage** (`01 - Documents de Référence\`) — la référence figée
3. Les **3 documents de Planification** (`05 - Planification du Projet\`) — pour les durées, l'ordre et la Definition of Done
4. La **maquette V2.1** + `SPECIFICATIONS_V2_Plateforme.md` — pour tout ce qui s'affiche
5. Le **Journal de Développement** — pour les décisions techniques prises en cours de route
6. `CLAUDE.md` et les documents de `docs/` — la mémoire de travail

L'ancien **Cahier des Charges (24 p., 22 juillet 2026) est archivé** : il n'est plus une source. Les renvois « CDC §x.y » encore présents dans le Journal désignent ce document mort — les vérifier dans les 4 nouveaux documents avant de s'y fier.

**Et la règle qui prime sur toutes les autres** (`CLAUDE.md` §7.1) : *ne jamais inventer une information factuelle.* Si l'information existe dans un document, aller la lire. Si elle n'existe nulle part, **demander** — ne pas supposer.

---

*FayeMath Academy — La réussite se construit à domicile*

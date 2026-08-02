# CONVENTIONS.md — Comment on écrit le code

**Projet :** FayeMath Academy — application mobile
**Créé le :** 1er août 2026
**Statut :** conventions du projet. Elles s'appliquent à tout code écrit ici, par Ousseynou comme par Claude Code.

L'intérêt d'une convention n'est pas qu'elle soit la meilleure — c'est qu'elle soit **la même partout**. Un projet où chaque fichier suit sa propre logique devient illisible bien avant d'être gros.

---

## 1. La langue du code

> **DÉCISION DE CONVENTION — 1er août 2026, à confirmer par Ousseynou.**
> Une seule règle claire vaut mieux qu'un mélange au cas par cas.

| Quoi | Langue | Pourquoi |
|---|---|---|
| **Vocabulaire métier** (entités, champs, valeurs) | **Français** | `Chapitre`, `Ressource`, `Progression`, `type: 'corrige_evaluation'` — c'est déjà la langue du cadrage, du schéma Supabase et du manifeste CSV. Traduire en anglais créerait une double correspondance permanente et des bugs de traduction. |
| **Vocabulaire technique** (patterns, mots-clés) | **Anglais** | `repository`, `provider`, `state`, `builder`, `controller` — ce sont les termes de Flutter et de Dart, tout l'écosystème et toute la documentation les emploient. |
| **Commentaires et documentation** | **Français** | C'est ton projet, tu le reliras dans deux ans. |
| **Messages affichés à l'élève** | **Français** | Libellés exacts dans `SPECIFICATIONS_V2_Plateforme.md` — ne jamais les improviser. |
| **Messages de commit** | **Français**, sans accents | Les accents passent mal dans certains terminaux Windows. |

**En pratique :** `ChapitreRepository`, `ProgressionState`, `RessourceCardWidget`, `chapitreProvider`. Le nom métier en français, le suffixe technique en anglais.

---

## 2. Nommage — fichiers, classes, variables

| Élément | Règle Dart | Exemple pour ce projet |
|---|---|---|
| Fichier | `snake_case.dart` | `chapitre_repository.dart`, `liste_chapitres_screen.dart` |
| Classe, enum, typedef | `PascalCase` | `Chapitre`, `TypeRessource`, `EtatProgression` |
| Variable, fonction, paramètre | `lowerCamelCase` | `chapitreCourant`, `calculerProgression()` |
| Constante | `lowerCamelCase` aussi (pas de `SCREAMING_CASE` en Dart) | `const nombreChapitresGratuits = 2;` |
| Membre privé | Préfixe `_` | `_chargerDepuisCache()` |
| Dossier | `snake_case`, au **pluriel** pour une collection | `entities/`, `repositories/`, `screens/` |

**Suffixes obligatoires** — ils permettent de savoir ce qu'est un fichier sans l'ouvrir :

| Suffixe | Pour quoi | Exemple |
|---|---|---|
| `_screen.dart` | Un écran complet | `detail_chapitre_screen.dart` |
| `_widget.dart` | Un composant réutilisable | `badge_premium_widget.dart` |
| `_provider.dart` | Un provider Riverpod | `progression_provider.dart` |
| `_repository.dart` | Un contrat (dans `domain/`) ou son implémentation (dans `data/`) | `chapitre_repository.dart` |
| `_model.dart` | Une traduction JSON/SQL ↔ entité | `chapitre_model.dart` |

**Ce qu'on ne fait pas :** abréger. `ressource`, jamais `res`. `chapitre`, jamais `chap`. Le gain de frappe est nul, le coût de relecture est réel.

---

## 3. Ordre des `import`

Trois blocs, séparés par une ligne vide, dans cet ordre :

```dart
// 1. Bibliothèque Dart et Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// 2. Paquets externes
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 3. Fichiers du projet — toujours en chemin absolu package:
import 'package:fayemath_academy/domain/entities/chapitre.dart';
import 'package:fayemath_academy/presentation/widgets/badge_premium_widget.dart';
```

**Toujours `package:fayemath_academy/...`, jamais `../../domain/...`.** Les chemins relatifs cassent dès qu'on déplace un fichier, et ils rendent invisible la couche qu'on est en train d'importer — or c'est précisément ce qu'il faut voir d'un coup d'œil pour vérifier la règle de dépendance d'[`ARCHITECTURE.md`](ARCHITECTURE.md) §3.

---

## 4. Écrire un widget

**Toujours une classe, jamais une fonction qui renvoie un `Widget`.** Une fonction ne peut pas être `const`, ne peut pas être optimisée par Flutter au rebuild, et n'apparaît pas dans l'outil d'inspection. C'est une des rares règles Flutter qui fait consensus total.

```dart
// ✅ OUI
class BadgePremiumWidget extends StatelessWidget {
  const BadgePremiumWidget({super.key, required this.estPremium});

  final bool estPremium;

  @override
  Widget build(BuildContext context) { ... }
}

// ❌ NON
Widget construireBadgePremium(bool estPremium) { ... }
```

**Les autres règles :**

- **`const` partout où c'est possible.** Un widget `const` n'est reconstruit jamais. Sur un téléphone d'entrée de gamme — la cible réelle du projet — ce n'est pas du détail.
- **Constructeur en premier**, puis les champs (`final`), puis `build()`, puis les méthodes privées.
- **Les champs sont `final`.** Un widget ne change pas ; c'est son state qui change.
- **Découper à partir de ~80 lignes de `build()`.** Un `build()` de 300 lignes est impossible à relire dans un diff — et tu relis chaque diff.
- **Jamais de valeur brute dans un widget.** Pas de `Color(0xFF16213E)`, pas de `16.0` en dur : tout passe par `core/theme/`. Sinon le jour où la charte bouge, il faut fouiller 20 écrans.

---

## 5. Gestion des erreurs

**Aucun `try/catch` silencieux.** Un `catch` qui ne fait rien est un bug qu'on découvrira dans six mois, sur le téléphone d'un élève, sans aucune trace.

La couche `data/` attrape les erreurs techniques (réseau coupé, base illisible, 401 Supabase) et les traduit en **types d'échec métier** définis dans `core/errors/` : `PanneReseau`, `NonAutorise`, `Introuvable`, `StockagePlein`. La couche `presentation/` ne voit jamais une exception Supabase ou Drift — elle voit un échec métier, et sait quel message afficher.

**Rappel du contrat hors-ligne :** l'absence de réseau **n'est pas une erreur**. C'est un mode de fonctionnement normal, prévu, qui ne doit produire aucun message d'erreur — seulement l'affichage de ce qui est disponible localement.

---

## 6. Traces et journalisation

- **Jamais de `print()`** dans du code qui part en production.
- **Jamais** de jeton, de mot de passe, de clé Supabase ou d'adresse e-mail d'élève dans une trace. C'est une règle de `SECURITY.md`, pas une préférence de style.
- Utiliser `debugPrint()` en développement, un logger propre dès qu'il y en aura un (étape 10).

---

## 7. Avant chaque commit — les 3 commandes

```bash
dart format .          # met en forme, supprime tout débat sur le style
flutter analyze        # doit sortir "No issues found!"
flutter test           # doit passer
```

`flutter analyze` s'appuie sur `analysis_options.yaml` (déjà présent, `flutter_lints` activé). **Un avertissement d'analyse n'est pas cosmétique** — c'est souvent un vrai bug (variable inutilisée qui signale un oubli, `null` mal géré, `await` manquant).

---

## 8. Messages de commit

Format court, en français sans accents, avec un préfixe qui dit la nature du changement :

```
etape 8 : creer l'arborescence en 4 couches
fix : corriger le calcul de progression quand la revision est absente
docs : ajouter le glossaire du vocabulaire metier
chore : mettre a jour les dependances
```

**Un commit = un changement cohérent.** Pas de commit « divers » de 40 fichiers : il devient impossible à relire, donc impossible à annuler proprement. Comme tu relis chaque diff avant de valider, un gros commit fourre-tout te fait perdre le contrôle exactement au moment où tu en as besoin.

**Rappel `SECURITY.md` §9 :** relire `git diff` avant chaque commit, vérifier qu'aucune clé n'y apparaît et que `config/*.json` (hors `env.example.json`) reste ignoré.

---

## 9. Commentaires

Commenter **le pourquoi**, jamais le quoi. Le code dit déjà ce qu'il fait.

```dart
// ❌ inutile : le code le dit
// Incrémente le compteur
compteur++;

// ✅ utile : le code ne peut pas le dire
// On lit d'abord le local même si le reseau est present : c'est le contrat
// offline-first du cadrage (doc 3, §1.4). L'eleve ne doit jamais attendre.
final chapitres = await _local.lireChapitres();
```

Toute décision qui **s'écarte** du cadrage se commente dans le code **et** se note dans le Journal de Développement (OneDrive). Un commentaire seul se perd ; le Journal est la mémoire du projet.

---

## 10. Tests

En V1, on ne vise pas une couverture totale — le temps est compté et tu es seul. On teste **ce qui casse silencieusement** :

- Les règles métier de `domain/` (calcul de progression, dérivation gratuit/premium). Ce sont du Dart pur, donc rapides et faciles à tester.
- La traduction `data/models/` ↔ entités : c'est là que se logent les bugs de champ mal nommé.

Les écrans se vérifient à la main sur les deux appareils, conformément à la Definition of Done (`CLAUDE.md` §7.9) : émulateur Pixel_7 **et** téléphone physique SM-G9650.

---

*FayeMath Academy — La réussite se construit à domicile*

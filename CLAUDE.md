# CLAUDE.md — FayeMath Academy, application mobile (Lot 0 → V1)

Instructions permanentes pour Claude Code sur ce projet. À lire intégralement avant toute action. Ce fichier est la mémoire de travail ; les documents qu'il référence sont la source de vérité complète — ne jamais deviner un contenu qui s'y trouve, toujours aller le lire.

## 1. Qui est le porteur du projet

Ousseynou Faye, ingénieur en Transmission des Données et Sécurité de l'Information, fondateur de FayeMath Academy (cours de renforcement Maths/Physique-Chimie à domicile, zone Bargny-Rufisque-Dakar, Sénégal). Il réalise cette application **lui-même**, avec ton assistance directe ici dans Claude Code, en parallèle d'un suivi stratégique global mené ailleurs (Claude/Cowork) sur l'ensemble de son activité.

Ousseynou est ingénieur, pas débutant en programmation — mais c'est son premier vrai projet Flutter. **Il a demandé explicitement qu'on lui explique clairement ce qu'on fait et pourquoi, à chaque étape, plutôt que d'exécuter des changements sans les justifier.** Prends le temps d'expliquer les concepts Flutter/Dart au fil du code (widgets, state, etc.), avec des exemples concrets tirés du projet.

## 2. Documents de référence (chemins absolus — à consulter, jamais à réinventer)

> ⚠️ **L'ancien Cahier des Charges unique (24 p., 22 juillet 2026) est ARCHIVÉ** dans
> `…\P01- FAYEMATH ACADEMY\99 - ARCHIVES\08 - Plateforme (cadrage v1, 22 juil 2026)\`.
> Il a été remplacé le **29 juillet 2026** par les 4 documents de cadrage ci-dessous.
> Ne plus le citer comme source. Les renvois « CDC §x.y » encore présents dans ce fichier
> et dans le Journal désignent l'ancien document : les vérifier dans les 4 nouveaux docs
> avant de s'y fier.

Racine commune (notée `<P01>` ci-dessous) :
`C:\Users\DELL\OneDrive\Desktop\00 - DOCS PERSONNELS & PROJETS\P01- FAYEMATH ACADEMY`

**A. Cadrage — la référence figée (réécrite le 29/07/2026)**
Dossier : `<P01>\08 - PLATEFORME NUMÉRIQUE\01 - Documents de Référence\`

| Fichier | Quand l'ouvrir |
|---|---|
| `01 - Cadrage de la Plateforme.pdf` (15 p.) | Périmètre V1/V2/V3, les 3 profils, vision produit, contraintes, critères de succès — **ce qu'on construit et pourquoi** |
| `02 - Contenu et Experience.pdf` (10 p.) | Organisation du contenu, les 8 types de documents, la matrice gratuit/premium, le suivi de progression, les 20 écrans, le contrat hors-ligne, l'accessibilité — **ce que l'élève voit** |
| `03 - Technique et Pilotage.pdf` (10 p.) | Architecture, hors-ligne, serveur et données, sécurité et protection des mineurs, publication, lots, budget, risques — **pourquoi tel choix technique** |
| `04 - Feuille de Route.pdf` (8 p.) | Les 38 étapes en 8 phases, en cases à cocher |

**B. Planification — le chiffrage et le critère de « fini » (rédigés le 31/07/2026)**
Dossier : `<P01>\08 - PLATEFORME NUMÉRIQUE\05 - Planification du Projet\`

| Fichier | Quand l'ouvrir |
|---|---|
| `01 - Plan de Projet et Structure des Tâches.pdf` | Les 35 étapes restantes, chiffrées (durées) et enchaînées (dépendances) |
| `02 - Échéancier et Jalons.pdf` | Calendrier daté — publication visée semaine du 17 novembre 2026 |
| `03 - Risques, Qualité et Suivi.pdf` | Registre des 8 risques + **Definition of Done** (voir §7.9) |

**C. Maquettes, journal, marque, sécurité**

| Document | Chemin | Usage |
|---|---|---|
| **Maquettes V2.1 — 20 écrans (version figée le 28/07/2026)** | `<P01>\08 - PLATEFORME NUMÉRIQUE\02 - Maquettes & Écrans\FayeMath_Maquettes_Ecrans_V2.html` | **Ouvrir l'écran correspondant avant de coder chaque page** — respecter fidèlement disposition, libellés, couleurs. **C'est la V2 qui fait foi, pas la V1** |
| Spécifications détaillées des écrans V2 | même dossier, `SPECIFICATIONS_V2_Plateforme.md` | Comportements, états, libellés exacts — à lire avec la maquette |
| Maquettes V1 (10 écrans) | même dossier, `FayeMath_Maquettes_Ecrans_V1.html` | **Obsolète** — conservé pour historique uniquement, ne pas coder d'après |
| Journal de Développement Lot 0 (décisions techniques + suivi étapes 7-11) | `<P01>\08 - PLATEFORME NUMÉRIQUE\03 - Architecture Technique\Journal de Développement - Lot 0.md` | **Mettre à jour à chaque étape terminée et à chaque décision technique** (coche + nouvelle entrée datée) |
| Index du dossier plateforme | `<P01>\08 - PLATEFORME NUMÉRIQUE\00 - LISEZ-MOI - Plateforme Numérique.md` | Vue d'ensemble et état d'avancement global |
| Logo et guide de marque | `<P01>\00 - VISION & STRATÉGIE\Identité de Marque\Logo\` (SVG/PNG + `Guide-utilisation.md`) | Pour l'écran d'onboarding et toute utilisation du logo dans l'app |
| `SECURITY.md` (racine de ce projet) | ici même, `D:\PLATEFORME-FAYEMATH-ACADEMY\SECURITY.md` | **À consulter avant toute implémentation d'authentification, d'accès Supabase, de stockage local ou de données personnelles** |

**D. Documents internes du dépôt — `docs/` (créés le 01/08/2026, versionnés avec le code)**

Ils traduisent le cadrage en règles applicables ligne par ligne. **À lire avant d'écrire du code**, pas seulement en cas de doute.

| Fichier | Ce qu'il fixe | Quand l'ouvrir |
|---|---|---|
| `docs/ARCHITECTURE.md` | Rôle de chaque couche, **règle de dépendance** (qui importe qui), arborescence cible de `lib/`, arbre de décision « où ranger ce fichier », les 8 tables → entités, le pattern offline-first | **Avant de créer le moindre fichier dans `lib/`** |
| `docs/CONVENTIONS.md` | Langue du code (métier en français, technique en anglais), nommage, ordre des imports, écriture d'un widget, erreurs, commits, tests | Avant d'écrire du code, et avant chaque commit |
| `docs/GLOSSAIRE.md` | Le vocabulaire figé : hiérarchie à 4 niveaux, 8 types de ressource, 4 états de progression, contrat hors-ligne, **table anti-synonymes** | Dès qu'on nomme quelque chose — entité, champ, variable, libellé |
| `docs/ZONES-PROTEGEES.md` | Les zones 🔴 rouge / 🟠 orange / 🟢 verte, le **rituel de relecture de diff**, l'ordre de priorité des sources en cas de contradiction | **Avant de modifier un fichier existant**, et avant chaque validation |

## 3. Décisions verrouillées — à exécuter, pas à renégocier

Si un doute survient sur l'une de ces décisions, demander confirmation à Ousseynou plutôt que de changer silencieusement.

- **Stack** : Flutter (Dart) + Supabase (Postgres, Auth, Storage) + `flutter_riverpod` (état) + `go_router` (navigation) + **Drift** (base locale offline — **pas Isar**, abandonné par son mainteneur, vérifié le 28/07/2026) + `dio` (réseau) + `syncfusion_flutter_pdfviewer` ou `pdfx` (lecture PDF) + `flutter_secure_storage` (jetons).
- **Cible V1** : Android uniquement (`--platforms=android`), Play Store. iOS/web viendront plus tard, sans réécriture.
- **Approche** : offline-first (téléphones d'entrée de gamme, data chère, connexion instable au Sénégal). Toujours lire en local d'abord, synchroniser ensuite.
- **Architecture du code** (CDC §8.2) — structure en couches dans `lib/` :
  - `core/` — thème, constantes, utils, gestion réseau/erreurs (rien de spécifique à un écran)
  - `data/` — sources de données (Supabase, Drift), modèles, implémentation des repositories
  - `domain/` — entités et règles métier pures (ex. « qu'est-ce qu'un chapitre », calcul de progression), ne connaît ni Supabase ni Drift
  - `presentation/` — écrans, widgets, providers Riverpod
  - `routing/` — navigation `go_router`
- **Identifiant Android** : org `com.fayemathacademy`, nom de projet `fayemath_academy` → `applicationId` = `com.fayemathacademy.fayemath_academy`. Ne jamais le changer après une première publication Play Store.
- **Modèle** : freemium. V1 = bibliothèque + téléchargement + suivi de progression. V2 = exercices auto-corrigés + gamification + paiement. V3 = vidéos + tableau de bord prof.

## 4. Taxonomie des ressources et règle gratuit/premium (verrouillée le 28/07/2026, corrigée le 31/07/2026)

Champ `ressource.type` — pas d'énumération fermée dans le schéma de données, ces 8 valeurs sont la convention retenue. Source de vérité : `02 - Contenu et Experience.pdf` :

| `ressource.type` | Contenu | Règle gratuit/premium |
|---|---|---|
| `cours` | Cours du chapitre | Toujours **gratuit** |
| `resume` | Fiche méthode/résumé | Toujours **gratuit** |
| `exercices` | Énoncés d'exercices | **Gratuit** sur les N premiers chapitres de chaque classe/matière (N = 2, valeur modifiable), **premium** ensuite |
| `corrige` | Corrigé des exercices | Toujours **premium** |
| `revision` | QCM + barème | Toujours **gratuit** (corrigé le 31/07/2026 — voir note ci-dessous) |
| `evaluation` | Évaluation de chapitre | Toujours **premium** |
| `corrige_evaluation` | Corrigé d'évaluation | Toujours **premium** |
| `sujet_examen` | Banque BFEM/BAC (dossiers `99 -`, hors kit de chapitre) | **Premium**, sauf 1 sujet gratuit par classe |
| *(fiche de séance prof)* | Usage interne du kit de production | **Jamais publiée dans l'app** |

Le champ `ressource.premium` (booléen, déjà prévu au schéma) doit être dérivable automatiquement de `(type, position_chapitre)` — ne pas construire de marquage manuel fichier par fichier.

> **Pourquoi `revision` est gratuit.** Décision du 29/07/2026, appliquée au Journal le 31/07/2026 :
> un chapitre n'est considéré « fait » dans le suivi de progression que lorsque sa fiche de
> révision est validée. Classer `revision` en premium rendrait donc inutilisable le suivi de
> progression annoncé comme gratuit. Si tu croises encore « revision = premium » quelque part,
> c'est une trace périmée — signale-la à Ousseynou.

## 5. Charte graphique

- Couleur principale : **indigo `#16213E`**
- Couleur d'accent : **ocre `#B8622F`**
- Couleurs secondaires (identité de marque) : sable clair `#F2E8DC`, doré `#C9A15A` (accent discret)
- Signature de marque : « La réussite se construit à domicile »
- Typographie : le logo utilise Century Gothic (vectorisé, pas une police libre de droits pour l'app). **Police d'interface à choisir ensemble** — pistes : Poppins, Questrial, Jost (Google Fonts, style géométrique proche). Ne pas embarquer Century Gothic tel quel.
- Logo : réutiliser les fichiers du dossier Logo référencé ci-dessus, ne jamais régénérer un logo.

## 6. État actuel du projet (dernière mise à jour : 4 août 2026)

- **Étape 7 (environnement)** : ✅ terminée, **re-vérifiée en direct le 31/07/2026** poste par poste. Flutter 3.44.8 stable, Android SDK 36.1.0 (licences acceptées), Git 2.51.2 (identité complète), VS Code 1.131.0 + extensions `dart-code.dart-code`/`dart-code.flutter`. `flutter doctor -v` : aucun problème.
- **Étape 8 (projet Flutter, 2,5 j estimés)** : ✅ **terminée le 01/08/2026**. Projet `fayemath_academy` restructuré en 4 couches (`core/data/domain/presentation/` + `routing/`), point d'entrée réduit à `main.dart` → `runApp(FayeMathApp())`, widget racine dans `app.dart`, écran de démonstration descendu dans `presentation/screens/compteur_demo_screen.dart`. Validé par Ousseynou avec `flutter run` sur les deux appareils (émulateur Pixel_7 et téléphone physique Samsung SM-G9650) après les 3 lots. **Reste un point d'hygiène mineur, non bloquant** : le `.gitkeep` de `presentation/screens/` doit être retiré au prochain commit, puisque le dossier n'est plus vide.
- **Étape 9 (Backend Supabase)** : ✅ **terminée le 02/08/2026**. Projet Supabase `fayemath-academy` (région `eu-west-1`) créé et lié au dépôt. **6 migrations SQL versionnées** dans `supabase/migrations/` : (01) 8 tables + contraintes d'intégrité, (02) trigger de dérivation automatique de `ressource.premium` avec **sortie anticipée pour `sujet_examen`** (premium fixé à la main), (03) RLS sur les 8 tables, (04) trigger de création automatique du profil `utilisateur` sur inscription, (05) **seed de test** (ni catalogue réel ni les 77 PDF), (06) bucket Storage **privé `bibliotheque` (vide)** + policy de lecture `to authenticated` (gratuit OU abonnement actif). **RLS prouvé à deux comptes réels** par impersonation SQL (deny / allow / `anon`), auth email+mot de passe vérifiée de bout en bout.
  - **Auth anonyme : NON activée (décision A, 02/08/2026)** — cohérent avec « compte requis pour tout téléchargement, gratuit compris ». L'option reste activable plus tard (opt-in Supabase) si les retours élèves le justifient ; il faudrait alors retoucher la policy Storage (exclure `is_anonymous`).
  - **Storage en deux temps** : le bucket et sa policy existent, mais **les 77 PDF de `assets/` ne sont PAS migrés** — tâche séparée, non planifiée. `assets/` reste inchangé (zone rouge).
- **Étape 10 (outils clés)** : ✅ **terminée le 03/08/2026**, en 5 lots validés un par un sur émulateur Pixel_7 + Samsung SM-G9650. `flutter_riverpod` (`ProviderScope` + un `Notifier`), `go_router` (`MaterialApp.router`, deux routes de démo), `drift` via **`drift_flutter`** (base locale `data/local/base_locale.dart` + génération de code `build_runner`/`drift_dev`, `.g.dart` versionné), `dio` (présent, usage réel — téléchargement PDF — différé), `supabase_flutter` (init dans `main.dart`, secrets lus depuis `config/dev.json` via `lib/core/env/env.dart`, jamais en dur). **Choix technique notable** : `drift_flutter` plutôt que `sqlite3_flutter_libs` en direct (isole de la migration EOL de ce paquet). **Incident résolu** : `kotlin.incremental=false` dans `android/gradle.properties` (bug du compilateur Kotlin quand cache Pub sur C: et projet sur D:). Détails complets dans le Journal (entrées du 02-03/08). **Écrans/table de démonstration encore présents, à retirer à l'étape 11** : compteur, seconde page, table `LignesDemo` + preuve Drift dans `main.dart`.
- **Étape 11 (charte graphique et composants accessibles)** : ✅ **terminée le 03/08/2026**, en 4 lots validés un par un sur émulateur Pixel_7 + Samsung SM-G9650. Thème centralisé dans `lib/core/theme/` (`couleurs.dart` palette auditée AA, `typographie.dart` Poppins, `couleurs_marque.dart` = `ThemeExtension` pour l'ocre décoratif `#B8622F` et le vert succès, `theme.dart` = `ThemeData` avec un `ColorScheme` **construit à la main**, pas `fromSeed`). **Poppins embarquée en local** (`fonts/`, 4 graisses, licence OFL jointe), pas `google_fonts` (offline-first). Trois composants accessibles dans `presentation/widgets/` : `bouton_primaire_widget`, `carte_selection_widget`, `badge_premium_widget` (contraste AA, 48 px, statut jamais porté par la seule couleur, icônes libellées, `disableAnimations` respecté). **Tout le code de démonstration de l'étape 10 a été retiré** (compteur, seconde page, provider de démo, table `LignesDemo` + `base_locale.g.dart`, preuve Drift dans `main.dart`) ; accueil provisoire = `galerie_composants_screen.dart` jusqu'à l'étape 14. `flutter analyze` « No issues found! », `flutter test` « All tests passed! ». Détails complets dans le Journal (entrée du 03/08). **Point verrouillé** : le doré `#C9A15A` n'a pas d'usage dans la palette auditée de la maquette — laissé sans rôle, à trancher plus tard. `drift`/`drift_flutter`/`path_provider` gardés dans `pubspec.yaml` (stack verrouillée) bien que temporairement inutilisés, resserviront à l'étape 12.
- **Étape 12 (modèle de données)** : ✅ **terminée le 04/08/2026**, en 4 lots validés un par un ; `flutter analyze` propre, **32 tests** verts, lancé sans régression sur émulateur Pixel_7 + Samsung SM-G9650 (migration de base locale v1→v2 comprise). Première étape de la Phase 2 ; dépend de l'étape 9, pas de la 11. Livré : **5 enums** du vocabulaire figé (`domain/entities/`, champ `valeurSql` + parseur strict), **8 entités** immuables Dart pur (aucun import technique, `==`/`hashCode` à la main, règles pures `Abonnement.estActif` et `Ressource.rattachementCoherent`, `premium` lu tel quel), **8 tables Drift** miroir (`data/local/base_locale.dart`, `.g.dart` versionné, `schemaVersion 2` + migration destructive de la table de démo, sans FK/CHECK locales car cache reconstructible), **8 modèles** de traduction (`data/models/`, JSON↔entité et Drift↔entité ; `versJson` limité à `utilisateur`/`progression`/`telechargement` selon le RLS). Nouveau maillon d'erreurs `core/errors/donnees_invalides.dart` + lecteurs JSON typés. **`domain/repositories/` volontairement reporté** à l'étape qui le consommera (pas d'API devinée sans consommateur). Aucune dépendance ajoutée, aucune migration Supabase touchée. Détails complets dans le Journal (entrée du 04/08).
- **Git** : ✅ dépôt initialisé, remote privé `origin` = `https://github.com/ousseynou-faye/Plateforme_Biblio_FayeMath.git`, branche `main`. Étape 11 committée (`51735e8` thème+composants, `5d3894e` nettoyage démo). **Les commits de l'étape 12 sont en préparation** (relus avant `git commit`). Vérifier l'état `ahead`/push avec `git status` en début de session.
- **`assets/` et `manifests/` (ajoutés le 31/07/2026)** : les **77 PDF de la bibliothèque 6e Maths** ont été copiés dans `assets/bibliotheque/6e-maths/` (arborescence source conservée, compressés à −68,5 % via Ghostscript, 3,6 Mo), avec `manifests/manifeste_6e_maths.csv` (77 lignes) et le rapport de compression.
  - ⚠️ **Question partiellement clarifiée le 01/08/2026** : l'étape 9 construit l'infrastructure Supabase Storage (bucket + policies), mais la migration réelle de ces 77 PDF hors du dépôt Git reste une décision et une tâche séparées, non planifiées. **Ne rien modifier dans `assets/` tant qu'Ousseynou n'a pas tranché explicitement cette migration.**
- **Contenu pédagogique** (hors périmètre de ce projet de code, géré ailleurs) : bibliothèque 6e Maths terminée à 100 % (77 fiches), 5e/4e/3e en structure seulement (arbitrage reporté en Phase 7, hors chemin critique).
- **Tarif premium** : 1 000 / 2 500 / 6 000 FCFA — **verrouillé le 31/07/2026**, ce n'est plus « à valider ».

## 7. Méthode de travail attendue

1. **Ne jamais inventer une information factuelle** (règle du programme scolaire, prix, détail technique du cadrage). Si l'info existe dans un des documents du §2, aller la lire. Si elle n'existe nulle part, demander à Ousseynou plutôt que de supposer.
2. **Avancer étape par étape**, avec un point de validation explicite avant de passer à la suivante (Ousseynou confirme que ça marche avant qu'on enchaîne).
3. **Expliquer clairement** chaque décision et chaque nouveau concept Flutter/Dart en le reliant à un exemple concret du projet.
4. **Avant de coder un écran**, ouvrir la **maquette V2.1** correspondante (`FayeMath_Maquettes_Ecrans_V2.html`) et son fichier de spécifications, et respecter sa disposition/ses libellés. La V1 est obsolète.
5. **Documenter dans le Journal de Développement** (chemin en §2) toute étape terminée (cocher la case) et toute décision technique qui précise ou dévie le cadrage, datée.
6. Les décisions du §3 et §4 sont **figées** — ne pas les renégocier silencieusement ; si un changement semble nécessaire, le signaler explicitement à Ousseynou et attendre confirmation.
7. **Sécurité non négociable** : suivre `SECURITY.md` à la lettre — RLS activé dès la création de chaque table utilisateur, aucun secret en dur dans le code (voir convention `config/dev.json` + `--dart-define-from-file`), jamais la clé `service_role` côté app.
8. **Avant tout commit Git** : relire `git diff` pour vérifier qu'aucune clé/jeton n'y apparaît, et que `config/*.json` (hors `env.example.json`) reste bien ignoré.
9. **Definition of Done — une étape n'est cochée que si elle est finie ET testée** (source : `03 - Risques, Qualité et Suivi.pdf`, §2) :

   | Critère générique (toute étape de code) | Exigence |
   |---|---|
   | Compilation | Sans erreur, **sur émulateur ET sur téléphone physique** |
   | Régression | Aucune étape précédente cassée |
   | Écart au cadrage | Noté dans le Journal de Développement s'il y en a un |

   Critères spécifiques : Phase 3 (hors-ligne) testée **en mode avion réel**, pas seulement « sans wifi » · Phase 5 (sécurité) RLS vérifié **table par table avec un second compte élève** · Phase 6 (publication) les 12 testeurs ont **réellement utilisé** l'app, pas juste installée.
10. **Répartition du travail (choisie le 01/08/2026) : Claude Code écrit le code, Ousseynou relit chaque diff avant validation.** Avant chaque point de validation, fournir systématiquement les 4 éléments du rituel de `docs/ZONES-PROTEGEES.md` §5 :
    1. **ce qui a changé**, fichier par fichier, une ligne chacun ;
    2. **pourquoi**, en le reliant à une décision du cadrage ou à une demande explicite ;
    3. **ce qui a été touché en zone rouge ou orange** — et si rien ne l'a été, le dire ;
    4. **comment vérifier** : la commande exacte à lancer et le résultat attendu.

    Corollaire : **garder les diffs relisibles**. Au-delà d'une quinzaine de fichiers ou de ~400 lignes, découper en plusieurs étapes validables séparément. Un diff qu'Ousseynou ne peut pas relire en entier ne le protège de rien.
11. **Ne jamais dégrader un acquis pour faire avancer la suite.** La liste de ce qui est déjà validé est dans `docs/ZONES-PROTEGEES.md` §2.5. En particulier, l'app de démonstration doit **rester fonctionnelle pendant toute la restructuration de l'étape 8** — on ne casse pas le build « le temps de finir ».

## 8. Prochaine tâche

**Étape 13 — Développer les comptes élève** : inscription et connexion (email + mot de passe, déjà activés côté Supabase à l'étape 9), avec le parcours « continuer sans compte » (rôle `anon`, lecture du catalogue seule). C'est là qu'on branche `supabase_flutter` Auth sur du vrai code, qu'on crée les premiers **contrats de repository** (`domain/repositories/`) et leur implémentation (`data/repositories/`) autour de l'`Utilisateur`, et qu'on pose la gestion d'état d'authentification (Riverpod) + les redirections `go_router`. Les entités et modèles nécessaires existent depuis l'étape 12.

> **Séquencement (confirmé le 04/08/2026).** Feuille de Route (doc 04) : **12 (modèle de données, faite) → 13 (comptes élève) → 14 (écran choix classe/série/matière) → 15 (liste des chapitres, qui attend 12 ET 14)**. La prochaine étape est donc la **13**.

Ensuite les 20 écrans de la V2.1 un par un (à partir de l'étape 14), en ouvrant à chaque fois la maquette (`FayeMath_Maquettes_Ecrans_V2.html`) et ses spécifications avant de coder. L'accueil actuel est l'écran-galerie provisoire (`galerie_composants_screen.dart`), à remplacer par le premier vrai écran.

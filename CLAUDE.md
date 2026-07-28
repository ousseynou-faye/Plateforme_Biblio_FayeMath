# CLAUDE.md — FayeMath Academy, application mobile (Lot 0 → V1)

Instructions permanentes pour Claude Code sur ce projet. À lire intégralement avant toute action. Ce fichier est la mémoire de travail ; les documents qu'il référence sont la source de vérité complète — ne jamais deviner un contenu qui s'y trouve, toujours aller le lire.

## 1. Qui est le porteur du projet

Ousseynou Faye, ingénieur en Transmission des Données et Sécurité de l'Information, fondateur de FayeMath Academy (cours de renforcement Maths/Physique-Chimie à domicile, zone Bargny-Rufisque-Dakar, Sénégal). Il réalise cette application **lui-même**, avec ton assistance directe ici dans Claude Code, en parallèle d'un suivi stratégique global mené ailleurs (Claude/Cowork) sur l'ensemble de son activité.

Ousseynou est ingénieur, pas débutant en programmation — mais c'est son premier vrai projet Flutter. **Il a demandé explicitement qu'on lui explique clairement ce qu'on fait et pourquoi, à chaque étape, plutôt que d'exécuter des changements sans les justifier.** Prends le temps d'expliquer les concepts Flutter/Dart au fil du code (widgets, state, etc.), avec des exemples concrets tirés du projet.

## 2. Documents de référence (chemins absolus — à consulter, jamais à réinventer)

| Document | Chemin | Usage |
|---|---|---|
| Cahier des charges complet (24 p., référence figée) | `C:\Users\DELL\OneDrive\Desktop\00 - DOCS PERSONNELS & PROJETS\P01- FAYEMATH ACADEMY\08 - PLATEFORME NUMÉRIQUE\01 - Documents de Référence\FayeMath_Academy_Cahier_des_Charges_Plateforme.pdf` | Toute question sur le périmètre, les personas, le modèle de données, la sécurité, le budget |
| Checklist des 38 étapes (8 phases) | même dossier, `FayeMath_Academy_Feuille_de_Route_Checklist.pdf` | Suivi d'avancement — ne pas sauter une phase avant d'avoir fini la précédente |
| Maquettes des écrans V1 (HTML interactif, 10 écrans) | `C:\Users\DELL\OneDrive\Desktop\00 - DOCS PERSONNELS & PROJETS\P01- FAYEMATH ACADEMY\08 - PLATEFORME NUMÉRIQUE\02 - Maquettes & Écrans\FayeMath_Maquettes_Ecrans_V1.html` | **Ouvrir l'écran correspondant avant de coder chaque page** — respecter fidèlement disposition, libellés, couleurs |
| Journal de Développement Lot 0 (décisions techniques + suivi étapes 7-11) | `C:\Users\DELL\OneDrive\Desktop\00 - DOCS PERSONNELS & PROJETS\P01- FAYEMATH ACADEMY\08 - PLATEFORME NUMÉRIQUE\03 - Architecture Technique\Journal de Développement - Lot 0.md` | **Mettre à jour à chaque étape terminée et à chaque décision technique** (coche + nouvelle entrée datée) |
| Logo et guide de marque | `C:\Users\DELL\OneDrive\Desktop\00 - DOCS PERSONNELS & PROJETS\P01- FAYEMATH ACADEMY\00 - VISION & STRATÉGIE\Identité de Marque\Logo\` (fichiers SVG/PNG + `Guide-utilisation.md`) | Pour l'écran d'onboarding et toute utilisation du logo dans l'app |
| `SECURITY.md` (racine de ce projet) | ici même, `D:\PLATEFORME-FAYEMATH-ACADEMY\SECURITY.md` | **À consulter avant toute implémentation d'authentification, d'accès Supabase, de stockage local ou de données personnelles** |

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

## 4. Taxonomie des ressources et règle gratuit/premium (verrouillée le 28/07/2026)

Champ `ressource.type` — pas d'énumération fermée dans le schéma CDC §9.4, ces 8 valeurs sont la convention retenue :

| `ressource.type` | Contenu | Règle gratuit/premium |
|---|---|---|
| `cours` | Cours du chapitre | Toujours **gratuit** |
| `resume` | Fiche méthode/résumé | Toujours **gratuit** |
| `exercices` | Énoncés d'exercices | **Gratuit** sur les N premiers chapitres de chaque classe/matière (N = 2, valeur modifiable), **premium** ensuite |
| `corrige` | Corrigé des exercices | Toujours **premium** |
| `revision` | QCM + barème | Toujours **premium** |
| `evaluation` | Évaluation de chapitre | Toujours **premium** |
| `corrige_evaluation` | Corrigé d'évaluation | Toujours **premium** |
| `sujet_examen` | Banque BFEM/BAC (dossiers `99 -`, hors kit de chapitre) | **Premium**, sauf 1 sujet gratuit par classe |
| *(fiche de séance prof)* | Usage interne du kit de production | **Jamais publiée dans l'app** |

Le champ `ressource.premium` (booléen, déjà prévu au schéma) doit être dérivable automatiquement de `(type, position_chapitre)` — ne pas construire de marquage manuel fichier par fichier.

## 5. Charte graphique

- Couleur principale : **indigo `#16213E`**
- Couleur d'accent : **ocre `#B8622F`**
- Couleurs secondaires (identité de marque) : sable clair `#F2E8DC`, doré `#C9A15A` (accent discret)
- Signature de marque : « La réussite se construit à domicile »
- Typographie : le logo utilise Century Gothic (vectorisé, pas une police libre de droits pour l'app). **Police d'interface à choisir ensemble** — pistes : Poppins, Questrial, Jost (Google Fonts, style géométrique proche). Ne pas embarquer Century Gothic tel quel.
- Logo : réutiliser les fichiers du dossier Logo référencé ci-dessus, ne jamais régénérer un logo.

## 6. État actuel du projet (dernière mise à jour : 28 juillet 2026)

- **Étape 7 (environnement)** : ✅ terminée. Flutter 3.44.8 stable, Android SDK 36.1.0, Git 2.51.2, VS Code + extensions `dart-code.dart-code`/`dart-code.flutter`.
- **Étape 8 (projet Flutter)** : projet `fayemath_academy` créé (`flutter create --org com.fayemathacademy --project-name fayemath_academy --platforms=android .`), tourne et confirmé sur deux appareils :
  - Émulateur **Pixel_7** — instable au premier essai (déconnexions, puis échec de démarrage), résolu par un redémarrage à froid. À surveiller si le problème revient.
  - **Téléphone physique Samsung SM-G9650 (Android 10, API 29), branché en USB — appareil de test principal désormais**, plus représentatif des téléphones d'entrée de gamme des futurs élèves.
  - Reste à faire pour clore l'étape 8 : **restructurer `lib/` en couches** (`core/data/domain/presentation/routing`) — c'est la prochaine tâche.
- **Étapes 9-11** (Supabase, outils clés, charte graphique appliquée) : pas commencées.
- **Contenu pédagogique** (hors périmètre de ce projet de code, géré ailleurs) : bibliothèque 6e Maths terminée à 100 % (77 fiches), 5e/4e/3e en structure seulement.

## 7. Méthode de travail attendue

1. **Ne jamais inventer une information factuelle** (règle du programme scolaire, prix, détail technique du CDC). Si l'info existe dans un des documents ci-dessus, aller la lire. Si elle n'existe nulle part, demander à Ousseynou plutôt que de supposer.
2. **Avancer étape par étape**, avec un point de validation explicite avant de passer à la suivante (Ousseynou confirme que ça marche avant qu'on enchaîne).
3. **Expliquer clairement** chaque décision et chaque nouveau concept Flutter/Dart en le reliant à un exemple concret du projet.
4. **Avant de coder un écran**, ouvrir la maquette correspondante (fichier référencé en §2) et respecter sa disposition/ses libellés.
5. **Documenter dans le Journal de Développement** (chemin en §2) toute étape terminée (cocher la case) et toute décision technique qui précise ou dévie le CDC, datée.
6. Les décisions du §3 et §4 sont **figées** — ne pas les renégocier silencieusement ; si un changement semble nécessaire, le signaler explicitement à Ousseynou et attendre confirmation.
7. **Sécurité non négociable** : suivre `SECURITY.md` à la lettre — RLS activé dès la création de chaque table utilisateur, aucun secret en dur dans le code (voir convention `config/dev.json` + `--dart-define-from-file`), jamais la clé `service_role` côté app.
8. **Avant tout commit Git** : relire `git diff` pour vérifier qu'aucune clé/jeton n'y apparaît, et que `config/*.json` (hors `env.example.json`) reste bien ignoré.

## 8. Prochaine tâche

Restructurer `lib/` selon l'architecture en couches du §3, en conservant l'app de démonstration fonctionnelle pendant la transition (valider avec `flutter run` après chaque changement significatif). Ensuite : construire les écrans de la V1 un par un en suivant les maquettes.

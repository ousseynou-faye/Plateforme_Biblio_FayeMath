# GLOSSAIRE.md — Le vocabulaire du projet

**Projet :** FayeMath Academy — application mobile
**Créé le :** 1er août 2026
**Sources :** `01 - Documents de Référence\02 - Contenu et Experience.pdf` et `03 - Technique et Pilotage.pdf`
**Statut :** vocabulaire figé. Le code, la base de données, les écrans et les documents de cadrage emploient **les mêmes mots**.

Pourquoi ce document existe : dans un projet où le contenu est aussi structuré que celui-ci, un synonyme innocent — « leçon » au lieu de « chapitre », « fiche » au lieu de « ressource » — finit par créer deux notions là où il n'y en avait qu'une. C'est le genre de dérive qui ne se voit pas pendant un mois, puis coûte une refonte.

---

## 1. La hiérarchie du contenu — 4 niveaux, sans exception

Tout le contenu suit cette arborescence : la navigation, la base de données et les fichiers sur le disque.

| Niveau | Terme officiel | Nom dans le code | Valeurs possibles |
|---|---|---|---|
| 1 | **Classe** | `Classe` | 6e, 5e, 4e, 3e, 2nde, 1ère, Terminale |
| 2 | **Matière** | `Matiere` | Mathématiques, physique-chimie |
| 3 | **Chapitre** | `Chapitre` | Selon le livret officiel du Ministère |
| 4 | **Document** / **Ressource** | `Ressource` | Cours, exercices, corrigé, révision… |

> **RÈGLE DE CONFORMITÉ ABSOLUE** (document 2, §1.1)
> Le découpage en chapitres suit le **livret officiel du Ministère de l'Éducation nationale**, classe par classe. On vérifie le programme officiel avant de publier. **On n'invente jamais un chapitre.** Les documents d'enseignants sont d'excellentes sources d'exercices — jamais une source de programme.

---

## 2. Les termes, un par un

### Classe
Le niveau scolaire, de la 6e à la Terminale. Porte son **cycle** (collège / lycée) et, pour la 1ère et la Terminale, sa **série**.

### Série
L, S1 ou S2. **Demandée uniquement en 1ère et Terminale**, et toujours **avant** les matières, jamais après. En série L, la physique-chimie n'est pas proposée.

| Classe | Série demandée ? | Matières proposées |
|---|---|---|
| 6e, 5e | Non | Mathématiques |
| 4e, 3e | Non | Mathématiques, physique-chimie |
| 2nde | Non | Mathématiques, physique-chimie |
| 1ère, Terminale | **Oui** (L, S1, S2) | Selon la série |

### Matière
Mathématiques ou physique-chimie. **Une matière n'est proposée que si sa bibliothèque existe réellement** ; sinon elle apparaît avec la mention « bientôt disponible » plutôt que de mener l'élève vers un dossier vide. Au lancement, seule la **6e Mathématiques** est complète.

### Strate
Le regroupement de chapitres à l'intérieur d'une matière — en 6e Maths : « Activités Numériques » et « Activités Géométriques ». Correspond aux dossiers `01 -`, `02 -` de la bibliothèque source, et figure dans le manifeste CSV. **Ne pas confondre avec la matière.**

### Chapitre
L'unité de travail. Porte son numéro officiel et son ordre d'affichage. C'est **l'objet du suivi de progression** : c'est un chapitre qu'on marque « fait », jamais un document.

### Ressource (ou Document)
Un fichier publié : son type, son titre, sa taille, son statut gratuit ou premium, et son **numéro de version** (pour proposer une mise à jour si le document évolue). Les deux mots sont acceptés en français courant ; **dans le code, c'est toujours `Ressource`**.

> **Précision ajoutée le 01/08/2026 (étape 9).** La taille est **stockée en octets** (`taille_octets`, cohérent avec le manifeste CSV) et **affichée en kilooctets** à l'élève — deux choses différentes. Ne pas confondre l'unité de stockage et le format d'affichage.

### Kit
L'ensemble des documents produits pour **un** chapitre par le Standard de production de la bibliothèque. **Notion de production de contenu, pas de code** — l'application ne manipule jamais un « kit », elle manipule des ressources.

---

## 3. Les 8 types de ressource

Valeurs du champ `Ressource.type`. **Figées** — voir `CLAUDE.md` §4 pour la règle gratuit/premium associée.

| `type` | Ce que c'est | Publié dans l'app |
|---|---|---|
| `cours` | La leçon complète du chapitre | Oui |
| `resume` | La synthèse des points clés et des méthodes (fichiers « Méthodes » de la bibliothèque) | Oui |
| `exercices` | Les énoncés à travailler | Oui |
| `corrige` | La correction détaillée des exercices | Oui |
| `revision` | 10 questions à choix multiples avec barème | Oui |
| `evaluation` | Le devoir noté du chapitre | Oui |
| `corrige_evaluation` | La correction du devoir | Oui |
| `sujet_examen` | BFEM, Bac, compositions et sujets types (dossiers `99 -`) | Oui |
| *fiche de séance prof* | L'outil de préparation du tuteur | **Jamais — interne** |

> La **fiche de séance du professeur** fait partie du kit de production mais ne sort **jamais** de l'usage interne. Elle n'a pas de valeur de `type` parce qu'elle n'entre jamais dans l'application.

---

## 4. Premium et gratuit

**Premium** : le statut d'une ressource réservée aux abonnés. Le champ `Ressource.premium` est un booléen, **dérivé automatiquement** de `(type, position du chapitre)` — jamais saisi à la main fichier par fichier.

> **Exception, précisée le 01/08/2026 (étape 9).** `sujet_examen` échappe à cette dérivation : le Journal de Développement (Décision 3, 28/07/2026) fixe que le sujet gratuit de chaque classe est **choisi à la main** au moment de peupler le dossier `99 -`, pas calculé depuis une position. C'est la seule exception aux « jamais saisi à la main » — elle doit rester documentée ici pour ne pas être redécouverte à chaque fois.

**Ce qui justifie le premium** : les corrigés détaillés, les évaluations et la banque de sujets d'examen — tout ce qui permet de se préparer sérieusement au BFEM et au Bac.

**Deux clarifications à ne jamais oublier :**

1. **Le hors-ligne est identique dans les deux offres.** Le premium ajoute des *documents*, pas un mode hors-ligne différent, pas plus d'espace de stockage. Aucun quota n'est imposé par FayeMath.
2. **Le suivi de progression est gratuit, entièrement.** C'est ce qui distingue l'application des plateformes gratuites concurrentes. Les fiches de révision sont donc gratuites elles aussi, puisque c'est leur validation qui fait avancer la progression.

**N** = le nombre de chapitres dont les exercices sont gratuits par classe/matière. Vaut **2** aujourd'hui. **C'est une donnée, pas du code** : ajustable sans modifier l'application.

---

## 5. Les 4 états de progression

Valeurs de `Progression.etat`. Il y en a **quatre**, ni plus ni moins.

| État | Ce que ça veut dire |
|---|---|
| `a_faire` | Pas encore commencé |
| `en_cours` | Des documents du chapitre ont été consultés |
| `fait` | Le chapitre a été travaillé **et la fiche de révision validée** |
| `a_revoir` | Marqué par l'élève pour être revu avant un devoir |

> **La définition de « fait » est une règle métier, pas un détail d'affichage.**
> Un chapitre passe en `fait` quand l'élève a **validé sa fiche de révision** — pas quand il a simplement ouvert le cours. Cette définition est affichée à l'élève dans l'application. Elle traduit la promesse de FayeMath Academy : *une progression mesurable, jamais déclarative.*

**Régularité hebdomadaire**, et non « série de jours consécutifs » : une série se casserait pour une simple panne de réseau et culpabiliserait l'élève. Le mot « streak » n'a pas sa place dans ce projet.

---

## 6. Hors-ligne : deux notions à ne jamais confondre

C'est la confusion la plus coûteuse du projet. Elle est signalée explicitement dans le cadrage (document 2, §4.5).

| Notion | Question posée | Où elle s'affiche |
|---|---|---|
| **État du réseau** | L'appareil est-il connecté ? | **Une seule fois**, dans le bandeau du haut |
| **Disponibilité d'un document** | Ce document est-il sur le téléphone ? | **Sur chaque ligne** de document ou de chapitre |

Dans le code : **deux variables distinctes, deux sources, deux affichages.** Jamais l'une déduite de l'autre.

### Les 5 règles du contrat hors-ligne — non négociables

1. Rien ne se télécharge sans une **action explicite** de l'élève.
2. La **taille est toujours annoncée avant**, jamais après.
3. Un téléchargement interrompu **reprend là où il s'est arrêté**, même après fermeture de l'application.
4. Le hors-ligne **ne bloque jamais complètement** — il propose toujours ce qui est lisible localement.
5. La progression est **enregistrée en local d'abord**, puis synchronisée au retour du réseau.

**Téléchargement** : la copie d'une ressource dans l'espace privé de l'application — invisible des autres applications, effacée si on la désinstalle.

**File d'attente** : les actions faites sans réseau ne sont pas perdues, elles sont mises en file et rejouées au retour du réseau. En cas de contradiction entre téléphone et serveur, **la modification la plus récente l'emporte**.

---

## 7. Comptes et abonnement

**Utilisateur / Élève** : le compte. L'application permet aussi de **continuer sans compte** — le parcours « Découvrir » le prévoit explicitement.

**Abonnement** : la formule (mensuel 1 000 FCFA · trimestriel 2 500 · année scolaire 6 000, **verrouillé le 31/07/2026**), ses dates, sa référence de paiement. Offert aux élèves inscrits au tutorat.

**Tuteur** : Ousseynou. L'application affiche son contact (gratuit comme premium). Ne pas écrire « professeur » ni « enseignant » dans l'interface — la marque dit **tuteur**.

---

## 8. Table anti-synonymes

Le tableau à consulter au moindre doute. À gauche ce qu'on lit parfois ailleurs, à droite le seul terme admis ici.

| ❌ Ne pas dire | ✅ Dire | Pourquoi |
|---|---|---|
| Leçon, cours (pour l'unité) | **Chapitre** | « Cours » est un *type de ressource*, pas un niveau de la hiérarchie |
| Fiche, PDF, doc | **Ressource** | « Fiche » appartient au vocabulaire de production, pas à l'application |
| Module, unité, thème | **Chapitre** ou **Strate** selon le niveau visé | Deux niveaux distincts |
| Niveau | **Classe** | « Niveau » est ambigu (niveau scolaire ? niveau de maîtrise ?) |
| Filière, option | **Série** | Le terme du système sénégalais |
| Quiz, QCM | **Révision** (type) | Le type s'appelle `revision` ; « QCM » décrit son contenu |
| Payant, abonné, pro | **Premium** | Un seul mot dans toute l'application |
| Streak, série de jours | **Régularité hebdomadaire** | Choix produit assumé, voir §5 |
| Terminé, complété, validé | **Fait** | Les 4 états sont figés |
| Professeur, enseignant | **Tuteur** | Vocabulaire de marque |
| Cache | **Base locale** ou **Téléchargement** | « Cache » suggère quelque chose de jetable — or le hors-ligne est une promesse |
| Sync, synchro | **Synchronisation** | Pas d'abréviation dans le code ni dans l'interface |

---

## 9. Les mots de la marque

- Signature : **« La réussite se construit à domicile »**
- Ton : rigoureux, proche, rassurant
- Couleurs : indigo `#16213E` (rigueur), ocre `#B8622F` (proximité, **surfaces non textuelles uniquement**), `#96501F` pour tout texte ou icône fonctionnelle — contrainte de contraste WCAG AA issue de l'audit du 28/07/2026

**L'application n'invente pas sa propre identité — elle applique celle de la marque.**

---

*FayeMath Academy — La réussite se construit à domicile*

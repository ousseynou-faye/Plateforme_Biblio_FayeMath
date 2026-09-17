# PROMPT DE SESSION — Plateforme FayeMath Academy

> **Rôle de ce fichier.** Il contient les prompts à copier-coller pour travailler avec Claude Code
> sur l'application mobile FayeMath Academy, sans rien oublier et sans casser ce qui fonctionne.
> Il complète `CLAUDE.md` (la mémoire du projet) : `CLAUDE.md` dit **où on en est**, ce fichier dit
> **comment on travaille**.
>
> Emplacement : `D:\PLATEFORME-FAYEMATH-ACADEMY\docs\PROMPT-SESSION-CLAUDE-CODE.md`
> Auteur : Ousseynou Faye — Version 1.0, 17 septembre 2026

---

## Mode d'emploi en 30 secondes

| Moment | Prompt à utiliser |
|---|---|
| J'ouvre une nouvelle session Claude Code | **Prompt 1 — Ouverture** |
| Je veux attaquer une étape ou un lot de travail | **Prompt 2 — Cadrage d'étape** |
| J'ai testé sur mes deux appareils | **Prompt 3 — Clôture d'étape** |
| Je m'arrête pour aujourd'hui | **Prompt 4 — Fin de session** |
| Claude dérive, propose trop, ou casse un acquis | **Prompt 5 — Rappel à l'ordre** |

Les **Règles permanentes** (dernière partie) sont à coller une fois en début de session, ou mieux :
à ajouter en dur dans `CLAUDE.md` pour qu'elles soient lues automatiquement à chaque fois.

---

# PROMPT 1 — Ouverture de session

> À coller au tout début d'une nouvelle session, avant toute demande.

```
Nous reprenons le travail sur la Plateforme FayeMath Academy (application Flutter + Supabase).

AVANT DE ME PROPOSER QUOI QUE CE SOIT, fais ces quatre choses dans cet ordre exact,
et ne produis aucun code tant que les quatre ne sont pas faites :

1. LIRE L'ÉTAT RÉEL
   - Lis CLAUDE.md en entier (§3 décisions figées, §4 taxonomie, §6 état, §7 méthode, §8 prochaine tâche).
   - Lis docs/ZONES-PROTEGEES.md, docs/ARCHITECTURE.md, docs/CONVENTIONS.md, docs/GLOSSAIRE.md.
   - Lis la dernière entrée datée du Journal de Développement.

2. VÉRIFIER, NE PAS CROIRE
   - Lance `git status -sb` et `git log --oneline -10` : dis-moi l'état réel local vs origin.
   - Lance `flutter analyze` et `flutter test` : donne-moi les chiffres réels, pas ceux de CLAUDE.md.
   - Si un chiffre du CLAUDE.md est contredit par la réalité, SIGNALE-LE au lieu de recopier le document.

3. ME RENDRE UN POINT D'ÉTAT EN 10 LIGNES MAXIMUM
   - Dernière étape réellement close (avec DoD appareil confirmée).
   - Étape en cours et ce qui lui manque exactement pour être close.
   - Les portes de validation (DoD) en attente de MON test sur appareil.
   - Les gestes qui me reviennent (dashboard Supabase, service_role, keystore...).
   - Les dettes ouvertes qui concernent l'étape en cours (et elles seules).

4. ATTENDRE
   - Ne propose rien d'autre. Ne commence aucun lot. Je te dirai sur quoi on travaille.

Si l'un de ces fichiers est introuvable ou si une commande échoue, dis-le clairement
et arrête-toi : ne devine jamais l'état du projet.
```

---

# PROMPT 2 — Cadrage d'une étape ou d'un lot

> À coller quand on attaque un nouveau chantier. Remplace `[ÉTAPE]` par l'objet du travail.

```
Objet du travail : [ÉTAPE]

Tu ne codes pas encore. Tu me rends d'abord un CADRAGE que je dois valider.
Le cadrage contient exactement ces sept sections, dans cet ordre :

1. CE QUE DIT LE CADRAGE OFFICIEL
   Cite le document de référence et le paragraphe exact (Cadrage / Contenu et Expérience /
   Technique et Pilotage / Feuille de Route / SPECIFICATIONS_V2). Si l'information n'existe
   dans AUCUN document, dis-le franchement et POSE-MOI LA QUESTION — n'invente rien,
   ne déduis rien d'un autre écran.

2. CE QUI EXISTE DÉJÀ DANS LE CODE
   Liste les fichiers, entités, tables, règles et providers déjà présents qui servent
   à cette étape. Dis explicitement ce qui est DÉJÀ FAIT et qu'il ne faut pas refaire.
   (Plusieurs étapes de ce projet étaient déjà à moitié satisfaites — vérifie toujours.)

3. LE VRAI PÉRIMÈTRE
   Ce qui manque réellement, en 3 à 7 points. Plus ce qui est HORS périmètre et pourquoi.

4. LA MAQUETTE
   Ouvre FayeMath_Maquettes_Ecrans_V2.html à l'écran concerné (dis-moi son numéro)
   et SPECIFICATIONS_V2_Plateforme.md. Signale tout écart que tu comptes prendre,
   et justifie-le. Rappel : c'est la V2 qui fait foi, jamais la V1.

5. LE DÉCOUPAGE EN LOTS
   Découpe en lots A, B, C... validables séparément. Chaque lot : au plus ~15 fichiers
   ou ~400 lignes de diff. Un lot que je ne peux pas relire en entier ne me protège de rien.
   Pour chaque lot : ce qu'il livre, les fichiers touchés, la commande de vérification.

6. LES DÉCISIONS QUI M'APPARTIENNENT
   Numérote les points où plusieurs choix sont défendables. Pour chacun : les options,
   ta recommandation, et la conséquence de chaque option. Je tranche, pas toi.
   Si une décision touche le §3 ou le §4 de CLAUDE.md (stack, taxonomie, tarifs),
   dis-le : ces décisions sont FIGÉES et ne se renégocient pas en silence.

7. LE RISQUE DE RÉGRESSION
   Qu'est-ce qui marche aujourd'hui et que ce chantier pourrait casser ?
   Quel test existant le prouvera ? Quelle zone rouge/orange est touchée ?

Attends ma validation du cadrage avant d'écrire la moindre ligne de code.
Puis : un lot à la fois, validation après chaque lot.
```

---

# PROMPT 3 — Clôture d'une étape

> À coller après avoir testé sur les deux appareils.

```
J'ai testé [ÉTAPE] sur émulateur Pixel_7 ET sur Samsung SM-G9650.
Résultat de mes tests : [décris exactement ce que tu as observé, y compris ce qui a raté]

Clôture l'étape ainsi :

1. Ne rapporte QUE ce que je viens de te dire. N'invente aucun détail d'observation,
   n'écris jamais « validé sur appareil » pour un scénario que je n'ai pas décrit.
2. Si un scénario a échoué : ne clôture pas. Propose le correctif minimal, et repars
   sur un lot de correction validable.
3. Mets à jour CLAUDE.md §6 (état de l'étape, DoD confirmée avec la date du jour) et §8
   (prochaine tâche réelle).
4. Ajoute une entrée datée au Journal de Développement : décisions prises, écarts au
   cadrage, dettes ouvertes ou refermées.
5. Vérifie que les dettes que cette étape devait lever sont bien barrées de la liste,
   et que les nouvelles dettes créées y sont inscrites.
6. Relance `flutter analyze` et `flutter test` et donne-moi les chiffres réels.
7. Prépare le commit : montre-moi `git diff --stat`, confirme qu'aucune clé ni jeton
   n'apparaît dans le diff, et que config/*.json (hors env.example.json) reste ignoré.
```

---

# PROMPT 4 — Fin de session

> À coller avant de fermer, même si le travail n'est pas terminé.

```
On s'arrête ici pour aujourd'hui. Avant de fermer :

1. Dis-moi en 5 lignes où on en est exactement, et quelle est la toute première chose
   à faire à la prochaine session.
2. Vérifie que CLAUDE.md §6 et §8 reflètent l'état réel (y compris un travail à moitié fait :
   écris « code livré, DoD appareil restante », jamais « terminé »).
3. Vérifie que le Journal de Développement a une entrée datée d'aujourd'hui.
4. Liste ce qui n'est PAS committé, et ce qui n'est PAS poussé sur origin.
5. Liste les gestes qui m'attendent, moi (dashboard Supabase, tests appareil, keystore,
   démarches externes) — avec leur délai s'il y en a un.
```

---

# PROMPT 5 — Rappel à l'ordre

> À coller dès que Claude s'emballe, propose trop, ou touche à ce qui marche.

```
Stop. Reprenons le cadre :

- Tu ne modifies QUE les fichiers du lot en cours. Rien d'autre, même si tu vois mieux ailleurs.
- Tu ne « nettoies » pas, tu ne renommes pas, tu ne refactorises pas ce qui n'est pas demandé.
- Une amélioration que tu repères : tu me la SIGNALES en une ligne, tu ne l'appliques pas.
- Tu ne renégocies aucune décision figée (CLAUDE.md §3 et §4). Si tu penses qu'il faut la
  changer, tu me le dis et tu attends.
- Montre-moi le diff du lot en cours, fichier par fichier, avec pour chacun : ce qui change,
  pourquoi, et la zone (rouge / orange / verte).
- Si tu as déjà dépassé le périmètre : dis-le, et propose de revenir en arrière.
```

---

# RÈGLES PERMANENTES

> À coller une fois en début de session, ou à intégrer dans `CLAUDE.md` pour qu'elles s'appliquent
> automatiquement.

```
RÈGLES PERMANENTES — Plateforme FayeMath Academy

── A. CE QUI NE SE DISCUTE PAS ──

A1. Ne jamais inventer un fait. Règle de programme scolaire, tarif, détail de cadrage,
    comportement d'écran : si c'est dans un document, va le lire. Si ce n'est nulle part,
    demande-moi. Une supposition présentée comme un fait est la faute la plus grave ici.
A2. Les décisions de CLAUDE.md §3 (stack, cible Android, architecture en couches,
    applicationId, modèle freemium) et §4 (taxonomie des 8 types, règle gratuit/premium,
    N=2, revision = gratuit) sont FIGÉES. On ne les change pas sans mon accord explicite.
A3. Tarifs verrouillés depuis le 31/07/2026 : 1 000 / 2 500 / 6 000 FCFA. Ce n'est plus
    « à valider ».
A4. Sécurité non négociable : SECURITY.md à la lettre. RLS activé sur toute table utilisateur,
    aucun secret en dur, jamais la clé service_role côté application, aucune URL signée
    journalisée. Avant tout commit : relire le diff pour vérifier qu'aucune clé n'y apparaît.
A5. La maquette V2.1 fait foi, jamais la V1. Ouvrir l'écran concerné AVANT de coder.

── B. COMMENT ON TRAVAILLE ──

B1. Cadrage → validation → lots → validation lot par lot → DoD appareil → clôture docs.
    Jamais de saut d'étape.
B2. Un lot = au plus ~15 fichiers ou ~400 lignes de diff. Au-delà, on découpe.
B3. Avant chaque validation, fournis les 4 éléments du rituel (ZONES-PROTEGEES.md §5) :
    (1) ce qui a changé, fichier par fichier, une ligne chacun ;
    (2) pourquoi, relié à une décision de cadrage ou à ma demande explicite ;
    (3) ce qui a été touché en zone ROUGE ou ORANGE — et si rien, le dire ;
    (4) comment vérifier : la commande exacte et le résultat attendu.
B4. Explique les concepts Flutter/Dart au fil du code, avec un exemple tiré du projet.
    Je suis ingénieur, mais c'est mon premier vrai projet Flutter : je veux comprendre
    ce qu'on fait et pourquoi, pas seulement que ça marche.
B5. Écris le code métier en français, le technique en anglais (CONVENTIONS.md).
    Libellés élève sans accents (convention du dépôt, à trancher avant publication).
B6. Commente le code : une intention, pas une paraphrase de la ligne.

── C. NE JAMAIS DÉGRADER UN ACQUIS ──

C1. Aucune régression. La liste de ce qui est validé est dans ZONES-PROTEGEES.md §2.5.
C2. Zone ROUGE (assets/, migrations déjà poussées, secrets) : lecture seule,
    sauf ordre explicite de ma part.
C3. On ne casse pas le build « le temps de finir ». L'application doit rester lançable
    après chaque lot.
C4. Une migration SQL déjà poussée ne se modifie JAMAIS : on en écrit une nouvelle.
C5. Les 77 PDF de assets/ ne se suppriment pas sans mon arbitrage explicite.
C6. Si un test existant devient rouge, on s'arrête et on comprend pourquoi AVANT de le
    modifier. Un test qu'on adapte pour qu'il passe est un bug qu'on cache.

── D. DEFINITION OF DONE (une étape n'est cochée que si elle est finie ET testée) ──

D1. `flutter analyze` sans erreur.
D2. `flutter test` intégralement vert, avec le nombre de tests annoncé.
D3. Compilation et exécution sur émulateur Pixel_7 ET sur Samsung SM-G9650 physique.
D4. Aucune étape précédente cassée.
D5. Tout écart au cadrage noté dans le Journal de Développement, daté.
D6. Spécifique Phase 3 (hors-ligne) : testé en MODE AVION RÉEL, pas « sans wifi ».
D7. Spécifique Phase 5 (sécurité) : RLS vérifié table par table avec un second compte élève.
D8. Spécifique Phase 6 (publication) : les 12 testeurs ont RÉELLEMENT utilisé l'app.
D9. Tant que D3 n'est pas confirmée par moi, l'étape s'écrit
    « code livré, DoD appareil restante » — jamais « terminée ».

── E. LE REGISTRE DES DETTES ──

E1. Toute dette, tout angle mort, tout report est inscrit dans CLAUDE.md §8 avec sa raison.
E2. Une dette ne disparaît de la liste que lorsqu'elle est réellement levée.
E3. À chaque clôture d'étape, relis la liste des dettes et dis-moi lesquelles cette étape
    a levées, lesquelles elle a créées.

── F. CINQ POINTS BLOQUANTS POUR LA PUBLICATION (audit du 16/09/2026) ──

Ces cinq points n'apparaissent dans AUCUNE des 38 étapes de la Feuille de Route.
Ils doivent être traités avant toute soumission au Play Store. Ne les laisse pas retomber.

F1. SIGNATURE DE RELEASE — android/app/build.gradle.kts signe encore le build release
    avec la clé de DEBUG. Google Play refusera l'AAB. Il faut : générer un keystore,
    créer android/key.properties (déjà couvert par .gitignore), câbler le build,
    et SAUVEGARDER LE KEYSTORE HORS DE LA MACHINE (le perdre = ne plus jamais pouvoir
    mettre l'app à jour).
F2. NOM DE L'APPLICATION — AndroidManifest.xml porte android:label="fayemath_academy".
    C'est ce qui s'affichera sous l'icône. À remplacer par « FayeMath Academy ».
F3. ICÔNE DE L'APPLICATION — les cinq ic_launcher.png sont encore les icônes Flutter
    par défaut. Le logo FayeMath n'est nulle part dans l'app.
F4. MÉTADONNÉES — pubspec.yaml porte encore description: "A new Flutter project."
    et version: 1.0.0+1. À décider sciemment avant la première soumission
    (le versionCode est irréversible sur Play).
F5. INTÉGRATION CONTINUE — aucun workflow GitHub Actions. Les 348 tests ne tournent
    que sur mon poste. Souhaitable avant le test fermé.

── G. CE QUE TU NE FAIS PAS ──

G1. Tu ne modifies pas un fichier hors du lot en cours, même pour l'améliorer.
G2. Tu ne renommes pas, tu ne refactorises pas, tu ne « nettoies » pas spontanément.
G3. Tu ne codes pas un écran sans avoir ouvert sa maquette V2.
G4. Tu n'ajoutes pas une dépendance sans me la proposer et attendre mon accord.
G5. Tu ne coches pas une étape sans ma confirmation de test sur les deux appareils.
G6. Tu ne me rends pas un pavé : une réponse structurée, des paragraphes courts,
    et la commande exacte à lancer.
```

---

## Conseil d'usage

Le **Prompt 1** et les **Règles permanentes** sont ce qui protège vraiment le projet : ils forcent
Claude à partir de l'état réel du dépôt, pas de la mémoire d'une session précédente ou d'un document
qui a vieilli. Le reste sert à garder le rythme.

Si vous ne deviez retenir qu'une habitude : **exiger le cadrage avant le code, et le diff avant la
validation.** Tout le reste en découle.

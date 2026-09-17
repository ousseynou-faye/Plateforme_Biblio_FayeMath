# PROMPT — PHASE 5 : Sécurité et conformité (étapes 29 et 30)

> **Objet.** Prompts prêts à copier-coller pour mener la Phase 5 de la Plateforme FayeMath Academy
> avec Claude Code, étape par étape, sans rien laisser passer et sans casser l'existant.
>
> Emplacement : `D:\PLATEFORME-FAYEMATH-ACADEMY\docs\PROMPT-PHASE-5-SECURITE-CONFORMITE.md`
> Auteur : Ousseynou Faye — Version 1.0, 17 septembre 2026
> À utiliser avec : `docs/PROMPT-SESSION-CLAUDE-CODE.md` (règles permanentes et rituel de validation)

---

## Avertissement préalable — pourquoi cette phase est différente

Les étapes 7 à 26 construisaient des fonctionnalités : on ajoutait, on testait, on cochait.
**La Phase 5 ne construit presque rien : elle vérifie et elle engage.**

- L'**étape 29** est un **audit**. Le RLS est en place depuis l'étape 9 et a déjà été éprouvé.
  Le risque principal n'est pas de mal coder : c'est que Claude « améliore » des policies qui
  fonctionnent et casse un cloisonnement prouvé. Le prompt ci-dessous verrouille ce point.
- L'**étape 30** produit un **engagement juridique public** envers des familles et des mineurs.
  Une phrase fausse dans une politique de confidentialité n'est pas un bug : c'est une déclaration
  inexacte. Le prompt impose donc de ne décrire que ce que le code fait réellement.

---

## Décision de séquencement actée le 17 septembre 2026

**La Phase 4 est mise en pause, volontairement, à ce point précis :**

| Étape | État figé | Reprise prévue |
|---|---|---|
| ㉕ Verrouillage premium | ✅ Close (DoD 08/09) | — |
| ㉖ Écran d'abonnement | ⏸️ **Code complet et committé (`0d4da4b`), DoD appareil non passée** | Après la Phase 6 |
| ㉗ Paiement mobile | ⏸️ Non commencé | V2, après publication |
| ㉘ Déblocage automatique | ⏸️ Non commencé | V2, dépend de ㉗ |

**Motif :** le chemin critique vers une V1 publiée ne passe pas par le paiement. L'application tient
déjà sa promesse (bibliothèque + hors-ligne + suivi), et le verrou premium fonctionne. Le canal de
souscription humain (WhatsApp / appel) de l'étape 26 suffit pour encaisser manuellement pendant que
l'application est en ligne.

**Règle à tenir :** ces trois étapes restent **inscrites et visibles** dans `CLAUDE.md`, marquées
« ⏸️ en pause — reprise après Phase 6 ». Une étape mise en pause n'est pas une étape oubliée.
Ne jamais les effacer de la Feuille de Route.

---

# PROMPT A — Étape 29 : Sécuriser (audit RLS complet)

> À coller après le Prompt 1 d'ouverture de session. Un seul objectif : **prouver** le cloisonnement,
> pas le réécrire.

```
Nous attaquons l'ÉTAPE 29 — « Sécuriser » (première étape de la Phase 5).

CONTEXTE ET ÉTAT D'ESPRIT
Cette étape n'est PAS un chantier de développement. Le RLS est en place depuis l'étape 9
(migration 20260801100200_rls_policies.sql) et a déjà été éprouvé par impersonation SQL.
L'étape 29 est un AUDIT DE PREUVE, table par table, avec deux comptes élèves réels.

RÈGLE ABSOLUE DE CETTE ÉTAPE
Tu ne modifies AUCUNE policy existante tant qu'un test n'a pas prouvé un trou réel.
Si tu penses qu'une policy pourrait être meilleure : tu me le signales en une ligne,
tu ne la touches pas. Une migration déjà poussée ne se modifie jamais : si un correctif
s'avère nécessaire, on écrit une migration NEUVE, et je valide avant.

TRAVAIL DEMANDÉ — en trois temps, dans cet ordre

── TEMPS 1 : L'INVENTAIRE (aucun code, aucune modification) ──

1. Lis la migration 03 (RLS) et la migration 06 (Storage) en entier.
2. Rends-moi un tableau de l'état déclaré, une ligne par table, avec pour chacune :
   nom de la table · RLS activé oui/non · policies existantes · rôles visés ·
   opérations autorisées (SELECT/INSERT/UPDATE/DELETE) · ce qui est interdit par ABSENCE
   de policy.
   Les 8 tables à couvrir : classe, matiere, chapitre, ressource, utilisateur,
   progression, telechargement, abonnement. Plus storage.objects (bucket « bibliotheque »).
3. Signale toute table où le RLS serait désactivé, ou qui n'aurait aucune policy alors
   qu'elle contient des données d'élève.

── TEMPS 2 : LE PROTOCOLE DE TEST (tu l'écris, je l'exécute) ──

Écris-moi un fichier SQL de vérification, à lancer dans l'éditeur SQL Supabase, qui prouve
chaque ligne du tableau par impersonation (set local role / set local request.jwt.claims).
Le fichier doit être commenté en français, exécutable par blocs, et couvrir au minimum
cette matrice — chaque cas avec le résultat ATTENDU écrit à côté :

  A. CLOISONNEMENT ENTRE ÉLÈVES (élève A vs élève B, deux comptes réels)
     A1. A lit son propre profil utilisateur                         → 1 ligne
     A2. A lit le profil de B                                        → 0 ligne
     A3. A tente de modifier la classe de B                          → 0 ligne affectée
     A4. A tente de réécrire son id pour prendre celui de B          → refus (with check)
     A5. A lit ses propres progressions                              → ses lignes
     A6. A lit les progressions de B                                 → 0 ligne
     A7. A tente d'insérer une progression au nom de B               → refus
     A8. A lit ses propres téléchargements / ceux de B               → ses lignes / 0 ligne
     A9. A lit son abonnement / celui de B                           → sa ligne / 0 ligne

  B. INTÉGRITÉ DU CATALOGUE (le point le plus sensible commercialement)
     B1. A tente de passer une ressource premium en gratuit
         (update ressource set premium = false)                      → refus
     B2. A tente d'insérer un faux chapitre                          → refus
     B3. A tente de supprimer une ressource                          → refus
     B4. A tente de s'offrir un abonnement (insert into abonnement)  → refus
     B5. A tente de prolonger son abonnement (update date_fin)       → refus
     → Si UN SEUL de ces cinq tests passe, le modèle freemium est mort. Ce sont les plus
       importants de toute l'étape.

  C. VISITEUR NON CONNECTÉ (rôle anon)
     C1. anon lit classe / matiere / chapitre / ressource            → autorisé (voulu)
     C2. anon lit utilisateur / progression / telechargement / abonnement → 0 ligne
     C3. anon écrit quoi que ce soit, n'importe où                   → refus

  D. STORAGE — le vrai garde-fou du premium
     D1. anon demande une URL signée sur un fichier du bucket        → refus
     D2. A connecté SANS abonnement demande un fichier GRATUIT       → autorisé
     D3. A connecté SANS abonnement demande un fichier PREMIUM       → refus
     D4. A connecté AVEC abonnement actif demande un fichier PREMIUM → autorisé
     D5. A dont l'abonnement est EXPIRÉ demande un fichier PREMIUM   → refus
     → D3 et D5 sont les deux tests qui prouvent que le verrou tient côté serveur,
       indépendamment de l'application.

  E. SECRETS ET SURFACE D'ATTAQUE
     E1. Confirme qu'aucune clé service_role n'est présente dans lib/, android/,
         config/env.example.json, ni dans l'historique Git (cherche les motifs
         « service_role », « eyJ », « SUPABASE_SERVICE »).
     E2. Confirme que config/*.json (hors env.example.json) est bien ignoré par Git.
     E3. Confirme qu'aucune URL signée n'est journalisée (debugPrint / log) dans le code.
     E4. Vérifie que la clé anon utilisée par l'app est bien la clé PUBLIQUE et rien d'autre.

Pour chaque bloc : le SQL, le résultat attendu, et comment je reconnais un échec.
Je lance, je te rapporte les résultats RÉELS, tu ne les inventes pas.

── TEMPS 3 : LE POINT QUE LE CADRAGE N'A PAS PRÉVU ──

Un constat d'audit externe du 16/09/2026 à traiter dans cette étape :

  LA SUPPRESSION DE COMPTE N'EXISTE NULLE PART.
  - La table `utilisateur` n'a AUCUNE policy DELETE (migration 03, section B).
  - L'écran Profil n'a aucune ligne « Supprimer mon compte » (vérifié dans profil_screen.dart).
  - Or Google Play EXIGE, pour toute application permettant de créer un compte, DEUX chemins
    de suppression : un chemin DANS l'application, ET une URL web accessible depuis l'extérieur
    (pour l'utilisateur qui a désinstallé l'app). Cela se déclare dans le formulaire
    « Sécurité des données » de la Play Console.
  - Et la loi sénégalaise n° 2008-12 du 25 janvier 2008 consacre le droit de suppression
    des données à caractère personnel.

  Ce n'est donc pas une option : c'est bloquant pour la publication ET pour la conformité.

  Ce que je te demande ICI (pas de code encore) :
  1. Dis-moi précisément ce que « supprimer son compte » doit effacer dans notre modèle :
     ligne utilisateur, progressions, téléchargements, abonnement, compte auth Supabase,
     fichiers téléchargés sur l'appareil. Distingue ce qui part en cascade de ce qui reste.
  2. Dis-moi ce qu'on a le droit de CONSERVER et pourquoi (une trace d'abonnement payé
     peut relever d'une obligation comptable — dis-le clairement, ne tranche pas seul).
  3. Propose-moi l'architecture de la suppression, en pesant les options :
     suppression directe depuis l'app (mais l'app est en SELECT seul sur abonnement),
     fonction Postgres `security definer`, ou Edge Function Supabase.
     Donne ta recommandation et ses conséquences.
  4. Estime le découpage en lots.
  Je tranche ensuite, et on codera dans un lot séparé, clairement identifié.

── CE QUE TU NE FAIS PAS DANS CETTE ÉTAPE ──
- Tu ne modifies aucune policy existante sans preuve d'un trou réel et sans mon accord.
- Tu ne touches à aucune migration déjà poussée.
- Tu ne refactorises rien « pendant que tu y es ».
- Tu ne rends pas un verdict « tout est sécurisé » : tu rends des résultats de tests.

── DEFINITION OF DONE DE L'ÉTAPE 29 ──
1. Les 8 tables + storage.objects vérifiées UNE PAR UNE, avec un second compte élève réel.
2. Les 5 tests du bloc B (intégrité du catalogue) passés, sans exception.
3. Les tests D3 et D5 (verrou premium côté Storage) passés.
4. Aucun secret dans le dépôt, prouvé par recherche.
5. La question de la suppression de compte tranchée et son lot planifié.
6. Résultats consignés dans le Journal de Développement, datés, avec ce qui a été
   réellement observé — jamais un « conforme » sans test derrière.
```

---

# PROMPT B — Étape 30 : Politique de confidentialité et démarche CDP

> À coller **après** que l'étape 29 soit close. La politique doit décrire un code déjà audité,
> pas un code supposé.

```
Nous attaquons l'ÉTAPE 30 — « Politique de confidentialité + démarche CDP » (Phase 5).

CONTEXTE JURIDIQUE
- Pays : Sénégal. Texte applicable : loi n° 2008-12 du 25 janvier 2008 sur la protection
  des données à caractère personnel. Autorité : la Commission de Protection des Données
  personnelles (CDP), qui est active et instruit plusieurs centaines de dossiers par trimestre.
- Public visé : des ÉLÈVES, donc en grande majorité des MINEURS. C'est le facteur aggravant
  de toute cette étape : les obligations d'information et de consentement sont renforcées,
  et Google Play applique en plus ses propres règles aux applications destinées aux enfants
  ou à un public mixte.
- Responsable de traitement : Ousseynou Faye / FayeMath Academy, Bargny-Rufisque, Sénégal.

RÈGLE ABSOLUE DE CETTE ÉTAPE
Tu ne décris QUE ce que le code fait réellement. Chaque phrase de la politique doit être
adossée à une ligne de code, une table ou une policy que tu as vérifiée. Si tu ne peux pas
prouver une affirmation dans le dépôt, tu ne l'écris pas et tu me poses la question.
Une politique de confidentialité inexacte est pire que pas de politique : c'est une
déclaration fausse faite à des familles.

TRAVAIL DEMANDÉ — en quatre temps

── TEMPS 1 : LA CARTOGRAPHIE RÉELLE DES DONNÉES (la fondation) ──

Avant d'écrire une seule phrase juridique, dresse la carte des données à partir du CODE,
pas de suppositions. Un tableau, une ligne par donnée collectée :

  Donnée · Où elle est collectée (écran/fichier) · Où elle est stockée (table Supabase,
  table Drift locale, coffre chiffré, disque de l'appareil) · Pourquoi (finalité) ·
  Combien de temps · Qui y a accès · Sort-elle du Sénégal ?

À couvrir au minimum, en vérifiant chacune dans le code :
  - adresse e-mail et mot de passe (Supabase Auth, étape 13)
  - classe et série de l'élève (table utilisateur, étape 14)
  - progression par chapitre (table progression + Drift local, étapes 22-23)
  - historique de téléchargements (table telechargement, étape 19)
  - abonnement, le cas échéant (table abonnement, étape 25)
  - jetons de session (flutter_secure_storage, coffre chiffré)
  - drapeau d'onboarding et réglage Wi-Fi (coffre chiffré, lots Qualité A et D)
  - fichiers PDF téléchargés (espace privé de l'application sur l'appareil)
  - CE QUI N'EST PAS COLLECTÉ : dis-le explicitement — pas de nom, pas de téléphone,
    pas de ville, pas de géolocalisation, pas d'analytics, pas de publicité, pas de
    traceur tiers. C'est un argument de confiance ET une exigence du formulaire
    « Sécurité des données » de Google Play. Vérifie-le dans pubspec.yaml avant de l'affirmer.

Signale aussi explicitement : l'hébergement Supabase est en région eu-west-1 (Irlande).
Il y a donc un TRANSFERT DE DONNÉES HORS DU SÉNÉGAL. La loi de 2008 encadre ces transferts.
Ce point doit figurer dans la politique ET dans le dossier CDP. Ne le passe pas sous silence.

── TEMPS 2 : LA DÉMARCHE CDP (recherche à faire, sources à citer) ──

Va chercher l'information à jour sur le site officiel de la CDP (cdp.sn) et les sources
officielles sénégalaises. Ne te fie pas à ta mémoire, et cite chaque source par son URL.
Réponds à :
  1. Quel régime s'applique à notre traitement : déclaration préalable, demande
     d'autorisation, ou autre ? Le fait de traiter des données de MINEURS change-t-il
     le régime ?
  2. Quel est le formulaire exact, où le déposer, sous quel format ?
  3. Quelles pièces sont demandées (statut juridique, description du traitement, mesures
     de sécurité, transfert hors du Sénégal) ?
  4. Y a-t-il des frais ? Quel est le délai d'instruction annoncé ?
  5. Faut-il désigner un correspondant à la protection des données ?
  6. Que faut-il faire si le responsable de traitement est une personne physique
     et non une société déjà immatriculée ?

Rends-moi ensuite une FICHE DE DÉMARCHE : les étapes numérotées, ce que je dois préparer,
ce que je dois déposer, dans quel ordre, avec les délais. C'est une démarche administrative
à délai externe : elle doit être lancée tôt, pas à la veille de la publication.

Si une information reste introuvable ou ambiguë sur les sources officielles, dis-le
franchement et recommande-moi de contacter directement la CDP — ne comble jamais un vide
juridique par une supposition.

── TEMPS 3 : LES DEUX DOCUMENTS À PRODUIRE ──

DOCUMENT 1 — Politique de confidentialité (destinée aux familles, publique)
  Langue : français simple, lisible par un parent d'élève, pas par un juriste.
  Phrases courtes. Aucun jargon non expliqué.
  Structure attendue :
    1. Qui nous sommes et comment nous joindre (identité, e-mail, téléphone)
    2. Quelles données nous collectons — repris EXACTEMENT du tableau du Temps 1
    3. Pourquoi (une finalité par donnée, honnête et précise)
    4. Ce que nous ne collectons PAS (section courte et explicite)
    5. Où les données sont stockées, et le fait qu'elles sortent du Sénégal (Irlande)
    6. Combien de temps nous les gardons
    7. Le cas particulier des MINEURS : rôle du parent ou tuteur, comment il peut
       exercer les droits de son enfant
    8. Les droits de l'élève et de sa famille : accès, rectification, suppression,
       opposition — et COMMENT les exercer concrètement (l'adresse à écrire, le bouton
       dans l'application, le délai de réponse que nous nous engageons à tenir)
    9. La sécurité : mot de passe, RLS, coffre chiffré, bucket privé — décrit simplement
   10. Absence de publicité, de revente et de partage à des tiers (si c'est vrai — vérifie)
   11. Date de dernière mise à jour et comment nous signalerons un changement

DOCUMENT 2 — Page « Suppression de compte » (exigée par Google Play)
  Une page web publique, accessible SANS installer l'application, indiquant :
  quoi faire pour supprimer son compte, quelles données sont effacées, lesquelles sont
  conservées et pourquoi, et sous quel délai. Son URL devra être déclarée dans la
  Play Console.

Les deux documents doivent être :
  - publiables sur le site vitrine FayeMath Academy (donne-moi le format qui s'y intègre) ;
  - cohérents entre eux, et cohérents avec ce que l'application fait réellement ;
  - datés et versionnés.

Prépare-moi aussi, en annexe, les RÉPONSES AU FORMULAIRE « SÉCURITÉ DES DONNÉES » de la
Play Console, question par question, déduites du tableau du Temps 1. Ce formulaire sera
demandé à l'étape 32 : autant le préparer pendant qu'on a la cartographie sous les yeux.

── TEMPS 4 : LA BOUCLE DE COHÉRENCE ──

Une fois les documents rédigés, relis-les CONTRE le code et dis-moi, honnêtement :
  1. Quelle phrase de la politique n'est pas encore vraie dans l'application ?
     (Exemple probable : le droit de suppression, tant que le lot « suppression de compte »
     de l'étape 29 n'est pas codé.)
  2. Qu'est-ce qui doit être développé pour que chaque phrase devienne vraie ?
  3. Quelle phrase engage FayeMath au-delà de ce que je peux réellement tenir seul ?
     (Exemple : un délai de réponse de 48 h.) Signale-le, ne me laisse pas m'engager
     à l'aveugle.

── DEFINITION OF DONE DE L'ÉTAPE 30 ──
1. Cartographie des données établie à partir du code, vérifiée ligne par ligne.
2. Politique de confidentialité rédigée, lisible par un parent, sans aucune phrase
   non adossée au code.
3. Page de suppression de compte rédigée.
4. Réponses au formulaire « Sécurité des données » préparées.
5. Fiche de démarche CDP établie, sources officielles citées par URL.
6. Écart entre ce qui est promis et ce qui est codé : listé, chiffré, planifié.
7. Entrée datée au Journal de Développement.
8. Aucune affirmation juridique inventée : ce qui n'a pas été vérifié est signalé comme tel.
```

---

## Annexe — Faits vérifiés le 17 septembre 2026

Ces éléments ont été constatés directement dans votre dépôt et sur les sources officielles.
Ils sont fournis pour que vous puissiez contrôler ce que Claude Code vous rendra.

**État réel du RLS** (migration `20260801100200_rls_policies.sql`, lue intégralement) :

| Table | Policies | Ce qui est autorisé |
|---|---|---|
| `classe`, `matiere`, `chapitre`, `ressource` | 1 policy SELECT chacune | Lecture pour `anon` **et** `authenticated`. Aucune policy d'écriture → écriture interdite à tous sauf `service_role` |
| `utilisateur` | 2 policies | SELECT et UPDATE de sa propre ligne uniquement, avec `with check` |
| `progression` | 1 policy `for all` | Toutes opérations, filtrées sur `auth.uid()` |
| `telechargement` | 1 policy `for all` | Idem |
| `abonnement` | 1 policy SELECT | Lecture de son abonnement. **Aucune écriture possible depuis l'app** |
| `storage.objects` | 1 policy SELECT | `authenticated` uniquement, gratuit **ou** abonnement actif |

Le modèle est solide : le premium est protégé par l'**absence** de policy d'écriture sur
`abonnement` et `ressource`, ce qui est la bonne approche. L'audit doit le prouver, pas le supposer.

**Manque constaté :** aucune policy DELETE sur `utilisateur`, et aucune ligne « Supprimer mon compte »
dans `profil_screen.dart`. Or Google Play impose deux chemins de suppression — dans l'application
**et** via une URL web — et cela se déclare dans le formulaire « Sécurité des données ».

**Hébergement :** projet Supabase en région `eu-west-1` → transfert de données hors du Sénégal,
à déclarer.

Sources consultées :

- [Google Play — Exigences de suppression de compte](https://support.google.com/googleplay/android-developer/answer/13327111?hl=fr)
- [Loi sénégalaise n° 2008-12 sur la protection des données à caractère personnel (texte intégral, AFAPDP)](https://www.afapdp.org/wp-content/uploads/2018/05/Senegal-texte-de-loi-2008.pdf)
- [APS — Activité de la CDP au premier trimestre 2026](https://aps.sn/plus-de-300-dossiers-traites-par-la-commission-de-protection-des-donnees-personnelles-au-premier-trimestre-2026-officiel/)
- [OSIRIS — Dossiers traités par la CDP, deuxième trimestre 2026](https://www.osiris.sn/donnees-personnelles-plus-de-190-dossiers-traites-par-la-cdp-entre-avril-et.html)

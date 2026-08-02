# Sécurité & Bonnes Pratiques — FayeMath Academy App

Document de référence pour toute décision touchant à la sécurité, la vie privée ou la fiabilité de l'application. **Claude Code doit consulter ce fichier avant d'implémenter l'authentification, les accès à Supabase, le stockage local ou tout ce qui touche aux données personnelles.** Base non négociable : CDC §10 (Sécurité et protection des données). Ce document le complète avec des règles actionnables, pas seulement des principes.

Principe directeur : la sécurité se conçoit à chaque étape (*secure by design*), elle ne s'ajoute pas à la fin. Les utilisateurs sont majoritairement des élèves mineurs — ce n'est pas une formalité.

---

## 1. Gestion des secrets (clés, jetons)

**Distinction essentielle sur Supabase :**
- La **clé "anon" (publique)** est conçue pour être embarquée côté client — elle est protégée par les règles RLS (§3), pas par le secret. Elle reste quand même hors du code source (voir ci-dessous), pour rester facile à faire tourner et à gérer par environnement.
- La **clé "service_role"** contourne toutes les règles RLS. **Elle ne doit JAMAIS apparaître dans l'application Flutter**, ni dans un commit, ni dans un log. Elle n'a sa place que côté serveur (ex. une fonction Supabase Edge Function pour un traitement administratif), jamais côté mobile.

**Convention retenue pour ce projet :**
- Les clés vivent dans `config/dev.json` (fichier local, exclu de Git — voir `.gitignore`), au format défini par `config/env.example.json` (celui-ci reste versionné, sans valeur réelle, comme modèle).
- Lancement de l'app avec les secrets injectés au build, jamais écrits en dur dans le code :
  ```
  flutter run --dart-define-from-file=config/dev.json
  ```
- Lecture dans le code Dart via `String.fromEnvironment('SUPABASE_URL')` (typiquement centralisé dans `lib/core/env/env.dart`).
- **Aucune clé, mot de passe ou jeton ne doit jamais être écrit en dur dans un fichier `.dart`.**

---

## 2. Authentification (CDC §9.2)

- Email + mot de passe pour démarrer (pas de SMS OTP au lancement — coût par SMS et dépendance à un fournisseur externe, évités volontairement).
- Les mots de passe ne sont **jamais** stockés, loggés ou transmis en clair côté app — c'est Supabase Auth qui gère entièrement ce cycle.
- Les jetons de session sont stockés via `flutter_secure_storage` (chiffré, s'appuie sur le Keystore Android) — **jamais** via `SharedPreferences` en clair.
- À la déconnexion, invalider proprement le jeton côté Supabase, pas seulement l'effacer localement.

---

## 3. Base de données — Row Level Security (RLS)

**Règle absolue : toute table contenant des données liées à un utilisateur doit avoir le RLS activé dès sa création — pas "on l'ajoutera plus tard".**

- Un élève ne doit pouvoir lire/modifier que ses propres lignes (`progression`, `telechargement`, `abonnement`) : policy filtrant sur `auth.uid() = utilisateur_id`.
- Les tables de catalogue public (`classe`, `matiere`, `chapitre`, `ressource`) peuvent être en lecture publique, mais l'écriture reste réservée à un rôle administrateur (Ousseynou), jamais ouverte aux élèves.
- Avant de considérer une table "terminée" : la tester avec un compte élève normal (pas le compte admin) et vérifier qu'il ne voit **que** ce qu'il doit voir.

---

## 4. Stockage local et mode hors-ligne

- Les PDF téléchargés sont stockés dans l'espace privé de l'application (`path_provider`), jamais dans un espace de stockage public partagé du téléphone.
- La base locale Drift ne contient que ce qui est nécessaire au hors-ligne (catalogue, progression) — jamais de copie de mots de passe ou de jetons.

---

## 5. Réseau et communications

- HTTPS uniquement — Supabase l'impose par défaut, ne jamais contourner ou désactiver la vérification de certificat.
- Ne jamais logger (même en mode debug) une requête contenant un jeton d'authentification ou une donnée personnelle d'élève. Vérifier qu'aucun `print()` de ce type ne traîne avant un commit.

---

## 6. Protection des mineurs et conformité (CDC §10.1, §10.3)

- **Minimisation stricte** : ne collecter que l'identifiant, la classe, la progression. Pas de géolocalisation, pas d'accès aux contacts ou aux photos sans raison fonctionnelle explicite.
- Prévoir un consentement parental clair à l'inscription pour les élèves mineurs.
- Le Sénégal a une loi sur la protection des données personnelles (n° 2008-12) et une autorité, la CDP. Une politique de confidentialité est obligatoire avant toute publication (aussi exigée par le Play Store) ; une déclaration auprès de la CDP est à prévoir.

---

## 7. Paiement mobile (anticipé pour la V2, CDC §5.3)

- Aucune donnée de paiement (numéro de carte, identifiants mobile money) ne doit jamais transiter ni être stockée dans l'application.
- Le flux passe entièrement par l'agrégateur (PayDunya/CinetPay/Paytech/InTouch) : l'app déclenche le paiement et lit un statut confirmé côté serveur (webhook) — jamais de logique de confirmation côté client.

---

## 8. Dépendances (supply chain)

- Avant d'ajouter un package : vérifier son score et sa maintenance sur pub.dev (dernière mise à jour récente, pas de mention "discontinued"). L'abandon d'Isar (voir Journal de Développement) est l'exemple concret de ce qu'on évite en vérifiant avant d'adopter.
- De temps en temps, lancer `flutter pub outdated` pour repérer les mises à jour importantes, notamment de sécurité.

---

## 9. Checklist avant chaque commit

- [ ] Aucune clé ni jeton en clair dans le diff (`git diff` relu avant de committer)
- [ ] `config/*.json` (sauf `env.example.json`) bien ignoré par Git — vérifier avec `git status`
- [ ] Aucun `print()`/log de debug contenant des données sensibles laissé dans le code

## 10. Checklist avant publication sur le Play Store

- [ ] RLS activé et testé sur **toutes** les tables contenant des données utilisateur
- [ ] Politique de confidentialité rédigée, accessible, et conforme à la loi sénégalaise 2008-12
- [ ] Clé de signature Android (keystore) générée, sauvegardée en lieu sûr (hors du dépôt Git)
- [ ] Toutes les clés de développement/test remplacées par les clés de production dans la configuration de build

---

## 11. Secrets d'infrastructure Supabase (ajouté le 02/08/2026)

La création du projet Supabase (étape 9) fait apparaître des secrets d'un autre type que les clés applicatives du §1 — à traiter avec le même soin.

- **Mot de passe de la base Postgres.** Choisi à la création du projet, il ouvre un accès direct à la base via le rôle `postgres`, qui **contourne le RLS**. Il est **distinct** de la clé `anon` (publique, embarquée) et de la clé `service_role` (§1).
  - Jamais dans le dépôt Git, jamais dans `config/*.json`, jamais en clair dans un log.
  - À conserver dans un gestionnaire de secrets personnel, hors dépôt — au même rang que la future clé de signature Android (§10).
  - Saisi manuellement par Ousseynou lors de `supabase link` / `supabase db push` ; il ne doit apparaître dans aucune commande consignée dans un fichier versionné.
- **Personal Access Token (PAT) du CLI Supabase.** Nécessaire à `supabase login --token` en environnement non interactif (les commandes `!` de Claude Code sont non-TTY). Même règle : hors dépôt, révocable depuis le tableau de bord en cas de compromission.

Rappel : la clé `service_role` reste le secret le plus sensible — elle ne quitte jamais le poste local d'Ousseynou et n'entre dans aucun fichier du dépôt, aucun log, aucun message persistant.

---

*Ce document vit et se complète au fil du projet — toute nouvelle décision de sécurité doit y être ajoutée, datée, comme dans le Journal de Développement.*

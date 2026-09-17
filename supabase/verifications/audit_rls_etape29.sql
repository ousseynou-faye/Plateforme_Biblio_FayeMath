-- =============================================================================
-- ÉTAPE 29 — Audit RLS (Temps 2) : protocole de vérification par impersonation
-- FayeMath Academy — Phase 5, étape 29 (« Sécuriser »)
-- Écrit le : 2026-09-17
--
-- ⚠️ CE FICHIER N'EST PAS UNE MIGRATION.
--    Il vit dans supabase/verifications/, PAS dans supabase/migrations/.
--    `supabase db push` ne le regarde jamais. On le lance À LA MAIN, par blocs,
--    dans l'éditeur SQL Supabase (Studio). Il ne modifie RIEN durablement :
--    chaque test est encadré par `begin; ... rollback;`.
--
-- BUT : PROUVER, table par table, que le cloisonnement RLS tient — avec deux
--    comptes élèves réels (A et B). On ne réécrit aucune policy : on la teste.
--
-- COMMENT ÇA MARCHE (impersonation) :
--    Dans une transaction, on se fait passer pour un rôle Supabase :
--      set local role authenticated;                       -- ou `anon`
--      set local request.jwt.claims = '{"sub":"<uuid>","role":"authenticated"}';
--    Résultat : `auth.uid()` renvoie <uuid>, et les policies `to authenticated`
--    s'appliquent — exactement comme pour une requête venue de l'app via PostgREST.
--    (Équivalent en fonction : select set_config('request.jwt.claims', '…', true);)
--    Le rôle `postgres` de l'éditeur CONTOURNE le RLS (BYPASSRLS) : il ne sert
--    donc JAMAIS à prouver un refus — uniquement à préparer les données (bloc 0).
--
-- COMMENT LIRE UN RÉSULTAT :
--    - Les tests de LECTURE renvoient une ligne : test | lignes | attendu.
--      Succès = la colonne `lignes` vaut ce que dit `attendu`.
--    - Les tests d'ÉCRITURE-REFUSÉE se lisent de DEUX façons selon le cas :
--        * « ATTENDU 0 ligne » : la requête renvoie 0 (refus SILENCIEUX — la ligne
--          est invisible pour l'écriture faute de policy). SUCCÈS = 0.
--        * « ATTENDU ERROR 42501 » : la requête LÈVE une erreur
--          « new row violates row-level security policy ». CETTE ERREUR EST LE
--          SUCCÈS du test (le refus est prouvé par l'erreur). Après l'erreur,
--          relance le bloc suivant (la transaction est déjà annulée).
--
-- À FAIRE AVANT DE LANCER :
--    1. Créer/avoir DEUX comptes élèves réels (A et B) — deux e-mails distincts,
--       confirmés. Récupérer leurs `id` avec la requête du BLOC 0.
--    2. Remplacer partout <UUID_A> et <UUID_B> par ces deux id (garder les quotes).
--    3. Pour le BLOC D (Storage), remplacer <CHEMIN_GRATUIT> et <CHEMIN_PREMIUM>
--       par les deux chemins que renvoie la requête D0.
-- =============================================================================


-- =============================================================================
-- BLOC 0 — PRÉPARATION (à lancer en tant que postgres, SANS impersonation)
-- =============================================================================

-- 0.1 — Les deux comptes élèves. Choisis-en deux : A et B.
--       (Copie leurs id dans <UUID_A> / <UUID_B> partout dans ce fichier.)
select id, email, created_at
from auth.users
order by created_at;

-- 0.2 — Preuve que le bucket est peuplé (sinon le bloc D donnerait des faux 0).
--       ATTENDU : 77 (les 77 PDF de la 6e Maths déposés à l'étape 19).
select count(*) as objets_dans_bibliotheque
from storage.objects
where bucket_id = 'bibliotheque';

-- 0.3 — Choisis un fichier GRATUIT et un fichier PREMIUM qui existent VRAIMENT
--       dans le bucket (jointure ressource <-> objet). Copie les deux chemins
--       dans <CHEMIN_GRATUIT> / <CHEMIN_PREMIUM> du bloc D.
--       (Requête en postgres : elle voit tout, sans filtre RLS — c'est voulu ici.)
select r.premium, r.chemin_storage
from public.ressource r
join storage.objects o
  on o.name = r.chemin_storage and o.bucket_id = 'bibliotheque'
where r.premium = false
limit 1;

select r.premium, r.chemin_storage
from public.ressource r
join storage.objects o
  on o.name = r.chemin_storage and o.bucket_id = 'bibliotheque'
where r.premium = true
limit 1;


-- =============================================================================
-- BLOC A — CLOISONNEMENT ENTRE ÉLÈVES (A ne voit/touche jamais B)
-- =============================================================================

-- A — LECTURES (toutes en tant que A, en un seul résultat)
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';

  select 'A1 — A lit son propre profil'            as test, count(*) as lignes, '1'      as attendu from public.utilisateur    where id = '<UUID_A>'
  union all
  select 'A2 — A lit le profil de B',                     count(*),               '0'              from public.utilisateur    where id = '<UUID_B>'
  union all
  select 'A5 — A lit ses progressions',                   count(*),               'ses lignes'     from public.progression    where utilisateur_id = '<UUID_A>'
  union all
  select 'A6 — A lit les progressions de B',              count(*),               '0'              from public.progression    where utilisateur_id = '<UUID_B>'
  union all
  select 'A8a — A lit ses telechargements',               count(*),               'ses lignes'     from public.telechargement where utilisateur_id = '<UUID_A>'
  union all
  select 'A8b — A lit les telechargements de B',          count(*),               '0'              from public.telechargement where utilisateur_id = '<UUID_B>'
  union all
  select 'A9a — A lit son abonnement',                    count(*),               'sa/ses ligne(s)' from public.abonnement    where utilisateur_id = '<UUID_A>'
  union all
  select 'A9b — A lit l''abonnement de B',                count(*),               '0'              from public.abonnement     where utilisateur_id = '<UUID_B>';
rollback;

-- A3 — A tente de modifier la classe/série de B  → ATTENDU 0 ligne (refus silencieux)
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  with essai as (
    update public.utilisateur set serie = 'S1' where id = '<UUID_B>' returning 1
  )
  select 'A3 — A modifie la classe de B' as test, count(*) as lignes_modifiees, '0' as attendu from essai;
rollback;

-- A4 — A tente de réécrire son propre id (voler/fuir son identité) → ATTENDU ERROR 42501
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  update public.utilisateur set id = gen_random_uuid() where id = '<UUID_A>';
rollback;

-- A7 — A tente d'insérer une progression AU NOM DE B → ATTENDU ERROR 42501
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  insert into public.progression (utilisateur_id, chapitre_id, etat)
  values ('<UUID_B>', (select id from public.chapitre limit 1), 'a_faire');
rollback;


-- =============================================================================
-- BLOC B — INTÉGRITÉ DU CATALOGUE (le cœur commercial : si UN test passe,
--          le modèle freemium est mort). Tout en tant que A.
-- =============================================================================

-- B1 — A tente de passer une ressource PREMIUM en gratuit → ATTENDU 0 ligne
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  with essai as (
    update public.ressource set premium = false where premium = true returning 1
  )
  select 'B1 — A passe un premium en gratuit' as test, count(*) as lignes_modifiees, '0' as attendu from essai;
rollback;

-- B2 — A tente d'insérer un FAUX chapitre → ATTENDU ERROR 42501
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  insert into public.chapitre (classe_id, matiere_id, numero, titre, ordre)
  values ((select id from public.classe limit 1), (select id from public.matiere limit 1), 999, 'FAUX CHAPITRE — TEST AUDIT', 999);
rollback;

-- B3 — A tente de SUPPRIMER une ressource → ATTENDU 0 ligne
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  with essai as (
    delete from public.ressource where premium = true returning 1
  )
  select 'B3 — A supprime une ressource' as test, count(*) as lignes_supprimees, '0' as attendu from essai;
rollback;

-- B4 — A tente de S'OFFRIR un abonnement (même pour lui-même) → ATTENDU ERROR 42501
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  insert into public.abonnement (utilisateur_id, formule, date_debut, date_fin)
  values ('<UUID_A>', 'mensuel', current_date, current_date + 30);
rollback;

-- B5 — A tente de PROLONGER un abonnement existant → ATTENDU 0 ligne
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  with essai as (
    update public.abonnement set date_fin = date_fin + 365 where utilisateur_id = '<UUID_A>' returning 1
  )
  select 'B5 — A prolonge son abonnement' as test, count(*) as lignes_modifiees, '0' as attendu from essai;
rollback;


-- =============================================================================
-- BLOC C — VISITEUR NON CONNECTÉ (rôle anon)
-- =============================================================================

-- C1 + C2 — anon : lit le catalogue (autorisé) mais AUCUNE donnée d'élève
begin;
  set local role anon;
  set local request.jwt.claims = '{"role":"anon"}';

  select 'C1a — anon lit classe'         as test, count(*) as lignes, '> 0 (autorise)' as attendu from public.classe
  union all
  select 'C1b — anon lit matiere',              count(*),               '> 0 (autorise)'          from public.matiere
  union all
  select 'C1c — anon lit chapitre',             count(*),               '> 0 (autorise)'          from public.chapitre
  union all
  select 'C1d — anon lit ressource',            count(*),               '> 0 (autorise)'          from public.ressource
  union all
  select 'C2a — anon lit utilisateur',          count(*),               '0'                       from public.utilisateur
  union all
  select 'C2b — anon lit progression',          count(*),               '0'                       from public.progression
  union all
  select 'C2c — anon lit telechargement',       count(*),               '0'                       from public.telechargement
  union all
  select 'C2d — anon lit abonnement',           count(*),               '0'                       from public.abonnement;
rollback;

-- C3 — anon tente d'écrire quoi que ce soit → ATTENDU ERROR 42501
begin;
  set local role anon;
  set local request.jwt.claims = '{"role":"anon"}';
  insert into public.progression (utilisateur_id, chapitre_id, etat)
  values ('<UUID_A>', (select id from public.chapitre limit 1), 'a_faire');
rollback;


-- =============================================================================
-- BLOC D — STORAGE : le vrai garde-fou du premium (indépendant de l'app)
--          Remplace <CHEMIN_GRATUIT> / <CHEMIN_PREMIUM> (issus du bloc 0.3).
--          On teste la VISIBILITÉ de l'objet sous la policy de lecture : un objet
--          visible = URL signée délivrable ; 0 ligne = accès refusé côté serveur.
-- =============================================================================

-- D1 — anon demande un objet du bucket → ATTENDU 0 (anon hors du `to authenticated`)
begin;
  set local role anon;
  set local request.jwt.claims = '{"role":"anon"}';
  select 'D1 — anon demande un fichier' as test, count(*) as lignes, '0' as attendu
  from storage.objects
  where bucket_id = 'bibliotheque' and name = '<CHEMIN_GRATUIT>';
rollback;

-- D2 — A SANS abonnement demande un fichier GRATUIT → ATTENDU 1
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  select 'D2 — A sans abo lit un GRATUIT' as test, count(*) as lignes, '1' as attendu
  from storage.objects
  where bucket_id = 'bibliotheque' and name = '<CHEMIN_GRATUIT>';
rollback;

-- D3 — A SANS abonnement demande un fichier PREMIUM → ATTENDU 0  ⭐ test critique
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  select 'D3 — A sans abo lit un PREMIUM' as test, count(*) as lignes, '0 (verrou serveur)' as attendu
  from storage.objects
  where bucket_id = 'bibliotheque' and name = '<CHEMIN_PREMIUM>';
rollback;

-- ── Préalable D4/D5 : donner puis expirer un abonnement à A (postgres, service_role) ──
--    À LANCER SANS impersonation. C'est le SEUL écrit réel de tout ce fichier ;
--    supprime-le à la fin (voir NETTOYAGE) pour ne pas laisser A « abonné ».

-- (a) Abonnement ACTIF pour A :
insert into public.abonnement (utilisateur_id, formule, date_debut, date_fin)
values ('<UUID_A>', 'mensuel', current_date, current_date + 30);

-- D4 — A AVEC abonnement actif demande un fichier PREMIUM → ATTENDU 1
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  select 'D4 — A abonne lit un PREMIUM' as test, count(*) as lignes, '1' as attendu
  from storage.objects
  where bucket_id = 'bibliotheque' and name = '<CHEMIN_PREMIUM>';
rollback;

-- (b) Faire EXPIRER l'abonnement de A (fin dans le passé) :
update public.abonnement set date_fin = current_date - 1 where utilisateur_id = '<UUID_A>';

-- D5 — A dont l'abonnement est EXPIRÉ demande un PREMIUM → ATTENDU 0  ⭐ test critique
begin;
  set local role authenticated;
  set local request.jwt.claims = '{"sub":"<UUID_A>","role":"authenticated"}';
  select 'D5 — A expire lit un PREMIUM' as test, count(*) as lignes, '0 (verrou serveur)' as attendu
  from storage.objects
  where bucket_id = 'bibliotheque' and name = '<CHEMIN_PREMIUM>';
rollback;

-- ── NETTOYAGE (postgres) : retire l'abonnement de test, A redevient « sans abonnement » ──
delete from public.abonnement where utilisateur_id = '<UUID_A>';


-- =============================================================================
-- BLOC E — Secrets et surface d'attaque : NE SE TESTE PAS EN SQL.
--          Ce sont des vérifications côté DÉPÔT (grep de lib/, android/, config/,
--          historique Git) + configuration. Elles sont menées séparément par
--          Claude Code et consignées au Journal (voir Temps 2, rapport E1–E4).
-- =============================================================================

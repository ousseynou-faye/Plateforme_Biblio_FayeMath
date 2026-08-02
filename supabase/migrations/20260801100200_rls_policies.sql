-- =============================================================================
-- Migration 03 — Row Level Security (RLS), table par table
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase)
-- Date : 2026-08-01
--
-- Principe (SECURITY.md §3) : toute table contenant des données d'un utilisateur
-- a le RLS activé dès sa création. RLS = un filtre que Postgres applique à CHAQUE
-- requête, ligne par ligne, selon QUI la fait. L'élève ne « voit » et ne « touche »
-- que ce que la policy autorise, même s'il forge une requête à la main.
--
-- Deux rôles Supabase interviennent :
--   - `anon`          : visiteur non connecté (parcours « Découvrir » / sans compte)
--   - `authenticated` : élève connecté ; `auth.uid()` renvoie l'id de son compte
-- Un troisième, `service_role` (utilisé seulement par Ousseynou, en local, jamais
-- dans l'app), CONTOURNE le RLS : c'est lui qui écrit le catalogue. On n'a donc
-- AUCUNE policy d'écriture à créer pour le catalogue — l'absence de policy = interdit.
--
-- Détail de perf (reco Supabase) : on écrit `(select auth.uid())` plutôt que
-- `auth.uid()`. Ça force Postgres à évaluer l'id UNE fois par requête au lieu d'une
-- fois par ligne. Même résultat, beaucoup plus rapide sur une longue liste.
-- =============================================================================


-- =============================================================================
-- A. TABLES DE CATALOGUE — lecture pour tous, écriture pour personne (sauf admin)
--    classe, matiere, chapitre, ressource
--    `anon` inclus : la bibliothèque se parcourt sans compte (parcours Découvrir).
--    Aucune policy INSERT/UPDATE/DELETE -> un élève ne peut pas créer un faux
--    chapitre ni marquer un corrigé « gratuit ». Seul service_role écrit.
-- =============================================================================

alter table public.classe enable row level security;
create policy "classe_lecture_publique"
  on public.classe for select
  to anon, authenticated
  using (true);

alter table public.matiere enable row level security;
create policy "matiere_lecture_publique"
  on public.matiere for select
  to anon, authenticated
  using (true);

alter table public.chapitre enable row level security;
create policy "chapitre_lecture_publique"
  on public.chapitre for select
  to anon, authenticated
  using (true);

alter table public.ressource enable row level security;
create policy "ressource_lecture_publique"
  on public.ressource for select
  to anon, authenticated
  using (true);
-- NB : lire la FICHE d'une ressource premium (titre, badge premium) est autorisé —
-- c'est ce qui permet d'afficher le cadenas. Lire son FICHIER est un autre sujet,
-- géré par la policy Storage (Lot D), pas ici.


-- =============================================================================
-- B. utilisateur — chacun ne voit et ne modifie QUE son propre profil
--    SELECT + UPDATE seulement. PAS d'INSERT (décision d.6) : le profil est créé
--    automatiquement par le trigger de la migration 04, jamais par l'app.
--    PAS de DELETE : la suppression suit celle du compte auth (on delete cascade).
-- =============================================================================

alter table public.utilisateur enable row level security;

-- Empêche concrètement : l'élève A ne peut pas lire la classe/série de l'élève B.
create policy "utilisateur_lecture_de_soi"
  on public.utilisateur for select
  to authenticated
  using ((select auth.uid()) = id);

-- Empêche concrètement : l'élève A ne peut pas changer la classe de l'élève B.
-- `with check` s'applique à la ligne APRÈS modif -> il ne peut pas non plus
-- « offrir » sa ligne à un autre id en réécrivant la clé.
create policy "utilisateur_maj_de_soi"
  on public.utilisateur for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);


-- =============================================================================
-- C. progression & telechargement — données propres à l'élève, lecture ET écriture
--    `for all` = SELECT + INSERT + UPDATE + DELETE, tous filtrés sur auth.uid().
--    `with check` protège les écritures : impossible d'insérer/mettre à jour une
--    ligne au nom d'un autre élève.
-- =============================================================================

alter table public.progression enable row level security;
-- Empêche : l'élève A ne peut ni lire ni fabriquer une progression « fait »
-- au nom de l'élève B.
create policy "progression_acces_de_soi"
  on public.progression for all
  to authenticated
  using ((select auth.uid()) = utilisateur_id)
  with check ((select auth.uid()) = utilisateur_id);

alter table public.telechargement enable row level security;
-- Empêche : l'élève A ne voit pas la liste des documents téléchargés par l'élève B.
create policy "telechargement_acces_de_soi"
  on public.telechargement for all
  to authenticated
  using ((select auth.uid()) = utilisateur_id)
  with check ((select auth.uid()) = utilisateur_id);


-- =============================================================================
-- D. abonnement — l'élève LIT le sien, mais n'écrit RIEN
--    SELECT seul. Aucune policy d'écriture : un élève ne peut pas s'offrir un
--    abonnement premium en insérant une ligne. Seul un processus serveur (futur
--    webhook de paiement, SECURITY.md §7), via service_role, crée un abonnement.
-- =============================================================================

alter table public.abonnement enable row level security;
create policy "abonnement_lecture_de_soi"
  on public.abonnement for select
  to authenticated
  using ((select auth.uid()) = utilisateur_id);

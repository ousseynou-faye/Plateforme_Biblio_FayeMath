-- =============================================================================
-- Migration 02 — Dérivation automatique de `ressource.premium`
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase)
-- Date : 2026-08-01
--
-- But : `ressource.premium` ne se saisit JAMAIS à la main (CLAUDE.md §4,
-- GLOSSAIRE §4). Il se DÉDUIT de (type, position du chapitre). On met cette
-- règle dans UN SEUL endroit — un trigger — pour que la base refuse d'elle-même
-- d'écrire une ligne incohérente, quel que soit l'auteur de l'insertion.
--
-- Pourquoi un trigger et pas une colonne générée : une colonne générée Postgres
-- ne peut lire que les colonnes de SA propre ligne. Or la règle des `exercices`
-- a besoin de l'`ordre` du chapitre (une autre table) et de N — impossible en
-- colonne générée. Le trigger, lui, peut.
--
-- Règle (CLAUDE.md §4) :
--   cours, resume, revision                     -> gratuit  (false)
--   corrige, evaluation, corrige_evaluation     -> premium  (true)
--   exercices                                   -> gratuit sur les N premiers
--                                                  chapitres (par `ordre`) de la
--                                                  (classe, matiere), premium ensuite
--   sujet_examen                                -> SORTIE ANTICIPÉE : premium choisi
--                                                  à la main, jamais recalculé ici
-- =============================================================================


create or replace function public.ressource_definir_premium()
returns trigger
language plpgsql
-- search_path vidé + objets qualifiés `public.` : durcissement recommandé par
-- Supabase pour qu'aucun objet homonyme ne puisse détourner la fonction.
set search_path = ''
as $$
declare
  -- N = nombre de chapitres dont les EXERCICES sont gratuits, par (classe, matiere).
  -- Vaut 2 aujourd'hui (CLAUDE.md §4). C'est une donnée : la changer = une nouvelle
  -- migration. Source unique, côté base — l'app ne connaît pas N, elle lit le booléen.
  v_n       constant smallint := 2;
  v_classe  uuid;
  v_matiere uuid;
  v_ordre   smallint;
  v_rang    integer;
begin
  -- 1. SORTIE ANTICIPÉE — sujet_examen.
  -- Son premium est fixé à la main au moment de peupler le dossier « 99 - »
  -- (décision d.1/d.4 du 01/08/2026, Journal Décision 3 du 28/07). On le laisse
  -- EXACTEMENT tel qu'il a été fourni, sans jamais le recalculer.
  if new.type = 'sujet_examen' then
    return new;
  end if;

  -- 2. Types dont le statut ne dépend que du type.
  if new.type in ('cours', 'resume', 'revision') then
    new.premium := false;

  elsif new.type in ('corrige', 'evaluation', 'corrige_evaluation') then
    new.premium := true;

  -- 3. exercices : dépend de la position du chapitre dans sa (classe, matiere).
  elsif new.type = 'exercices' then
    -- Le chapitre existe forcément : la contrainte `ressource_rattachement_coherent`
    -- impose chapitre_id NOT NULL pour tout type autre que sujet_examen.
    select c.classe_id, c.matiere_id, c.ordre
      into v_classe, v_matiere, v_ordre
      from public.chapitre c
     where c.id = new.chapitre_id;

    -- Rang du chapitre (1 = tout premier) : combien de chapitres de la même
    -- (classe, matiere) ont un `ordre` <= le sien. `ordre` étant unique par
    -- (classe, matiere), ce compte est sans ex aequo possible.
    select count(*)
      into v_rang
      from public.chapitre c
     where c.classe_id  = v_classe
       and c.matiere_id = v_matiere
       and c.ordre     <= v_ordre;

    -- Dans les N premiers -> gratuit ; au-delà -> premium.
    new.premium := (v_rang > v_n);
  end if;

  return new;
end;
$$;


-- BEFORE : la valeur est fixée AVANT l'écriture de la ligne, donc toute valeur de
-- `premium` passée dans un INSERT/UPDATE est écrasée pour les types calculés — c'est
-- précisément ce qu'on veut (« jamais saisi à la main »). UPDATE est couvert aussi :
-- changer le type ou le chapitre d'une ressource recalcule son premium.
create trigger trg_ressource_definir_premium
  before insert or update on public.ressource
  for each row
  execute function public.ressource_definir_premium();

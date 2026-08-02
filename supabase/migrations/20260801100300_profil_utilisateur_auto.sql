-- =============================================================================
-- Migration 04 — Création automatique du profil `utilisateur`
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase)
-- Date : 2026-08-01
--
-- Contexte (décision d.6 du 01/08/2026) : la table `utilisateur` n'a PAS de policy
-- INSERT (migration 03). Il faut donc un autre mécanisme pour créer la ligne de
-- profil au moment où un compte est créé. C'est le patron standard Supabase :
-- un trigger sur `auth.users` qui insère la ligne miroir dans `public.utilisateur`.
--
-- `security definer` : la fonction s'exécute avec les droits de SON PROPRIÉTAIRE
-- (postgres), qui contourne le RLS. C'est ce qui lui permet d'insérer dans
-- `public.utilisateur` alors même qu'aucune policy INSERT n'existe pour l'élève.
-- C'est volontaire et sûr : la fonction ne fait qu'UNE chose, insérer l'id du
-- nouveau compte — elle ne peut pas servir à autre chose.
-- =============================================================================


create or replace function public.gerer_nouvel_utilisateur()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  -- Profil minimal : juste l'id (= auth.users.id). classe_id et serie restent NULL ;
  -- l'élève les renseignera plus tard via la policy `utilisateur_maj_de_soi`.
  insert into public.utilisateur (id)
  values (new.id);
  return new;
end;
$$;


-- AFTER INSERT : le profil est créé juste après que le compte auth existe.
create trigger trg_creer_profil_utilisateur
  after insert on auth.users
  for each row
  execute function public.gerer_nouvel_utilisateur();

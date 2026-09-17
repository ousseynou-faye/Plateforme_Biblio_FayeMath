-- =============================================================================
-- Migration 10 — Fonction de suppression de compte par l'élève (RTBF)
-- FayeMath Academy — Phase 5, étape 29, lot « Suppression de compte » (Lot 1)
-- Date : 2026-09-17
--
-- POURQUOI (bloquant publication + conformité) :
--   - Google Play EXIGE, pour toute app permettant de créer un compte, un chemin
--     de suppression DANS l'app (+ une URL web, faite à l'étape 30).
--   - La loi sénégalaise 2008-12 consacre le droit à la suppression des données.
--   Constat d'audit (étape 29) : `utilisateur` n'avait AUCUNE policy DELETE, et
--   l'app ne peut supprimer ni `auth.users` (réservé admin) ni `abonnement`
--   (SELECT seul) — donc rien ne permettait à l'élève de partir. Cette fonction
--   ouvre ce chemin, sans jamais mettre de `service_role` dans l'app.
--
-- COMMENT (option B validée le 17/09) :
--   `security definer` : la fonction s'exécute avec les droits de son PROPRIÉTAIRE
--   (le rôle qui applique la migration), pas ceux de l'appelant. Elle supprime la
--   ligne `auth.users` du SEUL appelant — `auth.uid()`, jamais un paramètre —, et
--   la CASCADE de la migration 01 efface tout le reste :
--       auth.users --(on delete cascade)--> utilisateur
--                                            --> progression, telechargement, abonnement
--   Décision de rétention (17/09) : on efface TOUT, abonnement compris (le paiement
--   en ligne est en pause ; à revoir à l'étape 27 si une archive comptable devient
--   nécessaire). Pas de table d'archive ici.
--
--   Le nettoyage de l'APPAREIL (fichiers PDF, cache Drift, coffre chiffré) n'est
--   PAS du ressort du serveur : il est fait côté app dans le même geste (Lot 2).
--
-- ⚠️ À VÉRIFIER SUR L'INSTANCE APRÈS `supabase db push` (sinon repli option C,
--    Edge Function) : le propriétaire de la fonction doit pouvoir SUPPRIMER dans
--    le schéma `auth`. Test rapide (éditeur SQL, en postgres) :
--       select has_table_privilege('postgres', 'auth.users', 'DELETE');
--    -> attendu `true`. Si `false`, un `delete from auth.users` lèvera 42501 :
--       on bascule alors sur une Edge Function utilisant l'API Auth Admin.
--
-- SÉCURITÉ :
--   - `set search_path = ''` + tout est schéma-qualifié (anti-détournement de
--     search_path sur une fonction security definer).
--   - Droit d'exécution RETIRÉ à `public`/`anon`, ACCORDÉ au seul `authenticated`.
--   - Un élève ne peut supprimer QUE son propre compte : la cible vient de
--     `auth.uid()`, il n'y a aucun paramètre à forger.
-- =============================================================================

create or replace function public.supprimer_mon_compte()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  -- Appel sans session (anon / jeton absent) : on ne touche personne.
  if v_uid is null then
    raise exception 'Aucun utilisateur connecte : suppression impossible'
      using errcode = '28000';
  end if;

  -- Supprime le compte d'authentification de l'appelant. La cascade (migration 01)
  -- efface derriere : utilisateur -> progression, telechargement, abonnement.
  delete from auth.users where id = v_uid;
end;
$$;

comment on function public.supprimer_mon_compte() is
  'Suppression de compte par l''eleve lui-meme (droit a l''effacement, loi 2008-12 '
  '+ exigence Google Play). security definer : supprime la ligne auth.users du seul '
  'appelant (auth.uid()), la cascade de la migration 01 efface le reste. Ne prend '
  'aucun parametre : impossible de viser le compte d''un autre.';

-- Verrouillage des droits d'appel : seul un eleve CONNECTE peut l'invoquer.
revoke all on function public.supprimer_mon_compte() from public;
revoke all on function public.supprimer_mon_compte() from anon;
grant execute on function public.supprimer_mon_compte() to authenticated;

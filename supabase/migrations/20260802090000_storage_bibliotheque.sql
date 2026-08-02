-- =============================================================================
-- Migration 06 — Bucket Storage « bibliotheque » + policy d'accès
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase), Lot D
-- Date : 2026-08-02
--
-- Portée : STRUCTURE UNIQUEMENT. On crée le bucket (privé) et sa policy de
-- lecture. On N'UPLOADE AUCUN fichier — le bucket est vide à la fin. La
-- migration réelle des 77 PDF de `assets/` est une tâche séparée, non planifiée.
--
-- Règle d'accès (décisions du Lot D, 02/08/2026) :
--   - Bucket PRIVÉ : aucun accès par URL publique, tout passe par cette policy.
--   - Téléchargement réservé aux comptes CONNECTÉS (`to authenticated`). Le
--     visiteur `anon` garde la lecture du CATALOGUE (policies migration 03) mais
--     n'a AUCUN accès au bucket. -> point 4 tranché : compte requis pour tout
--     téléchargement, gratuit compris.
--   - Parmi les connectés : ressource NON premium -> accès direct ;
--     ressource premium -> accès seulement si un abonnement actif existe.
--   - Abonnement actif = date_fin >= current_date (déjà la règle de la migration 01).
--
-- Lien fichier <-> ressource : `ressource.chemin_storage` = `name` (chemin de
-- l'objet dans le bucket), convention {classe}/{matiere}/{chapitre}/{type}.pdf.
--
-- NB RLS : `storage.objects` a déjà le RLS activé par défaut chez Supabase — on
-- ne le réactive pas (table possédée par le rôle Storage). On crée seulement la
-- policy. Aucune policy d'écriture n'est créée : INSERT/UPDATE/DELETE restent donc
-- interdits pour `anon`/`authenticated` — seul `service_role` (Ousseynou, en local)
-- déposera le contenu plus tard.
-- =============================================================================


-- 1. Le bucket, privé. Idempotent (ne casse pas si la migration est rejouée).
insert into storage.buckets (id, name, public)
values ('bibliotheque', 'bibliotheque', false)
on conflict (id) do nothing;


-- 2. Policy de LECTURE (téléchargement) sur les objets du bucket.
--    Empêche concrètement :
--      - un visiteur sans compte de télécharger quoi que ce soit (to authenticated) ;
--      - un élève connecté SANS abonnement de télécharger un corrigé premium ;
--    Autorise :
--      - tout élève connecté à télécharger un cours/résumé/révision gratuit ;
--      - un élève avec abonnement actif à télécharger n'importe quelle ressource.
create policy "bibliotheque_lecture_gratuit_ou_abonne"
on storage.objects
for select
to authenticated
using (
  bucket_id = 'bibliotheque'
  and exists (
    -- La ressource correspondant à ce fichier (lecture publique en migration 03).
    select 1
    from public.ressource r
    where r.chemin_storage = storage.objects.name
      and (
        -- soit elle est gratuite,
        r.premium = false
        -- soit l'élève a un abonnement actif. Cette sous-requête est elle-même
        -- filtrée par le RLS de `abonnement` : elle ne voit que les abonnements
        -- de l'utilisateur courant. Le `where` explicite dit la même chose.
        or exists (
          select 1
          from public.abonnement a
          where a.utilisateur_id = (select auth.uid())
            and a.date_fin >= current_date
        )
      )
  )
);

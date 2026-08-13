-- =============================================================================
-- Migration 07 — Catalogue RÉEL : les 7 classes + 2 matières
-- FayeMath Academy — Lot 0, étape 14 (Écran choix classe / série / matière)
-- Date : 2026-08-13
--
-- Portée : DONNÉES DE RÉFÉRENCE (catalogue), pas de contenu pédagogique.
--   - On insère les 7 classes officielles (6e … Terminale) et les 2 matières
--     (Mathématiques, Physique-chimie). Source : GLOSSAIRE.md §1-2 et
--     SPECIFICATIONS_V2 §3.2. Ce sont des faits fixes du programme sénégalais,
--     indépendants de l'avancement du contenu : la règle GLOSSAIRE §1
--     « on n'invente jamais un chapitre » vise les CHAPITRES, pas ces 2 tables.
--   - On NE crée AUCUN chapitre ni ressource : le contenu (les 77 fiches de
--     6e Maths, puis les autres classes) est le sujet de l'étape 18, hors périmètre.
--
-- Remplace le SEED DE TEST de la migration 05 (`20260801100400_seed_test.sql`).
-- On NE MODIFIE JAMAIS une migration déjà appliquée : le nettoyage du seed se
-- fait ici, dans une nouvelle migration.
--
-- /!\ Suppression de données de test vérifiée EN DIRECT le 13/08/2026 sur le
-- projet lié (SQL Editor, contexte service_role qui contourne le RLS) avant
-- d'écrire le moindre DELETE :
--     progression_sur_test   = 2   (créées pendant la preuve RLS de l'étape 9)
--     telechargement_sur_test = 2
--     nb_chapitres_test      = 3
--     nb_ressources_test     = 7   (6 rattachées à un chapitre + 1 sujet_examen)
-- => l'ordre de suppression doit purger d'abord les données élève de test, sinon
--    violation de clé étrangère (progression.chapitre_id, telechargement.ressource_id
--    n'ont pas de ON DELETE CASCADE).
--
-- Identifiants FIXES et reconnaissables (même principe que le seed) : le cache
-- Drift local et la future migration des chapitres (étape 18) référenceront ces
-- UUID sans avoir à capturer des valeurs générées.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Nettoyage du seed de test (migration 05) — ordre des dépendances
--    Ciblé sur les seuls identifiants du seed : classe '1111…', matiere '2222…'
--    et ce qui en dépend. N'affecte aucune autre ligne.
-- -----------------------------------------------------------------------------

-- 1.a Données élève de test qui accrochent le catalogue de test (branche 2).
delete from public.telechargement
 where ressource_id in (
   select id from public.ressource
   where chapitre_id in (
           select id from public.chapitre
           where classe_id = '11111111-1111-1111-1111-111111111111'
         )
      or classe_id = '11111111-1111-1111-1111-111111111111'   -- sujet_examen de test
 );

delete from public.progression
 where chapitre_id in (
   select id from public.chapitre
   where classe_id = '11111111-1111-1111-1111-111111111111'
 );

-- 1.b Catalogue de test lui-même (ressources -> chapitres -> matiere/classe).
delete from public.ressource
 where chapitre_id in (
         select id from public.chapitre
         where classe_id = '11111111-1111-1111-1111-111111111111'
       )
    or classe_id = '11111111-1111-1111-1111-111111111111';

delete from public.chapitre
 where classe_id = '11111111-1111-1111-1111-111111111111';

delete from public.matiere
 where id = '22222222-2222-2222-2222-222222222222';

delete from public.classe
 where id = '11111111-1111-1111-1111-111111111111';


-- -----------------------------------------------------------------------------
-- 2. Les 7 classes réelles
--    `cycle` : college | lycee (valeurs ASCII, cf. CHECK migration 01)
--    `ordre` : ordre d'affichage 6e -> Terminale (SPECIFICATIONS_V2 §3.2)
--    La règle « quelle série / quelles matières » NE vit PAS ici : elle est une
--    règle métier pure (domain/usecases/, étape 14), déduite du cycle + du nom.
-- -----------------------------------------------------------------------------
insert into public.classe (id, nom, cycle, ordre) values
  ('c1a55e00-0000-0000-0000-000000000006', '6e',        'college', 1),
  ('c1a55e00-0000-0000-0000-000000000005', '5e',        'college', 2),
  ('c1a55e00-0000-0000-0000-000000000004', '4e',        'college', 3),
  ('c1a55e00-0000-0000-0000-000000000003', '3e',        'college', 4),
  ('c1a55e00-0000-0000-0000-000000000002', '2nde',      'lycee',   5),
  ('c1a55e00-0000-0000-0000-000000000011', '1ère',      'lycee',   6),
  ('c1a55e00-0000-0000-0000-000000000012', 'Terminale', 'lycee',   7);


-- -----------------------------------------------------------------------------
-- 3. Les 2 matières réelles
--    Libellés d'affichage (avec accents) ; le vocabulaire figé est dans GLOSSAIRE.
-- -----------------------------------------------------------------------------
insert into public.matiere (id, nom) values
  ('ba71e2e0-0000-0000-0000-000000000001', 'Mathématiques'),
  ('ba71e2e0-0000-0000-0000-000000000002', 'Physique-chimie');


-- =============================================================================
-- Vérification attendue (à lancer après application, SQL Editor) :
--
--   select nom, cycle, ordre from public.classe order by ordre;
--     -> 6e, 5e, 4e, 3e, 2nde, 1ère, Terminale  (cycles college x4, lycee x3)
--   select nom from public.matiere order by nom;
--     -> Mathématiques, Physique-chimie
--   select count(*) from public.chapitre;     -> 0  (aucun contenu, normal)
--   select count(*) from public.ressource;    -> 0
--   -- plus aucune ligne « (test) » :
--   select count(*) from public.classe  where nom like '%(test)%';   -> 0
--   select count(*) from public.matiere where nom like '%(test)%';   -> 0
-- =============================================================================

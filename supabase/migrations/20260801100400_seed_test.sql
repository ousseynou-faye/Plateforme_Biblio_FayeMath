-- =============================================================================
-- Migration 05 — Données de TEST (seed)
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase)
-- Date : 2026-08-01
--
-- /!\ DONNÉES DE TEST, PAS LE CATALOGUE RÉEL /!\
-- Seul but : permettre le test à deux comptes du Lot C (une `progression` doit
-- pouvoir pointer vers un chapitre existant) ET vérifier « à l'œil » que le trigger
-- `premium` (migration 02) fait bien son travail.
--
-- Ce n'est PAS le programme officiel : les titres sont des placeholders neutres
-- (règle GLOSSAIRE §1 « on n'invente jamais un chapitre » — elle vise le contenu
-- publié, pas une fixture de test). Quand le vrai catalogue 6e Maths sera importé
-- (tâche séparée, non planifiée), ces lignes seront à retirer ou réconcilier.
--
-- Identifiants fixes et reconnaissables pour pouvoir référencer les lignes entre
-- elles sans avoir à capturer des UUID générés.
-- =============================================================================


-- 1 classe + 1 matière ---------------------------------------------------------
insert into public.classe (id, nom, cycle, ordre) values
  ('11111111-1111-1111-1111-111111111111', '6e (test)', 'college', 1);

insert into public.matiere (id, nom) values
  ('22222222-2222-2222-2222-222222222222', 'Mathématiques (test)');


-- 3 chapitres, `ordre` 1 / 2 / 3 ----------------------------------------------
-- Avec N = 2, les exercices des chapitres d'ordre 1 et 2 seront GRATUITS,
-- ceux du chapitre d'ordre 3 seront PREMIUM. C'est ce qu'on vérifie plus bas.
insert into public.chapitre (id, classe_id, matiere_id, numero, titre, strate, ordre) values
  ('33333333-3333-3333-3333-333333333301', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 1, 'Chapitre de test 1', 'Activités Numériques', 1),
  ('33333333-3333-3333-3333-333333333302', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 2, 'Chapitre de test 2', 'Activités Numériques', 2),
  ('33333333-3333-3333-3333-333333333303', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 3, 'Chapitre de test 3', 'Activités Géométriques', 3);


-- Ressources -------------------------------------------------------------------
-- On insère volontairement des valeurs `premium` FAUSSES pour prouver que le
-- trigger les corrige : ce qui est écrit ci-dessous n'est PAS ce qui sera stocké.
insert into public.ressource
  (chapitre_id, classe_id, matiere_id, type, titre, taille_octets, premium, ordre)
values
  -- Chapitre 1 (ordre 1) -> exercices GRATUITS
  ('33333333-3333-3333-3333-333333333301', null, null, 'cours',     'Cours ch.1',     250000, true,  1),  -- trigger -> false
  ('33333333-3333-3333-3333-333333333301', null, null, 'exercices', 'Exercices ch.1', 120000, true,  2),  -- trigger -> false (rang 1 <= 2)
  ('33333333-3333-3333-3333-333333333301', null, null, 'corrige',   'Corrigé ch.1',   130000, false, 3),  -- trigger -> true

  -- Chapitre 2 (ordre 2) -> exercices GRATUITS
  ('33333333-3333-3333-3333-333333333302', null, null, 'exercices', 'Exercices ch.2', 118000, true,  1),  -- trigger -> false (rang 2 <= 2)

  -- Chapitre 3 (ordre 3) -> exercices PREMIUM
  ('33333333-3333-3333-3333-333333333303', null, null, 'exercices', 'Exercices ch.3', 121000, false, 1),  -- trigger -> true (rang 3 > 2)
  ('33333333-3333-3333-3333-333333333303', null, null, 'revision',  'Révision ch.3',   45000, true,  2);  -- trigger -> false (revision toujours gratuit)

-- 1 sujet_examen -> rattaché à (classe, matiere), PAS à un chapitre.
-- Son premium est fixé À LA MAIN (ici true) et le trigger NE LE TOUCHE PAS
-- (sortie anticipée). C'est aussi ce qui valide la contrainte de rattachement.
insert into public.ressource
  (chapitre_id, classe_id, matiere_id, type, titre, taille_octets, premium, ordre)
values
  (null, '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'sujet_examen', 'Sujet type (test)', 300000, true, 1);


-- =============================================================================
-- Vérification attendue du trigger premium (à lancer après application) :
--
--   select titre, type, premium from public.ressource order by titre;
--
-- Résultat attendu :
--   Cours ch.1          | cours        | f
--   Corrigé ch.1        | corrige      | t
--   Exercices ch.1      | exercices    | f
--   Exercices ch.2      | exercices    | f
--   Exercices ch.3      | exercices    | t   <- premium car 3e chapitre (> N=2)
--   Révision ch.3       | revision     | f
--   Sujet type (test)   | sujet_examen | t   <- valeur MANUELLE, non recalculée
-- =============================================================================

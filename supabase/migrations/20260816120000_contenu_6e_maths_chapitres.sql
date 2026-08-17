-- =============================================================================
-- Migration 08 — Contenu reel : les 19 chapitres de 6e Mathematiques
-- FayeMath Academy — Lot 0, etape 18 (Mise en ligne du contenu reel), Lot B
-- Date : 2026-08-16
--
-- Portee : les 19 chapitres de 6e Maths, cote SERVEUR (le contenu vit sur le
-- serveur, pas dans l'app — 03 - Technique et Pilotage.pdf §2.3). Les 77
-- ressources et le depot des PDF dans Storage sont des taches separees (Lots C
-- et D). Aucune donnee eleve, aucune RLS, aucun trigger touche ici.
--
-- S'appuie sur la migration 07 (catalogue reel) : les UUID FIXES de la classe 6e
-- et de la matiere Mathematiques sont repris tels quels, jamais regeneres.
--
-- ---------------------------------------------------------------------------
-- Deux numerotations DISTINCTES, decidees avec Ousseynou le 16/08/2026 :
--   - `numero` = numero OFFICIEL du chapitre DANS SON BLOC (livret du Ministere,
--     GLOSSAIRE §1) : Activites Numeriques 1..10, Activites Geometriques 1..9.
--     C'est ce que l'eleve voit (« Chapitre 2 · Le cercle », comme son cahier).
--   - `ordre` = rang GLOBAL 1..19 sur toute la matiere (Numerique 1..10 puis
--     Geometrique 11..19). C'est LUI qui pilote le tri d'affichage
--     (regroupement_par_strate) ET la regle des N premiers chapitres gratuits en
--     exercices (trigger migration 02). Il reste globalement unique.
--
-- Consequence : deux chapitres peuvent porter le meme `numero` (Num 1 et Geo 1)
-- au sein d'une meme (classe, matiere). La contrainte d'unicite de la migration
-- 01 — unique (classe_id, matiere_id, numero) — l'interdisait. On l'ASSOUPLIT
-- ci-dessous pour la rendre unique PAR STRATE. C'est le seul changement de
-- structure de cette etape ; il ne touche ni RLS, ni trigger, ni donnees eleve.
-- La base locale Drift (miroir hors-ligne) n'a aucune unicite sur numero : rien
-- a y changer.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. Assouplir l'unicite de `numero` : unique PAR STRATE, plus par matiere seule.
--
--    `nulls not distinct` (Postgres 15+, cas de Supabase) : deux chapitres SANS
--    strate (colonne nullable) restent soumis a l'unicite du numero — sinon des
--    NULL distincts laisseraient passer des doublons. En 6e Maths chaque chapitre
--    a une strate, mais la regle doit rester correcte pour les classes futures.
--
--    L'unique (classe_id, matiere_id, ordre) de la migration 01 est CONSERVEE
--    telle quelle : `ordre` doit rester globalement unique (base du tri et de la
--    regle premium).
--
--    Auto-controle : si le `drop` ci-dessous ne visait pas le bon nom, l'ancienne
--    contrainte survivrait et le 11e chapitre (Geo, numero 1) echouerait a
--    l'insertion — un echec BRUYANT, jamais une corruption silencieuse.
-- -----------------------------------------------------------------------------
alter table public.chapitre
  drop constraint if exists chapitre_classe_id_matiere_id_numero_key;

alter table public.chapitre
  add constraint chapitre_classe_matiere_strate_numero_key
  unique nulls not distinct (classe_id, matiere_id, strate, numero);


-- -----------------------------------------------------------------------------
-- 2. Les 19 chapitres. UUID fixes (memes conventions que le catalogue,
--    migration 07) : suffixe = `ordre` global sur 2 chiffres, pour un lien lisible
--    et stable avec les ressources du Lot C.
--
--    classe_id  = 6e            : c1a55e00-0000-0000-0000-000000000006 (migration 07)
--    matiere_id = Mathematiques : ba71e2e0-0000-0000-0000-000000000001 (migration 07)
--
--    `titre` : contenu reel, AVEC accents (comme la maquette et la demo validee).
--    `strate` : libelle affiche a l'eleve -> SANS accents (CONVENTIONS §1), rendu
--               « ACTIVITES NUMERIQUES / GEOMETRIQUES » par l'en-tete (toUpperCase).
-- -----------------------------------------------------------------------------
insert into public.chapitre (id, classe_id, matiere_id, numero, titre, strate, ordre) values
  -- Activites Numeriques : numero 1..10, ordre 1..10
  ('c6a17e00-0000-0000-0000-000000000001', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  1, 'Nombres décimaux arithmétiques',              'Activites numeriques',  1),
  ('c6a17e00-0000-0000-0000-000000000002', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  2, 'Addition des nombres décimaux arithmétiques', 'Activites numeriques',  2),
  ('c6a17e00-0000-0000-0000-000000000003', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  3, 'Soustraction des nombres décimaux arithmétiques', 'Activites numeriques',  3),
  ('c6a17e00-0000-0000-0000-000000000004', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  4, 'Rangement des nombres décimaux arithmétiques', 'Activites numeriques',  4),
  ('c6a17e00-0000-0000-0000-000000000005', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  5, 'Multiplication des nombres décimaux arithmétiques', 'Activites numeriques',  5),
  ('c6a17e00-0000-0000-0000-000000000006', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  6, 'Division des nombres décimaux arithmétiques', 'Activites numeriques',  6),
  ('c6a17e00-0000-0000-0000-000000000007', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  7, 'Organisation d''un calcul',                   'Activites numeriques',  7),
  ('c6a17e00-0000-0000-0000-000000000008', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  8, 'Proportionnalité',                            'Activites numeriques',  8),
  ('c6a17e00-0000-0000-0000-000000000009', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  9, 'Nombres décimaux relatifs',                   'Activites numeriques',  9),
  ('c6a17e00-0000-0000-0000-000000000010', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001', 10, 'Repérage',                                    'Activites numeriques', 10),
  -- Activites Geometriques : numero 1..9, ordre 11..19
  ('c6a17e00-0000-0000-0000-000000000011', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  1, 'Introduction à la géométrie',                 'Activites geometriques', 11),
  ('c6a17e00-0000-0000-0000-000000000012', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  2, 'Le cercle',                                   'Activites geometriques', 12),
  ('c6a17e00-0000-0000-0000-000000000013', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  3, 'Droites perpendiculaires et droites parallèles', 'Activites geometriques', 13),
  ('c6a17e00-0000-0000-0000-000000000014', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  4, 'Symétrie orthogonale',                        'Activites geometriques', 14),
  ('c6a17e00-0000-0000-0000-000000000015', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  5, 'Les angles',                                  'Activites geometriques', 15),
  ('c6a17e00-0000-0000-0000-000000000016', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  6, 'Les polygones',                               'Activites geometriques', 16),
  ('c6a17e00-0000-0000-0000-000000000017', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  7, 'Les aires',                                   'Activites geometriques', 17),
  ('c6a17e00-0000-0000-0000-000000000018', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  8, 'La géométrie dans l''espace',                 'Activites geometriques', 18),
  ('c6a17e00-0000-0000-0000-000000000019', 'c1a55e00-0000-0000-0000-000000000006', 'ba71e2e0-0000-0000-0000-000000000001',  9, 'Repérage sur la sphère',                      'Activites geometriques', 19);


-- -----------------------------------------------------------------------------
-- 3. Verification (a lancer a la main apres `supabase db push`).
--
--    a) 19 chapitres, dont 10 Numeriques et 9 Geometriques :
--       select strate, count(*) from public.chapitre
--        where classe_id = 'c1a55e00-0000-0000-0000-000000000006'
--        group by strate order by strate;
--       -> Activites geometriques | 9
--          Activites numeriques   | 10
--
--    b) numero repart bien a 1 dans chaque strate, ordre continu 1..19 :
--       select strate, numero, ordre, titre from public.chapitre
--        where classe_id = 'c1a55e00-0000-0000-0000-000000000006'
--        order by ordre;
--       -> ordre 1..10 = Numerique (numero 1..10), 11..19 = Geometrique (numero 1..9)
-- -----------------------------------------------------------------------------

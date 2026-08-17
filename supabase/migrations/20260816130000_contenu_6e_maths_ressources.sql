-- =============================================================================
-- Migration 09 — Contenu reel : les 77 ressources de 6e Mathematiques
-- FayeMath Academy — Lot 0, etape 18 (Mise en ligne du contenu reel), Lot C
-- Date : 2026-08-16
--
-- Portee : les 77 documents des 19 chapitres (migration 08), cote SERVEUR.
-- Le DEPOT des PDF dans le bucket Storage est une tache separee (Lot D) : ici on
-- ne fait qu'enregistrer les LIGNES (metadonnees + chemin attendu du fichier).
--
-- Source : manifests/manifeste_6e_maths.csv (77 lignes). Mapping des types
-- (colonne `type_document` -> valeur figee GLOSSAIRE §3) :
--   Cours -> cours | Methodes -> resume | Exercices -> exercices
--   Corrige -> corrige | Revision -> revision
-- `Methodes` n'apparait qu'une fois (chapitre 1 Numerique).
--
-- REGLES RESPECTEES :
--   - `premium` N'EST JAMAIS fourni : la colonne est absente de l'INSERT, le
--     trigger `trg_ressource_definir_premium` (migration 02) le calcule depuis
--     (type, ordre du chapitre). Voir le controle croise en fin de fichier.
--   - `classe_id`/`matiere_id` absents -> NULL : impose par la contrainte
--     `ressource_rattachement_coherent` pour tout type autre que sujet_examen
--     (ils se lisent via le chapitre).
--   - `version` absent -> defaut 1.
--   - `ordre` (interne au chapitre) = ordre de lecture pedagogique :
--     cours 1, resume 2, exercices 3, corrige 4, revision 5. Les deux repos
--     offline-first trient dessus (chapitre_repository / ressource_repository).
--   - `chemin_storage` = 6e/mathematiques/{strate}/{numero}/{type}.pdf, ou
--     {strate} = numerique|geometrique, {numero} = numero OFFICIEL par bloc
--     (migration 08) sur 2 chiffres. Globalement unique (numero seul ne l'est
--     plus), stable, et A REPRENDRE TEL QUEL au depot des fichiers (Lot D) : la
--     policy Storage (migration 06) compare `storage.objects.name` a ce chemin
--     au caractere pres.
--   - `taille_octets` = taille REELLE du PDF compresse (-68,5%) depose dans
--     Storage (Lot D), et NON la taille d'origine de la colonne du manifeste
--     (qui date d'avant la compression). La taille annoncee a l'eleve doit etre
--     celle du fichier qu'il telecharge (contrat hors-ligne, GLOSSAIRE §6 regle 2).
--   - `titre` : contenu reel, AVEC accents (repris du libelle du manifeste).
--
-- chapitre_id : UUID fixes de la migration 08 (suffixe = ordre global 01..19).
-- =============================================================================

insert into public.ressource (chapitre_id, type, titre, taille_octets, chemin_storage, ordre) values
  -- === Activites Numeriques ===
  -- Chapitre 1 (Num, numero 1) — Nombres decimaux arithmetiques (5 documents)
  ('c6a17e00-0000-0000-0000-000000000001', 'cours',     'Cours - Nombres décimaux arithmétiques',     59631, '6e/mathematiques/numerique/01/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000001', 'resume',    'Méthodes - Nombres décimaux arithmétiques',  47877, '6e/mathematiques/numerique/01/resume.pdf',    2),
  ('c6a17e00-0000-0000-0000-000000000001', 'exercices', 'Exercices - Nombres décimaux arithmétiques', 39048, '6e/mathematiques/numerique/01/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000001', 'corrige',   'Corrigé - Nombres décimaux arithmétiques',   50847, '6e/mathematiques/numerique/01/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000001', 'revision',  'Révision - Nombres décimaux arithmétiques',  44370, '6e/mathematiques/numerique/01/revision.pdf',  5),
  -- Chapitre 2 (Num, numero 2) — Addition des nombres decimaux arithmetiques
  ('c6a17e00-0000-0000-0000-000000000002', 'cours',     'Cours - Addition des nombres décimaux arithmétiques',     52615, '6e/mathematiques/numerique/02/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000002', 'exercices', 'Exercices - Addition des nombres décimaux arithmétiques', 35176, '6e/mathematiques/numerique/02/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000002', 'corrige',   'Corrigé - Addition des nombres décimaux arithmétiques',   49222, '6e/mathematiques/numerique/02/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000002', 'revision',  'Révision - Addition des nombres décimaux arithmétiques',  42837, '6e/mathematiques/numerique/02/revision.pdf',  5),
  -- Chapitre 3 (Num, numero 3) — Soustraction des nombres decimaux arithmetiques
  ('c6a17e00-0000-0000-0000-000000000003', 'cours',     'Cours - Soustraction des nombres décimaux arithmétiques',     58663, '6e/mathematiques/numerique/03/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000003', 'exercices', 'Exercices - Soustraction des nombres décimaux arithmétiques', 38584, '6e/mathematiques/numerique/03/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000003', 'corrige',   'Corrigé - Soustraction des nombres décimaux arithmétiques',   53167, '6e/mathematiques/numerique/03/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000003', 'revision',  'Révision - Soustraction des nombres décimaux arithmétiques',  47797, '6e/mathematiques/numerique/03/revision.pdf',  5),
  -- Chapitre 4 (Num, numero 4) — Rangement des nombres decimaux arithmetiques
  ('c6a17e00-0000-0000-0000-000000000004', 'cours',     'Cours - Rangement des nombres décimaux arithmétiques',     42465, '6e/mathematiques/numerique/04/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000004', 'exercices', 'Exercices - Rangement des nombres décimaux arithmétiques', 38423, '6e/mathematiques/numerique/04/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000004', 'corrige',   'Corrigé - Rangement des nombres décimaux arithmétiques',   49893, '6e/mathematiques/numerique/04/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000004', 'revision',  'Révision - Rangement des nombres décimaux arithmétiques',  42271, '6e/mathematiques/numerique/04/revision.pdf',  5),
  -- Chapitre 5 (Num, numero 5) — Multiplication des nombres decimaux arithmetiques
  ('c6a17e00-0000-0000-0000-000000000005', 'cours',     'Cours - Multiplication des nombres décimaux arithmétiques',     57247, '6e/mathematiques/numerique/05/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000005', 'exercices', 'Exercices - Multiplication des nombres décimaux arithmétiques', 35598, '6e/mathematiques/numerique/05/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000005', 'corrige',   'Corrigé - Multiplication des nombres décimaux arithmétiques',   47617, '6e/mathematiques/numerique/05/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000005', 'revision',  'Révision - Multiplication des nombres décimaux arithmétiques',  43720, '6e/mathematiques/numerique/05/revision.pdf',  5),
  -- Chapitre 6 (Num, numero 6) — Division des nombres decimaux arithmetiques
  ('c6a17e00-0000-0000-0000-000000000006', 'cours',     'Cours - Division des nombres décimaux arithmétiques',     47053, '6e/mathematiques/numerique/06/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000006', 'exercices', 'Exercices - Division des nombres décimaux arithmétiques', 35990, '6e/mathematiques/numerique/06/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000006', 'corrige',   'Corrigé - Division des nombres décimaux arithmétiques',   49246, '6e/mathematiques/numerique/06/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000006', 'revision',  'Révision - Division des nombres décimaux arithmétiques',  44890, '6e/mathematiques/numerique/06/revision.pdf',  5),
  -- Chapitre 7 (Num, numero 7) — Organisation d'un calcul
  ('c6a17e00-0000-0000-0000-000000000007', 'cours',     'Cours - Organisation d''un calcul',     49068, '6e/mathematiques/numerique/07/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000007', 'exercices', 'Exercices - Organisation d''un calcul', 38172, '6e/mathematiques/numerique/07/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000007', 'corrige',   'Corrigé - Organisation d''un calcul',   51390, '6e/mathematiques/numerique/07/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000007', 'revision',  'Révision - Organisation d''un calcul',  42573, '6e/mathematiques/numerique/07/revision.pdf',  5),
  -- Chapitre 8 (Num, numero 8) — Proportionnalite
  ('c6a17e00-0000-0000-0000-000000000008', 'cours',     'Cours - Proportionnalité',     46474, '6e/mathematiques/numerique/08/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000008', 'exercices', 'Exercices - Proportionnalité', 36600, '6e/mathematiques/numerique/08/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000008', 'corrige',   'Corrigé - Proportionnalité',   45833, '6e/mathematiques/numerique/08/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000008', 'revision',  'Révision - Proportionnalité',  45923, '6e/mathematiques/numerique/08/revision.pdf',  5),
  -- Chapitre 9 (Num, numero 9) — Nombres decimaux relatifs
  ('c6a17e00-0000-0000-0000-000000000009', 'cours',     'Cours - Nombres décimaux relatifs',     52857, '6e/mathematiques/numerique/09/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000009', 'exercices', 'Exercices - Nombres décimaux relatifs', 42363, '6e/mathematiques/numerique/09/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000009', 'corrige',   'Corrigé - Nombres décimaux relatifs',   55610, '6e/mathematiques/numerique/09/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000009', 'revision',  'Révision - Nombres décimaux relatifs',  46217, '6e/mathematiques/numerique/09/revision.pdf',  5),
  -- Chapitre 10 (Num, numero 10) — Reperage
  ('c6a17e00-0000-0000-0000-000000000010', 'cours',     'Cours - Repérage',     51448, '6e/mathematiques/numerique/10/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000010', 'exercices', 'Exercices - Repérage', 40807, '6e/mathematiques/numerique/10/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000010', 'corrige',   'Corrigé - Repérage',   47730, '6e/mathematiques/numerique/10/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000010', 'revision',  'Révision - Repérage',  47520, '6e/mathematiques/numerique/10/revision.pdf',  5),
  -- === Activites Geometriques ===
  -- Chapitre 11 (Geo, numero 1) — Introduction a la geometrie
  ('c6a17e00-0000-0000-0000-000000000011', 'cours',     'Cours - Introduction à la géométrie',     45463, '6e/mathematiques/geometrique/01/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000011', 'exercices', 'Exercices - Introduction à la géométrie', 40749, '6e/mathematiques/geometrique/01/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000011', 'corrige',   'Corrigé - Introduction à la géométrie',   52977, '6e/mathematiques/geometrique/01/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000011', 'revision',  'Révision - Introduction à la géométrie',  45473, '6e/mathematiques/geometrique/01/revision.pdf',  5),
  -- Chapitre 12 (Geo, numero 2) — Le cercle
  ('c6a17e00-0000-0000-0000-000000000012', 'cours',     'Cours - Le cercle',     48925, '6e/mathematiques/geometrique/02/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000012', 'exercices', 'Exercices - Le cercle', 37746, '6e/mathematiques/geometrique/02/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000012', 'corrige',   'Corrigé - Le cercle',   53290, '6e/mathematiques/geometrique/02/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000012', 'revision',  'Révision - Le cercle',  45663, '6e/mathematiques/geometrique/02/revision.pdf',  5),
  -- Chapitre 13 (Geo, numero 3) — Droites perpendiculaires et droites paralleles
  ('c6a17e00-0000-0000-0000-000000000013', 'cours',     'Cours - Droites perpendiculaires et droites parallèles',     45162, '6e/mathematiques/geometrique/03/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000013', 'exercices', 'Exercices - Droites perpendiculaires et droites parallèles', 41608, '6e/mathematiques/geometrique/03/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000013', 'corrige',   'Corrigé - Droites perpendiculaires et droites parallèles',   51456, '6e/mathematiques/geometrique/03/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000013', 'revision',  'Révision - Droites perpendiculaires et droites parallèles',  45979, '6e/mathematiques/geometrique/03/revision.pdf',  5),
  -- Chapitre 14 (Geo, numero 4) — Symetrie orthogonale
  ('c6a17e00-0000-0000-0000-000000000014', 'cours',     'Cours - Symétrie orthogonale',     50795, '6e/mathematiques/geometrique/04/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000014', 'exercices', 'Exercices - Symétrie orthogonale', 42243, '6e/mathematiques/geometrique/04/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000014', 'corrige',   'Corrigé - Symétrie orthogonale',   57099, '6e/mathematiques/geometrique/04/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000014', 'revision',  'Révision - Symétrie orthogonale',  46998, '6e/mathematiques/geometrique/04/revision.pdf',  5),
  -- Chapitre 15 (Geo, numero 5) — Les angles
  ('c6a17e00-0000-0000-0000-000000000015', 'cours',     'Cours - Les angles',     51127, '6e/mathematiques/geometrique/05/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000015', 'exercices', 'Exercices - Les angles', 40389, '6e/mathematiques/geometrique/05/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000015', 'corrige',   'Corrigé - Les angles',   53799, '6e/mathematiques/geometrique/05/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000015', 'revision',  'Révision - Les angles',  47105, '6e/mathematiques/geometrique/05/revision.pdf',  5),
  -- Chapitre 16 (Geo, numero 6) — Les polygones
  ('c6a17e00-0000-0000-0000-000000000016', 'cours',     'Cours - Les polygones',     61023, '6e/mathematiques/geometrique/06/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000016', 'exercices', 'Exercices - Les polygones', 43044, '6e/mathematiques/geometrique/06/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000016', 'corrige',   'Corrigé - Les polygones',   51331, '6e/mathematiques/geometrique/06/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000016', 'revision',  'Révision - Les polygones',  43719, '6e/mathematiques/geometrique/06/revision.pdf',  5),
  -- Chapitre 17 (Geo, numero 7) — Les aires
  ('c6a17e00-0000-0000-0000-000000000017', 'cours',     'Cours - Les aires',     50254, '6e/mathematiques/geometrique/07/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000017', 'exercices', 'Exercices - Les aires', 39983, '6e/mathematiques/geometrique/07/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000017', 'corrige',   'Corrigé - Les aires',   49263, '6e/mathematiques/geometrique/07/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000017', 'revision',  'Révision - Les aires',  44110, '6e/mathematiques/geometrique/07/revision.pdf',  5),
  -- Chapitre 18 (Geo, numero 8) — La geometrie dans l'espace
  ('c6a17e00-0000-0000-0000-000000000018', 'cours',     'Cours - La géométrie dans l''espace',     57072, '6e/mathematiques/geometrique/08/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000018', 'exercices', 'Exercices - La géométrie dans l''espace', 38901, '6e/mathematiques/geometrique/08/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000018', 'corrige',   'Corrigé - La géométrie dans l''espace',   50838, '6e/mathematiques/geometrique/08/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000018', 'revision',  'Révision - La géométrie dans l''espace',  43457, '6e/mathematiques/geometrique/08/revision.pdf',  5),
  -- Chapitre 19 (Geo, numero 9) — Reperage sur la sphere
  ('c6a17e00-0000-0000-0000-000000000019', 'cours',     'Cours - Repérage sur la sphère',     43402, '6e/mathematiques/geometrique/09/cours.pdf',     1),
  ('c6a17e00-0000-0000-0000-000000000019', 'exercices', 'Exercices - Repérage sur la sphère', 37557, '6e/mathematiques/geometrique/09/exercices.pdf', 3),
  ('c6a17e00-0000-0000-0000-000000000019', 'corrige',   'Corrigé - Repérage sur la sphère',   45396, '6e/mathematiques/geometrique/09/corrige.pdf',   4),
  ('c6a17e00-0000-0000-0000-000000000019', 'revision',  'Révision - Repérage sur la sphère',  44344, '6e/mathematiques/geometrique/09/revision.pdf',  5);


-- -----------------------------------------------------------------------------
-- Verification (a lancer a la main apres `supabase db push`).
--
--   a) 77 ressources au total, dont exactement 1 resume :
--      select type, count(*) from public.ressource group by type order by type;
--      -> cours 19 | corrige 19 | exercices 19 | resume 1 | revision 19
--
--   b) premium CALCULE PAR LE TRIGGER (jamais copie du manifeste). Resultat
--      attendu : 41 gratuit / 36 premium.
--      select premium, count(*) from public.ressource group by premium;
--      -> false (gratuit) 41 | true (premium) 36
--      Detail : cours(19) + resume(1) + revision(19) = 39 toujours gratuits ;
--               exercices gratuits UNIQUEMENT sur les 2 chapitres d'ordre global
--               1 et 2 (Numerique 1 et 2) = +2 ; corrige(19) + 17 exercices = 36 premium.
--
--   c) CONTROLE CROISE avec le manifeste (colonne `statut` : 43 gratuit / 34 premium).
--      Ecart ATTENDU de 2 documents : le manifeste applique la regle des 2 premiers
--      chapitres PAR STRATE (Num 1-2 ET Geo 1-2), le trigger l'applique PAR MATIERE
--      (regle figee CLAUDE.md §4, N=2 global). Consequence assumee : les exercices
--      de Geometrie chapitres 1 et 2 (Introduction a la geometrie, Le cercle)
--      passent en PREMIUM. La source de verite VIVANTE est le trigger, pas le
--      manifeste. Si un autre ecart apparait, le signaler (ne pas corriger en base).
-- -----------------------------------------------------------------------------

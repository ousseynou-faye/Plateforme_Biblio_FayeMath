-- =============================================================================
-- Migration 01 — Schéma des 8 tables (V1)
-- FayeMath Academy — Lot 0, étape 9 (Backend Supabase)
-- Date : 2026-08-01
--
-- Portée : STRUCTURE UNIQUEMENT.
--   - Pas de RLS ici  -> migration 03 (Lot C).
--   - Pas de trigger `premium` ici -> migration 02 (Lot B, trigger).
--   - Pas de données de seed ici -> migration séparée (Lot C, données de test).
--
-- Principe : les contraintes (check, unique, clés étrangères) sont là pour
-- rendre une incohérence IMPOSSIBLE à écrire, pas seulement improbable.
-- Vocabulaire figé : voir docs/GLOSSAIRE.md. Règle gratuit/premium : CLAUDE.md §4.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- 1. classe — le niveau scolaire (6e … Terminale)
--    `cycle` : college | lycee (valeurs ASCII, le libellé accentué est à l'affichage)
--    `ordre` : ordre d'affichage (6e avant 5e, etc.)
-- -----------------------------------------------------------------------------
create table public.classe (
  id     uuid     primary key default gen_random_uuid(),
  nom    text     not null unique,
  cycle  text     not null check (cycle in ('college', 'lycee')),
  ordre  smallint not null
);


-- -----------------------------------------------------------------------------
-- 2. matiere — Mathématiques, physique-chimie
-- -----------------------------------------------------------------------------
create table public.matiere (
  id   uuid primary key default gen_random_uuid(),
  nom  text not null unique
);


-- -----------------------------------------------------------------------------
-- 3. chapitre — l'unité de travail, objet du suivi de progression
--    `numero` : numéro officiel du chapitre (livret du Ministère)
--    `ordre`  : ordre d'affichage ; c'est LUI qui sert au « N premiers chapitres »
--               de la règle premium (décision d.3 du 01/08/2026)
--    `strate` : regroupement d'affichage (« Activités Numériques »…), nullable ;
--               gardé en colonne texte plutôt qu'en 9e table (ARCHITECTURE §6)
-- -----------------------------------------------------------------------------
create table public.chapitre (
  id          uuid     primary key default gen_random_uuid(),
  classe_id   uuid     not null references public.classe(id),
  matiere_id  uuid     not null references public.matiere(id),
  numero      smallint not null,
  titre       text     not null,
  strate      text,
  ordre       smallint not null,
  unique (classe_id, matiere_id, numero),
  -- `ordre` sans ambiguïté au sein d'une (classe, matiere) : c'est la base
  -- de la règle des N premiers chapitres gratuits (décision d.3 du 01/08/2026).
  unique (classe_id, matiere_id, ordre)
);


-- -----------------------------------------------------------------------------
-- 4. ressource — un document publié (les 8 types de docs/GLOSSAIRE.md §3)
--
--    Rattachement (décision d.1 du 01/08/2026) :
--      - sujet_examen  -> appartient à une CLASSE + MATIÈRE, pas à un chapitre
--                         (dossiers « 99 - », hors kit de chapitre)
--      - tous les autres -> appartiennent à un CHAPITRE ; leur classe/matière
--                           se lisent via ce chapitre (pas de doublon de colonne)
--    La contrainte `ressource_rattachement_coherent` impose exactement cela.
--
--    `taille_octets` : en octets (décision d.2) ; l'affichage en Ko/Mo est du ressort de l'app
--    `premium`       : DÉRIVÉ, jamais saisi à la main -> posé par le trigger (migration 02).
--                      Défaut `false` en attendant que le trigger le calcule.
--    `chemin_storage`: chemin dans le bucket (Lot D) ; nullable tant que Storage est vide
-- -----------------------------------------------------------------------------
create table public.ressource (
  id             uuid     primary key default gen_random_uuid(),
  chapitre_id    uuid     references public.chapitre(id),
  classe_id      uuid     references public.classe(id),
  matiere_id     uuid     references public.matiere(id),
  type           text     not null check (type in (
                    'cours', 'resume', 'exercices', 'corrige', 'revision',
                    'evaluation', 'corrige_evaluation', 'sujet_examen'
                  )),
  titre          text     not null,
  taille_octets  integer  not null,
  premium        boolean  not null default false,
  version        integer  not null default 1,
  chemin_storage text,
  ordre          smallint not null,

  -- Un seul document de chaque type par chapitre. En Postgres, deux chapitre_id NULL
  -- (les sujet_examen) ne sont jamais considérés égaux : aucun effet sur la banque
  -- d'examens, la contrainte ne joue que pour les ressources rattachées à un chapitre.
  unique (chapitre_id, type),

  constraint ressource_rattachement_coherent check (
    (   type =  'sujet_examen'
        and chapitre_id is null
        and classe_id   is not null
        and matiere_id  is not null )
    or
    (   type <> 'sujet_examen'
        and chapitre_id is not null
        and classe_id   is null
        and matiere_id  is null )
  )
);


-- -----------------------------------------------------------------------------
-- 5. utilisateur — le profil de l'élève, adossé à auth.users de Supabase
--    `id` = auth.users(id) : un profil par compte, supprimé si le compte l'est
--    `classe_id` nullable : l'élève peut ne pas encore avoir choisi sa classe
--    `serie` nullable : demandée seulement en 1ère/Terminale (GLOSSAIRE §2)
--       NB : `check (serie in (...))` autorise déjà NULL (un CHECK passe sur NULL)
-- -----------------------------------------------------------------------------
create table public.utilisateur (
  id         uuid        primary key references auth.users(id) on delete cascade,
  classe_id  uuid        references public.classe(id),
  serie      text        check (serie in ('L', 'S1', 'S2')),
  cree_le    timestamptz not null default now()
);


-- -----------------------------------------------------------------------------
-- 6. progression — l'état d'un chapitre pour un élève (4 états, GLOSSAIRE §5)
--    unique (utilisateur_id, chapitre_id) : une seule ligne d'état par chapitre
--    `date_maj` : sert au « la modif la plus récente l'emporte » de la synchro
--                 (sémantique horloge client/serveur à préciser en Phase 3, hors périmètre ici)
-- -----------------------------------------------------------------------------
create table public.progression (
  id              uuid        primary key default gen_random_uuid(),
  utilisateur_id  uuid        not null references public.utilisateur(id) on delete cascade,
  chapitre_id     uuid        not null references public.chapitre(id),
  etat            text        not null check (etat in ('a_faire', 'en_cours', 'fait', 'a_revoir')),
  date_maj        timestamptz not null default now(),
  unique (utilisateur_id, chapitre_id)
);


-- -----------------------------------------------------------------------------
-- 7. telechargement — ce qu'un élève a enregistré sur son téléphone
--    unique (utilisateur_id, ressource_id) : pas de doublon de téléchargement
-- -----------------------------------------------------------------------------
create table public.telechargement (
  id                  uuid        primary key default gen_random_uuid(),
  utilisateur_id      uuid        not null references public.utilisateur(id) on delete cascade,
  ressource_id        uuid        not null references public.ressource(id),
  date_telechargement timestamptz not null default now(),
  unique (utilisateur_id, ressource_id)
);


-- -----------------------------------------------------------------------------
-- 8. abonnement — la formule payée par l'élève
--    `formule` : mensuel | trimestriel | annee_scolaire (tarif verrouillé 31/07/2026)
--    Pas de colonne `statut` : actif/expiré se DÉDUIT de (date_fin >= aujourd'hui)
--    `abonnement_periode_valide` : une fin ne peut pas précéder un début
-- -----------------------------------------------------------------------------
create table public.abonnement (
  id                 uuid primary key default gen_random_uuid(),
  utilisateur_id     uuid not null references public.utilisateur(id) on delete cascade,
  formule            text not null check (formule in ('mensuel', 'trimestriel', 'annee_scolaire')),
  date_debut         date not null,
  date_fin           date not null,
  reference_paiement text,

  constraint abonnement_periode_valide check (date_fin >= date_debut)
);

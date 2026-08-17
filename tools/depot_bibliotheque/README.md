# Depot de la bibliotheque dans Storage — Lot D (etape 18)

Outil ponctuel qui televerse les **77 PDF de 6e Mathematiques** depuis
`assets/bibliotheque/6e-maths/` vers le bucket Storage **`bibliotheque`**.

Ce n'est **pas** du code de l'application (rien sous `lib/`, aucune dependance
Flutter) : c'est un utilitaire d'administration a lancer une fois, depuis ton
poste, avec ton compte.

## Ce qu'il fait

Pour chacune des 77 lignes du manifeste (`manifests/manifeste_6e_maths.csv`) :

- **source** : le PDF dans `assets/bibliotheque/6e-maths/...` ;
- **cible** : `6e/mathematiques/{strate}/{numero}/{type}.pdf`
  (ex. `6e/mathematiques/numerique/01/cours.pdf`).

La regle de calcul de la cible est **la meme que la migration 09** (Lot C) :
les deux derivent du **meme manifeste**, donc `ressource.chemin_storage` en base
et le `name` de l'objet dans le bucket coincident **au caractere pres** — c'est
ce que la policy de lecture (migration 06) exige.

## Securite — a lire avant de lancer

- Le televersement exige la cle **`service_role`** de Supabase (elle seule a le
  droit d'ecrire dans le bucket). Cette cle **ne doit jamais** :
  - etre ecrite dans un fichier du depot (ni ce script, ni `config/dev.json`) ;
  - etre committee ;
  - etre utilisee cote application.
- Le script la lit **uniquement** depuis la variable d'environnement
  `SUPABASE_SERVICE_ROLE_KEY`, que tu poses dans ton shell le temps du depot.
- Ou trouver la cle : Dashboard Supabase -> **Project Settings -> API ->
  `service_role` (secret)**. Copie-la dans le shell, pas dans un fichier.

## Utilisation — en deux temps

### 1. Verifier (rien n'est envoye)

```powershell
cd tools\depot_bibliotheque
./deposer_bibliotheque.ps1
```

Attendu : **77 documents**, `0` manquant, et une taille totale d'environ
**3,4 Mo** (les PDF compresses -68,5%). Chaque ligne affiche le chemin cible et
la taille reelle du fichier ; un fichier manquant affiche aussi sa source.

Note : la migration 09 enregistre la **taille reelle de ces fichiers compresses**
(pas la colonne `taille_octets` du manifeste, qui date d'avant la compression) —
c'est la taille annoncee a l'eleve avant telechargement.

### 2. Televerser

```powershell
$env:SUPABASE_URL = 'https://xxxxxxxx.supabase.co'
$env:SUPABASE_SERVICE_ROLE_KEY = '...ta cle service_role...'
./deposer_bibliotheque.ps1 -Upload
```

Attendu : `Televerses avec succes : 77`, `Echecs d'upload : 0`. Le script est
rejouable (`x-upsert` actif) : le relancer remplace les objets, sans doublon.

Quand tu as fini, ferme le shell (ou `Remove-Item Env:SUPABASE_SERVICE_ROLE_KEY`)
pour ne pas laisser la cle en memoire de session.

## Verifier apres coup

- Dashboard Supabase -> **Storage -> bibliotheque** : l'arborescence
  `6e/mathematiques/numerique|geometrique/NN/` doit contenir les 77 fichiers.
- Prerequis : les migrations 08 (chapitres) et 09 (ressources) doivent avoir ete
  poussees **avant** (`supabase db push`) — sinon les lignes `ressource` qui
  autorisent la lecture des fichiers n'existent pas encore.

## Prerequis techniques

- **PowerShell** (deja present sous Windows) — aucune dependance a installer.
- Les 77 PDF presents dans `assets/bibliotheque/6e-maths/` (zone rouge, non
  modifiee par cet outil : il ne fait que **lire** ces fichiers).

<#
.SYNOPSIS
  Depose les 77 PDF de 6e Mathematiques dans le bucket Storage `bibliotheque`
  (FayeMath Academy - Lot 0, etape 18, Lot D).

.DESCRIPTION
  Lit `manifests/manifeste_6e_maths.csv` et, pour chaque document, calcule :
    - son chemin SOURCE dans `assets/bibliotheque/6e-maths/...` ;
    - son chemin CIBLE dans le bucket : 6e/mathematiques/{strate}/{numero}/{type}.pdf.
  La regle de calcul de la cible est EXACTEMENT celle de la migration 09 (Lot C),
  toutes deux derivees du meme manifeste : le lien ressource <-> fichier est donc
  coherent au caractere pres, sans quoi la policy Storage (migration 06) le
  refuserait.

  SECURITE (SECURITY.md, ZONES-PROTEGEES section 2.2) : ce fichier ne contient
  AUCUN secret. La cle `service_role` est lue depuis la variable d'environnement
  SUPABASE_SERVICE_ROLE_KEY, jamais ecrite ici, jamais committee, jamais placee
  dans config/dev.json (qui ne contient que la cle ANON, publique).

.PARAMETER Upload
  ABSENT (defaut) : mode VERIFICATION. Affiche les 77 correspondances (chemin
  cible + taille reelle du fichier), controle que chaque source existe, et
  N'ENVOIE RIEN. A lancer en premier.
  PRESENT : televerse reellement. Necessite SUPABASE_URL et
  SUPABASE_SERVICE_ROLE_KEY dans l'environnement. `x-upsert` est actif : rejouer
  le script remplace les objets, sans doublon.

.EXAMPLE
  # 1) Verifier d'abord (rien n'est envoye) :
  ./deposer_bibliotheque.ps1

.EXAMPLE
  # 2) Puis televerser (cle collee dans le SHELL, jamais dans un fichier) :
  $env:SUPABASE_URL = 'https://xxxxxxxx.supabase.co'
  $env:SUPABASE_SERVICE_ROLE_KEY = '...ta cle service_role...'
  ./deposer_bibliotheque.ps1 -Upload
#>
[CmdletBinding()]
param([switch]$Upload)

$ErrorActionPreference = 'Stop'

# Racine du depot = deux niveaux au-dessus de ce script (tools/depot_bibliotheque/).
$racine     = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$manifeste  = Join-Path $racine 'manifests\manifeste_6e_maths.csv'
$assetsBase = Join-Path $racine 'assets\bibliotheque\6e-maths'
$bucket     = 'bibliotheque'

if (-not (Test-Path -LiteralPath $manifeste)) {
  throw "Manifeste introuvable : $manifeste"
}

# En mode upload, exiger la configuration AVANT de commencer, avec un message clair.
if ($Upload) {
  if ([string]::IsNullOrWhiteSpace($env:SUPABASE_URL)) {
    throw "Variable SUPABASE_URL absente. Ex : `$env:SUPABASE_URL = 'https://xxxx.supabase.co'"
  }
  if ([string]::IsNullOrWhiteSpace($env:SUPABASE_SERVICE_ROLE_KEY)) {
    throw "Variable SUPABASE_SERVICE_ROLE_KEY absente. Colle ta cle service_role dans le shell (jamais dans un fichier)."
  }
}

# --- Regles de mapping (identiques a la migration 09) -------------------------

# strate du manifeste ("Numerique"/"Geometrique", accentue) -> slug ASCII.
# On teste la 1re lettre : robuste quelle que soit la lecture des accents.
function Get-StrateSlug([string]$strate) {
  if ($strate.StartsWith('N')) { return 'numerique' }
  if ($strate.StartsWith('G')) { return 'geometrique' }
  throw "Strate inconnue : '$strate'"
}

# type_document du manifeste -> valeur figee (GLOSSAIRE section 3). Teste sur des
# prefixes ASCII pour ne pas dependre des accents (Methodes, Corrige, Revision).
function Get-TypeValue([string]$doc) {
  if ($doc.StartsWith('Cou')) { return 'cours' }      # Cours
  if ($doc.StartsWith('M'))   { return 'resume' }     # Methodes
  if ($doc.StartsWith('E'))   { return 'exercices' }  # Exercices
  if ($doc.StartsWith('Cor')) { return 'corrige' }    # Corrige
  if ($doc.StartsWith('R'))   { return 'revision' }   # Revision
  throw "Type de document inconnu : '$doc'"
}

# --- Lecture du manifeste (de-BOM defensif, accents preserves) ----------------

$contenu = Get-Content -LiteralPath $manifeste -Raw -Encoding UTF8
$contenu = $contenu.TrimStart([char]0xFEFF)   # de-BOM defensif (ASCII pur)
$lignes  = $contenu | ConvertFrom-Csv

$total = 0; $manquants = 0; $octetsTotal = 0; $ok = 0; $echecs = 0
$cibles = @{}   # detection de collision de chemin cible

foreach ($l in $lignes) {
  $total++

  # Source : tail du chemin du manifeste apres "6e - Maths\", replante sous assets/.
  $tail = $l.chemin_source -replace '^.*?6e - Maths\\', ''
  $src  = Join-Path $assetsBase $tail

  # Cible dans le bucket (meme regle que la migration 09).
  $slug = Get-StrateSlug $l.strate
  $type = Get-TypeValue  $l.type_document
  $num  = $l.chapitre_numero.Trim()          # deja sur 2 chiffres dans le manifeste
  $dest = "6e/mathematiques/$slug/$num/$type.pdf"

  if ($cibles.ContainsKey($dest)) {
    throw "Collision de chemin cible : $dest (deux documents pointent au meme endroit)"
  }
  $cibles[$dest] = $true

  $existe       = Test-Path -LiteralPath $src
  $tailleDisque = if ($existe) { (Get-Item -LiteralPath $src).Length } else { 0 }
  if (-not $existe) { $manquants++ } else { $octetsTotal += $tailleDisque }

  $etat = if (-not $existe) { 'MANQUANT' } else { 'ok' }
  Write-Host ("[{0,-8}] {1,-46} {2,8} o" -f $etat, $dest, $tailleDisque)
  if (-not $existe) { Write-Host ("            source: {0}" -f $src) }

  if ($Upload -and $existe) {
    # POST /storage/v1/object/{bucket}/{path} - upload binaire, upsert actif.
    $uri = "$($env:SUPABASE_URL.TrimEnd('/'))/storage/v1/object/$bucket/$dest"
    try {
      Invoke-WebRequest -Method Post -Uri $uri -InFile $src -ContentType 'application/pdf' `
        -Headers @{
          Authorization = "Bearer $($env:SUPABASE_SERVICE_ROLE_KEY)"
          'x-upsert'    = 'true'
        } | Out-Null
      $ok++
    } catch {
      $echecs++
      Write-Warning "Echec upload $dest : $($_.Exception.Message)"
    }
  }
}

Write-Host ""
Write-Host "=== Resume ==="
Write-Host "Documents dans le manifeste            : $total (attendu 77)"
Write-Host "Fichiers source manquants sur disque   : $manquants"
Write-Host ("Taille totale a televerser             : {0:N0} o (~{1:N1} Mo)" -f $octetsTotal, ($octetsTotal/1MB))
if ($Upload) {
  Write-Host "Televerses avec succes                 : $ok"
  Write-Host "Echecs d'upload                        : $echecs"
  if ($echecs -eq 0 -and $manquants -eq 0) {
    Write-Host "-> Depot complet. Verifie ensuite dans le dashboard (bucket bibliotheque)."
  }
} else {
  Write-Host "(mode VERIFICATION - rien n'a ete envoye ; relance avec -Upload pour televerser)"
}

# Publishes the classroom games to GitHub Pages (repo Ahmed-3wad/math-games).
#   powershell -File D:\EduGames\site\deploy.ps1 ["commit message"]
# Self-tests the engine, rebuilds each game, copies its site/ folder in, commits and pushes. Every device that
# has the game installed picks up the new version the next time it opens online.
param([string]$Message = "Update games")
$ErrorActionPreference = "Stop"
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
$here = $PSScriptRoot
$root = Split-Path $here

# published folder (kept as "grade4-millionaire" so installed home-screen apps keep working) -> game folder
$games = @{ "grade4-millionaire" = "games\millionaire" }
foreach ($slug in $games.Keys) {
  $dir = Join-Path $root $games[$slug]
  node (Join-Path $root "engine\test_engine.js") 300
  if ($LASTEXITCODE) { throw "engine self-test failed - nothing was published" }
  node (Join-Path $dir "_source\build.js")
  if ($LASTEXITCODE) { throw "build failed: $slug" }
  $dest = Join-Path $here $slug
  if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
  Copy-Item -Recurse (Join-Path $dir "site") $dest
}

Push-Location $here
try {
  git add -A
  git diff --cached --quiet
  if ($LASTEXITCODE) { git commit -m $Message; git push origin main } else { "nothing changed" }
} finally { Pop-Location }

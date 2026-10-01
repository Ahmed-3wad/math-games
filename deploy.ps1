# Publishes the app (home screen + all ready games) to GitHub Pages (repo Ahmed-3wad/math-games).
#   powershell -File D:\EduGames\site\deploy.ps1 ["commit message"]
# Self-tests the engine, builds every game, assembles the app into this folder, commits and pushes.
# Every device that has the app installed picks up the new version the next time it opens online.
param([string]$Message = "Update app")
$ErrorActionPreference = "Stop"
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
$here = $PSScriptRoot
$root = Split-Path $here

node (Join-Path $root "engine\test_engine.js") 300
if ($LASTEXITCODE) { throw "engine self-test failed - nothing was published" }
foreach ($game in Get-ChildItem (Join-Path $root "games") -Directory) {
  node (Join-Path $game.FullName "_source\build.js")
  if ($LASTEXITCODE) { throw "build failed: $($game.Name)" }
}
node (Join-Path $root "app\build.js")
if ($LASTEXITCODE) { throw "app build failed" }

Push-Location $here
try {
  git add -A
  git diff --cached --quiet
  if ($LASTEXITCODE) { git commit -m $Message; git push origin main } else { "nothing changed" }
} finally { Pop-Location }

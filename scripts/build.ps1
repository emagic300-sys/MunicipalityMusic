$ErrorActionPreference='Stop'; $root=Split-Path $PSScriptRoot -Parent; Set-Location $root
& (Join-Path $PSScriptRoot 'import_events.ps1')
$json=Get-Content -Raw 'src/data/events.json'; Set-Content -Encoding utf8 'src/data/events.js' ("window.EVENTS="+$json+";")
$dist=Join-Path $root 'dist'; if(Test-Path $dist){Remove-Item $dist -Recurse -Force}; New-Item -ItemType Directory "$dist/src/data","$dist/src/styles" -Force|Out-Null
Copy-Item index.html $dist; Copy-Item src/app.js "$dist/src"; Copy-Item src/data/events.js "$dist/src/data"; Copy-Item src/styles/app.css "$dist/src/styles"
$zip=Join-Path $root 'EJ-North-Jersey-Summer-Events-Planner.zip'; if(Test-Path $zip){Remove-Item $zip -Force}; Compress-Archive -Path index.html,package.json,README.md,src,scripts,tests,EJ_North_Jersey_Lifestyle_Database_2026_FIXED.xlsx -DestinationPath $zip
Write-Host "Production build: $dist"; Write-Host "ZIP: $zip"

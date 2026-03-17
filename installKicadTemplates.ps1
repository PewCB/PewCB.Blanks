# KiCad user templates folder - auto-detected, falls back to hardcoded path
$hardcodedTemplatesDir = "C:\Users\ruddy\Documents\KiCad\9.0\template"

$kicadDocsBase = Join-Path $env:USERPROFILE "Documents\KiCad"
$templatesDir = $hardcodedTemplatesDir

if (Test-Path $kicadDocsBase) {
    $candidate = Get-ChildItem -Path $kicadDocsBase -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "template") } |
        Sort-Object Name -Descending |
        Select-Object -First 1

    if ($candidate) {
        $templatesDir = Join-Path $candidate.FullName "template"
    }
}

Write-Host "KiCad templates folder: $templatesDir"

if (-not (Test-Path $templatesDir)) {
    Write-Error "Templates folder not found: $templatesDir"
    exit 1
}

$rootDir = $PSScriptRoot

Get-ChildItem -Path $rootDir -Directory -Filter "PewCB.*" | ForEach-Object {
    $blank = $_
    $kicadSrc = Join-Path $blank.FullName "Kicad"

    if (-not (Test-Path $kicadSrc)) {
        Write-Host "[$($blank.Name)] No Kicad subfolder, skipping."
        return
    }

    $dest = Join-Path $templatesDir $blank.Name

    if (Test-Path $dest) {
        Remove-Item $dest -Recurse -Force
        Write-Host "[$($blank.Name)] Removed existing template."
    }

    Copy-Item -Path $kicadSrc -Destination $dest -Recurse
    Write-Host "[$($blank.Name)] Installed to $dest"
}

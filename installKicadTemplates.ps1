# KiCad user templates folders - auto-detected, falls back to hardcoded path
$hardcodedTemplatesDir = "C:\Users\ruddy\Documents\KiCad\10.0\template"

$kicadDocsBase = Join-Path $env:USERPROFILE "Documents\KiCad"
$templatesDirs = @()

if (Test-Path $kicadDocsBase) {
    $templatesDirs = Get-ChildItem -Path $kicadDocsBase -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName "template") } |
        Sort-Object {
            $version = $null
            if ([Version]::TryParse($_.Name, [ref]$version)) {
                $version
            }
            else {
                [Version]"0.0"
            }
        } |
        ForEach-Object { Join-Path $_.FullName "template" }
}

if (-not $templatesDirs) {
    $templatesDirs = @($hardcodedTemplatesDir)
}

$templatesDirs = $templatesDirs | Where-Object { Test-Path $_ } | Select-Object -Unique

if (-not $templatesDirs) {
    Write-Error "No KiCad templates folders found under $kicadDocsBase or at fallback path $hardcodedTemplatesDir"
    exit 1
}

Write-Host "KiCad templates folders detected:"
$templatesDirs | ForEach-Object { Write-Host " - $_" }

$rootDir = $PSScriptRoot

Get-ChildItem -Path $rootDir -Directory -Filter "PewCB.*" | ForEach-Object {
    $blank = $_
    $kicadSrc = Join-Path $blank.FullName "Kicad"

    if (-not (Test-Path $kicadSrc)) {
        Write-Host "[$($blank.Name)] No Kicad subfolder, skipping."
        return
    }

    foreach ($templatesDir in $templatesDirs) {
        $dest = Join-Path $templatesDir $blank.Name

        if (Test-Path $dest) {
            Remove-Item $dest -Recurse -Force
            Write-Host "[$($blank.Name)] Removed existing template from $templatesDir"
        }

        Copy-Item -Path $kicadSrc -Destination $dest -Recurse
        Write-Host "[$($blank.Name)] Installed to $dest"
    }
}

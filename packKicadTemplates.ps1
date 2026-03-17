$rootDir = $PSScriptRoot
$zipPath = Join-Path $rootDir "PewCB.KicadTemplates.zip"
$tempDir = Join-Path $env:TEMP "PewCB.KicadTemplates.pack"

# Clean up temp staging dir
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Copy installer script
Copy-Item -Path (Join-Path $rootDir "installKicadTemplates.ps1") -Destination $tempDir

# Copy only Kicad subfolders for each blank
Get-ChildItem -Path $rootDir -Directory -Filter "PewCB.*" | ForEach-Object {
    $blank = $_
    $kicadSrc = Join-Path $blank.FullName "Kicad"

    if (-not (Test-Path $kicadSrc)) {
        Write-Host "[$($blank.Name)] No Kicad subfolder, skipping."
        return
    }

    $destBlank = Join-Path $tempDir $blank.Name
    $destKicad = Join-Path $destBlank "Kicad"
    New-Item -ItemType Directory -Path $destKicad | Out-Null
    Copy-Item -Path "$kicadSrc\*" -Destination $destKicad -Recurse
    Write-Host "[$($blank.Name)] Staged."
}

# Pack
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath
Remove-Item $tempDir -Recurse -Force

Write-Host "Created: $zipPath"

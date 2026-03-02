$rootDir = $PSScriptRoot

Get-ChildItem -Path $rootDir -Directory -Filter "PewCB.*" | ForEach-Object {
    $folder = $_
    $folderName = $folder.Name
    $descriptionFile = Join-Path $folder.FullName "description.txt"
    $appBlankGerbersDir = Join-Path $folder.FullName "AppBlankGerbers"

    $filesToAdd = @()

    if (Test-Path $descriptionFile) {
        $filesToAdd += $descriptionFile
    }

    if (Test-Path $appBlankGerbersDir) {
        $gbrFiles = Get-ChildItem -Path $appBlankGerbersDir -Filter "*.gbr"
        $filesToAdd += $gbrFiles.FullName
    }

    if ($filesToAdd.Count -eq 0) {
        Write-Host "[$folderName] No files to archive, skipping."
        return
    }

    $zipPath = Join-Path $rootDir "$folderName.zip"
    $blankPath = Join-Path $rootDir "$folderName.blank"

    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
    if (Test-Path $blankPath) { Remove-Item $blankPath -Force }

    Compress-Archive -Path $filesToAdd -DestinationPath $zipPath
    Rename-Item -Path $zipPath -NewName "$folderName.blank"

    Write-Host "[$folderName] Created $folderName.blank with $($filesToAdd.Count) file(s)."
}

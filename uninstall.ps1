$ErrorActionPreference = 'Stop'

$menuKeys = @(
    'HKCU:\Software\Classes\*\shell\CopyFilePath',
    'HKCU:\Software\Classes\Directory\shell\CopyFilePath'
)

foreach ($menuKey in $menuKeys) {
    if (Test-Path -LiteralPath $menuKey) {
        Remove-Item -LiteralPath $menuKey -Recurse -Force
        Write-Host "Removed: $menuKey"
    }
}

Write-Host 'Done.'

$ErrorActionPreference = 'Stop'

$menuKey = 'HKCU:\Software\Classes\*\shell\CopyFilePath'

if (Test-Path -LiteralPath $menuKey) {
    Remove-Item -LiteralPath $menuKey -Recurse -Force
    Write-Host "Removed context menu item."
} else {
    Write-Host "Nothing to remove."
}

$ErrorActionPreference = 'Stop'

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsPath = Join-Path $projectDir 'CopyFilePath.vbs'

if (-not (Test-Path -LiteralPath $vbsPath)) {
    throw "CopyFilePath.vbs not found next to install.ps1: $vbsPath"
}

$menuName = '复制文件路径(&P)'
$cmdLine = "wscript.exe `"$vbsPath`" `"%1`""

$menuKeys = @(
    'HKCU:\Software\Classes\*\shell\CopyFilePath',
    'HKCU:\Software\Classes\Directory\shell\CopyFilePath'
)

foreach ($menuKey in $menuKeys) {
    New-Item -Path $menuKey -Force -Value $menuName | Out-Null
    New-Item -Path (Join-Path $menuKey 'command') -Force -Value $cmdLine | Out-Null
}

Write-Host "Installed for files and folders. Menu item: $menuName"
Write-Host "Launcher: $vbsPath"
Write-Host "Note: keep this folder in place; moving or deleting it will break the menu item."

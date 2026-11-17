$ErrorActionPreference = 'Stop'

$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$vbsPath = Join-Path $projectDir 'CopyFilePath.vbs'

if (-not (Test-Path -LiteralPath $vbsPath)) {
    throw "CopyFilePath.vbs not found next to install.ps1: $vbsPath"
}

$menuKey = 'HKCU:\Software\Classes\*\shell\CopyFilePath'
$cmdKey = Join-Path $menuKey 'command'
$cmdLine = "wscript.exe `"$vbsPath`" `"%1`""

New-Item -Path $menuKey -Force -Value '复制文件路径(&P)' | Out-Null
New-Item -Path $cmdKey -Force -Value $cmdLine | Out-Null

Write-Host "Installed. Menu item: 复制文件路径(&P)"
Write-Host "Launcher: $vbsPath"
Write-Host "Note: keep this folder in place; moving or deleting it will break the menu item."

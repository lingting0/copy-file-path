param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$EncodedPath
)

$ErrorActionPreference = 'Stop'

$bytes = [Convert]::FromBase64String($EncodedPath)
$path = [Text.Encoding]::UTF8.GetString($bytes)
Set-Clipboard -Value $path

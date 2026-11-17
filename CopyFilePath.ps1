$ErrorActionPreference = 'Stop'

$path = [Environment]::GetEnvironmentVariable('WB_CFP_TARGET')
if ([string]::IsNullOrEmpty($path)) {
    throw 'WB_CFP_TARGET is not set'
}

Set-Clipboard -Value $path

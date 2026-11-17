$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
if (!(Test-Path .env)) {
    $clave = [Guid]::NewGuid().ToString('N') + [Guid]::NewGuid().ToString('N')
    [IO.File]::WriteAllText((Join-Path $PWD '.env'), "POSTGRES_PASSWORD=$clave`nAPP_VERSION=1.0.0`nHTTP_PORT=8080`nGHCR_OWNER=`n")
    Write-Output '.env creado con una clave local aleatoria.'
}
if (!(Test-Path .git)) { & git init; if ($LASTEXITCODE -ne 0) { throw 'No se pudo inicializar Git' } }
Write-Output 'Preparado. No publiques .env. Los scripts siguientes requieren Docker Desktop en modo Linux.'

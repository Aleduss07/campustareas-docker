param([string]$Owner = 'aleduss07')
. "$PSScriptRoot/Comun.ps1"
$Owner = $Owner.ToLowerInvariant()
if ($Owner -notmatch '^[a-z0-9][a-z0-9-]*$') { throw 'Usuario GHCR invalido' }
# Login fuera del transcript: no guardar tokens ni contrasenas en evidencias.
Write-Output 'Usa tu autenticacion existente o introduce un PAT de GitHub con write:packages cuando Docker pida Password.'
Docker login ghcr.io -u $Owner
Start-Transcript -Path evidencias/reto-ghcr.log -Force
try {
    Docker tag campus-api:1.0.0 "ghcr.io/${Owner}/campus-api:1.0.0"
    Docker push "ghcr.io/${Owner}/campus-api:1.0.0"
} finally { Stop-Transcript }

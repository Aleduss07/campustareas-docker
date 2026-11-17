. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/reto-vulnerabilidades.log -Force
try {
    Docker scout cves campus-api:1.0.0
    Write-Output 'Guarda una CVE real del resultado, paquete, version afectada, version corregida y plan de actualizacion en INFORME.md. Si no hay hallazgos, registra ese resultado sin inventar una CVE.'
} finally { Stop-Transcript }

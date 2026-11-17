$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
New-Item -ItemType Directory -Force evidencias | Out-Null
if (!(Test-Path .env)) { throw 'Falta .env. Ejecuta primero scripts/Preparar.ps1.' }
Get-Content .env | ForEach-Object {
    if ($_ -match '^([A-Z_]+)=(.*)$') { [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process') }
}
$script:Base = "http://localhost:$($env:HTTP_PORT)/"
if (!$env:HTTP_PORT) { $script:Base = 'http://localhost:8080/' }
function Docker {
    & docker.exe @args
    if ($LASTEXITCODE -ne 0) { throw "Docker fallo ($LASTEXITCODE): $($args -join ' ')" }
}
function Esperar {
    for ($n = 0; $n -lt 60; $n++) {
        try { $r = Invoke-RestMethod "${script:Base}health/ready" -TimeoutSec 3; if ($r.status -eq 'ready') { return } } catch {}
        Start-Sleep -Seconds 2
    }
    throw 'La API no quedo lista en 120 segundos.'
}
function Api($Ruta, $Metodo = 'GET', $Datos = $null) {
    $p = @{ Uri = "${script:Base}$Ruta"; Method = $Metodo; TimeoutSec = 20 }
    if ($null -ne $Datos) { $p.ContentType = 'application/json'; $p.Body = [Text.Encoding]::UTF8.GetBytes(($Datos | ConvertTo-Json -Compress)) }
    Invoke-RestMethod @p
}
function Comprobar($Condicion, $Mensaje) { if (!$Condicion) { throw $Mensaje }; Write-Output "OK: $Mensaje" }
function Reparto([int]$Esperadas) {
    $replicas = @()
    1..30 | ForEach-Object {
        $r = Invoke-WebRequest "${script:Base}v1/info" -UseBasicParsing -DisableKeepAlive -TimeoutSec 15
        $dato = $r.Content | ConvertFrom-Json
        $replicas += $dato.replica
        Write-Output "$($r.StatusCode) $($r.Content) X-Upstream=$($r.Headers['X-Upstream'])"
    }
    Comprobar (@($replicas | Sort-Object -Unique).Count -eq $Esperadas) "Se observaron $Esperadas replicas distintas en 30 peticiones"
}

. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/reto-version.log -Force
$anterior = $env:APP_VERSION
try {
    Docker build -t campus-api:1.1.0 --build-arg APP_VERSION=1.1.0 ./api
    $env:APP_VERSION = '1.1.0'
    Docker compose up -d --build --wait
    # Si cambian las IP al recrear las replicas, renovar la resolucion de Nginx.
    Docker compose restart balanceador
    Esperar
    1..12 | ForEach-Object { $r = Api 'v1/info'; $r | ConvertTo-Json -Compress; Comprobar ($r.version -eq '1.1.0') 'Version 1.1.0 servida por el balanceador' }
    $contenido = (Get-Content .env -Raw) -replace '(?m)^APP_VERSION=.*$', 'APP_VERSION=1.1.0'
    [IO.File]::WriteAllText((Join-Path $PWD '.env'), $contenido)
} finally {
    $env:APP_VERSION = $anterior
    Stop-Transcript
}
Write-Output 'Se conservan ambas imagenes y .env queda configurado para 1.1.0.'

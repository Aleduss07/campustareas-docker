param([switch]$LeastConn)
. "$PSScriptRoot/Comun.ps1"
$archivos = @('-f', 'compose.yaml')
$nombre = '03-round-robin'
if ($LeastConn) { $archivos += @('-f', 'compose.least-conn.yaml'); $nombre = 'reto-least-conn' }
Start-Transcript -Path "evidencias/$nombre.log" -Force
try {
    Docker compose @archivos up -d --build --remove-orphans --wait
    # Recarga Nginx para aplicar la configuracion de balanceo.
    Docker compose @archivos exec -T balanceador nginx -t
    Docker compose @archivos exec -T balanceador nginx -s reload
    Docker compose @archivos ps
    Esperar
    Reparto 3
    try {
        Docker compose stop api2
        Reparto 2
        Docker compose logs balanceador --tail 20
    } finally { Docker compose start api2 }
    # Espera a que termine la exclusion temporal de la replica recuperada.
    Start-Sleep -Seconds 12
    $t = Api 'v1/tareas' POST @{ titulo = "Prueba compartida $nombre" }
    1..12 | ForEach-Object {
        $lista = @(Api 'v1/tareas')
        Comprobar ($lista.id -contains $t.id) 'Todas las lecturas incluyen la misma tarea'
    }
    Api 'v1/tareas' | ConvertTo-Json
    try {
        Docker compose stop api1 api3
        Reparto 1
        Write-Output 'El cliente web puede verificarse con una sola replica mediante scripts/08-Web.ps1.'
    } finally { Docker compose start api1 api3 }
} finally { Stop-Transcript }

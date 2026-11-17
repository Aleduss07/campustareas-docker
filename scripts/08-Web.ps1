. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/08-web.log -Force
try {
    Esperar
    $pagina = Invoke-WebRequest $script:Base -UseBasicParsing
    Comprobar ($pagina.StatusCode -eq 200 -and $pagina.Content.Contains('Mis entregas')) 'Cliente web servido por Nginx'
    Start-Process $script:Base
    Read-Host 'Crea una tarea desde el navegador y pulsa Enter aqui'
    Api 'v1/tareas' | ConvertTo-Json
    try {
        Docker compose stop api1 api3
        Reparto 1
        Read-Host 'Actualiza y crea otra tarea desde la web con una sola replica. Guarda captura en evidencias y pulsa Enter'
        Api 'v1/tareas' | ConvertTo-Json
    } finally { Docker compose start api1 api3 }
} finally { Stop-Transcript }

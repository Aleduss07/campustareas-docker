# Usa exclusivamente el proyecto de laboratorio campus-una; borra su volumen de prueba.
. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/02-persistencia.log -Force
try {
    Docker compose -f compose.una.yaml up -d --build --wait
    Docker compose -f compose.una.yaml ps
    Esperar
    $t = Api 'v1/tareas' POST @{ titulo = 'Informe de Docker'; fechaEntrega = '2026-11-27' }
    Api 'v1/tareas' | ConvertTo-Json
    Docker compose -f compose.una.yaml down
    Docker compose -f compose.una.yaml up -d --wait
    Esperar
    $lista = @(Api 'v1/tareas'); $lista | ConvertTo-Json
    Comprobar ($lista.id -contains $t.id) 'La tarea sobrevive a down'
    Docker compose -f compose.una.yaml down -v
    Docker compose -f compose.una.yaml up -d --wait
    Esperar
    $lista = @(Api 'v1/tareas'); ConvertTo-Json -InputObject $lista
    Comprobar ($lista.Count -eq 0) 'La lista queda vacia tras down -v'
} finally {
    Docker compose -f compose.una.yaml down
    Stop-Transcript
}

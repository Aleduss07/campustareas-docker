. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/04-analisis.log -Force
$temporal = Join-Path $PWD 'api-cache-prueba'
$creado = $false
try {
    Docker build --progress=plain -t campus-api:1.0.0 ./api
    # Aisla el cambio de codigo para comprobar la reutilizacion de dependencias.
    if (Test-Path $temporal) { throw 'Ya existe api-cache-prueba; revisar antes de continuar.' }
    New-Item -ItemType Directory $temporal | Out-Null
    $creado = $true
    Copy-Item api/package*.json,api/Dockerfile,api/.dockerignore $temporal
    Copy-Item api/src $temporal -Recurse
    Add-Content "$temporal/src/server.js" "`n// Prueba de cache: $([DateTime]::UtcNow.ToString('o'))"
    Docker build --progress=plain -t campus-api:cache ./api-cache-prueba
    Docker build -f api/Dockerfile.pesada -t campus-api:pesada ./api
    Docker images campus-api
    Docker image inspect campus-api:1.0.0 campus-api:pesada --format '{{.RepoTags}} bytes={{.Size}} usuario={{.Config.User}}'
    Docker run --rm --entrypoint id campus-api:1.0.0
} finally {
    # Elimina unicamente el contexto generado para la prueba de cache.
    $permitido = [IO.Path]::GetFullPath((Join-Path $PWD 'api-cache-prueba'))
    if ($creado -and (Test-Path $temporal) -and ([IO.Path]::GetFullPath($temporal) -eq $permitido) -and $permitido.StartsWith([IO.Path]::GetFullPath($PWD.Path) + [IO.Path]::DirectorySeparatorChar)) {
        Remove-Item -LiteralPath $temporal -Recurse -Force
    }
    Stop-Transcript
}

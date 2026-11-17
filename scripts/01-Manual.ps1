. "$PSScriptRoot/Comun.ps1"
Start-Transcript -Path evidencias/01-manual.log -Force
try {
    Docker version
    Docker compose version
    Docker build -t campus-api:1.0.0 ./api
    Docker images campus-api
    Docker history campus-api:1.0.0
    Docker network create campus-red
    try {
        Docker run -d --name db --network campus-red -e POSTGRES_USER=app -e "POSTGRES_PASSWORD=$env:POSTGRES_PASSWORD" -e POSTGRES_DB=campus postgres:17-alpine
        Docker run -d --name api --network campus-red -p "$($env:HTTP_PORT):3000" -e "DATABASE_URL=postgres://app:$env:POSTGRES_PASSWORD@db:5432/campus" campus-api:1.0.0
        Esperar
        Docker logs api
        $r = Api 'v1/info'; $r | ConvertTo-Json
        Comprobar ($r.version -eq '1.0.0') 'Version manual 1.0.0'
        & docker.exe run --rm campus-api:1.0.0
        Comprobar ($LASTEXITCODE -ne 0) 'Sin DATABASE_URL la API termina con error'
    } finally {
        Docker rm -f api db
        Docker network rm campus-red
    }
} finally { Stop-Transcript }

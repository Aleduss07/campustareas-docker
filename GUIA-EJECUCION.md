# Ejecutar la práctica en Windows

Abre PowerShell en esta carpeta. Docker Desktop debe usar contenedores Linux. Estos scripts son la adaptación de los comandos Bash de la guía y guardan evidencias automáticamente.

Si la política local bloquea archivos `.ps1`, puedes invocar cada uno en un proceso dedicado así:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Preparar.ps1
```

Esta opción se aplica solo a ese proceso. Usa el mismo prefijo para los demás scripts si lo necesitas. Si una política administrada lo impide, debe respetarse y revisarse con el administrador.

## Orden completo

```powershell
.\scripts\Preparar.ps1
.\scripts\01-Manual.ps1
.\scripts\02-Persistencia.ps1
.\scripts\03-Balanceo.ps1
.\scripts\08-Web.ps1
.\scripts\04-Analisis.ps1
.\scripts\03-Balanceo.ps1 -LeastConn
.\scripts\05-Escanear.ps1
.\scripts\06-Publicar.ps1 -Owner aleduss07
.\scripts\07-Version.ps1
```

Ejecuta uno a uno y resuelve cualquier fallo antes de avanzar. El paso 02 borra únicamente el volumen de prueba de `campus-una` para demostrar `down -v`. Los contenedores manuales se llaman `api` y `db`: esos nombres y el puerto 8080 deben estar disponibles antes del paso 01. Un fallo no equivale a una prueba aprobada.

El cliente web abre en **http://localhost:8080** después del paso 03. En el paso 08 crea una tarea desde el formulario, verifica la salida de la API y guarda una captura. Después el script detiene api1 y api3 para que puedas repetir la operación con api2 sola; pulsa Enter al terminar y se restauran las réplicas.

`03-Balanceo.ps1` hace 30 peticiones por escenario para observar las réplicas y registra los códigos HTTP, `replica` y `X-Upstream`. Nginx mantiene su detección pasiva de fallos durante 10 segundos, por eso el script espera su recuperación.

Para volver a round robin después del reto:

```powershell
docker compose up -d --force-recreate balanceador
docker compose exec -T balanceador nginx -t
```

Para usar directamente el sistema sin repetir las demostraciones:

```powershell
docker compose up -d --build --wait
docker compose ps
curl.exe -i http://localhost:8080/v1/info
curl.exe http://localhost:8080/v1/tareas
```

Si prefieres no introducir el PAT de GHCR de forma interactiva en el script 06, autentica Docker antes con el método de tu organización y ejecuta manualmente tag y push indicados en `INFORME.md`. No guardes tokens en scripts ni evidencias.

## Finalizar y entregar

```powershell
.\scripts\09-Cierre.ps1
docker images campus-api
git status --short
git add .
git commit -m "Completar despliegue Docker, cliente web y retos de CampusTareas"
```

El cierre conserva datos e imágenes. La limpieza `docker image prune -f` propuesta en el PDF es global para las imágenes sin etiqueta del motor: ejecútala aparte si deseas esa limpieza. No se automatiza sobre imágenes de otros proyectos.

Revisa los logs antes de compartirlos y agrégalos individualmente con `git add -f evidencias/ARCHIVO.log` si no contienen secretos. El repositorio de esta práctica es https://github.com/Aleduss07/campustareas-docker y se creó privado. El paquete GHCR tiene su propia URL y permisos; su publicación espera una credencial con write:packages.

Si aparece «permission denied» sobre `docker_engine` desde el agente pero `docker version` funciona en tu terminal normal, el problema es el aislamiento de esa sesión. No hace falta reinstalar Docker ni exponer su API TCP. Reabrir la tarea con los permisos adecuados o ejecutar estos scripts desde la terminal normal permite continuar.

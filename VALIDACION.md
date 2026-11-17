# Validación realizada

Fecha: 17 de noviembre de 2026. Docker Engine 29.7.2, Docker Desktop 4.86.0 y Compose 5.3.1. El bloqueo inicial se resolvió al activar acceso completo; las siguientes pruebas son reales.

| Comprobación | Resultado | Evidencia |
|---|---|---|
| Sintaxis JS, PowerShell y Compose | Aprobada | Validaciones ejecutadas |
| Imagen y usuario | Construida; uid=1000(node) | 01-imagen-y-configuracion.log, 04-analisis.log |
| Contenedores manuales | Versión 1.0.0; conexión BD al segundo intento; fallo esperado sin DATABASE_URL | 01-manual.log |
| Persistencia | Tarea conservada tras down; lista vacía tras down -v | 02-persistencia.log |
| Nginx | nginx -t correcto; solo puerto 8080 publicado | reto-least-conn.log |
| Round robin | HTTP 200; 3, 2 y 1 réplicas en 30 peticiones por escenario | 03-round-robin.log |
| Least connections | HTTP 200 en los mismos escenarios | reto-least-conn.log |
| Datos compartidos | 12 lecturas incluyen la tarea recién creada | Logs de ambos algoritmos |
| Web real | Crear, listar, buscar, completar y volver a pendiente | 08-web.log |
| Web con una réplica | Lectura y creación con api1 y api3 detenidas | 08-web.log, web-tareas.json |
| Escritorio/móvil | Capturas 1366 y 390 px; sin errores JS ni desbordamiento | Capturas PNG |
| Caché y tamaños | npm ci reutilizado; COPY src reconstruido; 250 MB frente a 1.64 GB de DISK USAGE | 04-analisis.log |
| Trivy | 20 hallazgos: 6 HIGH, 13 MEDIUM, 1 LOW | trivy.json, VULNERABILIDADES.md |
| Versión 1.1.0 | 12 respuestas correctas, tres réplicas | reto-version.log |
| GHCR | Push correcto, descarga por digest y ejecución verificadas; versión 1.0.0, uid=1000 | reto-ghcr.log |
| Cierre y limpieza | down y image prune completados; imágenes etiquetadas y volumen conservados | 09-cierre.log |

Scout pedía autenticación Docker Hub: se utilizó Trivy, alternativa admitida por el PDF. La CVE analizada procede del reporte real. No se declara corregida ni publicada una imagen que no lo esté.

Playwright operó contra el cliente web y PostgreSQL reales, sin respuestas simuladas. Las capturas se inspeccionaron visualmente. El detector mecánico del frontend devolvió [].

Se corrigieron dos problemas de los scripts en Windows PowerShell: enumerar arrays JSON para reconocer [] y guardar stdout/stderr nativos con Out-Host. Algunas líneas vacías de stderr aparecen como RemoteException por el formato de PowerShell; las construcciones terminaron con código 0.

Se revisó que las evidencias no contengan la contraseña de PostgreSQL; .env permanece ignorado por Git. Repositorio privado: https://github.com/Aleduss07/campustareas-docker.

Después del cierre se volvió a levantar la pila con 1.1.0 para que el usuario pueda abrir http://localhost:8080. Los contenedores se dejaron activos.

Imagen publicada: `ghcr.io/aleduss07/campus-api:1.0.0`. Digest verificado: `sha256:0cc9f13301eb00beeed48ade831ac6f380d0aaa9b97c48e48f83b82cf9d303fa`. Los cinco retos opcionales están completados.

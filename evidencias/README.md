# Evidencias

Los scripts guardan transcripciones reales en esta carpeta. Los logs estan ignorados por Git por defecto: revisa que no contengan secretos antes de adjuntarlos al informe o agregarlos con `git add -f evidencias/nombre.log`.

Pendientes de ejecucion en un entorno con acceso a Docker:

- 01-manual.log: versiones, imagen, capas, red, peticion y fallo sin DATABASE_URL.
- 02-persistencia.log: lectura tras down y tras down -v.
- 03-round-robin.log: tres replicas, caida de api2, dos replicas sin error y datos compartidos.
- 04-analisis.log: pasos CACHED y tamanos reales.
- reto-least-conn.log: mismo experimento con least_conn.
- reto-vulnerabilidades.log: escaneo real; analizar una CVE encontrada.
- reto-ghcr.log: push y digest del paquete.
- reto-version.log: respuestas reales con version 1.1.0.
- 08-web.log y captura-web.png: tarea creada desde el navegador y prueba con una sola replica.

No se incluyen salidas inventadas. VALIDACION.md registra lo que se pudo comprobar en esta sesion.

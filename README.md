# CampusTareas · Docker, Nginx y cliente web

Implementación de la guía con tres réplicas, PostgreSQL persistente, balanceo Nginx y los cinco retos opcionales preparados. Por indicación del usuario, la aplicación Android se sustituye por un cliente web.

**Inicio:** `scripts/Preparar.ps1`, después `docker compose up -d --build --wait` y abrir **http://localhost:8080**.

- [Guía de ejecución y pruebas](GUIA-EJECUCION.md)
- [Informe y ocho respuestas de análisis](INFORME.md)
- [Validaciones realizadas y pendientes](VALIDACION.md)
- [Evidencias que generan los scripts](evidencias/README.md)

La ejecución real en Docker y la publicación GHCR están pendientes por restricciones de acceso de la sesión; no se incluyen evidencias simuladas.

---

Este proyecto contiene la API REST de CampusTareas en Node.js con PostgreSQL.
La API ya está terminada: el trabajo de las prácticas es **desplegarla**.

```
campustareas/
└── api/
    ├── package.json
    ├── package-lock.json
    └── src/
        ├── server.js   # rutas, salud y apagado ordenado
        └── db.js       # conexión a PostgreSQL y creación de la tabla
```

## Endpoints

| Método | Ruta                  | Qué hace                                                  |
|--------|-----------------------|-----------------------------------------------------------|
| GET    | `/health/live`        | 200 si el proceso está vivo                               |
| GET    | `/health/ready`       | 200 si la base de datos responde; 503 si no               |
| GET    | `/v1/info`            | Versión y nombre de la réplica que atendió                |
| GET    | `/v1/tareas`          | Lista las tareas                                          |
| POST   | `/v1/tareas`          | Crea una tarea: `{"titulo", "descripcion", "fechaEntrega"}` |
| PATCH  | `/v1/tareas/{id}`     | Marca una tarea: `{"completada": true}`                   |
| GET    | `/v1/trabajo-pesado`  | Consume CPU unos 50 ms (práctica de autoescalado)         |

## Variables de entorno

| Variable       | Obligatoria | Valor por defecto | Ejemplo                                        |
|----------------|-------------|-------------------|------------------------------------------------|
| `DATABASE_URL` | Sí          | —                 | `postgres://app:secret@db:5432/campus`         |
| `PORT`         | No          | `3000`            | `3000`                                         |
| `APP_VERSION`  | No          | `dev`             | `1.0.0`                                        |
| `DB_POOL_MAX`  | No          | `10`              | `10`                                           |

Sin `DATABASE_URL` la API no arranca. La tabla `tareas` se crea sola la primera
vez que la API se conecta a la base de datos.

Cada respuesta incluye la cabecera `X-Replica` con el nombre del contenedor o
Pod que la atendió.

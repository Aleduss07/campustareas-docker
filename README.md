# CampusTareas

API Node.js con PostgreSQL, cliente web y tres réplicas detrás de Nginx.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Preparar.ps1
docker compose up -d --build --wait
```

Aplicación: http://localhost:8080. API: http://localhost:8080/v1/.

- `compose.una.yaml`: despliegue de una réplica y prueba de persistencia.
- `compose.yaml`: despliegue final con tres réplicas.
- `compose.least-conn.yaml`: configuración alternativa de balanceo.
- `scripts/`: ejecución de los pasos y retos de la práctica.
- [Informe final con capturas](informe/Informe%20CampusTareas%20Docker%20-%20Revisado.pdf).
- [Imagen publicada en GitHub Packages](https://github.com/users/Aleduss07/packages/container/package/campus-api): `ghcr.io/aleduss07/campus-api:1.0.0`.

`.env` contiene la configuración local y no se publica. Las variables se documentan en `.env.example`.

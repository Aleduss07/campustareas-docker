# Escaneo de vulnerabilidades

Se ejecuto Trivy sobre `campus-api:1.0.0` el 17 de noviembre de 2026. Scout no pudo utilizarse porque no habia una sesion Docker Hub autenticada. Trivy es la alternativa admitida por la guia.

Resultado: 20 hallazgos. Severidades: MEDIUM: 13, HIGH: 6, LOW: 1.

Fuente completa: [trivy.json](evidencias/trivy.json). Los resultados corresponden a la imagen y base de vulnerabilidades de esta fecha.

| CVE | Paquete | Instalada | Corregida segun Trivy | Severidad |
|---|---|---|---|---|
| CVE-2026-4738 | zlib | 1.3.2-r1 | 1.4-r0 | MEDIUM |
| CVE-2026-102276 | brace-expansion | 5.0.9 | 5.0.10, 3.0.7, 2.1.5, 1.1.19 | HIGH |
| CVE-2026-102278 | brace-expansion | 5.0.9 | 5.0.11, 3.0.8, 2.1.6, 1.1.20 | HIGH |
| CVE-2026-102277 | brace-expansion | 5.0.9 | 5.0.12, 3.0.9, 2.1.7, 1.1.21 | MEDIUM |
| CVE-2026-118773 | glob | 13.0.6 | 14.0.2 | MEDIUM |
| CVE-2026-101910 | ip-address | 10.5.0 | 10.5.1 | MEDIUM |
| CVE-2026-101911 | ip-address | 10.5.0 | 10.7.1 | MEDIUM |
| CVE-2026-101912 | ip-address | 10.5.0 | 10.7.1 | MEDIUM |
| CVE-2026-101913 | ip-address | 10.5.0 | 10.5.1 | MEDIUM |
| CVE-2026-111997 | ip-address | 10.5.0 | 10.7.4 | MEDIUM |
| CVE-2026-118764 | minimatch | 10.2.5 | 11.0.1 | MEDIUM |
| CVE-2026-104844 | postcss-selector-parser | 7.1.4 | 7.1.6, 6.1.5 | MEDIUM |
| CVE-2026-109383 | undici | 6.28.0 | 6.29.1, 7.30.1, 8.12.2 | HIGH |
| CVE-2026-109869 | undici | 6.28.0 | 6.29.1, 7.30.1, 8.12.2 | HIGH |
| CVE-2026-19534 | undici | 6.28.0 | 6.28.1, 7.29.1, 8.10.2 | HIGH |
| CVE-2026-87018 | undici | 6.28.0 | 6.29.1, 7.30.1, 8.12.2 | HIGH |
| CVE-2026-109924 | undici | 6.28.0 | 6.29.1, 7.30.1, 8.12.2 | MEDIUM |
| CVE-2026-109932 | undici | 6.28.0 | 6.29.1, 7.30.1, 8.12.2 | MEDIUM |
| CVE-2026-85024 | undici | 6.28.0 | 6.28.1, 7.29.1, 8.10.2 | MEDIUM |
| CVE-2026-18540 | undici | 6.28.0 | 6.28.1, 7.29.1, 8.10.2 | LOW |

## Analisis de una vulnerabilidad encontrada

**CVE-2026-102276**, severidad HIGH, afecta a `brace-expansion` 5.0.9. Trivy la encontro dentro de `usr/local/lib/node_modules/npm/node_modules/brace-expansion/package.json`: viene con npm en la imagen base; no es una dependencia declarada por CampusTareas.

Segun el aviso incluido en el reporte, patrones de expansion de llaves especialmente construidos pueden agotar la pila nativa de Node.js y terminar el proceso, causando denegacion de servicio. El arreglo de esta CVE esta en 5.0.10 para esa rama. Hay ademas otros hallazgos de brace-expansion en la misma imagen, por lo que actualizar solo a la primera version corregida no garantiza resolverlos todos.

La API no procesa patrones de brace-expansion y arranca mediante `node src/server.js`; el hallazgo por presencia del paquete no demuestra por si solo explotabilidad remota en esta aplicacion. Sin embargo, el componente vulnerable debe actualizarse o eliminarse si no se necesita.

Correccion propuesta: reconstruir con una imagen Node 24 que incorpore npm y sus dependencias corregidas, o retirar npm/npx de la etapa final una vez instaladas las dependencias en la primera etapa. Reescanear la imagen resultante para comprobar esta CVE y el resto; no se declara una correccion ejecutada que no se ha verificado.

Referencia primaria del paquete: https://github.com/juliangruber/brace-expansion/security/advisories/GHSA-6j4f-fj2g-mc7p

## Comando ejecutado

```powershell
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "${PWD}/evidencias:/report" aquasec/trivy:latest image --scanners vuln --format json --output /report/trivy.json campus-api:1.0.0
```

El montaje del socket permite a Trivy consultar la imagen local; no se publicaron puertos del motor. El script `05-Escanear.ps1` automatiza el fallback y guarda la cache en un volumen propio para ejecuciones posteriores.

# Fuentes: lo que abre issues

Una fuente **detecta y describe; nunca arregla**. Abre issues en el repo del
proyecto responsable (o en Tafona si es un fallo del proceso), y el trabajo
empieza cuando una persona pone `claude` (los dos pasos).

## El contrato de una fuente

1. **Una issue por causa**, no por síntoma: si veinte páginas fallan por la
   misma plantilla, es una issue.
2. **Cómo se verifica**, escrito en la issue: qué mirar, dónde, para darla por
   buena. La etapa de verificar lo usa.
3. **Un límite** de issues abiertas a la vez por proyecto, y **no repetir**
   lo que ya está abierto. Una fuente que entierra a David en issues no sirve.
4. Una etiqueta propia que diga de dónde viene (`auditoria`, `nocturna`…),
   para que el tablero la muestre y se pueda filtrar.
5. **Sin `claude`**: lo que se hace lo decide una persona.

## Las fuentes

| Fuente | Cuándo | Qué mira | Estado |
|---|---|---|---|
| **Personas** (David, Juan, un cliente vía David) | cuando quieran | lo que escriban | funciona |
| **Auditoría** (`auditoria-tool`) | lunes, desde el servidor de SiteGround | los 208 puntos de cada web | funciona (la tarea programada de SiteGround, pendiente de David) |
| **Fallos del proceso** | en cada ejecución de Tafona | lo que impida hacer bien el trabajo | funciona (etiqueta `tafona`) |
| **Nocturna · errores** | de madrugada | lo que cambió en el repo desde la noche anterior: fallos probables | montada, sin activar (ver abajo) |
| **Nocturna · rendimiento** | de madrugada | velocidad real de las páginas clave con el visor (navegador de verdad) | pendiente |
| **Nocturna · recursos** | de madrugada | el servidor en solo lectura: disco, tamaño de la base de datos, plugins sin usar, crons | pendiente |
| **Nocturna · oportunidades** | de madrugada (semanal) | mejoras y evolutivos; etiqueta `propuesta`, decide David | pendiente |

## Las nocturnas, cómo se montan

Un flujo programado de Tafona por tarea, que recorre los proyectos enganchados
y lanza a Claude con las instrucciones de esa tarea, sus herramientas (`ssh
prod` de solo lectura, el visor) y el contrato de arriba. Cada una cuesta
tiempo de la suscripción de Claude: se empieza por una (errores) en un
proyecto, se mira una semana lo que abre, y se decide si se sigue.

## Nocturna · errores

De madrugada (03:30 UTC) mira los commits de `main` de las últimas 24 h. **Sin
commits no gasta nada.** Claude lee el diff y el código de alrededor y abre
como mucho **3 issues por noche** con la etiqueta `nocturna`, una por causa y
con «Cómo se verifica», **sin `claude`**. Antes mira las `nocturna` abiertas
para no repetir. Si no encuentra nada, no abre nada. Nunca abre PR.

- **El flujo:** `plantilla/nocturna-errores.yml` (reutilizable). Debe vivir en
  `.github/workflows/nocturna-errores.yml`; está en `plantilla/` porque la app
  de Claude no puede escribir en `.github/workflows`, así que una persona lo
  mueve (`git mv`).
- **Activarla en un proyecto:** en su `tafona.yml`, descomentar el `schedule` y
  el job `nocturna` (están en `plantilla/tafona.yml`). Mismos secretos que el
  resto. PENDIENTE: lanzarla a mano. El `workflow_dispatch` de la plantilla
  es el de la revisora (pide una PR), así que hace falta una entrada propia
  para la nocturna; mientras, se prueba con un `cron` cercano.
- **Coste:** una ejecución de Claude por proyecto y noche, solo si hubo
  commits (hasta 40 turnos). Sale de la suscripción de Claude de David.
- **Empezamos por** `estrategiaweb-es`; se mira una semana lo que abre y se
  decide si sigue y a qué más proyectos llega.

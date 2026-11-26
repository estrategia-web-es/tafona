# Pendientes — Tafona

Lo terminado sale de aquí, al historial de git con el commit que lo cierra.

## 0. Regenerar el token del tablero
**Fecha:** 26-11-2026 · **Vence:** en cuanto David esté en la oficina

El token de proyectos se pegó en una conversación: está comprometido. David lo
regenera (github.com/settings/personal-access-tokens, «Regenerate token») y se
vuelve a cargar como `TAFONA_TOKEN` en tafona, estrategiaweb-es y
gastronomicament-cat, y como `PROJECTS_TOKEN` en auditoria-tool. El valor no
se pega en el chat: va a `auditoria-tool/secretos/github-projects.txt`.

## 1. La decisión se retoma sola
**Fecha:** 26-11-2026

Cuando la persona que decide comenta en una issue o PR con la etiqueta
`decide`, el proceso la retoma: Claude lee la respuesta y sigue. Hoy hay que
poner la etiqueta `claude` a mano. La etiqueta `decide-david` pasa a `decide`,
con la issue **asignada** a David o a Juan.

## 2. Flujos reutilizables
**Fecha:** 26-11-2026

`claude.yml` y `revisar.yml` como `workflow_call` aquí; cada proyecto solo
lleva un fichero que los llama con su servidor. Con ellos, las instrucciones
fijas de Claude para TODA issue (abrir la PR con `gh pr create`, «Refs» o
«Closes», usar `ssh prod` y el visor), que hoy solo llevan las issues de la
auditoría. Se mueven aquí `ver.sh`/`ver.mjs` y el criterio de la revisora.
Primeros proyectos: `gastronomicament-cat`, `estrategiaweb-es` y el plugin.

## 3. Clasificar como etapa
**Fecha:** 26-11-2026

Una bandeja (las issues de este repo con la etiqueta `tafona`): Claude
clasifica y **traslada** la issue al repo responsable (`gh issue transfer`).
El triaje de `auditoria-tool` se queda en lo suyo: agrupar los fallos por
causa y abrir las issues en la bandeja.

## 4. Verificar según la fuente
**Fecha:** 26-11-2026

- **Auditoría:** `auditoria verificar <issue>` en el momento, solo sus páginas
  y sus puntos, leyendo por `ssh prod pagina` (desde GitHub el antibots no
  deja) y una orden nueva del guardián para las cabeceras.
- **Manual:** una pasada corta de Claude con el «cómo se comprueba» de la
  issue, el visor y `ssh prod`; si está bien, la cierra como verificada.
- Se lanza al pasar a «Aplicado». La pasada del lunes sigue de red.

## 5. Aplicar con aprobación
**Fecha:** 26-11-2026

Cada proyecto declara cómo se aplica. El paso corre con un entorno
`produccion` que pide aprobación y una llave atada a una sola orden (probado
el 26-11-2026 con la llave del «hola»).

## 5 bis. Publicar con la release, en todos los proyectos
**Fecha:** 26-11-2026

Una regla: fusionar acumula, la release publica (OK de Juan o David).
- Issue «Publicar vX» con `claude` → PR de versión (número, changelog con las
  PR desde la anterior, comprobaciones) → release → publicar → `aplicado` en
  las issues de esa versión → verificar.
- Plugin: `10up/action-wordpress-plugin-deploy` al SVN; credenciales SVN como
  secretos (decidir de quién). Tema padre: comprobar si un autor puede
  publicar un tema por SVN o solo por el formulario de la web.
- Webs: el desplegador de tafona#2 pasa a dispararse con la release, no con
  el push a `main`.
- Tablero: «Aplicado» pasa a «Fusionado» (la regla de PR merged apunta ahí),
  y una columna nueva «Publicado» que pone Tafona al publicar.

## 7. Tareas nocturnas: fuentes de issues
**Fecha:** 26-11-2026

Ejecuciones programadas de madrugada que miran un proyecto con IA y abren
issues (nunca PR): errores, rendimiento y velocidad (el visor), recursos del
servidor (solo lectura) y oportunidades o evolutivos (etiqueta propia: decide
David). Cada una con límite de issues abiertas y sin repetir lo abierto, como
la auditoría.

## 8. Tafona pública y para otras organizaciones
**Fecha:** 26-11-2026

Vivirá en `estrategia-web-es`, pública. Separar el motor (flujos, reglas,
visor; con versiones `@v1`) de lo de cada organización (quién decide, el
tablero, el idioma, el tipo de proyectos), que hoy está escrito a fuego:
`estrategia-web-es`, los usuarios de David y Juan, el puerto 18765, las
reglas de WP-CLI. Después de que el ciclo entero funcione aquí.

## 6. El tablero, aquí
**Fecha:** 26-11-2026

La sincronización y las tarjetas de salud salen de `auditoria-tool`; las de
salud de la auditoría siguen siendo suyas (es una fuente), las del proceso
(tokens, llaves) pasan aquí.

# Tafona

**Cómo se trabaja en los proyectos de Estrategia Web.** Por aquí pasa todo cambio:
entra una incidencia, se clasifica, Claude hace la PR, una persona decide, se
aplica y se verifica. Como en una tafona, la almazara mallorquina: entra
aceituna, se muele, se prensa, se decanta y sale aceite.

Nació el 26-11-2026, cuando David y Juan pasaron de programar a dar el OK:
el desarrollo lo hace el proceso, y ellos deciden.

## Las seis etapas

| Etapa | Qué pasa | Quién |
|---|---|---|
| **Entrada** | Una issue nueva, venga de donde venga | una fuente |
| **Clasificar** | Tipo (código, contenido o configuración), repo responsable y quién decide. La issue se traslada al repo que toca | Claude |
| **PR** | El arreglo completo, con todo lo opinable ya propuesto dentro | Claude, en el repo del proyecto |
| **Decisión** | La revisora: **rutina** o **decide una persona** (David o Juan), con una sola pregunta | la revisora, y después la persona |
| **Aplicar** | Desplegar o ejecutar el script del proyecto | el proyecto, con aprobación |
| **Verificar** | Comprobar en la web real que está bien, y cerrar | según la fuente |

El tablero es de Tafona: https://github.com/orgs/estrategia-web-es/projects/1

## El mapa (David, 26-11-2026)

Un tablero, Tafona en medio, y tres clases de cosas:

- **Fuentes** — solo abren issues, nunca arreglan: la auditoría semanal
  (`auditoria-tool`), las tareas nocturnas (errores, rendimiento, recursos,
  oportunidades) y las personas. Cada fuente tiene un **límite** de issues
  abiertas y **no repite** lo que ya está abierto.
- **Proyectos** — cada uno con su forma de publicar, y **la release es el
  OK**: fusionar acumula en `main`; publicar es crear la release en GitHub.
  - plugin y tema padre → WordPress.org;
  - tema hijo de cada web → su directorio en el servidor, con sus migraciones
    (las ejecuta el módulo del plugin al cambiar la versión);
  - herramientas → su release;
  - Tafona y la auditoría → se trabajan a sí mismas por el mismo proceso.
- **Tafona** — el motor: clasificar, PR, revisora, decisión, publicar,
  verificar.

Tafona será **pública** y vivirá en `estrategia-web-es`: es el motor de todo,
y para que otras organizaciones lo usen sus flujos tienen que poder leerse
desde fuera (no hay nada sensible dentro: clientes, servidores y llaves viven
en cada proyecto).

## Las tres piezas

- **Las fuentes solo abren issues.** Detectan y describen; no clasifican ni
  arreglan. Hoy: la auditoría semanal (`auditoria-tool`) y las issues escritas
  a mano. Cada fuente dice **cómo se verifica** lo que abre.
- **Tafona** es el proceso: las etapas, el tablero, el criterio de la revisora,
  las instrucciones fijas de Claude y las herramientas comunes (el visor de
  páginas, el guardián de solo lectura).
- **Los proyectos** (cada web, el plugin, el tema) ponen su código y un fichero
  corto que engancha Tafona, con lo suyo: su servidor y cómo se aplica un
  cambio en él.

## Quién decide qué

- **David:** datos de cliente, textos que verá el público, lo legal, lo que
  cuesta dinero.
- **Juan** (`SoporteEstrategiaWeb`): lo técnico del plugin y del tema
  compartidos.
- **No está claro:** los dos; contesta el primero.

Contestar en la issue **es** la decisión: el proceso la retoma solo.

## Documentación

- [docs/decisiones.md](docs/decisiones.md) — qué se decidió, cuándo y por qué.
- [docs/fuentes.md](docs/fuentes.md) — lo que abre issues: personas,
  auditoría, fallos del proceso, tareas nocturnas.
- [docs/publicar.md](docs/publicar.md) — fusionar acumula, la release publica.
- [docs/migraciones.md](docs/migraciones.md) — el contenido viaja con el tema
  hijo; lo ejecuta el plugin.
- [docs/alta-de-proyecto.md](docs/alta-de-proyecto.md) — cómo entra un repo
  en Tafona, con sus trampas.

## Qué hay aquí

- [.github/workflows/trabajar.yml](.github/workflows/trabajar.yml): clasificar,
  hacer la PR, retomar cuando la persona contesta, verificar. Lleva dentro las
  reglas fijas de Claude y el visor de páginas.
- [.github/workflows/revisar.yml](.github/workflows/revisar.yml): la revisora,
  con el criterio dentro. Asigna a quien decide.
- [plantilla/tafona.yml](plantilla/tafona.yml): el único fichero que lleva un
  proyecto.

**Las etiquetas:** `claude` (hazlo), `decide` (decide la persona asignada),
`rutina` (la revisora no ve nada que decidir), `aplicado` (está en
producción: verifícalo), y las de tipo `codigo`, `contenido`, `configuracion`.

**Empezar son dos pasos:** se escribe la issue y se le pone la etiqueta
`claude`. Abrirla sola no arranca nada, a propósito: el trabajo empieza
cuando alguien lo pide.

**Contestar es decidir:** si quien está asignado comenta en algo con
`decide`, Tafona lo retoma sin `@claude`. `@claude` sigue valiendo para pedir
cualquier otra cosa.

## Estado

Primera versión (26-11-2026): trabajar y revisar. Aplicar sigue siendo
manual; la bandeja de clasificar y la verificación de la auditoría, en
[PENDIENTES.md](PENDIENTES.md).

## Cómo se mantiene

- **Un proyecto nuevo** entra con: el fichero que engancha Tafona, los tres
  secretos (`CLAUDE_CODE_OAUTH_TOKEN`, `PROD_LECTURA_KEY` y `TAFONA_TOKEN`, el
  token de proyectos que escribe en el tablero; repo a repo porque un secreto
  de organización pide un permiso de administrador), la llave de solo
  lectura en su servidor y, si tiene auditoría, su línea en `sitios.json` de
  `auditoria-tool`.
- **Una fuente nueva** solo tiene que abrir issues con la etiqueta `tafona` y
  decir en el cuerpo cómo se verifica. Lo demás es de Tafona.
- **Un cambio en el proceso** se hace aquí, una vez, y llega a todos los
  proyectos. Nunca se copia un fichero de proceso a un proyecto: es lo que
  pasó antes de Tafona, y los arreglos había que hacerlos dos veces.

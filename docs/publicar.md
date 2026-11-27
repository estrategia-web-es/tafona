# Publicar: fusionar acumula, la release publica

**Una regla para todos los proyectos** (David, 26-11-2026). Fusionar una PR
la deja en `main`, nada más. Lo que llega a la gente sale con una **release**
de GitHub, y crearla es el OK de Juan o de David (solo ellos pueden).

## El ciclo

1. Los cambios entran por PR y se acumulan en `main`.
2. **Preparar la versión:** una issue «Publicar vX.Y.Z» con la etiqueta
   `claude`. Tafona abre la **PR de versión**:
   - sube el número donde lo lleve el proyecto (cabecera del plugin y
     `readme.txt` → *Stable tag*; `style.css` → *Version* de un tema);
   - escribe el changelog con las PR fusionadas desde la release anterior;
   - pasa las comprobaciones del proyecto (pruebas, Plugin Check, `php -l`).
   La revisora la marca DECIDE: publicar no se deshace.
3. Se fusiona la PR de versión (todavía no publica).
4. **Publicar = crear la release `vX.Y.Z`** en GitHub. El flujo de publicar
   del proyecto:
   - comprueba que la versión del código coincide con la etiqueta, y se
     niega si no;
   - publica (ver la tabla);
   - adjunta el zip a la release.
5. Como último paso del flujo de publicar,
   [publicado.yml](../.github/workflows/publicado.yml) busca las PR fusionadas
   entre la etiqueta anterior y esta, y sus «Refs #n». A cada issue abierta le
   pone un comentario con la release, la etiqueta `publicado` y su tarjeta en
   **Publicado**. La etiqueta lanza la etapa de verificar, que la comprueba y
   la cierra.

## Qué hace la release en cada proyecto

| Proyecto | Publica en | Con | Estado |
|---|---|---|---|
| Plugin (`estrategia-web-wp-plugin`) | SVN de WordPress.org (`trunk` y `tags/X.Y.Z`) | `10up/action-wordpress-plugin-deploy` | pendiente (issue en el plugin) |
| Tema padre (`estrategia-web-wp-theme`) | WordPress.org | **por comprobar**: si un autor puede publicar un tema por SVN o solo con el formulario de la web; si es lo segundo, la release deja el zip y la subida es a mano | pendiente |
| Cada web (`estrategiaweb-es`, `gastronomicament-cat`…) | su servidor: el directorio de su tema hijo | el desplegador de Tafona (tafona#2: `publicar.yml` y `servidor/aplicar.sh`) | en PR |
| Herramientas (`*-tool`) | su release (y `npm link` donde se usen) | — | pendiente |

## El tablero con releases (hecho el 27-11-2026, con OK de David)

    Triaje → PR abierta → Espera tu OK → Fusionado → Publicado → Verificado

| Columna | Quién la pone |
|---|---|
| **Fusionado** (en `main`, todavía no en la web) | la regla del tablero «Pull request merged» |
| **Publicado** (salió con una release; falta verificarlo) | `publicado.yml`, al acabar el flujo de publicar |
| **Verificado** | la regla «Item closed», cuando la etapa de verificar cierra la issue |

- *Fusionado* es la antigua *Aplicado* renombrada: conserva su id, así que la
  regla «Pull request merged» y las tarjetas que tenía siguen valiendo.
- **No se mueve al fusionar** porque fusionado no es publicado. Era el error
  de *Aplicado*.
- **No se mueve a mano** porque se olvida.

**La trampa al cambiar las columnas:** por la API se cambian con
`updateProjectV2Field`, que SUSTITUYE la lista entera de opciones. Si una
opción va sin su `id`, se crea de nuevo, y las tarjetas y las reglas que
apuntaban a ella se quedan sin columna. Se mandan todas con su `id` y solo la
nueva sin él. Comprobado el 27-11-2026 contando las tarjetas antes y después.

## Las migraciones al publicar una web

El desplegador (`servidor/aplicar.sh`) ejecuta `wp estrategia migrar` después
de copiar el tema hijo y antes de visitar la web (decidido por David el
27-11-2026, estrategia-web-wp-plugin#22). Las migraciones no se ejecutan nunca
en una visita. Si el comando falla, se deshace el tema (la BD no: su copia
queda en `~/copias`) y el flujo sale en rojo con el error; si el plugin es
viejo y no tiene el comando, avisa y sigue. Ver [migraciones.md](migraciones.md).

## Credenciales

- **SVN de WordPress.org:** secretos `SVN_USERNAME` y `SVN_PASSWORD` del repo
  del plugin. Falta decidir de quién (hoy publican David y Juan, cada uno con
  la suya; las de David, en `armazon-wp-sitio/secretos/svn.txt`).
- **Webs:** la llave de aplicar de cada servidor (tafona#2).

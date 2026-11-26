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
5. Tafona pone `aplicado` en las issues que entraron en esa versión (las que
   citan sus PR con «Refs #n») y la etapa de verificar las comprueba y cierra.

## Qué hace la release en cada proyecto

| Proyecto | Publica en | Con | Estado |
|---|---|---|---|
| Plugin (`estrategia-web-wp-plugin`) | SVN de WordPress.org (`trunk` y `tags/X.Y.Z`) | `10up/action-wordpress-plugin-deploy` | pendiente (issue en el plugin) |
| Tema padre (`estrategia-web-wp-theme`) | WordPress.org | **por comprobar**: si un autor puede publicar un tema por SVN o solo con el formulario de la web; si es lo segundo, la release deja el zip y la subida es a mano | pendiente |
| Cada web (`estrategiaweb-es`, `gastronomicament-cat`…) | su servidor: el directorio de su tema hijo | el desplegador de Tafona (tafona#2: `publicar.yml` y `servidor/aplicar.sh`) | en PR |
| Herramientas (`*-tool`) | su release (y `npm link` donde se usen) | — | pendiente |

## El tablero con releases (pendiente de David: toca sus reglas)

Hoy «Pull request merged» lleva a *Aplicado*, y con releases fusionar ya no es
aplicar. Propuesta:

- *Aplicado* → **Fusionado** (esperando release). La regla «Pull request
  merged» sigue apuntando ahí.
- Columna nueva **Publicado**, que pone Tafona al publicar.
- *Verificado*, como hoy.

Cambiar las opciones de la columna desde la API puede dejar sin valor las
tarjetas y descolgar las reglas integradas (apuntan a la opción), así que se
hace con David delante.

## Credenciales

- **SVN de WordPress.org:** secretos `SVN_USERNAME` y `SVN_PASSWORD` del repo
  del plugin. Falta decidir de quién (hoy publican David y Juan, cada uno con
  la suya; las de David, en `armazon-wp-sitio/secretos/svn.txt`).
- **Webs:** la llave de aplicar de cada servidor (tafona#2).

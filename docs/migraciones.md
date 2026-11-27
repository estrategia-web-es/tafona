# Migraciones: el contenido viaja con el tema hijo

Decidido por David el 26-11-2026: **desplegar una web es copiar su tema
hijo** (PHP, JS, CSS y migraciones). Un commit: si es código, código; si es
contenido, una migración. Al desplegar el tema, el desplegador ejecuta las
migraciones pendientes (ver «Cuándo se ejecutan»).

## Las piezas

| Pieza | Dónde | Qué hace | Estado |
|---|---|---|---|
| Las migraciones | `migraciones/` del **tema hijo** de cada web | ficheros PHP con fecha en el nombre (`2026-11-26-testimonio-luis.php`) | — |
| El ejecutor | módulo `migraciones` del **plugin** | aplica las pendientes en orden, una vez cada una, con `wp estrategia migrar` (nunca en una visita; en el escritorio solo avisa de las pendientes); WP-CLI `estado` y `aplicar --seco` | plugin#18 |
| El desplegador | **Tafona** | con la release de la web: copia de la base de datos y del tema, copia el tema hijo nuevo, provoca la ejecución, lee el resultado | tafona#2 |

## Cuándo se ejecutan (contrato decidido por David, 27-11-2026)

Las migraciones **no se ejecutan nunca en una visita**. Solo las ejecuta
`wp estrategia migrar`, y quien lo lanza es el desplegador (`servidor/aplicar.sh`),
en este orden: copia de la BD y del tema → copia del tema hijo nuevo →
`wp estrategia migrar` → visita de comprobación → purga de caché.

- Si el comando **falla**, se deshace el tema (se restaura `<tema>.ant`, como
  cuando falla la visita) y el despliegue sale en rojo con el error. La base de
  datos **no** se restaura sola: la copia queda en `~/copias` y lo decide una
  persona.
- Si el comando **no existe** porque el plugin es viejo, `aplicar.sh` avisa
  (registro y salida de error) y sigue sin migrar.
- Si el plugin ve migraciones pendientes fuera del despliegue, solo avisa en el
  escritorio de WordPress; no las ejecuta.
- Contrato en estrategia-web-wp-plugin#22.

## Por qué el ejecutor está en el plugin y no en el tema padre

El tema padre va camino de WordPress.org, y sus normas no dejan a un tema crear
ni modificar contenido (*plugin territory*). Al plugin sí. Si el tema padre no
fuera a WordPress.org, el ejecutor podría vivir en él.

## Por qué no un paquete existente tal cual

`deliciousbrains/wp-migrations` (GPL-2.0+, ~10 KB, el más conocido) es el
mismo patrón, pero pide Composer y un mu-plugin en cada sitio, y nuestras webs
no se gestionan con Composer. El módulo toma su lógica, citándolo.

## Reglas de una migración

- `aplicar()` y, si se puede, `deshacer()`.
- Se puede volver a leer: buscar por slug antes de crear, no dar nada por
  supuesto.
- Usa los ayudantes del módulo (crear o actualizar por slug, importar un medio
  con su alt, metadatos, orden) en vez de SQL.
- Nunca borra sin dejar copia de lo borrado.

## La revisión de una migración

La revisora **no la ejecuta** en producción, ni en seco: es código de la PR y
solo tiene lectura. Lee la migración y comprueba con `ssh prod` que lo que da
por supuesto existe. Si hace falta probarla de verdad, en la web de pruebas
(web2026) antes de fusionar.

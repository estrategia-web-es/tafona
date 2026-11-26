# Dar de alta un proyecto en Tafona

Lo que necesita un repo para entrar en el proceso. Hecho en `gastronomicament-cat`,
`estrategiaweb-es`, el plugin y la propia Tafona (26-11-2026).

## 1. El fichero

Copiar [plantilla/tafona.yml](../plantilla/tafona.yml) a
`.github/workflows/tafona.yml` del proyecto y rellenar `prod_host`,
`prod_user` y `web` (si no tiene web, como el plugin o una herramienta,
quitar esas tres líneas). Nada más del proceso vive en el proyecto.

## 2. Los secretos del repo

| Secreto | Qué es | De dónde |
|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | la suscripción de Claude de David | `claude setup-token`; caduca el 26-11-2027 |
| `TAFONA_TOKEN` | escribe en el tablero | token de proyectos de David (solo Projects); repo a repo porque un secreto de organización pide un permiso de administrador |
| `PROD_LECTURA_KEY` | la llave de solo lectura del servidor (si tiene web) | ver el punto 4 |

## 3. Ajustes del repo

- Settings → Actions → General → **«Allow GitHub Actions to create and
  approve pull requests»**. Hay que mirarlo repo a repo: en el plugin estaba
  apagado aunque la organización lo permitía.
- Las etiquetas las crea Tafona sola en la primera ejecución.

## 4. La llave de solo lectura (solo si tiene web)

1. Generar una llave ed25519 nueva para ese repo.
2. En la cuenta de SiteGround de la web: `~/bin/solo-lectura.sh` (está en
   `auditoria-tool/servidor/`) y una línea en `~/.ssh/authorized_keys2`:
   `command="/home/<cuenta>/bin/solo-lectura.sh <dominio>",no-pty,no-port-forwarding,no-agent-forwarding,no-X11-forwarding <llave pública>`
   (copia de `authorized_keys2` antes).
3. Probarla con `auditoria-tool/servidor/probar-solo-lectura.sh`: lo que debe
   pasar pasa, lo que no, no.
4. La privada, como `PROD_LECTURA_KEY` del repo; borrarla de la máquina.

## 5. La prueba

Una issue pequeña y real, la etiqueta `claude`, y mirar que salga la PR, el
veredicto de la revisora y la tarjeta en el tablero.

## Repos públicos (el plugin, la propia Tafona)

- Un repo **público** no puede usar flujos de uno **privado**: por eso Tafona
  se hizo pública el 26-11-2026 (el plugin falló con «workflow file issue» y
  cero trabajos mientras Tafona era privada).
- En un repo público cualquiera puede comentar `@claude`. La acción de Claude
  comprueba que quien lo pide tenga **permiso de escritura** en el repo; un
  extraño no lo arranca. Las etiquetas solo las ponen quienes escriben en el
  repo. Los secretos no llegan a las PR que vienen de forks.

## Trampas que ya mordieron

- Un fichero de proceso **copiado** en un proyecto se separa del de Tafona:
  nunca copiar, siempre llamar.
- Una PR creada por el bot de Actions **no arranca otros flujos** ni queda
  enlazada a su issue: por eso la revisora se lanza a mano y las PR dicen
  «Refs #n».
- `claude-code-action` no acepta eventos `push` ni actores bot sin
  `allowed_bots`, y deja las credenciales de git inservibles al terminar.

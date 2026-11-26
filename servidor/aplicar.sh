#!/usr/bin/env bash
# Guardián de la llave de APLICAR. Se ata en authorized_keys2 así:
#   command="/home/<cuenta>/bin/aplicar.sh <dir-web> <dir-temas> <tema-hijo> <url-web>",no-pty,no-port-forwarding,no-agent-forwarding,no-X11-forwarding <llave pública>
# Solo hace una cosa: recibe por la entrada estándar el tema hijo empaquetado
# (tar.gz) y lo despliega. El cliente solo puede decir «aplicar vX.Y.Z».
# Orden: valida → copia BD y tema → deja .nou → cambia de golpe → visita
# (migraciones) → purga caché. Si la migración falla, sale con error y NO
# da el cambio por aplicado (no revierte: la BD pudo cambiar; las copias
# quedan en ~/copias y <tema>.ant).
# Variables opcionales: APLICAR_MAX_MB (50), APLICAR_REGISTRO, APLICAR_COPIAS,
# MIGRACIONES_OPCION (nombre de la opción donde el módulo migraciones deja su
# resultado; PENDIENTE: contrato con el módulo, ver issue del plugin).
set -uo pipefail

WEB_DIR=${1:?}; TEMAS=${2:?}; TEMA=${3:?}; URL=${4:?}
REGISTRO=${APLICAR_REGISTRO:-$HOME/registro-aplicar.log}
COPIAS=${APLICAR_COPIAS:-$HOME/copias}
MAX=$(( ${APLICAR_MAX_MB:-50} * 1024 * 1024 ))
ORDEN=${SSH_ORIGINAL_COMMAND:-}

log() { printf '%s %s\n' "$(date -u +%FT%TZ)" "$*" >> "$REGISTRO"; }
fallo() { log "FALLO: $*"; echo "aplicar: $*" >&2; exit 1; }

[[ "$TEMA" =~ ^[A-Za-z0-9._-]+$ && "$TEMA" != .* ]] || fallo "nombre de tema no válido"
[[ "$ORDEN" =~ ^aplicar\ (v[0-9]+\.[0-9]+\.[0-9]+)$ ]] || { log "RECHAZADO: ${ORDEN:0:80}"; echo "aplicar: orden no permitida" >&2; exit 1; }
VER=${BASH_REMATCH[1]#v}
log "INICIO $TEMA $VER"

mkdir -p "$COPIAS"
BLOQUEO="$TEMAS/.aplicar.lock"
mkdir "$BLOQUEO" 2>/dev/null || fallo "ya hay un despliegue en curso"
TMP=$(mktemp -d); trap 'rmdir "$BLOQUEO"; rm -rf "$TMP"' EXIT

head -c $((MAX + 1)) > "$TMP/tema.tgz"
[ "$(stat -c %s "$TMP/tema.tgz")" -le "$MAX" ] || fallo "paquete mayor de ${MAX} bytes"

# Solo ficheros y directorios, rutas relativas y sin «..».
tar -tzvf "$TMP/tema.tgz" > "$TMP/lista" 2>/dev/null || fallo "paquete ilegible"
[ -s "$TMP/lista" ] || fallo "paquete vacío"
grep -qv '^[-d]' "$TMP/lista" && fallo "el paquete lleva enlaces o ficheros especiales"
tar -tzf "$TMP/tema.tgz" | grep -Eq '(^/|(^|/)\.\.(/|$))' && fallo "rutas no permitidas en el paquete"

NOU="$TEMAS/$TEMA.nou"; ANT="$TEMAS/$TEMA.ant"; ACTUAL="$TEMAS/$TEMA"
[ -d "$ACTUAL" ] || fallo "no existe el tema actual $ACTUAL"
rm -rf "$NOU"; mkdir "$NOU"
tar -xzf "$TMP/tema.tgz" -C "$NOU" --no-same-owner --no-same-permissions || { rm -rf "$NOU"; fallo "no se pudo desempaquetar"; }
V=$(sed -n 's/^[[:space:]]*Version:[[:space:]]*//p' "$NOU/style.css" 2>/dev/null | head -1 | tr -d '[:space:]')
[ "$V" = "$VER" ] || { rm -rf "$NOU"; fallo "style.css dice versión '$V', la release es $VER"; }

# Copias antes de tocar nada.
SELLO=$(date -u +%Y%m%d-%H%M%S)
wp --path="$WEB_DIR" db export "$COPIAS/bd-$SELLO.sql" >/dev/null 2>&1 || { rm -rf "$NOU"; fallo "falló la copia de la base de datos; no se toca nada"; }
rm -rf "$ANT"; cp -a "$ACTUAL" "$ANT" || { rm -rf "$NOU"; fallo "falló la copia del tema actual"; }
log "COPIAS bd-$SELLO.sql y $TEMA.ant"

# Cambio de golpe.
mv "$ACTUAL" "$TEMAS/$TEMA.vell" && mv "$NOU" "$ACTUAL" || { [ -d "$ACTUAL" ] || mv "$TEMAS/$TEMA.vell" "$ACTUAL"; fallo "falló el cambio"; }
rm -rf "$TEMAS/$TEMA.vell"
log "CAMBIADO $TEMA a $VER"

# Visita: ejecuta las migraciones; leemos su resultado.
CODIGO=$(curl -s -o /dev/null -w '%{http_code}' --max-time 120 "$URL") || CODIGO=000
if [[ ! "$CODIGO" =~ ^2 ]]; then
  fallo "la visita devolvió HTTP $CODIGO; migración no confirmada. Copias: $COPIAS/bd-$SELLO.sql y $ANT"
fi
if [ -n "${MIGRACIONES_OPCION:-}" ]; then
  RES=$(wp --path="$WEB_DIR" option get "$MIGRACIONES_OPCION" 2>&1) || RES="error: no se pudo leer $MIGRACIONES_OPCION"
  if [[ "$RES" =~ ^[Ee]rror ]]; then
    echo "$RES" >&2
    fallo "migración fallida: ${RES:0:300}. Copias: $COPIAS/bd-$SELLO.sql y $ANT"
  fi
fi

wp --path="$WEB_DIR" sg purge >/dev/null 2>&1 || log "AVISO: no se pudo purgar la caché"
log "APLICADO $TEMA $VER"
echo "aplicado $TEMA $VER"

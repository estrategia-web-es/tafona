#!/usr/bin/env bash
# Prueba de casos del guardián aplicar.sh, con wp y curl falsos. No toca ningún servidor.
set -u
AQUI=$(cd "$(dirname "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/bin" "$T/temas/hijo" "$T/web"
printf 'Theme Name: x\nVersion: 1.0.0\n' > "$T/temas/hijo/style.css"
cat > "$T/bin/wp" <<'W'
#!/usr/bin/env bash
case "$*" in
  *"db export"*) [ -n "${WP_FALLA_BD:-}" ] && exit 1; echo -- > "${@: -1}" ;;
  *"option get"*) echo "${WP_RES:-ok}" ;;
esac
W
cat > "$T/bin/curl" <<'W'
#!/usr/bin/env bash
echo "${CURL_CODIGO:-200}"
W
chmod +x "$T/bin/"*
export PATH="$T/bin:$PATH" APLICAR_REGISTRO="$T/reg.log" APLICAR_COPIAS="$T/copias" APLICAR_MAX_MB=1
paquete() { # versión → tgz en stdout
  local d; d=$(mktemp -d); printf 'Theme Name: x\nVersion: %s\n' "$1" > "$d/style.css"; echo "<?php" > "$d/functions.php"
  tar -czf - -C "$d" .; rm -rf "$d"; }
ok=0; mal=0
caso() { # nombre, esperado(0|1), orden, entrada(fichero), env...
  local n=$1 esp=$2 ord=$3 ent=$4; shift 4
  env "$@" SSH_ORIGINAL_COMMAND="$ord" "$AQUI/aplicar.sh" "$T/web" "$T/temas" hijo https://x.test/ < "$ent" >/dev/null 2>&1
  local r=$?; [ $r -ne 0 ] && r=1
  if [ "$r" = "$esp" ]; then ok=$((ok+1)); echo "ok   $n"; else mal=$((mal+1)); echo "MAL  $n"; fi
}
paquete 1.1.0 > "$T/bueno.tgz"; paquete 1.2.0 > "$T/otra.tgz"
caso "orden distinta"        1 "ls /"                "$T/bueno.tgz" A=1
caso "orden con añadidos"    1 "aplicar v1.1.0; id"  "$T/bueno.tgz" A=1
caso "sin orden"             1 ""                    "$T/bueno.tgz" A=1
caso "versión no coincide"   1 "aplicar v1.1.0"      "$T/otra.tgz" A=1
caso "basura por la entrada" 1 "aplicar v1.1.0"      /etc/hostname A=1
d=$(mktemp -d); ln -s /etc/passwd "$d/enlace"; printf 'Version: 1.1.0\n' > "$d/style.css"; tar -czf "$T/enlace.tgz" -C "$d" .
caso "enlaces"               1 "aplicar v1.1.0"      "$T/enlace.tgz" A=1
tar -czf "$T/abs.tgz" -P --transform='s,^,/tmp/,' "$d/style.css" 2>/dev/null
caso "ruta absoluta"         1 "aplicar v1.1.0"      "$T/abs.tgz" A=1
head -c 2000000 /dev/zero > "$T/grande"
caso "demasiado grande"      1 "aplicar v1.1.0"      "$T/grande" A=1
caso "falla la copia de BD"  1 "aplicar v1.1.0"      "$T/bueno.tgz" WP_FALLA_BD=1
grep -q 'Version: 1.0.0' "$T/temas/hijo/style.css" && { ok=$((ok+1)); echo "ok   tema intacto tras fallo"; } || { mal=$((mal+1)); echo "MAL  tema tocado"; }
caso "migración falla (HTTP)" 1 "aplicar v1.1.0"     "$T/bueno.tgz" CURL_CODIGO=500
paquete 1.3.0 > "$T/c.tgz"
caso "migración falla (opción)" 1 "aplicar v1.3.0"   "$T/c.tgz" MIGRACIONES_OPCION=r "WP_RES=error: boom"
paquete 1.4.0 > "$T/d.tgz"
caso "despliegue correcto"   0 "aplicar v1.4.0"      "$T/d.tgz" MIGRACIONES_OPCION=r
grep -q 'Version: 1.4.0' "$T/temas/hijo/style.css" && [ -d "$T/temas/hijo.ant" ] && ls "$T/copias"/bd-*.sql >/dev/null 2>&1 \
  && { ok=$((ok+1)); echo "ok   tema nuevo, .ant y copia de BD"; } || { mal=$((mal+1)); echo "MAL  resultado del despliegue"; }
grep -q APLICADO "$T/reg.log" && { ok=$((ok+1)); echo "ok   registro"; } || { mal=$((mal+1)); echo "MAL  registro"; }
echo "$ok bien, $mal mal"; [ $mal -eq 0 ]

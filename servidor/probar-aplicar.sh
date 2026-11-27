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
  *"estrategia migrar"*)
    case "${WP_MIGRAR:-ok}" in
      falla) echo "Error: boom en la migración" >&2; exit 1 ;;
      viejo) echo "Error: 'estrategia' is not a registered wp command. See 'wp help' for available commands." >&2; exit 1 ;;
      *) echo "Success: 0 pendientes" ;;
    esac ;;
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
grep -q 'Version: 1.0.0' "$T/temas/hijo/style.css" && [ ! -e "$T/temas/hijo.vell" ] && [ ! -e "$T/temas/hijo.nou" ] \
  && { ok=$((ok+1)); echo "ok   vuelta atrás: tema anterior restaurado"; } || { mal=$((mal+1)); echo "MAL  vuelta atrás"; }
grep -q 'VUELTA ATRÁS' "$T/reg.log" && { ok=$((ok+1)); echo "ok   vuelta atrás en el registro"; } || { mal=$((mal+1)); echo "MAL  registro de la vuelta atrás"; }
sal=$(env CURL_CODIGO=500 SSH_ORIGINAL_COMMAND="aplicar v1.1.0" "$AQUI/aplicar.sh" "$T/web" "$T/temas" hijo https://x.test/ < "$T/bueno.tgz" 2>&1 >/dev/null)
case "$sal" in *"vuelto atrás"*"NO se ha restaurado"*"bd-"*) ok=$((ok+1)); echo "ok   mensaje: vuelta atrás y copia de BD";; *) mal=$((mal+1)); echo "MAL  mensaje: $sal";; esac
paquete 1.3.0 > "$T/c.tgz"
caso "migración falla (comando)" 1 "aplicar v1.3.0"  "$T/c.tgz" WP_MIGRAR=falla
grep -q 'Version: 1.0.0' "$T/temas/hijo/style.css" && [ ! -e "$T/temas/hijo.vell" ] && [ ! -e "$T/temas/hijo.nou" ] \
  && { ok=$((ok+1)); echo "ok   migración falla: tema anterior restaurado"; } || { mal=$((mal+1)); echo "MAL  migración falla: no volvió atrás"; }
sal=$(env WP_MIGRAR=falla SSH_ORIGINAL_COMMAND="aplicar v1.3.0" "$AQUI/aplicar.sh" "$T/web" "$T/temas" hijo https://x.test/ < "$T/c.tgz" 2>&1 >/dev/null)
case "$sal" in *"boom en la migración"*"vuelto atrás"*"bd-"*) ok=$((ok+1)); echo "ok   migración falla: sale el error y la vuelta atrás";; *) mal=$((mal+1)); echo "MAL  mensaje migración: $sal";; esac
paquete 1.4.0 > "$T/d.tgz"
caso "plugin viejo: avisa y sigue" 0 "aplicar v1.4.0" "$T/d.tgz" WP_MIGRAR=viejo
grep -q 'plugin viejo' "$T/reg.log" && { ok=$((ok+1)); echo "ok   plugin viejo: aviso en el registro"; } || { mal=$((mal+1)); echo "MAL  plugin viejo sin aviso"; }
paquete 1.4.1 > "$T/d.tgz"
caso "despliegue correcto"   0 "aplicar v1.4.1"      "$T/d.tgz" A=1
grep -q 'Version: 1.4.1' "$T/temas/hijo/style.css" && [ -d "$T/temas/hijo.ant" ] && ls "$T/copias"/bd-*.sql >/dev/null 2>&1 \
  && { ok=$((ok+1)); echo "ok   tema nuevo, .ant y copia de BD"; } || { mal=$((mal+1)); echo "MAL  resultado del despliegue"; }
grep -q APLICADO "$T/reg.log" && { ok=$((ok+1)); echo "ok   registro"; } || { mal=$((mal+1)); echo "MAL  registro"; }
# Retención: solo las del guardián, y APLICAR_CONSERVAR las últimas.
touch "$T/copias/bd-ajeno.sql" "$T/copias/bd-20200101-000000.sql"
for v in 1.5.0 1.6.0 1.7.0; do paquete $v > "$T/r.tgz"; caso "retención $v" 0 "aplicar v$v" "$T/r.tgz" APLICAR_CONSERVAR=2; done
propias=$(ls "$T/copias"/bd-*.sql | grep -vc -e 'bd-ajeno.sql' -e 'bd-20200101-000000.sql')
[ "$propias" = 2 ] && [ -e "$T/copias/bd-ajeno.sql" ] && [ -e "$T/copias/bd-20200101-000000.sql" ] \
  && { ok=$((ok+1)); echo "ok   retención: 2 propias, ajenas intactas"; } || { mal=$((mal+1)); echo "MAL  retención ($propias propias)"; }
caso "APLICAR_CONSERVAR no válido" 1 "aplicar v1.8.0" "$T/r.tgz" APLICAR_CONSERVAR=0
echo "$ok bien, $mal mal"; [ $mal -eq 0 ]

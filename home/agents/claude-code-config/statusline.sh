#!/usr/bin/env bash
# Claude Code statusline — Catppuccin Mocha.
# Recibe el JSON de la sesion por stdin y pinta una sola linea.

input=$(cat)

# ---- Catppuccin Mocha (truecolor) ----
c() { printf '\033[38;2;%sm' "$1"; }
MAUVE=$(c '203;166;247')      # cwd
PINK=$(c '245;194;231')       # rama
TEXT=$(c '205;214;244')       # flecha, marcador de arbol sucio, separadores •
GREEN=$(c '166;227;161')      # lineas anadidas, umbral bajo en pct_color
RED=$(c '243;139;168')        # lineas borradas, umbral alto en pct_color, modelo por defecto
YELLOW=$(c '249;226;175')     # umbral medio en pct_color
TEAL=$(c '148;226;213')       # modelo: sonnet
MAROON=$(c '235;160;172')     # modelo: opus
PEACH=$(c '250;179;135')      # tokens in/out
OVERLAY=$(c '108;112;134')    # separadores
RESET=$'\033[0m'

# ---- Helpers ----

# Encadena partes no vacias con "• " (color TEXT) entre cada una; la primera
# parte no lleva separador. Usado para "modelo · diff · tokens" y para el
# cluster de la derecha "rate limit · rate limit · contexto".
segment_join() {
  local acc=$1 new=$2
  if [ -z "$new" ]; then printf '%s' "$acc"; return; fi
  if [ -z "$acc" ]; then printf '%s' "$new"
  else printf '%s%s %s• %s' "$acc" "$OVERLAY" "$TEXT" "$new"; fi
}

# Verde/amarillo/rojo segun umbral, para cualquier "% usado".
pct_color() {
  local pct=$1
  if [ "$(awk -v v="$pct" 'BEGIN{print (v>=80)?1:0}')" = "1" ]; then printf '%s' "$RED"
  elif [ "$(awk -v v="$pct" 'BEGIN{print (v>=50)?1:0}')" = "1" ]; then printf '%s' "$YELLOW"
  else printf '%s' "$GREEN"; fi
}

# Color del modelo segun su nombre (display_name o id, cualquiera de los dos formatos).
model_color() {
  case "${1,,}" in
    *sonnet*) printf '%s' "$TEAL" ;;
    *opus*) printf '%s' "$MAROON" ;;
    *) printf '%s' "$RED" ;;
  esac
}

# 15500 -> "15.5k", numeros chicos tal cual.
fmt_tokens() {
  local n=$1
  if [ "$n" -ge 1000 ]; then awk -v v="$n" 'BEGIN{printf "%.1fk", v/1000}'
  else printf '%d' "$n"; fi
}

# Largo visible de un string con colores ANSI truecolor, sin los codigos de escape.
visible_len() {
  local plain
  plain=$(sed -E $'s/\x1b\\[[0-9;]*m//g' <<<"$1")
  printf '%d' "${#plain}"
}

# ---- Datos de la sesion (con fallback si falta la clave) ----
cwd=$(jq -r '.workspace.current_dir // .cwd // empty' <<<"$input")
[ -z "$cwd" ] && cwd=$PWD
model=$(jq -r '.model.display_name // .model.id // "claude"' <<<"$input")
added=$(jq -r '.cost.total_lines_added // 0' <<<"$input")
removed=$(jq -r '.cost.total_lines_removed // 0' <<<"$input")
dir=${cwd/#$HOME/\~}

# ---- Rama y estado del arbol ----
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
git_part=""
if [ -n "$branch" ]; then
  git_part="${TEXT} -> ${PINK}${branch}"
  [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ] && git_part="${git_part} ${TEXT}•"
fi

# ---- Diff de la sesion ----
diff_part=""
if [ "$added" != "0" ] || [ "$removed" != "0" ]; then
  diff_part="${GREEN}+${added} ${RED}-${removed}"
fi

# ---- Tokens in/out del ultimo turno + % de cache hit ----
# Ausente antes de la 1a respuesta de la sesion o justo tras /compact.
# "in" suma input + cache_creation + cache_read: el input_tokens crudo excluye
# lo servido por cache y por si solo queda ridiculamente chico (misma cuenta
# que usa Claude Code para used_percentage del contexto). El % de cache es
# cache_read / in — cuanto de ese "in" salio gratis en vez de precio completo
# (cache_creation cuenta como "recien escrito", no como hit).
raw_in=$(jq -r '.context_window.current_usage.input_tokens // empty' <<<"$input")
out_tokens=$(jq -r '.context_window.current_usage.output_tokens // empty' <<<"$input")
io_part=""
if [ -n "$raw_in" ] || [ -n "$out_tokens" ]; then
  cache_creation=$(jq -r '.context_window.current_usage.cache_creation_input_tokens // 0' <<<"$input")
  cache_read=$(jq -r '.context_window.current_usage.cache_read_input_tokens // 0' <<<"$input")
  in_tokens=$(( ${raw_in:-0} + cache_creation + cache_read ))
  cache_note=""
  if [ "$in_tokens" -gt 0 ]; then
    cache_pct=$(awk -v r="$cache_read" -v t="$in_tokens" 'BEGIN{printf "%.0f", (r/t)*100}')
    cache_note=" (${cache_pct}%)"
  fi
  io_part=$(printf '%sin %s%s out %s' \
    "$PEACH" "$(fmt_tokens "$in_tokens")" "$cache_note" "$(fmt_tokens "${out_tokens:-0}")")
fi

# ---- Contexto de la ventana ----
# Ausente antes de la 1a respuesta de la sesion o justo tras /compact.
ctx_part=""
ctx_pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
[ -n "$ctx_pct" ] && ctx_part=$(printf '%s%.0f%% ctx' "$(pct_color "$ctx_pct")" "$ctx_pct")

# ---- Uso de rate limit ----
# Ausente sin plan de gateway.
rate5h_pct=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
rate5h_part=""
[ -n "$rate5h_pct" ] && rate5h_part=$(printf '%s5h %.0f%%' "$(pct_color "$rate5h_pct")" "$rate5h_pct")

rate7d_pct=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
rate7d_part=""
[ -n "$rate7d_pct" ] && rate7d_part=$(printf '%s7d %.0f%%' "$(pct_color "$rate7d_pct")" "$rate7d_pct")

# ---- Componer los dos lados de la linea ----
model_part="$(model_color "$model")${model}"

tail=""
tail=$(segment_join "$tail" "$model_part")
tail=$(segment_join "$tail" "$diff_part")
tail=$(segment_join "$tail" "$io_part")
left=$(printf '%s%s%s%s %s' "$MAUVE" "$dir" "$git_part" "$OVERLAY" "$tail")

right=""
for part in "$rate5h_part" "$rate7d_part" "$ctx_part"; do
  right=$(segment_join "$right" "$part")
done

# ---- Pegar el cluster derecho al borde ----
# $COLUMNS lo setea Claude Code (no hay tty para tput). $COLUMNS es el ancho
# total de la terminal, pero la caja del statusline reserva margen propio
# (~2 columnas a cada lado, no documentado oficialmente — ver
# github.com/anthropics/claude-code/issues/5430). Sin este descuento Claude
# Code trunca el borde derecho con "…".
if [ -n "$right" ]; then
  box_margin=4
  width=${COLUMNS:-80}
  padding=$((width - box_margin - $(visible_len "$left") - $(visible_len "$right")))
  [ "$padding" -lt 1 ] && padding=1
  printf '%s%*s%s%s\n' "$left" "$padding" "" "$right" "$RESET"
else
  printf '%s%s\n' "$left" "$RESET"
fi

#!/usr/bin/env bash
# Controller: styles all workspace items in one pass. Pins each to its current
# monitor (display=<id>) so each monitor's bar shows only its own workspaces.
#   visible on the focused monitor -> blue   (the one you're on)
#   visible on another monitor      -> sapphire
#   has windows, hidden             -> dim surface
#   empty                           -> not drawn
# display=<id> assumes sketchybar's display index matches aerospace monitor-id
# (both follow the macOS arrangement). Undocked: all workspaces map to mon 1.
source "$(dirname "$0")/colors.sh"

FOC_MON="$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)"
MAP="$(aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}' 2>/dev/null)"
VIS="$(aerospace list-workspaces --monitor all --visible --format '%{workspace} %{monitor-id}' 2>/dev/null)"
OCC="$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)"

mon_of() { printf '%s\n' "$MAP" | awk -v s="$1" '$1 == s {print $2; exit}'; }
vismon() { printf '%s\n' "$VIS" | awk -v s="$1" '$1 == s {print $2; exit}'; }
is_occ() { printf '%s\n' "$OCC" | grep -Fxq -- "$1"; }

# Assigned workspaces show their app glyph; everything else shows a dot.
ws_label() {
  case "$1" in
    1) printf '%s' "$WS_ICON_1" ;;
    2) printf '%s' "$WS_ICON_2" ;;
    3) printf '%s' "$WS_ICON_3" ;;
    4) printf '%s' "$WS_ICON_4" ;;
    7) printf '%s' "$WS_ICON_7" ;;
    *) printf '%s' "$WS_DOT" ;;
  esac
}

args=()
for sid in 1 2 3 4 5 6 7 8 9; do
  item="space.$sid"
  lbl="$(ws_label "$sid")"
  vm="$(vismon "$sid")"
  if [ -n "$vm" ]; then
    if [ "$vm" = "$FOC_MON" ]; then bg="$BLUE"; else bg="$SAPPHIRE"; fi
    args+=(--animate tanh 15 --set "$item" display="$vm" drawing=on label="$lbl" background.color="$bg" label.color="$CRUST")
  elif is_occ "$sid"; then
    m="$(mon_of "$sid")"
    args+=(--animate tanh 15 --set "$item" display="${m:-1}" drawing=on label="$lbl" background.color="$SURFACE0" label.color="$TEXT")
  else
    args+=(--set "$item" drawing=off)
  fi
done

sketchybar "${args[@]}"

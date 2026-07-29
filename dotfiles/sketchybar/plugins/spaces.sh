#!/usr/bin/env bash
# Controller: styles every monitor's workspace pills AND app labels in one pass.
#
# Items are created per SKETCHYBAR DISPLAY INDEX (space.<sb>.<sid>,
# front_app.<sb>), each pinned display=<sb> at creation. sketchybar's display
# index is the NSScreen order (main display first) which does NOT match
# aerospace's monitor-id (left->right by arrangement) — e.g. main monitor is
# aerospace-id 2 but sketchybar-display 1. aerospace hands us the bridge via
# %{monitor-appkit-nsscreen-screens-id}, which equals the sketchybar index, so
# we map monitor-id -> sb here and only ever toggle drawing/label/colour (never
# display=, which would break the per-display brackets). Recomputed live, so it
# follows dock/undock automatically.
#   pill visible on the focused monitor -> blue    (the one you're on)
#   pill visible on another monitor      -> sapphire
#   pill has windows, hidden             -> dim surface
#   pill empty                           -> not drawn
source "$(dirname "$0")/colors.sh"

FOC_MON="$(aerospace list-monitors --focused --format '%{monitor-id}' 2>/dev/null)"
# "<monitor-id> <sketchybar-display-index>" per line.
MONS="$(aerospace list-monitors --format '%{monitor-id} %{monitor-appkit-nsscreen-screens-id}' 2>/dev/null)"
MAP="$(aerospace list-workspaces --monitor all --format '%{workspace} %{monitor-id}' 2>/dev/null)"
VIS="$(aerospace list-workspaces --monitor all --visible --format '%{workspace} %{monitor-id}' 2>/dev/null)"
OCC="$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)"

# Globally focused window + the monitor it's on (used for that monitor's label).
GAPP="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
GMON="$(aerospace list-windows --focused --format '%{monitor-id}' 2>/dev/null)"

mon_of_sb() { printf '%s\n' "$MONS" | awk -v s="$1" '$2 == s {print $1; exit}'; }
mon_of()    { printf '%s\n' "$MAP"  | awk -v w="$1" '$1 == w {print $2; exit}'; }
is_vis()    { printf '%s\n' "$VIS"  | awk -v w="$1" '$1 == w {found=1} END{exit !found}'; }
is_occ()    { printf '%s\n' "$OCC"  | grep -Fxq -- "$1"; }
vis_ws()    { printf '%s\n' "$VIS"  | awk -v m="$1" '$2 == m {print $1; exit}'; }

# Assigned workspaces show their app glyph; everything else shows a dot.
ws_label() {
  case "$1" in
    1) printf '%s' "$WS_ICON_1" ;;
    2) printf '%s' "$WS_ICON_2" ;;
    3) printf '%s' "$WS_ICON_3" ;;
    4) printf '%s' "$WS_ICON_4" ;;
    7) printf '%s' "$WS_ICON_7" ;;
    8) printf '%s' "$WS_ICON_8" ;;
    *) printf '%s' "$WS_DOT" ;;
  esac
}

args=()
for sb in $(seq 1 "${MAX_DISPLAYS:-1}"); do
  mon="$(mon_of_sb "$sb")"

  # No monitor at this sketchybar index (undocked etc.) -> hide the whole island.
  if [ -z "$mon" ]; then
    args+=(--set front_app."$sb" drawing=off label="")
    for sid in 1 2 3 4 5 6 7 8 9; do args+=(--set space."$sb"."$sid" drawing=off); done
    continue
  fi

  # ---- app label for this monitor ----
  # Focused monitor shows the truly focused app; others show the topmost window
  # on their visible workspace. Blank when that workspace has no windows.
  vw="$(vis_ws "$mon")"
  fapp=""
  if [ -n "$vw" ]; then
    cnt="$(aerospace list-windows --workspace "$vw" --count 2>/dev/null)"
    if [ "${cnt:-0}" -gt 0 ] 2>/dev/null; then
      if [ "$mon" = "$GMON" ]; then
        fapp="$GAPP"
      else
        fapp="$(aerospace list-windows --workspace "$vw" --format '%{app-name}' 2>/dev/null | head -1)"
      fi
    fi
  fi
  # Hide the app label entirely when its workspace is empty — an empty item still
  # reserves ~20px of padding, which shows as dead space inside the island (most
  # visible on external monitors sitting on an empty workspace).
  if [ -n "$fapp" ]; then
    args+=(--set front_app."$sb" drawing=on label="$fapp")
  else
    args+=(--set front_app."$sb" drawing=off label="")
  fi

  # ---- workspace pills for this monitor ----
  for sid in 1 2 3 4 5 6 7 8 9; do
    item="space.$sb.$sid"
    if [ "$(mon_of "$sid")" != "$mon" ]; then
      args+=(--set "$item" drawing=off)
      continue
    fi
    lbl="$(ws_label "$sid")"
    # NOTE: no --animate. Animating a pill's width mutates it independently of
    # drawing, so when the controller re-runs and flips a pill off mid-animation
    # the item is left with phantom width -> a stray gap before front_app. Atomic
    # (unanimated) drawing/width changes keep every island tight.
    if is_vis "$sid"; then
      if [ "$mon" = "$FOC_MON" ]; then bg="$BLUE"; else bg="$SAPPHIRE"; fi
      args+=(--set "$item" drawing=on label="$lbl" background.color="$bg" label.color="$CRUST")
    elif is_occ "$sid"; then
      args+=(--set "$item" drawing=on label="$lbl" background.color="$SURFACE0" label.color="$TEXT")
    else
      args+=(--set "$item" drawing=off)
    fi
  done
done

sketchybar "${args[@]}"

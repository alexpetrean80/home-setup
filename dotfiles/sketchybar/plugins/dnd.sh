#!/usr/bin/env bash
# macOS 26 gates the real Focus state behind Full Disk Access (~/Library/
# DoNotDisturb is unreadable), so this tracks what WE last toggled via the
# bar. A Focus change made elsewhere (menu bar, schedule) won't reflect here
# — that would need FDA.
source "$(dirname "$0")/colors.sh"

STATE="${TMPDIR:-/tmp}/sketchybar_focus_state"

if [ "$SENDER" = "focus_toggle" ]; then
  CUR=0
  [ -f "$STATE" ] && read -r CUR < "$STATE"
  if [ "$CUR" = 1 ]; then echo 0 > "$STATE"; else echo 1 > "$STATE"; fi
fi

ON=0
[ -f "$STATE" ] && read -r ON < "$STATE"

if [ "$ON" = 1 ]; then
  sketchybar --animate tanh 15 --set "$NAME" icon="$ICON_BELL_OFF" icon.color="$MAUVE"
else
  sketchybar --animate tanh 15 --set "$NAME" icon="$ICON_BELL" icon.color="$SUBTEXT0"
fi

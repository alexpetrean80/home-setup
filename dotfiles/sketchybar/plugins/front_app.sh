#!/usr/bin/env bash
# Show the aerospace-focused window's app name, but clear it when the focused
# workspace has no windows (macOS front_app stays stale on an empty workspace,
# and aerospace's --focused can report the last window, so gate on the count).
FWS="$(aerospace list-workspaces --focused 2>/dev/null)"
COUNT="$(aerospace list-windows --workspace "$FWS" --count 2>/dev/null)"

if [ "${COUNT:-0}" -gt 0 ] 2>/dev/null; then
  APP="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)"
  sketchybar --set "$NAME" label="$APP"
else
  sketchybar --set "$NAME" label=""
fi

# AeroSpace's service-mode `close-all-windows-but-current`: kill every window
# on the focused workspace except the focused one. Bound to BackSpace in sway's
# service mode (alt+shift+; then BkSp).
focused="$(swaymsg -t get_tree | jq 'first(.. | objects | select(.focused? == true) | .id)')"
workspace="$(swaymsg -t get_workspaces | jq -r 'first(.[] | select(.focused) | .name)')"

if [ -z "$focused" ] || [ "$focused" = "null" ] || [ -z "$workspace" ]; then
  exit 0
fi

# `.pid != null` filters out the layout containers, leaving real windows.
swaymsg -t get_tree |
  jq -r --arg ws "$workspace" --argjson keep "$focused" '
    first(.. | objects | select(.type == "workspace" and .name == $ws))
    | [recurse(.nodes[]?, .floating_nodes[]?) | select(.pid != null) | .id]
    | map(select(. != $keep))
    | .[]
  ' |
  while read -r id; do
    swaymsg "[con_id=$id] kill"
  done

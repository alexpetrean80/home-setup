# which-key style keymap popup — the sway port of the sketchybar cheatsheet
# item. wofi in dmenu mode is the closest thing to a centred floating list;
# the selection is discarded, this is display-only.
#
# Bound to alt+shift+/ ("?") in modules/homemanager/sway.nix. Keep the rows in
# sync with the keybindings there.
rows=(
  "SWAY — KEYMAP"
  "Alt Enter          new terminal"
  "Alt Shift Enter    new browser window"
  "Alt space / Alt d  launcher (wofi drun)"
  "Alt Shift d        run a command (wofi run)"
  "Alt Shift w        whatsapp (nchat in a terminal) → ws8"
  "Alt hjkl           focus  ← ↓ ↑ →"
  "Alt Shift hjkl     move window"
  "Alt 1-9            go to workspace  (1 zen · 2 deezer · 3 term"
  "                    5 steam · 7 discord · 8 whatsapp)"
  "Alt Shift 1-9      move window → workspace"
  "Alt Tab            last workspace"
  "Alt [ ]            focus monitor  left / right"
  "Alt Shift [ ]      move window → monitor"
  "Alt / , f          split · stacking/tabbed · fullscreen"
  "Alt - =            resize  shrink / grow width"
  "Alt r              resize mode — hjkl, esc to exit"
  "Alt Shift space    toggle float / tile"
  "Alt Ctrl space     focus float ↔ tiled"
  "Alt q              close window"
  "Alt Shift c        reload config"
  "Alt Shift ;        service — f float · BkSp kill others · l lock"
  "                   d displays · s suspend · e exit · esc reload"
  "Print              region screenshot → clipboard"
  "Shift Print        full screenshot → clipboard"
  "Alt Print          region screenshot → ~/Pictures"
  "media keys         volume · mic · brightness · play/next/prev"
  "Alt Shift / or Esc to close"
)

printf '%s\n' "${rows[@]}" |
  wofi \
    --dmenu \
    --insensitive \
    --prompt 'sway keymap' \
    --width 760 \
    --height 640 \
    --cache-file /dev/null \
    >/dev/null 2>&1 || true

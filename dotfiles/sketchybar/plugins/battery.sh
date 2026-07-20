#!/usr/bin/env bash
source "$(dirname "$0")/colors.sh"

PERCENT="$(pmset -g batt | grep -Eo '[0-9]+%' | tr -d '%')"
CHARGING="$(pmset -g batt | grep 'AC Power')"

[ -z "$PERCENT" ] && exit 0

if [ -n "$CHARGING" ]; then
  ICON="$ICON_CHARGE"
  COLOR="$GREEN"
else
  case "$PERCENT" in
    100 | 9[0-9] | 8[0-9]) ICON="$ICON_BAT_FULL";  COLOR="$GREEN" ;;
    [67][0-9])             ICON="$ICON_BAT_3";     COLOR="$GREEN" ;;
    [45][0-9])             ICON="$ICON_BAT_HALF";  COLOR="$YELLOW" ;;
    [23][0-9])             ICON="$ICON_BAT_1";     COLOR="$PEACH" ;;
    *)                     ICON="$ICON_BAT_EMPTY"; COLOR="$RED" ;;
  esac
fi

sketchybar --animate tanh 15 --set "$NAME" icon="$ICON" icon.color="$COLOR" label.color="$COLOR" label="$PERCENT%"

#!/usr/bin/env bash
# Current conditions from wttr.in (IP-geolocated, no API key). Nerd Font glyph
# mapped from the condition text; sunny/clear picks a night variant after dark.
# Last good reading cached so a failed fetch keeps the value instead of blanking.
source "$(dirname "$0")/colors.sh"

CACHE="${TMPDIR:-/tmp}/sketchybar_weather"

# %C = condition text, %t = temperature (unit follows the IP's locale).
RAW="$(curl -sf --max-time 5 'wttr.in/?format=%C|%t' 2>/dev/null)"
case "$RAW" in
  ""|*Unknown*|*Sorry*) : ;;              # keep cache on error/rate-limit
  *) printf '%s' "$RAW" > "$CACHE" ;;
esac
[ -f "$CACHE" ] && RAW="$(cat "$CACHE")"

if [ -z "$RAW" ]; then
  sketchybar --set "$NAME" icon="$ICON_WEATHER_CLOUDY" icon.color="$SUBTEXT0" \
    label.color="$SUBTEXT0" label="n/a"
  exit 0
fi

COND="${RAW%%|*}"
TEMP="${RAW##*|}"
TEMP="${TEMP//+/}"        # wttr pads positive temps with a leading +
TEMP="${TEMP// /}"

HOUR="$(date +%H)"
NIGHT=0
{ [ "$HOUR" -ge 19 ] || [ "$HOUR" -lt 6 ]; } && NIGHT=1

c="$(printf '%s' "$COND" | tr '[:upper:]' '[:lower:]')"
case "$c" in
  *thunder*)                        ICON="$ICON_WEATHER_STORM";  COLOR="$YELLOW" ;;
  *snow*|*blizzard*|*sleet*|*ice*)  ICON="$ICON_WEATHER_SNOW";   COLOR="$SAPPHIRE" ;;
  *"heavy rain"*|*torrential*)      ICON="$ICON_WEATHER_POUR";   COLOR="$BLUE" ;;
  *rain*|*drizzle*|*shower*)        ICON="$ICON_WEATHER_RAIN";   COLOR="$BLUE" ;;
  *fog*|*mist*)                     ICON="$ICON_WEATHER_FOG";    COLOR="$SUBTEXT0" ;;
  *overcast*|*cloudy*)              ICON="$ICON_WEATHER_CLOUDY"; COLOR="$SUBTEXT0" ;;
  *partly*)                         ICON="$ICON_WEATHER_PARTLY"; COLOR="$TEAL" ;;
  *sunny*|*clear*)
    if [ "$NIGHT" -eq 1 ]; then ICON="$ICON_WEATHER_NIGHT"; COLOR="$LAVENDER"
    else ICON="$ICON_WEATHER_SUNNY"; COLOR="$YELLOW"; fi ;;
  *)                                ICON="$ICON_WEATHER_CLOUDY"; COLOR="$SUBTEXT0" ;;
esac

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" \
  label.color="$TEXT" label="$TEMP"

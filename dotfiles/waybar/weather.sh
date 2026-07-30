# Current conditions from wttr.in (IP-geolocated, no API key), emitted as
# waybar JSON. Port of dotfiles/sketchybar/plugins/weather.sh.
#
# Glyphs are written as printf byte sequences rather than literal characters —
# private-use codepoints get mangled in transit (same reason as colors.sh).
ICON_SUN=$(printf '\xef\x86\x85')   # nf-fa-sun_o        U+F185
ICON_MOON=$(printf '\xef\x86\x86')  # nf-fa-moon_o       U+F186
ICON_CLOUD=$(printf '\xef\x83\x82') # nf-fa-cloud        U+F0C2
ICON_RAIN=$(printf '\xef\x83\xa9')  # nf-fa-umbrella     U+F0E9
ICON_STORM=$(printf '\xef\x83\xa7') # nf-fa-bolt         U+F0E7
ICON_SNOW=$(printf '\xef\x8b\x9c')  # nf-fa-snowflake_o  U+F2DC

RAW="$(curl -sf --max-time 5 'wttr.in/?format=%C|%t' 2>/dev/null || true)"

if [ -z "$RAW" ]; then
  # No network / wttr down: draw nothing rather than a stale reading.
  jq -nc '{text: "", tooltip: "weather unavailable"}'
  exit 0
fi

COND="${RAW%%|*}"
TEMP="${RAW##*|}"
TEMP="${TEMP//+/}"    # wttr pads positive temps with a leading +
TEMP="${TEMP// /}"

# Night variant for clear skies after dark.
HOUR="$(date +%-H)"
if [ "$HOUR" -ge 20 ] || [ "$HOUR" -lt 6 ]; then
  CLEAR="$ICON_MOON"
else
  CLEAR="$ICON_SUN"
fi

# Lowercase once, then match wttr's condition wording.
LOWER="$(printf '%s' "$COND" | tr '[:upper:]' '[:lower:]')"
case "$LOWER" in
*thunder* | *storm*) ICON="$ICON_STORM" ;;
*snow* | *sleet* | *ice* | *blizzard*) ICON="$ICON_SNOW" ;;
*rain* | *drizzle* | *shower*) ICON="$ICON_RAIN" ;;
*fog* | *mist* | *overcast* | *cloud*) ICON="$ICON_CLOUD" ;;
*sun* | *clear*) ICON="$CLEAR" ;;
*) ICON="$ICON_CLOUD" ;;
esac

jq -nc \
  --arg text "$ICON  $TEMP" \
  --arg tooltip "$COND  $TEMP" \
  '{text: $text, tooltip: $tooltip, class: "weather"}'

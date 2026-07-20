#!/usr/bin/env bash
# Memory used % ~ (active + wired + compressed) / total, à la Activity Monitor.
source "$(dirname "$0")/colors.sh"

PAGE="$(vm_stat | sed -n 's/.*page size of \([0-9]*\).*/\1/p')"
PAGE="${PAGE:-16384}"

read -r A W C <<<"$(vm_stat | awk '
  /Pages active/                 {gsub(/[^0-9]/,"",$NF); a=$NF}
  /Pages wired down/             {gsub(/[^0-9]/,"",$NF); w=$NF}
  /Pages occupied by compressor/ {gsub(/[^0-9]/,"",$NF); c=$NF}
  END {print a, w, c}')"

TOTAL="$(sysctl -n hw.memsize)"
USED=$(((A + W + C) * PAGE * 100 / TOTAL))

if [ "$USED" -ge 85 ]; then
  COLOR="$RED"
elif [ "$USED" -ge 65 ]; then
  COLOR="$PEACH"
else
  COLOR="$LAVENDER"
fi

sketchybar --animate tanh 15 --set "$NAME" icon.color="$COLOR" label.color="$COLOR" label="$USED%"

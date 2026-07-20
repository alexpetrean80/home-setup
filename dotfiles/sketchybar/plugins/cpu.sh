#!/usr/bin/env bash
source "$(dirname "$0")/colors.sh"

CORES="$(sysctl -n hw.logicalcpu)"
LOAD="$(ps -A -o %cpu | awk '{s += $1} END {print s}')"
USAGE="$(awk -v l="$LOAD" -v c="$CORES" 'BEGIN {printf "%.0f", l / c}')"

if [ "$USAGE" -ge 80 ]; then
  COLOR="$RED"
elif [ "$USAGE" -ge 50 ]; then
  COLOR="$PEACH"
else
  COLOR="$TEAL"
fi

sketchybar --animate tanh 15 --set "$NAME" label="$USAGE%" icon.color="$COLOR" label.color="$COLOR"

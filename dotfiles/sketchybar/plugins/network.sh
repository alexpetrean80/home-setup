#!/usr/bin/env bash
# Up/down throughput on the default-route interface. Rate = byte delta
# between ticks / update_freq. State cached in TMPDIR.
source "$(dirname "$0")/colors.sh"

FREQ=2
STATE="${TMPDIR:-/tmp}/sketchybar_net_state"
IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"

if [ -z "$IFACE" ]; then
  sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color="$RED" label.color="$RED" label="off"
  exit 0
fi

# First matching row is the <Link#n> row: $7=Ibytes, $10=Obytes.
read -r RX TX <<<"$(netstat -ibn | awk -v i="$IFACE" '$1==i {print $7, $10; exit}')"
RX="${RX:-0}"
TX="${TX:-0}"

PRX="$RX"
PTX="$TX"
[ -f "$STATE" ] && read -r PRX PTX < "$STATE"
echo "$RX $TX" > "$STATE"

DRX=$(((RX - PRX) / FREQ)); [ "$DRX" -lt 0 ] && DRX=0
DTX=$(((TX - PTX) / FREQ)); [ "$DTX" -lt 0 ] && DTX=0

hr() { awk -v b="$1" 'BEGIN{split("B K M G T",u," "); i=1; while(b>=1024 && i<5){b/=1024;i++} printf "%.0f%s", b, u[i]}'; }

sketchybar --set "$NAME" icon="$ICON_WIFI" icon.color="$SAPPHIRE" label.color="$SAPPHIRE" \
  label="$(hr "$DRX")↓ $(hr "$DTX")↑"

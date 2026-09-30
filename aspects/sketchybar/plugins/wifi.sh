#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../colors.sh"

# SSID queries can report "not associated" on macOS even with an active link.
# Discover the Wi-Fi device rather than assuming en0 is wireless.
export LC_ALL=C
device="$(networksetup -listallhardwareports 2>/dev/null | awk '
  /Hardware Port: (Wi-Fi|AirPort)/ {wifi=1; next}
  wifi && /Device:/ {print $2; exit}
')"

if [ -z "$device" ]; then
  status="unavailable"
elif [[ "$(networksetup -getairportpower "$device" 2>/dev/null)" == *": Off" ]]; then
  status="off"
else
  link="$(ifconfig "$device" 2>/dev/null | awk '/status:/ {print $2; exit}')"
  case "$link" in
    active) status="connected" ;;
    inactive) status="disconnected" ;;
    *) status="unknown" ;;
  esac
fi

case "$status" in
  connected)
    icon="󰖩" # md-wifi
    color="$CAT_GREEN"
    ;;
  disconnected)
    icon="󰤮" # md-wifi_strength_off_outline
    color="$CAT_YELLOW"
    ;;
  off)
    icon="󰖪" # md-wifi_off
    color="$CAT_OVERLAY0"
    ;;
  *)
    icon="󱚵" # md-wifi_alert
    color="$CAT_RED"
    ;;
esac

sketchybar --set "$NAME" icon="$icon" icon.color="$color" label.drawing=off

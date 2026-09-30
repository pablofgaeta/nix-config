#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../colors.sh"

battery_line="$(LC_ALL=C pmset -g batt | awk '/InternalBattery/ {print; exit}')"
# The percentage precedes the first semicolon; splitting on '%' loses it.
if [[ "$battery_line" =~ ([0-9]+)% ]]; then
  percent="${BASH_REMATCH[1]}%"
else
  sketchybar --set "$NAME" drawing=off
  exit 0
fi
state="$(printf '%s\n' "$battery_line" | awk -F '; ' '{print $2}')"

color="$CAT_GREEN"
case "$state" in
  charging*) icon="󰂄" ;; # md-battery_charging
  charged*) icon="󰁹" ;; # md-battery
  *)
    level="${percent%%%}"
    if ((level <= 10)); then
      icon="󰂃" # md-battery_alert
      color="$CAT_RED"
    elif ((level <= 20)); then
      icon="󰁺" # md-battery_10
      color="$CAT_PEACH"
    elif ((level <= 40)); then
      icon="󰁼" # md-battery_30
      color="$CAT_YELLOW"
    elif ((level <= 60)); then icon="󰁾" # md-battery_50
    elif ((level <= 80)); then icon="󰂀" # md-battery_70
    elif ((level < 100)); then icon="󰂂" # md-battery_90
    else icon="󰁹"
    fi
    ;;
esac

sketchybar --set "$NAME" drawing=on icon="$icon" icon.color="$color" label="$percent"

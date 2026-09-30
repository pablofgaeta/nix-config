#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../colors.sh"

state_file="${TMPDIR:-/tmp}/sketchybar-app-drawer-open"
items=(apps.ghostty apps.brave apps.obsidian apps.spotify)

open_drawer() {
  : >"$state_file"
  sketchybar --set apps icon="󰀻" icon.color="$CAT_BASE" background.color="$CAT_MAUVE" background.drawing=on
  for item in "${items[@]}"; do
    sketchybar --set "$item" drawing=on
  done
  sketchybar --animate tanh 24 \
    --set apps.ghostty width=36 icon.padding_left=10 icon.padding_right=10 \
    --set apps.brave width=36 icon.padding_left=10 icon.padding_right=10 \
    --set apps.obsidian width=36 icon.padding_left=10 icon.padding_right=10 \
    --set apps.spotify width=36 icon.padding_left=10 icon.padding_right=10
}

close_drawer() {
  rm -f "$state_file"
  sketchybar --set apps icon="󰀻" icon.color="$CAT_MAUVE" background.color="$CAT_ACCENT_DIM" background.drawing=on
  sketchybar --animate tanh 24 \
    --set apps.ghostty width=0 icon.padding_left=0 icon.padding_right=0 \
    --set apps.brave width=0 icon.padding_left=0 icon.padding_right=0 \
    --set apps.obsidian width=0 icon.padding_left=0 icon.padding_right=0 \
    --set apps.spotify width=0 icon.padding_left=0 icon.padding_right=0
  sleep 0.25
  for item in "${items[@]}"; do
    sketchybar --set "$item" drawing=off
  done
}

case "${1:-toggle}" in
  open) open_drawer ;;
  close) close_drawer ;;
  toggle)
    if [ -e "$state_file" ]; then close_drawer; else open_drawer; fi
    ;;
  *) exit 2 ;;
esac

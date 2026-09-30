#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../colors.sh"

case "${SENDER:-}" in
  mouse.entered) color="$CAT_ACCENT_HOVER" ;;
  mouse.exited) color="$CAT_TRANSPARENT" ;;
  *) exit 0 ;;
esac

sketchybar --animate sin 8 --set "$NAME" background.color="$color"

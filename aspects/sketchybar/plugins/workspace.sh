#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/../colors.sh"

if ! command -v aerospace >/dev/null 2>&1; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

workspace="${NAME#space.}"
focused="${FOCUSED_WORKSPACE:-}"
if [ -z "$focused" ]; then
  focused="$(aerospace list-workspaces --focused 2>/dev/null | head -n 1)"
fi

app_icons=()
while IFS= read -r app; do
  [ -n "$app" ] || continue
  shopt -s nocasematch
  case "$app" in
    Ghostty) icon="󰊠" ;;
    Terminal|iTerm2) icon="󰆍" ;;
    "Podman Desktop") icon="" ;;
    "Brave Browser") icon="🦁" ;;
    "Google Chrome"|"Google Chrome Canary"|Chromium) icon="" ;;
    Firefox|"Firefox Developer Edition") icon="" ;;
    Safari) icon="" ;;
    "Visual Studio Code"|"Code - Insiders"|Cursor) icon="" ;;
    Claude) icon="" ;;
    "GitHub Desktop") icon="" ;;
    Notion) icon="" ;;
    Neovim|Neovide) icon="" ;;
    Obsidian) icon="󰹕" ;;
    Spotify|Music|GarageBand|Audacity|REAPER|"Ableton Live 11 Lite"|"Analog Lab 4"|"Analog Lab V"|"Piano V2"|"Piano V3"|"VOX Continental V2"|"Wurli V2") icon="" ;;
    Slack) icon="" ;;
    Discord) icon="" ;;
    Steam|"Steam Link"|"Slay the Spire"|"Stardew Valley"|Games) icon="󰊖" ;;
    Finder) icon="󰉋" ;;
    "System Settings"|"System Preferences"|"System Information") icon="󰒓" ;;
    Mail) icon="󰇮" ;;
    "Adobe Acrobat Reader") icon="󰈦" ;;
    Messages|FaceTime|Webex|"zoom.us") icon="󰕧" ;;
    Notes) icon="󰎞" ;;
    Calendar) icon="󰃭" ;;
    Reminders) icon="󰄬" ;;
    Books) icon="󰂺" ;;
    Preview|Photos|"Photo Booth"|"Image Playground") icon="󰋩" ;;
    Pages|TextEdit|"Script Editor") icon="󰈙" ;;
    Numbers) icon="󰨷" ;;
    Keynote) icon="󰐕" ;;
    "App Store") icon="" ;;
    "DB Browser for SQLite"|"pgAdmin 4"|Postgres) icon="󰆼" ;;
    NordVPN|Tailscale|WireGuard) icon="󰖂" ;;
    Bitwarden) icon="󰌾" ;;
    *) icon="$app" ;;
  esac
  app_icons+=("$icon")
done < <(aerospace list-windows --workspace "$workspace" --format '%{app-name}' 2>/dev/null)

if ((${#app_icons[@]})); then
  label="${app_icons[*]}"
  label_drawing=on
else
  label=""
  label_drawing=off
fi

if [ "$workspace" = "$focused" ]; then
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$CAT_BASE" \
    label="$label" \
    label.drawing="$label_drawing" \
    label.color="$CAT_BASE" \
    background.drawing=on \
    background.color="$CAT_LAVENDER" \
    background.border_color="$CAT_LAVENDER"
else
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color="$CAT_SUBTEXT1" \
    label="$label" \
    label.drawing="$label_drawing" \
    label.color="$CAT_SUBTEXT1" \
    background.drawing=on \
    background.color="$CAT_ACCENT_DIM" \
    background.border_color="$CAT_OVERLAY0"
fi

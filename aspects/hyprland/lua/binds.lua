-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod = "SUPER"
local altMod = "ALT"

-- Keep window-manager shortcuts on SUPER so applications receive CTRL and ALT.
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("hyprlock"))
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd("cliphist list | rofi -dmenu -display-columns 2 | cliphist decode | wl-copy")
)
hl.bind(
	mainMod .. " + SHIFT + E",
	hl.dsp.exec_cmd(
		"wlogout --buttons-per-row 3 --column-spacing 16 --row-spacing 16 --margin-left 500 --margin-right 500 --margin-top 330 --margin-bottom 330 --no-span"
	)
)
hl.bind("Print", hl.dsp.exec_cmd("grimblast save screen"))

-- Move and resize windows
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Switch workspaces
hl.bind(altMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(altMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(altMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(altMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(altMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(altMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(altMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(altMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(altMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(altMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(altMod .. " + S", hl.dsp.workspace.toggle_special("magic"))

-- Move the active window
hl.bind(altMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(altMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(altMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(altMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(altMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(altMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(altMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(altMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(altMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(altMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))
hl.bind(altMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Focus windows with SUPER + arrow keys or Vim keys.
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next())

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

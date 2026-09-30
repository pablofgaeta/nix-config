-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm-app -- " .. terminal)
	hl.exec_cmd("uwsm app -- mako")
	hl.exec_cmd("uwsm-app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm-app -- wl-paste --type image --watch cliphist store")
end)

"""Run with python3 -m unittest discover -s den/aspects/desktop/sketchybar/tests."""

import os
from pathlib import Path
import subprocess
import unittest

CONFIG = Path(__file__).resolve().parents[1]
AEROSPACE_ASPECT = Path(__file__).resolve().parents[2] / "aerospace.nix"
ZELLIJ_ASPECT = Path(__file__).resolve().parents[2] / "zellij/zellij.nix"
ZELLIJ_THEME = ZELLIJ_ASPECT.parent / "themes/catppuccin-mocha-surface.kdl"
LARK_HOST = Path(__file__).resolve().parents[3] / "hosts/lark.nix"
HARNESS = r"""
sketchybar() { printf '%s\n' "$@"; }
pmset() { printf '%s\n' "$BATTERY"; }
networksetup() {
  case "$1" in
    -listallhardwareports) printf 'Hardware Port: Wi-Fi\nDevice: en7\n' ;;
    -getairportpower) test "$2" = en7 || return 1; printf 'Wi-Fi Power (en7): %s\n' "$POWER" ;;
    -getairportnetwork) printf '%s\n' "$NETWORK" ;;
  esac
}
ifconfig() { test "$1" = en7 || return 1; printf '\tstatus: %s\n' "$LINK"; }
aerospace() {
  case "$1 $2" in
    "list-workspaces --focused") printf '%s\n' "$FOCUSED_WORKSPACE" ;;
    "list-windows --workspace") printf '%s\n' "$WINDOWS" ;;
    *) return 1 ;;
  esac
}
source "$1"
"""


class PluginsTest(unittest.TestCase):
    def run_plugin(self, name, **fixtures):
        env = dict(
            os.environ,
            NAME=name,
            BATTERY="",
            POWER="On",
            LINK="active",
            NETWORK="You are not associated with an AirPort network.",
            FOCUSED_WORKSPACE="1",
            WINDOWS="",
        )
        env.update(fixtures)
        result = subprocess.run(
            [
                "/bin/bash",
                "-c",
                HARNESS,
                "test",
                str(CONFIG / "plugins" / f"{name}.sh"),
            ],
            env=env,
            text=True,
            capture_output=True,
            check=True,
        )
        return result.stdout.splitlines()

    def test_battery_percentage_and_states(self):
        for percent, state, icon in [
            (92, "discharging", "\U000f0082"),
            (8, "charging", "\U000f0084"),
            (100, "charged", "\U000f0079"),
            (5, "discharging", "\U000f0083"),
            (15, "discharging", "\U000f007a"),
            (35, "discharging", "\U000f007c"),
            (55, "discharging", "\U000f007e"),
            (75, "discharging", "\U000f0080"),
        ]:
            with self.subTest(state=state):
                args = self.run_plugin(
                    "battery",
                    BATTERY=f" -InternalBattery-0 (id=123)\t{percent}%; {state}; 7:56 remaining",
                )
                self.assertIn(f"label={percent}%", args)
                self.assertIn(f"icon={icon}", args)

    def test_wifi_uses_link_not_ssid_access(self):
        args = self.run_plugin("wifi")
        self.assertIn("icon=\U000f05a9", args)
        self.assertIn("label.drawing=off", args)

    def test_wifi_disconnected_and_power_off(self):
        self.assertIn("icon=\U000f092e", self.run_plugin("wifi", LINK="inactive"))
        self.assertIn(
            "icon=\U000f05aa", self.run_plugin("wifi", POWER="Off", LINK="inactive")
        )

    def test_wifi_does_not_display_command_errors_as_network_names(self):
        self.assertIn(
            "icon=\U000f05a9", self.run_plugin("wifi", NETWORK="Error: unavailable")
        )

    def test_missing_battery_does_not_show_bare_percent(self):
        self.assertIn(
            "drawing=off",
            self.run_plugin("battery", BATTERY="Now drawing from 'AC Power'"),
        )

    def test_workspace_highlights_focused_workspace(self):
        focused = self.run_plugin("workspace", NAME="space.2", FOCUSED_WORKSPACE="2")
        self.assertIn("icon.color=0xff1e1e2e", focused)
        self.assertIn("background.color=0xffb4befe", focused)
        inactive = self.run_plugin("workspace", NAME="space.3", FOCUSED_WORKSPACE="2")
        self.assertIn("icon.color=0xffbac2de", inactive)
        self.assertIn("background.color=0x44cba6f7", inactive)
        self.assertIn("background.border_color=0xff6c7086", inactive)

    def test_workspace_displays_icons_for_opened_apps(self):
        args = self.run_plugin(
            "workspace", NAME="space.1", FOCUSED_WORKSPACE="1", WINDOWS="Ghostty"
        )
        self.assertIn("label=󰊠", args)
        self.assertIn("label.drawing=on", args)
        self.assertIn("label.color=0xff1e1e2e", args)

    def test_workspace_uses_a_lion_for_brave(self):
        args = self.run_plugin(
            "workspace", NAME="space.3", FOCUSED_WORKSPACE="1", WINDOWS="Brave Browser"
        )
        self.assertIn("label=🦁", args)

    def test_workspace_uses_docker_icon_for_podman_desktop(self):
        args = self.run_plugin(
            "workspace", NAME="space.3", FOCUSED_WORKSPACE="1", WINDOWS="Podman Desktop"
        )
        self.assertIn("label=", args)


class LayoutTest(unittest.TestCase):
    def test_lark_manages_raycast_with_homebrew(self):
        self.assertIn('"raycast"', LARK_HOST.read_text())

    def test_lark_manages_mole_for_raycast(self):
        self.assertIn('"mole"', LARK_HOST.read_text())

    def test_apple_notes_opens_floating(self):
        aerospace = AEROSPACE_ASPECT.read_text()
        self.assertIn('"if".app-id = "com.apple.Notes";', aerospace)
        self.assertIn('run = "layout floating";', aerospace)

    def test_ghostty_opens_floating(self):
        aerospace = AEROSPACE_ASPECT.read_text()
        self.assertIn('"if".app-id = "com.mitchellh.ghostty";', aerospace)
        self.assertIn('run = "layout floating";', aerospace)

    def test_bar_uses_a_light_translucent_base(self):
        colors = (CONFIG / "colors.sh").read_text()
        self.assertIn("export CAT_BAR=0x331e1e2e", colors)

    def test_bar_omits_redundant_apple_and_front_app_items(self):
        config = (CONFIG / "sketchybarrc").read_text()
        self.assertNotIn("sketchybar --add item apple left", config)
        self.assertNotIn("sketchybar --add item front_app left", config)

    def test_workspaces_are_placed_left_of_the_notch(self):
        config = (CONFIG / "sketchybarrc").read_text()
        self.assertIn('sketchybar --add item "space.$sid" left', config)

    def test_workspace_items_have_fixed_width_and_do_not_poll_aerospace(self):
        config = (CONFIG / "sketchybarrc").read_text()
        self.assertIn("icon.width=24", config)
        self.assertIn("update_freq=0", config)
        self.assertIn("background.border_width=0", config)

    def test_quick_launch_includes_brave_with_its_brand_font(self):
        config = (CONFIG / "sketchybarrc").read_text()
        marker = "--set apps.brave "
        start = config.index(marker)
        item = config[start : start + 240]
        self.assertIn('icon=""', item)
        self.assertIn('icon.font="Font Awesome 7 Brands:Regular:16.0"', item)

    def test_workspace_refreshes_on_front_app_switch_and_aerospace_uses_absolute_binary(
        self,
    ):
        config = (CONFIG / "sketchybarrc").read_text()
        aerospace = AEROSPACE_ASPECT.read_text()
        self.assertIn(
            '--subscribe "space.$sid" aerospace_workspace_change system_woke front_app_switched',
            config,
        )
        self.assertIn("${pkgs.sketchybar}/bin/sketchybar", aerospace)

    def test_app_drawer_toggle_is_centered(self):
        config = (CONFIG / "sketchybarrc").read_text()
        start = config.index("sketchybar --add item apps left")
        self.assertIn("width=32", config[start : start + 320])
        self.assertIn("icon.width=32", config[start : start + 320])
        self.assertIn("icon.align=center", config[start : start + 320])

    def test_app_drawer_has_the_same_outer_gap_before_and_after_it(self):
        config = (CONFIG / "sketchybarrc").read_text()
        self.assertIn("sketchybar --add item apps_spacer left", config)
        self.assertIn("--set apps_spacer width=8", config)

    def test_layout(self):
        result = subprocess.run(
            [
                "/bin/bash",
                "-c",
                'sketchybar() { printf "%s\\t" "$@"; printf "\\n"; }; source "$1"',
                "test",
                str(CONFIG / "sketchybarrc"),
            ],
            env=dict(os.environ, CONFIG_DIR=str(CONFIG)),
            text=True,
            capture_output=True,
            check=True,
        )
        settings = {}
        for line in result.stdout.splitlines():
            args = line.rstrip("\t").split("\t")
            target = None
            while args:
                arg = args.pop(0)
                if arg in ("--bar", "--default"):
                    target = arg
                elif arg == "--set":
                    target = args.pop(0)
                elif arg.startswith("--"):
                    target = None
                elif target and "=" in arg:
                    key, value = arg.split("=", 1)
                    settings.setdefault(target, {})[key] = value
        self.assertLessEqual(int(settings["--bar"]["height"]), 32)
        self.assertEqual(settings["--bar"]["notch_display_height"], "32")
        self.assertEqual(settings["clock"]["icon.drawing"], "off")
        # Background padding and item padding are aliases in SketchyBar.
        for side in ("left", "right"):
            self.assertEqual(settings["--default"][f"padding_{side}"], "4")
            self.assertNotIn(f"background.padding_{side}", settings["--default"])


class HoverTest(unittest.TestCase):
    run_plugin = PluginsTest.run_plugin

    def test_hover_enter_and_exit(self):
        for event, color in [
            ("mouse.entered", "0x33cba6f7"),
            ("mouse.exited", "0x00000000"),
        ]:
            args = self.run_plugin("hover", NAME="apps.ghostty", SENDER=event)
            self.assertEqual(
                args,
                [
                    "--animate",
                    "sin",
                    "8",
                    "--set",
                    "apps.ghostty",
                    f"background.color={color}",
                ],
            )
        self.assertEqual(self.run_plugin("hover", SENDER="forced"), [])


class ZellijThemeTest(unittest.TestCase):
    def test_alt_n_uses_zellijs_adaptive_new_pane_behavior(self):
        keybinds = (ZELLIJ_ASPECT.parent / "unlock-first.kdl").read_text()
        self.assertIn('bind "Alt n" { NewPane; }', keybinds)
        self.assertNotIn('bind "Alt n" { NewPane "stacked"; }', keybinds)

    def test_surface_theme_keeps_pane_frames_and_softens_tab_chrome(self):
        aspect = ZELLIJ_ASPECT.read_text()
        theme = ZELLIJ_THEME.read_text()
        self.assertIn('theme = lib.mkForce "catppuccin-mocha-surface";', aspect)
        self.assertIn("pane_frames = true;", aspect)
        self.assertIn("text_unselected", theme)
        self.assertIn("background 49 50 68", theme)
        self.assertIn("ribbon_unselected", theme)
        self.assertIn("background 88 91 112", theme)
        self.assertIn("ribbon_selected", theme)
        self.assertIn("background 166 227 161", theme)


if __name__ == "__main__":
    unittest.main()

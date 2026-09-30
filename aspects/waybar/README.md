# Waybar

Waybar configuration forked from [Athena](https://github.com/haikal-hakim/athena).

---

## Structure

```text
waybar.nix                       # Home Manager module: builds the bar + styling
config.jsonc                     # Bar layout (modules-left/center/right)
modules/                         # Each module's settings in its own file
```

`waybar.nix` reads `config.jsonc` + every file under `modules/` via
`builtins.fromJSON` and merges them into `programs.waybar.settings` (replacing
Waybar's native `include`). Styling lives inline in `programs.waybar.style`
using Catppuccin color variables (`@base`, `@surface0`, `@mauve`, ...) which
Catppuccin's Home Manager module injects ahead of our rules.

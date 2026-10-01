# Pablo's Nix Configurations

Personal macOS and NixOS configuration managed with [Nix](https://nix.dev/). The flake uses [Den](https://den.denful.dev/) to compose reusable aspects, hosts, and Home Manager profiles.

## Targets

| Target | Platform         | System                          | User environment                              |
| ------ | ---------------- | ------------------------------- | --------------------------------------------- |
| Lark   | `aarch64-darwin` | `NIX_HOST=lark make darwin`     | `NIX_HOST=lark NIX_USER=pablogaeta make home` |
| Hazel  | `x86_64-linux`   | `NIX_HOST=hazel make nixos`     | `NIX_HOST=hazel NIX_USER=pablo make home`     |
| Moss   | `aarch64-linux`  | `make deploy-moss` (from Hazel) | None                                          |

`NIX_HOST` and `NIX_USER` select a target; Home Manager targets use `NIX_USER@NIX_HOST`.

## Layout

- `aspects/`: reusable Den configuration
- `hosts/`: system-level host configuration
- `homes/`: user profiles and target composition
- `modules/`: reusable modules outside Den

## Guides

- [Development setup](docs/setup.md)
- [Extending the flake](docs/extensions.md)
- Host notes: [Lark](docs/hosts/lark.md), [Hazel](docs/hosts/hazel.md), and [Moss](docs/hosts/moss.md)
- [macOS device notes](docs/macos.md)

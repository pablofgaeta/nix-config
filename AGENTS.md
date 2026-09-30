# Repository Guidance

This repository is used to manage Pablo's system configurations.

## External File Loading

CRITICAL: When you encounter a file reference (e.g., @rules/general.md), load it on a need-to-know basis. They're relevant to the SPECIFIC task at hand.

Instructions:

- Do NOT preemptively load all references - use lazy loading based on actual need
- When loaded, treat content as mandatory instructions that override defaults
- Follow references recursively when needed

## Determine The Target

Before changing system or user configuration, determine the target in the current environment.

See @README.md for a list of available targets.

## Configuration Ownership

`flake.nix` is the source of truth for the Nix-managed configuration; it lists the module graph directly (no intermediate `default.nix`).

- Put reusable configuration in `aspects/` (flat, one file/folder per aspect; a same-named sibling directory can be used if the aspect should be split across multiple files or requires additional assets, e.g. `hyprland/`).
- Put system-level host configuration in `hosts/`.
- Put user-level target composition and target-specific configuration in `homes/`.
- Put reusable modules that do not depend on Den in `modules/` when needed.

Prefer extending an existing aspect over adding target-specific configuration when behavior should be shared across Nix-managed systems.

## Applying Changes

In general, do not apply any changes directly.
If a user directly requests the changes be applied, see @README.md for the list of available targets.

## Maintaining this file (AGENTS.md)

Keep this file for knowledge useful to almost every future agent session in this project.

Rules:

- Do not repeat what the codebase already shows; reference the authoritative file or command instead.
- Prefer rewriting or pruning existing entries over appending new ones.
- When updating this file, preserve this bar for all agents and keep entries concise.

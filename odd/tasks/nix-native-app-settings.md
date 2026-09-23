# Migrate selected application settings to Nix

## Goal

Remove redundant app config source files where their settings can be represented safely in Nix, while preserving the generated configuration and runtime behavior.

## Work units

- [x] 1. Migrate Starship settings from `home/core/starship.toml` to Home Manager's `programs.starship.settings`; verify parity and commit pending.
- [ ] 2. Migrate Fastfetch settings from `home/core/fastfetch/config.jsonc` to Home Manager's native settings; preserve module order and behavior, then commit.
- [ ] 3. Migrate only SwayNC's JSON settings into Nix-generated JSON; preserve manual package installation and do not enable the Home Manager systemd service; retain CSS/icons, then commit.
- [ ] 4. Migrate btop's explicit settings from `home/core/btop/btop.conf` to Home Manager's native settings; retain theme files/symlinks and commit.

## Verification evidence

### Starship

- Nix formatter and `git diff --check` passed.
- Generated TOML was parsed alongside the original with Python `tomllib`; both dictionaries matched exactly for desktop and laptop.
- Starship remains enabled with Bash/Fish integrations disabled and Nushell integration enabled.
- Standalone `starship.toml` source removed after parity passed.

## Boundaries

- Preserve effective settings, order-sensitive lists, paths, package identity, and integrations.
- Remove each standalone settings file only after equivalence checks pass.
- Preserve useful comments as Nix comments where appropriate; JSON/TOML/config serializers will not preserve source comments.
- Do not enable SwayNC's Home Manager service; keep its current package-only behavior and existing CSS/icon sources.
- Do not migrate scripts, CSS, icon/theme assets, or unrelated app modules.
- Validate with Home Manager evaluation and format/diff checks; do not run `nixos-rebuild test` or `switch`.

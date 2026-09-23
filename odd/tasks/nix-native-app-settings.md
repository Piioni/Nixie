# Migrate selected application settings to Nix

## Goal

Remove redundant app config source files where their settings can be represented safely in Nix, while preserving the generated configuration and runtime behavior.

## Work units

- [x] 1. Migrate Starship settings from `home/core/starship.toml` to Home Manager's `programs.starship.settings`; verify parity. Commit: `42a7ce2` (`refactor(home): define starship settings in nix`).
- [x] 2. Migrate Fastfetch settings from `home/core/fastfetch/config.jsonc` to Home Manager's native settings; preserve module order and behavior. Commit: `934e897` (`refactor(home): define fastfetch settings in nix`).
- [x] 3. Migrate only SwayNC's JSON settings into Nix-generated JSON; preserve manual package installation and do not enable the Home Manager systemd service; retain CSS/icons. Commit: `b0faa31` (`refactor(home): define swaync settings in nix`).
- [x] 4. Migrate btop's explicit settings from `home/core/btop/btop.conf` to Home Manager's native settings; retain theme files/symlinks; commit pending.

## Verification evidence

### Starship

- Nix formatter and `git diff --check` passed.
- Generated TOML was parsed alongside the original with Python `tomllib`; both dictionaries matched exactly for desktop and laptop.
- Starship remains enabled with Bash/Fish integrations disabled and Nushell integration enabled.
- Standalone `starship.toml` source removed after parity passed.

### Fastfetch

- `programs.fastfetch.settings` matched the parsed original JSONC exactly for desktop and laptop, including module array order and JSON value types.
- Confirmed the pinned Home Manager module writes these settings to `fastfetch/config.jsonc` using its JSON generator and retains the default Fastfetch package.
- Nix formatter and `git diff --check` passed; the original JSONC file was removed only after parity passed.

### SwayNC

- Nix formatter and `git diff --check` passed.
- Generated JSON parsed identically to the original for both hosts, including ordered widgets/actions and the derived logout command.
- Package-only behavior remains; `services.swaync.enable` is false, no SwayNC user systemd unit was added, and CSS plus all 21 icon mappings remain unchanged.
- Standalone `config.json` removed after parity passed.

### btop

- `nix fmt -- --check` and `git diff --check` passed.
- The generated native settings matched all 88 source assignments on desktop and laptop with exact keys, value types, and values.
- `programs.btop` remains enabled with the same `pkgs.btop` package; all three theme symlinks are unchanged.
- Removed `btop.conf` only after both host parity checks passed.

## Boundaries

- Preserve effective settings, order-sensitive lists, paths, package identity, and integrations.
- Remove each standalone settings file only after equivalence checks pass.
- Preserve useful comments as Nix comments where appropriate; JSON/TOML/config serializers will not preserve source comments.
- Do not enable SwayNC's Home Manager service; keep its current package-only behavior and existing CSS/icon sources.
- Do not migrate scripts, CSS, icon/theme assets, or unrelated app modules.
- Validate with Home Manager evaluation and format/diff checks; do not run `nixos-rebuild test` or `switch`.

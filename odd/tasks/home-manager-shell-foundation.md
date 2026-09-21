# Home Manager Nushell and Ghostty foundation

## Goal

Adopt Home Manager as Nixie's gradual user-configuration layer, keep Bash as the safe login shell, and migrate the active portable Nushell and Ghostty configuration without changing desktop sessions or hardware behavior.

## Boundaries

### In scope

- Add Home Manager `master` following the existing `nixpkgs-unstable` input.
- Integrate the `piioni` Home Manager profile with state version `25.11`.
- Keep Bash as the login shell.
- Manage Nushell, Ghostty, Zoxide integration, and the user packages required by the retained Nushell behavior.
- Migrate active portable Nushell configuration and safe Ghostty settings.
- Make Ghostty launch the declarative Nix-store Nushell executable.
- Preserve existing unrelated working-tree changes and live dotfiles.

### Out of scope

- Fish and Starship.
- Nushell history, databases, caches, runtime state, inactive `_fzf_integration.nu`, and generated `10-tools.nu`.
- Cargo, FVM, Dart, or other imperative path additions.
- The unknown `herdr` tool and its alias.
- Helium and `BROWSER` until Helium is available from an approved declarative source.
- Git identity or other identity-bearing configuration.
- Hyprland, Caelestia, Fuzzel, GNOME, GDM, Niri, monitor, GPU, workspace, or compositor settings.
- Activating the system, modifying live dotfiles, committing, or staging.

## Tasks

- [x] 1. Verify the active terminal, shell process, login shell, and safe Nushell/Ghostty configuration structure.
- [x] 2. Add and lock Home Manager while preserving the existing nixpkgs revision.
- [x] 3. Align Home Manager `master` with `nixpkgs-unstable`; keep `home.stateVersion = "25.11"` independent.
- [x] 4. Decide to retain Bash as the login shell and launch Nushell from Ghostty.
- [x] 5. Remove the incorrect Fish/Starship imports, options, and generated repository files.
- [x] 6. Migrate the bounded Nushell configuration and declarative dependencies.
- [x] 7. Manage Ghostty with safe existing settings and the Nix-store Nushell command.
- [x] 8. Independently verify formatting, flake evaluation, Nushell loading, Home Manager target ownership, and preservation of unrelated work.

## Acceptance criteria

- Home Manager `master` follows the same pinned `nixpkgs-unstable` input.
- `piioni` keeps Bash as the login shell.
- The Home Manager profile explicitly imports Nushell, Ghostty, and focused user-package modules.
- Ghostty launches `${pkgs.nushell}/bin/nu`, not a Cargo or home-directory path.
- Nushell config and environment load successfully with the pinned Nix package.
- Active aliases, functions, interface, colors, prompt indicators, editor, pager, terminal, XDG, and FZF settings are preserved unless explicitly excluded.
- Fish, Starship, history, imperative paths, `herdr`, Helium, `BROWSER`, and secret values are absent.
- Home Manager has no duplicate managed targets.
- Touched Nix files are formatted.
- Available read-only evaluation checks pass; missing real filesystem and bootloader configuration are reported as external blockers.

## Correction history

The first implementation incorrectly inferred active Fish usage from `Server-dotfiles`. Runtime verification showed that Ghostty launches Nushell while Bash remains the login shell. The Fish/Starship implementation was removed and replaced with the verified Nushell/Ghostty configuration.

## Rollback boundary

Remove only the Home Manager input/integration and the Home Manager files introduced by this work unit, then restore the corresponding lock-file entries. Do not alter pre-existing Nixie changes or live files under `/home/piioni/.config`.

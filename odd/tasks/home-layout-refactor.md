# Home layout refactor

## Goal

Replace the flat `home/piioni/` Home Manager layout with a readable platform-independent structure:

```text
home/
├── default.nix
├── core/
├── tui/
├── gui/
└── hosts/
```

There is intentionally no `linux/` or `darwin/` split because this repository targets NixOS workstations only.

## Target ownership

### `home/core`

Shared identity/schema and common user tooling:

- `agents.nix`
- `fastfetch.nix`
- `packages.nix`
- `starship.nix`
- `workstation.nix`

### `home/tui`

Terminal and text-interface applications:

- `btop.nix`
- `herdr.nix`
- `lazygit.nix`
- `moshi.nix`
- `nushell.nix`
- `tuxedo.nix`
- `yazi.nix`
- `zellij.nix`

### `home/gui`

Graphical applications and session configuration:

- `caelestia.nix`
- `ghostty.nix`
- `hypr.nix`
- `kitty.nix`
- `swappy.nix`
- `swayimg.nix`
- `swaync.nix`
- `zed.nix`

### `home/hosts`

Direct host Home Manager assignments:

- `desktop.nix`
- `laptop.nix`

`home/default.nix` owns shared identity and imports the three category aggregators. `hosts/<name>/home.nix`
bridges NixOS to the corresponding `home/hosts/<name>.nix` module.

## Work units

- [x] 1. Move modules and source directories into `core`, `tui`, and `gui`; create category aggregators and `home/default.nix`.
- [x] 2. Move direct host Home Manager assignments into `home/hosts` and update the host bridge modules.
- [x] 3. Rewrite live-symlink paths and relative source paths for the new locations.
- [x] 4. Update architecture documentation and verify the completed structural refactor.
- [x] 5. Commit the refactor after staged-source validation; pure evaluation limitations from live symlinks are documented.

## Verification record

Structural validation completed for the moved Home Manager layout:

- `nix flake show`: passed.
- `git diff --check` and the focused `nix fmt -- --check` path set: passed.
- Symlink-source resolution: all 52 sources resolved.
- Impure Home Manager activation evaluation: passed for both `desktop` and `laptop`.
- Staged Git-source Home Manager activation evaluation: the pure evaluator reaches the moved files but rejects
  the intentional absolute out-of-store symlink at `~/nix-config/home/tui/nushell/env.nu`; this is an inherent
  limitation of the live-dotfile strategy, not a missing source.
- Impure Git-source Home Manager activation evaluation: passed for both `desktop` and `laptop`, with only the
  known Yazi legacy-default warning.
- Staged validation: 111 paths, zero unstaged changes, zero untracked changes; 52 symlink sources resolved and
  category ownership has no duplicate targets.

No live `~/.config` files were modified.

## Boundaries

- Preserve behavior and target ownership; this is a structural refactor.
- Keep generated substitutions and host-dependent rendering unchanged.
- Keep the `~/nix-config` live-symlink contract, changing only repository-relative suffixes.
- Do not add `outputs/`, Linux/Darwin directories, or empty category modules beyond the three aggregators.
- Do not modify live files under `~/.config`.

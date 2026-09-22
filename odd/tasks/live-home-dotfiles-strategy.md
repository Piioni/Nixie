# Live Home Manager dotfiles strategy

## Goal

Adopt the `references/well-done` dotfile model for Nixie's editable repository-owned configuration, while preserving generated files that require Nix package paths, host facts, or runtime substitutions.

## Decision

Use `config.lib.file.mkOutOfStoreSymlink` for direct repository dotfiles under a stable checkout path (`${config.home.homeDirectory}/nix-config`). Keep generated/store-backed ownership for files that require substitutions, fetched artifacts, generated scripts, or host-dependent rendering.

## Boundaries

- Do not symlink an entire directory when generated and direct-owned targets coexist.
- Preserve exactly one Home Manager owner per target and remove recursive-prefix ownership before adding leaf targets.
- Keep WU3a's schema/facts plumbing separate from this conversion.
- Reconcile WU3b's Hyprland ownership model with the live-dotfile decision before implementing host-dependent rendering.
- Do not modify live files under `~/.config` during migration.

## Tasks

- [x] Record the bounded path contract and classify its targets as direct-symlink or generated.
- [x] Convert the bounded direct dotfiles to `mkOutOfStoreSymlink` entries with explicit target ownership.
- [x] Reconcile `hypr.nix`, `caelestia.nix`, `btop.nix`, and the WU3b/WU4 plan so host-dependent targets remain correct without duplicate ownership.
- [x] Verify both hosts, target ownership, symlink destinations, generated substitutions, and the existing payload invariants; commit the work unit.

## Bounded classification

All converted targets use this path contract:
`config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/<repository path>"`.

| Module | Home Manager target | Classification | Source / rationale |
| --- | --- | --- | --- |
| `starship.nix` | `xdg.configFile."starship.toml"` | direct-symlink | `home/piioni/starship.toml` has no Nix substitutions. |
| `fastfetch.nix` | `xdg.configFile."fastfetch/config.jsonc"` | direct-symlink | `home/piioni/fastfetch/config.jsonc` has no Nix substitutions. |
| `ghostty.nix` | `programs.ghostty.settings` (`~/.config/ghostty/config`) | generated | The `command` setting embeds `${pkgs.nushell}`, so Home Manager must render it. |

## Additional module classification and progress

Completed this bounded conversion without touching live `~/.config` files. Every direct file below now uses the explicit path contract; directory-level ownership was replaced by leaf ownership where needed.

| Module | Home Manager target(s) | Classification | Source / rationale |
| --- | --- | --- | --- |
| `agents.nix` | `xdg.configFile."agents/skill/guided-learning/SKILL.md"`; `xdg.configFile."agents/skills/domain-modeling/{ADR-FORMAT.md,CONTEXT-FORMAT.md,SKILL.md}"`; `xdg.configFile."agents/skills/{grilling,grill-me,grill-with-docs,show-me}/SKILL.md"` | direct-symlink | Eight repository-owned Markdown files; each leaf is explicitly owned under `home/piioni/agents/`. |
| `lazygit.nix` | `programs.lazygit.enable` | no direct target | The module only enables the package integration and has no repository-owned configuration file. Left unchanged. |
| `moshi.nix` | `xdg.configFile."moshi/config.toml"` | direct-symlink | `home/piioni/moshi/config.toml` has no substitutions. |
| `nushell.nix` | `programs.nushell.{configFile,envFile}`; `xdg.configFile."nushell/autoload/{20-interface.nu,30-colors.nu,40-prompt.nu,50-aliases.nu,60-functions.nu}"` | direct-symlink | Seven repository-owned Nushell files with no Nix substitutions. |
| `swappy.nix` | `xdg.configFile."swappy/config"` | direct-symlink | `home/piioni/swappy/config` has no substitutions. |
| `swayimg.nix` | `xdg.configFile."swayimg/init.lua"` | direct-symlink | `home/piioni/swayimg/init.lua` has no substitutions. |
| `swaync.nix` | `xdg.configFile."swaync/config.json"` | generated | `lib.replaceStrings` substitutes `config.xdg.configHome` into `home/piioni/swaync/config.json`; it remains store-rendered. |
| `swaync.nix` | `xdg.configFile."swaync/style.css"`; `xdg.configFile."swaync/icons/{airplane-mode-off.png,airplane-mode-on.png,bolt.png,brightness-100.png,brightness-20.png,brightness-40.png,brightness-60.png,brightness-80.png,gamemode.png,microphone-mute.png,microphone.png,music.png,palette.png,picture.png,play.png,timer.png,volume-high.png,volume-low.png,volume-mid.png,volume-mute.png,wand.png}"` | direct-symlink | The stylesheet and 21 repository-owned icon files have no substitutions; each icon is explicitly owned rather than recursively symlinking the directory. |
| `tuxedo.nix` | `xdg.configFile."tuxedo/config.toml"` | direct-symlink | `home/piioni/tuxedo/config.toml` has no substitutions. |
| `yazi.nix` | `programs.yazi.settings` | generated | The module builds Yazi configuration from a Nix attribute set; there is no direct repository-owned config file. Left unchanged. |

## WU3b/WU4 reconciliation

Safe isolated targets now use the explicit live-checkout contract:

- `hypr/hyprland.lua` and each `hypr/scripts/*` leaf are direct out-of-store symlinks.
- `caelestia/cli.json` and the three btop theme leaves are direct out-of-store symlinks.
- `hypr/lua` remains the existing recursive store-backed owner until WU3b. No leaf is added beneath it
  during this intermediate state.
- WU3b atomically removes that recursive owner, then owns six host-independent Lua leaves directly and
  five fact-dependent Lua leaves as rendered/store-backed targets, guarded by the existing one-owner/prefix
  assertion.
- `caelestia/shell.json` remains rendered/store-backed for runtime-path substitution and the later battery
  divergence. `btop/btop.conf` remains store-backed until its later battery rendering.
- WU4 remains the host-divergence unit: it changes host facts only and does not convert direct target
  ownership.

The authorized witness amendment remains operative. The live-dotfile work unit does not alter the generated
host-dependent payload owners; WU3b remains responsible for the final payload rendering witness.

## Verification evidence

- `nix flake show` lists exactly `desktop` and `laptop`.
- Both Home Manager activation packages evaluate successfully and share the expected generation derivation.
- Both hosts have 79 unique Home Manager targets, with zero duplicate or parent/child-prefix collisions.
- All 52 direct symlink sources resolve under `/home/piioni/nix-config/home/piioni/` and exist on this host.
- `nix fmt -- --check` and `git diff --check` pass for the changed work-unit files.
- The full NixOS toplevel remains blocked by the pre-existing missing root filesystem and GRUB device assertions;
  this is unrelated to Home Manager dotfile ownership.

## Acceptance checks

- Direct symlink targets resolve under `${config.home.homeDirectory}/nix-config`.
- No Home Manager target has a duplicate or parent/child owner.
- Generated substitutions remain active for Kitty, Herdr, Zellij, and any retained generated target.
- Host-dependent Hyprland/Caelestia/Btop behavior remains assigned to WU3b/WU4.
- No live `~/.config` file is changed.
- Both host evaluations pass with the repository's existing checks.

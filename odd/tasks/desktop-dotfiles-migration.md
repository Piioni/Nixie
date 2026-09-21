# Desktop dotfiles migration

## Goal

Migrate the user's active desktop and application configuration from `~/.config` into Nixie through Home Manager while separating portable user configuration from compositor, host, hardware, generated, and sensitive state.

## Global boundaries

### In scope

- Preserve the active live configuration for every migrated tool.
- Migrate allowlisted configuration from `agents`, `btop`, `caelestia`, `fastfetch`, `herdr`, `hypr`, `kitty`, `lazygit`, `moshi`, `swappy`, `swayimg`, `swaync`, `tuxedo`, `yazi`, `zed`, and `zellij`.
- Prefer first-class Home Manager modules when they preserve behavior without duplicate target ownership.
- Use explicit imports and focused, beginner-readable modules.
- Replace absolute interpreter and script paths with declarative Nix store paths.

### Excluded from every batch

- Credentials, tokens, private keys, auth stores, `.env` values, histories, databases, caches, generated indexes, AI transcripts, chat/session logs, backups, and runtime state.
- Machine-local absolute paths when a declarative package or config-relative path can replace them.
- Live dotfile deletion or replacement outside a Nix build/activation explicitly approved later.
- Staging, committing, activation, or system switching.

## Architecture

- `home/piioni/` is the Home Manager ownership boundary; modules live directly there.
- Tool-owned source data remains under `home/piioni/<tool>/`.
- Hyprland 0.56 uses **native Lua configuration** (`configProvider: lua`), so the Hyprland layer is managed as raw `xdg.configFile` entries. `wayland.windowManager.hyprland` must stay disabled because it generates a competing `hyprland.conf`.
- Config files consumed by a tool that rewrites them at runtime are managed by re-export from the repository, and the runtime-write caveat is tracked below.

## Reconciled state (2026-09-21)

The previous consolidated pass was interrupted after copying source data but before completing modules.

- `home/piioni/default.nix` imported the already-removed `./apps` directory, so the Home Manager profile did not evaluate. Repaired to import the flat modules.
- Source data already existed for `agents`, `btop`, `caelestia`, `fastfetch`, `hypr`, `kitty`, `swappy`, `swayimg`, `swaync`, `tuxedo`, and `zellij`.
- Source data was staged during this pass for `herdr`, `moshi`, and `zed`, and `hypr/scripts/record.sh` was added.
- `agents/skills/guided-learning` was moved to `agents/skill/guided-learning` to match the live layout.

## Work units

- [x] 1. Restore Starship from the active `~/.config/starship.toml` and enable official Nushell integration.
- [x] 2a. Migrate Btop config with its active `catppuccin_macchiato` theme, replacing the absolute theme path.
- [x] 2b. Migrate the additional inactive Btop themes separately.
- [x] 2c. Migrate LazyGit and Swappy.
- [x] 2d. Migrate Fastfetch config with the built-in NixOS logo; omit the custom logo by explicit user decision.
- [x] 3. Migrate `swayimg`, retaining only active declarative configuration.
- [x] 4a. Enable Yazi from pinned defaults and migrate intentional settings and dependency overrides.
- [x] 4d. Repair `home/piioni/default.nix` so the Home Manager profile evaluates again.
- [x] 5. Migrate Kitty with a declarative Nushell shell and Herdr with a declarative shell path.
- [x] 6. Migrate Zellij KDL configuration and pin `zjstatus.wasm` to its verified upstream release.
- [x] 7. Migrate SwayNC configuration, styles, icons, and command dependencies without absolute Hypr paths.
- [x] 8. Migrate generic Caelestia configuration; keep monitor profiles out of the user layer.
- [x] 9. Migrate the Hyprland Lua entrypoint, Lua modules, and scripts.
- [x] 10. Migrate Zed settings and keymap.
- [x] 11. Migrate the `agents` skill and skills trees.
- [x] 12. Migrate `moshi` and `tuxedo` configuration.

## Deferred work units

- [ ] 13. Yazi intentional keymap and theme overrides. The pinned Yazi 26.8.15 release embeds its presets inside the binary instead of shipping them as TOML under `share/`, so deriving the intentional override set requires a deliberate extraction step. Migrating the live 1,443-line files verbatim would freeze stale defaults and drop 25 newer pinned bindings, which contradicts the recorded decision to inherit pinned defaults.
- [ ] 14. Separate host-specific Hyprland monitor and workspace rules (`hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `caelestia/monitors/`) from the portable user layer.
- [ ] 15. Resolve runtime-write conflicts for tools that rewrite their own managed config: `caelestia/shell.json` (rewritten by the shell UI) and `zed/settings.json` (rewritten by the editor UI). A read-only Home Manager symlink prevents those tools from persisting UI changes.
- [ ] 16. Provide declarative sources for programs referenced by migrated configuration that are absent from pinned nixpkgs or from the current NixOS config: `helium`, `code`, `cliphist`, `wl-clipboard`, `gnome-keyring`, `nautilus`.

## Work unit 5-12 design

- All modules are raw `xdg.configFile` entries with `.source` or `.text`, except `kitty.nix` which also installs the package.
- Path substitution uses `lib.replaceStrings` over `builtins.readFile` so the migrated behavior is preserved byte-for-byte apart from the substituted interpreter, editor, or script path.
- Directory entries require `recursive = true`.
- `programs.kitty`, `programs.zellij`, `programs.moshi`, `programs.zed-editor`, and a Hyprland Home Manager module are deliberately not enabled, so there is exactly one owner per target.

## Completed batch evidence: work units 5-12

### Delivered

Modules created under `home/piioni/`: `agents.nix`, `caelestia.nix`, `herdr.nix`, `hypr.nix`, `kitty.nix`, `moshi.nix`, `swaync.nix`, `tuxedo.nix`, `zed.nix`, `zellij.nix`. `default.nix` now imports all twenty modules; `packages.nix` dropped `zellij` so the Zellij module is the single package owner.

### zjstatus pin

`https://github.com/dj95/zjstatus/releases/download/v0.23.0/zjstatus.wasm` with `hash = "sha256-4AaQEiNSQjnbYYAh5MxdF/gtxL+uVDKJW6QfA/E4Yf8="`. The hash was confirmed twice: `nix store prefetch-file` resolved it to `/nix/store/i41jxcamqpjbfa9721ydnxgfif4ckdl1-zjstatus.wasm`, and the sha256 of that store file equals `e006901223524239db618021e4cc5d17f82dc4bfae5432895ba41f03f13861ff`, which is the sha256 of the user's live wasm. The 4 MB blob was deleted from the repository.

### Verification evidence

Independent read-only verification passed all eight criteria.

- Formatting: `nixfmt --check home/piioni/*.nix` exits 0.
- Evaluation: `nix eval .#nixosConfigurations.desktop.config.home-manager.users.piioni.home.file --apply builtins.attrNames` exits 0 with 50 unique targets and no parent/child prefix pair.
- Coverage: all 22 required targets present exactly once; `.config/hypr/hyprland.conf` and `.config/zellij/config.yml` absent.
- Recursive targets: `agents/skill/guided-learning/SKILL.md`, `agents/skills/grilling/SKILL.md`, `hypr/lua/keybinds.lua`, `hypr/scripts/record.sh` (executable in store), and `swaync/icons/volume-high.png` all present in their resolved sources.
- Substitutions: `herdr` and `kitty` resolve to `/nix/store/9vinnxl5ansgi4xca5yidpypwzwqss4h-nushell-0.115.0/bin/nu`; `zellij/config.kdl` has zero `/usr/bin` leftovers and resolves `scrollback_editor` to `neovim-0.12.4`; the layout plugin path and both `logout.sh` references resolve as designed.
- Packages: `nix build --dry-run` resolves `herdr-0.8.2`, `moshi-0.2.12`, `tuxedo-rs-0.3.1`, `caelestia-cli-1.1.2`, `caelestia-shell-2.3.0`, `kitty-0.48.2`, `zed-editor-1.16.1`, `SwayNotificationCenter-0.12.6`, and `hyprland-0.56.2`.
- Warnings: none about colliding targets. The single `programs.yazi.shellWrapperName` notice is pre-existing and unrelated.
- Live dots: no live file under `~/.config` was modified; every migrated source is byte-identical to its live counterpart except the documented deviations below.

### Documented deviations

- `btop/btop.conf` uses the relative theme name instead of the absolute theme path.
- `fastfetch/config.jsonc` adds the built-in NixOS logo instead of the omitted 465-line custom asset.
- `caelestia/shell.json`, `swaync/config.json`, and `zellij/layouts/default.kdl` substitute `${config.xdg.configHome}`, which resolves to `/home/piioni/.config`, so their generated text intentionally equals the original absolute path.
- `zed/settings.json` is a verbatim JSONC copy and was not normalized. Strict-JSON diagnostics on it are false positives.

### Residual risk

- The full system toplevel was not built: `hosts/desktop/hardware-configuration.nix` is absent, so the pre-existing `fileSystems` and `boot.loader.grub.devices` assertions still block it. `nixos-rebuild build` and `switch` remain unrun.
- The `fetchurl` network path and actual compilation of the newly referenced packages were not exercised.
- Because the whole `home/` tree is untracked in Git, "nothing outside `home/piioni/` changed" rests on mtime evidence rather than a git diff.
- Delegation fallback: the first writer launch failed with `Codex error: The usage limit has been reached` on `openai-codex/gpt-5.6-terra` after one turn and zero tool calls. The batch was completed through a writer and a verifier re-pointed to `deepseek/deepseek-flash` in `~/.pi/agent/subagents.json`.

## Later decisions

- Kitty must not launch Fish; it uses the declarative Nushell path.
- Zellij resolves `fish`, `nvim`, and the status plugin through Nix store paths.
- Zed AI and provider settings and the `agents` content are limited to an explicit privacy-reviewed allowlist.

## Rollback boundary

Rollback only the modules and managed source files introduced by the failing work unit. Preserve completed earlier batches, unrelated Nixie changes, and every live file under `/home/piioni/.config`.

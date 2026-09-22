# Host module organization

## Goal

Grow Nixie's host structure step by step, keeping system composition, hardware, Home Manager, and future host-specific responsibilities separate without introducing an `outputs/` registry layer.

## Approach

Keep the direct `flake.nix -> hosts/<name>/default.nix` wiring. Each host's `default.nix` composes focused sibling modules. Add a sibling module only when there is real configuration to own; do not create empty placeholders.

## Work units

- [x] 1. Extract per-host hardware composition into `hosts/<name>/hardware.nix`.
- [x] 2. Review and extract concrete host-specific networking configuration, if any.
- [x] 3. Review and extract concrete host-specific services or power configuration, if any.
- [x] 4. Verify each module transition and commit each meaningful work unit.

## Work unit 1: hardware composition

- Desktop owns the reusable NVIDIA module plus the optional generated hardware configuration.
- Laptop owns only the optional generated hardware configuration.
- `hosts/<name>/default.nix` remains a readable composition entrypoint.
- No behavior should change; the imports are relocated only.

## Work unit 1 completion

- [x] Desktop and laptop hardware composition now live in sibling `hardware.nix` modules.

### Verification performed

- Passed: `git diff --check`.
- Passed: `nix fmt -- --check hosts/desktop/default.nix hosts/desktop/hardware.nix hosts/laptop/default.nix hosts/laptop/hardware.nix`.
- Passed targeted graph evaluation: `nix eval --impure --json path:.#nixosConfigurations.desktop.config.hardware.graphics.enable` returned `true`.
- Passed targeted graph evaluation: `nix eval --impure --json path:.#nixosConfigurations.laptop.config.system.stateVersion` returned `"25.11"`.
- Full-toplevel evaluation remains blocked for both hosts by the existing checkout hardware condition: `nix eval --impure --raw path:.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` reports no root `fileSystems` entry and no GRUB device configuration. Neither `hosts/<name>/hardware-configuration.nix` is present, and the optional guards leave those settings unset.
- `nix eval --raw .#nixosConfigurations.desktop.config.system.build.toplevel.drvPath` also cannot see the new untracked module through the Git flake source. It was not staged by design; `path:.` was used for the subsequent evaluations.

## Work unit 2 review

- [x] No host-specific networking module was added because the current networking configuration is shared.

The shared `modules/base/networking.nix` owns NetworkManager and the firewall. Host-specific identity remains in each
host's `host.nix` through `networking.hostName`; there are no current per-host interfaces, addresses, routes, or DNS
settings to extract. A future networking module should be added only when those settings become host-specific.

## Work unit 3: desktop gaming module

- [x] Add `hosts/desktop/gaming.nix` with Steam and GameMode enabled for desktop only.
- [x] Review and extract any other concrete host-specific services or power configuration, if needed.

### Laptop power

- [x] Add `hosts/laptop/power.nix` with `services.power-profiles-daemon.enable = true` for laptop only.
- [x] Keep the desktop composition free of the laptop power module.
- [x] Suspend when the lid closes on battery power; ignore lid closure on external power.
- [x] Leave idle suspension policy intentionally undecided.

### Validation performed

- Passed: `git diff --check`.
- Passed (exit 0; emitted `warning: Git tree '/home/piioni/Repos/Nixie' is dirty`): `nix fmt -- --check hosts/desktop/default.nix hosts/desktop/gaming.nix`.
- Passed targeted graph evaluation: `nix eval --impure --json path:.#nixosConfigurations.desktop.config.programs.steam.enable` returned `true`.
- Passed targeted graph evaluation: `nix eval --impure --json path:.#nixosConfigurations.desktop.config.programs.gamemode.enable` returned `true`.
- Passed laptop import boundary check: `if grep -Fq './gaming.nix' hosts/laptop/default.nix; then echo 'laptop imports gaming.nix'; exit 1; else echo 'laptop does not import gaming.nix'; fi` returned `laptop does not import gaming.nix`.

## Final verification for the current batch

- Passed: `nix flake show` lists `desktop` and `laptop`.
- Passed: Nix formatter checks for host modules and `git diff --check`.
- Passed targeted evaluation: desktop graphics, Steam, and GameMode are enabled; laptop power profiles are enabled;
  desktop power profiles are disabled; laptop state version is `25.11`.
- Passed import boundaries: desktop owns NVIDIA and gaming; laptop owns power profiles; neither crosses the other
  host's module boundary.
- Tracked worktree is clean after commits `1a4ab8f`, `d267646`, `dda4716`, `99bd7fc`, and `e0e3951`.
- Markdown Prettier verification is unavailable because `prettier` is not installed; no Markdown formatting error was
  reported by the repository write tool.
- Full production toplevel remains blocked by the pre-existing missing root filesystem and GRUB-device assertions;
  targeted evaluations succeed apart from the known Yazi warning.

## Boundaries

- Keep `modules/hardware/nvidia.nix` reusable and host selection explicit.
- Preserve the existing `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard.
- Do not add `outputs/` or a dynamic host registry.
- Do not create empty networking, services, or power modules.

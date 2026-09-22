# Host module organization

## Goal

Grow Nixie's host structure step by step, keeping system composition, hardware, Home Manager, and future host-specific responsibilities separate without introducing an `outputs/` registry layer.

## Approach

Keep the direct `flake.nix -> hosts/<name>/default.nix` wiring. Each host's `default.nix` composes focused sibling modules. Add a sibling module only when there is real configuration to own; do not create empty placeholders.

## Work units

- [x] 1. Extract per-host hardware composition into `hosts/<name>/hardware.nix`.
- [ ] 2. Review and extract concrete host-specific networking configuration, if any.
- [ ] 3. Review and extract concrete host-specific services or power configuration, if any.
- [ ] 4. Verify each module transition and commit each meaningful work unit.

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

## Boundaries

- Keep `modules/hardware/nvidia.nix` reusable and host selection explicit.
- Preserve the existing `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard.
- Do not add `outputs/` or a dynamic host registry.
- Do not create empty networking, services, or power modules.

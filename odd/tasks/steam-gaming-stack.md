# Steam, Proton, Wine, and Gaming Stack

## Objective

Port the useful gaming architecture from `references/well-done` into Nixie without copying host-specific hardware assumptions. Keep the feature modular, opt-in, and selectable independently by each host.

## Source Decision

- Use Well Done as the primary reference: it has the complete Steam/Proton/Wine/launcher/tooling stack.
- Do not copy Chillone gaming code: the audit found no activated gaming configuration there.
- Do not copy Well Done's NVIDIA/PRIME, bus IDs, persistence implementation, or host-specific package assumptions verbatim.

## Proposed Architecture

- `modules/gaming.nix`: shared NixOS module. Defines the gaming option surface and system-level configuration without implying a specific host.
- `modules/sessions.nix`: shared graphical-session and greeter module, relocated from the ambiguous `modules/desktop/` directory.
- `modules/xdg.nix`: shared system XDG portal integration, relocated from `modules/desktop/`.
- `modules/hardware/nvidia.nix`: hardware-specific NVIDIA module, relocated to the hardware namespace and used to restore the desktop import path.
- `home/gaming.nix`: shared Home Manager module. Installs user-facing tools and launchers only when the host-level gaming switch is enabled.
- `hosts/desktop/gaming.nix`: desktop policy. Declares the enabled gaming profile and any desktop-specific opt-ins.
- `hosts/laptop/gaming.nix`: laptop policy. Declares gaming disabled by default, while keeping the same option surface available for a later opt-in.
- `hosts/<host>/default.nix`: imports the shared NixOS gaming module and the host-local gaming policy.
- `home/default.nix`: imports the shared Home Manager gaming module once for both hosts.
- The Home Manager module reads the integrated NixOS host option (`osConfig.modules.gaming`) so each host has one authoritative gaming declaration.

## Option Surface

The shared module should expose a small master switch plus explicit opt-ins:

- `modules.gaming.enable`: master host switch; default `false`.
- Steam integration: Steam, Gamescope Session, Protontricks, Steam Input `extest`.
- Non-Steam tooling: ProtonPlus, Winetricks, umu-launcher, and Wine support.
- Launchers: Heroic and Lutris with Proton-GE/Wine/Gamescope/GameMode/MangoHud packages.
- Observability: MangoHud.
- Performance: GameMode, optional nix-gaming platform optimizations, and optional low-latency PipeWire.
- Data persistence: opt-in and host-specific; do not assume a persistence framework that Nixie has not enabled.

Defaults should avoid installing the full suite on hosts that only want Steam. Low-latency audio and platform optimizations should remain explicit opt-ins because they can affect compatibility and audio stability.

## Tasks

- [x] G0 — Remove the ambiguous `modules/desktop/` directory, relocate its contents by responsibility, solve the NVIDIA desktop validation blocker, and verify desktop evaluation.
- [x] G1 — Add and lock the `nix-gaming` input only if the current revision provides the required PipeWire and platform-optimization modules; document any cache policy without copying stale reference settings.
- [x] G2 — Implement the shared NixOS gaming module at `modules/gaming.nix`, with a default-off option surface and no hardware-specific GPU assumptions.
- [x] G3 — Add host-local gaming policy files for desktop and laptop, import the shared system module for both hosts, and make the host choice explicit and reviewable.
- [x] G4 — Implement `home/gaming.nix`, gated by the same host-level option, for MangoHud, ProtonPlus, Winetricks, umu-launcher, Heroic, Lutris, Proton-GE, Wine, and launcher extras.
- [x] G5 — Add optional gaming data persistence only after checking Nixie's actual storage/persistence model; preserve Steam, Lutris, Heroic, umu, and game-specific paths without inventing mount points.
- [x] G6 — Decide whether Niri gaming window placement and launch-option documentation belong in this feature; keep it separate from the package/module core if it is only convenience UX.
- [x] G7 — Validate the complete change with formatting checks, host evaluation checks, Home Manager builds for both hosts, and a readback that confirms gaming remains disabled on any host that did not opt in.

## Progress

- G0 complete: `modules/desktop/` was removed.
- `dual-sessions.nix` moved to `modules/sessions.nix`.
- `xdg.nix` moved to `modules/xdg.nix`.
- NVIDIA configuration restored at `modules/hardware/nvidia.nix`, matching the existing desktop import path without adding PRIME or bus-ID assumptions.
- Both host import lists and `AGENTS.md` were updated.
- Focused formatting checks and both host greeter evaluations passed.
- No activation, switching, disk operation, or commit was performed.
- G1–G4 complete: `nix-gaming` is locked at `1153f42bd4e293e23969481dd64b11fe8e745999`, follows root `nixpkgs`, and has no gaming-specific binary cache configured.
- The desktop opts into the complete profile; the laptop explicitly keeps `modules.gaming.enable = false`.
- Focused Nix formatting checks, both host greeter evaluations, and both Home Manager builds passed.
- G5 decision: Nixie's current Btrfs layout has ordinary persistent home data and no preservation framework; no extra gaming persistence paths were added.
- G6 decision: Niri placement and launch-option UX remain deferred as a separate convenience feature, avoiding unrequested workspace changes.
- G7 complete: focused formatting, flake evaluation, both host checks, both Home Manager builds, gaming option readback, and removal of `modules/desktop/` all passed. Only existing warnings were observed.

## Acceptance Criteria

- Gaming is disabled by default and a host enables it only through its own policy file.
- Desktop and laptop can choose different gaming profiles without duplicating module logic.
- Steam/Proton support works without requiring global Wine configuration.
- Non-Steam tools are optional and do not get installed on disabled hosts.
- Low-latency PipeWire and nix-gaming platform optimizations are independently opt-in.
- No Well Done hardware-specific NVIDIA/PRIME or persistence assumptions are copied.
- `references/` remains read-only.
- No activation, switching, disk operation, or generated hardware-file edits are performed.
- `modules/desktop/` no longer exists; sessions, XDG integration, and NVIDIA hardware configuration live under responsibility-based paths.
- The NVIDIA desktop path is solved and desktop evaluation passes before gaming implementation proceeds.

## Verification Plan

- `just --list`
- `just show-working`
- `just check ./modules/gaming.nix`
- `just check ./home/gaming.nix`
- `just check ./hosts/desktop/gaming.nix`
- `just check ./hosts/laptop/gaming.nix`
- `just check-desktop` and `just check-laptop`
- `just hm-build desktop` and `just hm-build laptop`
- `just check-tracked` only if a deliberate broad formatting sweep is warranted

A full system build remains unavailable until each host's generated `hardware-configuration.nix` exists.

## Non-Goals

- No automatic Proton version selection for individual games.
- No copying of another host's GPU driver, PRIME bus IDs, or display topology.
- No activation, `nixos-rebuild switch`, or destructive storage operation.
- NVIDIA resolution and the shared-module relocation stay as a prerequisite work unit and are not mixed into the gaming module changes.

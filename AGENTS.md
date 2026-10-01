# AGENTS.md

## Scope and Layout

This beginner-friendly flake defines two NixOS hosts: `desktop` and `laptop`.

- `flake.nix` exposes both `nixosConfigurations` and the `nixfmt` formatter.
- `hosts/desktop/` and `hosts/laptop/` compose each machine's host, Home Manager, hardware, and
  small host-specific modules.
- `modules/` contains shared system configuration, including Home Manager integration.
- Shared Home Manager modules live in `home/`, and each host's Home Manager-specific values live in
  `hosts/<host>/home.nix`.
- `modules/sessions.nix` enables SDDM with selectable Hyprland and Niri sessions
  on both hosts; `modules/xdg.nix` provides shared system XDG portal integration; and
  `hosts/desktop/nvidia.nix` contains desktop-specific NVIDIA configuration.
- `home/gui/hypr/` is the live Hyprland tree: Nix only creates out-of-store links, so editing
  those files takes effect on reload instead of requiring a rebuild.
- `references/` is read-only inspiration, not an edit target.

Each host's `hardware.nix` optionally imports a generated
`hosts/<host>/hardware-configuration.nix`. Those generated files are currently absent, so a full
system build is intentionally unavailable until the relevant hardware configuration is added.

## Live and Store-Backed Configuration

Home Manager deploys two kinds of file here, and the difference decides how you iterate:

- **Live (out of store).** `nixie.home.repositoryRoot` points at this checkout and the links resolve
  into the repository itself: the agent skills under `home/agents/skills`, and the whole Hyprland
  tree in `home/gui/hypr/` (`hyprland.lua`, the `lua/` directory and the `scripts/` directory).
  Editing those files is enough; reload the application instead of rebuilding. Each host declares
  that root explicitly in `hosts/<host>/home.nix`.
- **Store backed.** Nushell, Kitty, Zed, Zellij, Swappy, Swayimg, Niri and Noctalia settings, plus
  every generated file, are copied into the Nix store. Changing them requires rebuilding and
  activating the host's Home Manager configuration.

Hyprland is therefore fully live while Niri and Noctalia are fully declarative. Do not reintroduce
Nix-side generation of Hyprland Lua, and keep machine-specific Hyprland facts in the live tree
rather than in Nix options: `home/gui/hypr/lua/host.lua` reads `/etc/hostname` and returns the facts
from `home/gui/hypr/lua/hosts/<hostname>.lua`, whose file declares that machine's monitors,
workspace pins and capability flags. Shared `inputs.lua` and `keybinds.lua` consume those flags. Add
a host by adding `lua/hosts/<hostname>.lua`; an unknown hostname warns on stderr and falls back to
defaults rather than aborting the session; host-module load failures include the original error
before falling back. `.luarc.json` declares the `hl` global that Hyprland
injects so Lua tooling stops flagging it.

Two consequences worth remembering: live files are outside any Nix generation, so rolling back to an
older generation does not restore their previous content, and a missing or moved checkout breaks
those links at runtime.

## Safe Commands

Use the root `Justfile` to discover and inspect commands:

```bash
just --list
just --show <recipe>
```

The recipes use `path:.` deliberately. A normal Git flake reference such as `.#...` reads the Git
tracked source and can omit untracked modules; `path:.#...` evaluates the working tree instead.

```bash
just show-working
just inspect-login desktop
just inspect-login laptop
just hm-build desktop
just hm-build laptop
```

`inspect-login <desktop|laptop>` evaluates only
`services.displayManager.generic.execCmd`. `check-desktop` and `check-laptop` remain compatibility
aliases for that limited inspection; none of these commands is a full host check. Existing
show/build/eval recipes use `--no-write-lock-file` so validation does not refresh the lockfile.
The pinned NixOS SDDM module's default Wayland compositor (Weston) generates its keymap from the
system XKB layout, but local evaluation cannot prove the effective layout in a running login greeter.

`hm-build` builds only the selected host's Home Manager activation package and uses `--no-link`; it
does not activate a profile. Its `NIXPKGS_ALLOW_UNFREE=1` and `--impure` settings are scoped to that
recipe because the current Home Manager configuration needs unfree agent packages.

Use explicit Nix file paths for formatting checks. These recipes reject `references/`, paths
outside the repository, and symlinks:

```bash
just fmt ./modules/core/audio.nix
just check ./modules/core/audio.nix
```

For an intentionally broad, manually invoked pass, `fmt-tracked` formats only tracked project
`*.nix` files. It uses a NUL-delimited Git file list, preserves spaces in names, skips
`references/`, and stops at the first failure. It never runs from `default`, help, or validation.
`check-tracked` performs the same tracked-only scope without changing files. New untracked Nix
files are excluded; format them explicitly with `just fmt ./file.nix`.

```bash
just fmt-tracked
just check-tracked
```

Update lockfile entries only when you deliberately want newer floating inputs:

```bash
just update-one nixpkgs
just update-all
```

`update-one` accepts only `nixpkgs`, `nix-gaming`, `disko`, `home-manager`, `noctalia`, or
`noctalia-protonvpn`; `update-all` runs `nix flake update`. Neither builds,
switches, or commits. After either, inspect `git diff flake.lock`, then use `just show-working` and
`just hm-build desktop` or `just hm-build laptop` for each affected host. `nix-gaming` follows the
root `nixpkgs` input and no gaming-specific binary cache is configured. `helium` and `nixvim` use
commit-pinned URLs in `flake.nix`, so a lockfile refresh alone cannot advance them.

`just system-build desktop` or `just system-build laptop` is also non-activating, but it first
requires that host's generated `hardware-configuration.nix`; it prints a practical failure before
calling Nix when the file is missing.

## Validation Order

For a focused configuration change, use the smallest applicable checks in this order:

1. `just --list`
2. `just show-working`
3. `just inspect-login <desktop|laptop>` to inspect only the display-manager command; the
   `check-desktop` and `check-laptop` aliases preserve compatibility but provide no broader check
4. `just hm-build <desktop|laptop>` when Home Manager evaluation needs validation
5. `just fmt ./path/to/file.nix` and `just check ./path/to/file.nix` for each touched Nix file
6. `just check-tracked` only when a deliberate tracked-project formatting sweep is warranted

Do not add a TDD test by default: use behavior-level TDD only when a project or task configuration
enables it. There is no dedicated test runner configured here. Report every command run and any
skipped or failed check. In particular, disclose that missing generated hardware files prevent a
system build, and that evaluation or a Home Manager build does not validate live hardware or a
running graphical session.

## Operational checklist

After manual activation, verify these on both machines; local evaluation and builds do not prove
runtime behavior:

- [ ] US key positions work at console/login and in Hyprland and Niri; live Hyprland links resolve,
      reload, and select the intended host facts (including laptop outputs).
- [ ] SSH public keys are provisioned; tailnet peer ACLs permit intended access and deny unintended
      paths. Do not expose key material while checking.
- [ ] In LocalSend Settings → Receive, turn off both Quick Save toggles, including Quick Save from
      Favorites; confirm incoming transfers require approval, including from a favorite sender.
- [ ] Confirm the running firewall backend and rules match evaluated policy; private source ranges
      do not establish trusted sender identity.

## Deployment Boundary

This repository provides no activation recipe. `nixos-rebuild build` only builds a closure;
`nixos-rebuild test` temporarily activates a configuration until reboot; `nixos-rebuild boot` sets
the next boot configuration without switching the running system; and `nixos-rebuild switch`
builds and activates it now. These operations normally require root privileges and can affect the
running machine, so choose and run them manually only after appropriate validation.

## Nix Style

- Prefer small function-header modules, for example `{ pkgs, ... }:` when `pkgs` is used.
- Use two-space indentation, semicolon-terminated assignments, and readable multiline lists.
- Keep shared system behavior in `modules/`, shared user behavior in `home/`, and machine-specific
  behavior under the relevant `hosts/<host>/` directory.
- Preserve the optional hardware import pattern in each host's `hardware.nix`.

## Safety

- Read nearby files and make minimal, local changes.
- Never add secrets or edit generated hardware configuration without an explicit request.
- Do not use recipes for `sudo`, system switching, test activation, garbage collection, cleaning,
  or commits; none are provided here. Only the explicitly invoked `update-one` and `update-all`
  recipes can change `flake.lock`.
- Keep `references/` and unrelated dirty or untracked files untouched.

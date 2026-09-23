# AGENTS.md

## Purpose and Scope

- Primary target is the root NixOS config (`flake.nix`, `hosts/`, `modules/`).
- `references/` contains external examples to learn from, not the default edit target.
- Prefer minimal, beginner-friendly changes in the main config unless asked otherwise.

## Repository Layout

- `flake.nix`: root flake entrypoint for `nixosConfigurations.desktop`.
- `hosts/desktop/default.nix`: host composition and optional hardware import.
- `hosts/desktop/host.nix`: host identity and user declaration.
- `hosts/desktop/gpu-nvidia.nix`: Nvidia-specific options.
- `modules/default.nix`: root module entrypoint; imports shared base modules and Home Manager integration.
- `modules/base/default.nix`: aggregate imports for shared system modules (`audio`, `fonts`, `locale`,
  `networking`, `nix`, `packages`, `ssh`, and `users`).
- `modules/desktop/default.nix`: intentionally empty aggregator retained for later host-level desktop selection.
- `references/peachy-nixos/`: script-driven advanced example.
- `references/ryan-nixos/`: highly modular example with `Justfile` and CI workflow.

## Build, Lint, and Test Commands

### Main repo commands (root)

- Show flake outputs:

```bash
nix flake show
```

- Build config without switching system state:

```bash
sudo nixos-rebuild build --flake .#desktop
```

- Test activation without making it current (single-host validation):

```bash
sudo nixos-rebuild test --flake .#desktop
```

- Apply configuration:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

## Code Style Guidelines

### Nix file/module shape

- Prefer function-header modules:

```nix
{ ... }:
{
  # options
}
```

- Include only the arguments you use (example: `{ pkgs, ... }:` when needed).
- Keep module responsibilities narrow (one concern per file when possible).

### Imports and composition

- Keep the root module entrypoint in `modules/default.nix`.
- Keep shared imports in `modules/base/default.nix`.
- Retain `modules/desktop/default.nix` as an empty aggregator until a host explicitly selects it.
- Compose host-specific config in `hosts/desktop/default.nix`.
- Follow existing optional hardware import pattern:

```nix
++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;
```

### Formatting

- Use two-space indentation in Nix files.
- End assignments with semicolons.
- Prefer multiline lists for readability.
- Match existing formatter output instead of hand-styling.
- For prose/json/yaml files, follow Prettier settings in repo.

### Naming conventions

- Use kebab-case for file names (`gpu-nvidia.nix`).
- Keep host names lowercase (`desktop`).
- Keep directories descriptive (`hosts/desktop`, `modules/base`, `modules/desktop`).
- Use upstream NixOS option names exactly (`networking.hostName`, `services.openssh.enable`).

### Types and values

- Use canonical Nix primitives (`true/false`, quoted strings, lists, attrsets).
- Prefer explicit values over abstraction-heavy helper layers in this learning repo.
- Preserve module readability over clever terseness.

### Imports and package style

- For packages, match current style:

```nix
environment.systemPackages = with pkgs; [
  git
  vim
  curl
  wget
];
```

- Keep package lists alphabetized only if the surrounding file is already alphabetized.

### Error handling and safety

- In shell scripts, fail fast and check exit codes explicitly.
- Do not add silent failure patterns.
- Do not introduce destructive operations unless explicitly requested.
- Never commit real credentials or secrets.

### Comments and docs

- Keep comments short and practical.
- Spanish comments are acceptable and already present; stay consistent per file.
- Update docs when workflows or commands change.

## Agent Workflow Expectations

- Read nearby files before editing to match local conventions.
- Prefer small, surgical edits over broad refactors.
- Validate changes in this order when possible:
  1. `nix flake show`
  2. `sudo nixos-rebuild build --flake .#desktop`
  3. `sudo nixos-rebuild test --flake .#desktop`
- If a command cannot run in the current environment, state that explicitly in your report.

## Cursor/Copilot Rules

- No `.cursor/rules/`, `.cursorrules`, or `.github/copilot-instructions.md` files were found in this
  repository tree.
- If such files are added later, treat them as higher-priority constraints and merge guidance here.

## Known Constraints

- Root repo is intentionally simple and beginner-oriented; avoid over-engineering.
- `references/` includes advanced patterns that may not fit this repo yet.
- Keep hardware-sensitive options host-aware (especially GPU and generated hardware config imports).
- Keep target host as `desktop` unless requested otherwise.

## Quick Checklist for Agents

```text
1) Inspect flake.nix, hosts/desktop, modules/base, and modules/desktop.
2) Make minimal, local edits in one host/module area.
3) Format touched files (nixfmt and/or prettier where relevant).
4) Run flake show, then rebuild build/test for .#desktop.
5) Report exactly what changed and what was verified.
```

# Helix and Neovim Editor Configuration

## Objective

Manage Helix and Neovim declaratively in the shared Home Manager core, following Well Done's editor organization and full Nixvim approach for Neovim.

## Problem and rationale

Nixie previously installed Neovim as a package but had no editor configuration module, and Helix was not configured. Well Done provides a useful baseline: Home Manager settings for Helix and Nixvim for Neovim. Nixie now keeps these terminal editors under `home/core/editors/` and makes the configured Neovim binary available to Zellij's scrollback editor.

## Scope and constraints

- Add the Nixvim flake input pinned through `flake.lock`, following Nixie's root `nixpkgs` input, and pass it into Home Manager.
- Add shared Helix and Nixvim modules under `home/core/editors/`, porting Well Done's editor settings, keybindings, options, Catppuccin, LSP servers, Treesitter grammars, and Neo-tree.
- Keep `git` in `home/core/packages.nix`; remove only the standalone `neovim` package because Nixvim provides its configured package.
- Point Zellij's Neovim scrollback editor at the configured Nixvim package.
- Preserve Nixie's existing `EDITOR=nvim` and `VISUAL=nvim`; do not adopt Well Done's Helix-default session variables without a separate request.
- Do not change host-specific configuration, activate the system, or touch unrelated dirty files.
- Verification strategy: ordinary functional Nix checks, selected by the user; no TDD mode or runner is configured.
- Route: one bounded `gentle-ai-worker` for the multi-file implementation; parent reviewed the diff and independent verification evidence.
- Estimated authored change size: approximately 250 lines, excluding generated lockfile changes. Delivery strategy: ask-on-risk.
- The user authorized granular commits. Stage only the explicit work-unit paths/hunks below; leave all other dirty paths untouched.

## Tasks

- [x] **EDITORS-01 — Add shared Helix and Nixvim configuration.** Added and locked the Nixvim input, passed it through the Home Manager module arguments, added the editor modules, removed only the duplicate standalone Neovim package, and updated Zellij to use the configured Neovim package. Preserved the current default editor.
- [x] **EDITORS-02 — Verify editor modules on desktop and laptop.** Formatting and diff checks passed. Direct Home Manager option evaluations confirmed Helix and Nixvim enabled on both hosts and resolved the configured Neovim derivation. **Status:** complete; see the full-system blocker below.
- [ ] **EDITORS-03 — Resolve existing full-system evaluation blockers.** Full NixOS `system.build.toplevel` evaluation reaches pre-existing host assertions for missing root filesystem and GRUB device configuration. This is outside the editor change and remains blocked pending separate authorization to address host configuration.
- [x] **COMMIT-01 — Commit the earlier Git package addition separately.** Staged and committed only the Git addition hunk from `home/core/packages.nix`, retaining Neovim in this commit. **Commit:** `ef189a0dfadca0e512f41cf283acedcc59261d16` (`feat(core): add Git package`).
- [x] **COMMIT-02 — Commit Helix configuration as a standalone work unit.** Committed the shared-core import, Helix module, and Helix-only editor aggregator. **Commit:** `68857fecb542a17442f1c87be04d7d49277b4611` (`feat(home): configure Helix editor`).
- [x] **COMMIT-03 — Commit the Nixvim/Neovim integration.** Committed the Nixvim pin/wiring, Neovim module, aggregator update, standalone Neovim package removal, Zellij path update, and feature task document. **Commit:** `0a4a57290c8f5b1b6efbb23375cea2afb3bc7627` (`feat(home): configure Neovim with Nixvim`).

## Acceptance criteria

- Both `desktop` and `laptop` have Helix and Nixvim enabled in their shared Home Manager config.
- Nixvim follows Nixie's pinned root `nixpkgs` and its exact revision is recorded in `flake.lock`.
- The Neovim config matches the selected Well Done baseline without switching Nixie's default editor from `nvim`.
- `git` remains installed, and Zellij uses the configured Nixvim Neovim package.
- Editor-module formatting and focused evaluations pass; full-system evaluation limitations are reported without changing unrelated host files.
- Each authorized work unit has a narrow Conventional Commit and recorded identity.

## Verification plan and evidence

- `nix flake lock --update-input nixvim`: passed; lock revision is `167da56c3ab1e51751a6ae4a997ed66587f9edae` and Nixvim follows root `nixpkgs`.
- `nix develop --command nixfmt --check flake.nix modules/home-manager.nix home/core/default.nix home/core/packages.nix home/core/zellij.nix home/core/editors/default.nix home/core/editors/helix.nix home/core/editors/neovim.nix`: passed after updating the clipboard predicate to `pkgs.stdenv.hostPlatform.isLinux`.
- `git diff --check`: passed.
- Direct `path:.` option evaluations: `programs.helix.enable` and `programs.nixvim.enable` are `true` for both `desktop` and `laptop`.
- Direct `programs.nixvim.build.package.drvPath` evaluations passed for both hosts and resolved to `/nix/store/vjyvscj0imm9kl22vf23k3jm6gv52lb3-nixvim.drv`.
- Full `nix eval --json 'path:.#nixosConfigurations.<host>.config.system.build.toplevel.drvPath'` evaluations failed on pre-existing missing root filesystem and GRUB device assertions. They were read-only evaluations; no build or activation was attempted.
- Nonfatal warnings observed: selected Well Done Nixvim 26.05 is paired with Nixpkgs 26.11; this known version mismatch was retained to match the selected Well Done pin. Nix evaluation also emitted ignored eval-cache-busy messages. The `stdenv.isLinux` deprecation was removed by using `stdenv.hostPlatform.isLinux`.
- Native review assessment returned `risk=unassessable` (`native-assess-unavailable`); an independent verifier completed the focused checks. Native review `inspect` stopped with `rdd_disabled`, so no review was started or acknowledged.
- Other dirty working-tree changes are unrelated and remain excluded from the commit plan.

## Progress and evidence

- Exploration confirmed the Well Done reference uses a Home Manager Helix module and Nixvim's Home Manager module; its Nixvim input follows `nixpkgs` and is locked to revision `167da56c3ab1e51751a6ae4a997ed66587f9edae`.
- Exploration confirmed Nixie's previous editor package ownership was in `home/core/packages.nix`, its Nushell session keeps `EDITOR` and `VISUAL` set to `nvim`, and Zellij previously pointed at `${pkgs.neovim}`.
- The implementation added `home/core/editors/default.nix`, `helix.nix`, and `neovim.nix`; added Nixvim flake/Home Manager wiring; retained `git`; removed the duplicate standalone Neovim package; and set Zellij's scrollback editor to `${config.programs.nixvim.build.package}/bin/nvim`.
- Final parent readback confirmed the editor modules, Nixvim wiring, Zellij path, and preserved editor default. The unrelated working-tree changes remained untouched.
- `COMMIT-01` created `ef189a0dfadca0e512f41cf283acedcc59261d16` (`feat(core): add Git package`); its staged diff contained only the previously requested Git package addition.
- `COMMIT-02` created `68857fecb542a17442f1c87be04d7d49277b4611` (`feat(home): configure Helix editor`); its staged diff contained only the core editor import and Helix configuration.
- `COMMIT-03` created `0a4a57290c8f5b1b6efbb23375cea2afb3bc7627` (`feat(home): configure Neovim with Nixvim`); its staged diff contained the Nixvim wiring, Neovim module, package/Zellij updates, and this feature document.
- All unrelated worktree changes remain excluded from the three work-unit commits.

## Next step

Commit this task-document update so the repository records all three granular work-unit identities; no further editor source changes are planned.

# Classify Fastfetch and Starship as TUI

## Goal

Keep terminal-facing user tools together under `home/tui` instead of treating Fastfetch, Starship, and fzf as core infrastructure.

## Work units

- [x] Move Fastfetch and Starship modules and their source files from `home/core` to `home/tui`; move fzf package ownership from core into a TUI module.
- [x] Update category aggregators and live symlink sources without changing generated config destinations or behavior.
- [x] Verify source resolution and formatting, then commit the correction as `fdae6ad` (`refactor(home): classify terminal tools as tui`).

## Verification evidence

- `nix fmt -- --check` passed for the changed Nix files.
- `git diff --cached --check` passed.
- Desktop and laptop Home Manager activation evaluations passed (impure) and returned the same generation derivation; only the pre-existing Yazi `shellWrapperName` warning appeared.
- Fastfetch and Starship live sources resolve under `home/tui`; each module is imported once. fzf is owned by TUI; core packages retains `bat` and `neovim`.
- No stale `home/core/fastfetch` or `home/core/starship` references remain.

## Boundaries

- Do not change Fastfetch or Starship settings, packages, or generated XDG targets; fzf remains enabled with the same package and options.
- Keep `home/core` for shared infrastructure and packages; keep interactive/terminal-facing tools under `home/tui`.
- Preserve any concurrent username-parameterization changes and commit them separately.

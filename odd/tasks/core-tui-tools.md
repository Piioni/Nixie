# Group core terminal tools

## Goal

Create `home/core/tui.nix` to group fzf, bat, eza, and zoxide Home Manager configuration, inspired by well-done's core tool grouping.

## Work units

- [x] Consolidate bat/fzf/eza/zoxide declarations in `home/core/tui.nix`, add the module to the core aggregator, remove superseded declarations/modules, and remove the now-invalid Caelestia theme reference from btop while preserving its existing file deletion.
- [x] Verify desktop/laptop package and integration options, ensure existing Nushell aliases and zoxide integration are preserved, then commit `adee47d`.

## Boundaries

- Keep `neovim` in `home/core/packages.nix`.
- Preserve zoxide's Nushell integration; do not enable other shell integrations.
- Keep fzf package availability without adding new shell keybindings/integration.
- Add eza with Git status and automatic icons, but do not replace the existing Nushell `ls`, `ll`, or other aliases.
- Keep bat enabled without importing extra settings from well-done.
- No changes to Nushell config or unrelated tools beyond moving zoxide module ownership.
- The user explicitly authorized removing the reference to the already-missing `home/core/btop/themes/caelestia.theme`; do not restore that deleted file. Its removal is part of the authorized work and will be committed with the btop cleanup.

## Verification

- `nix fmt -- --check home/core/tui.nix home/core/default.nix home/core/packages.nix home/core/nushell.nix home/core/btop.nix` — passed.
- `git diff --check` — passed.
- Impure host toplevel derivation evaluation with the repository's generated-filesystem/GRUB stub — desktop and laptop both passed using a temporary copy that does not preserve archived evidence permissions. The first attempt returned exit 1 only because cleanup could not remove the protected-mode temporary copy; no source/evidence files were changed. The safe rerun returned both derivation paths and cleaned its temp directory successfully.
- Evaluated Home Manager values on both hosts: fzf, bat, eza, zoxide enabled; fzf integrations disabled; eza Git enabled, icons `auto`, integrations disabled; zoxide Nushell integration only; no Caelestia btop target.
- Existing Nushell aliases were unchanged; the Caelestia theme remains deleted as explicitly authorized. Existing Yazi legacy-default warning remains.
- Work-unit commit: `adee47d feat(home): group core terminal tools`.

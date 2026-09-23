# Migrate GUI app settings to native Home Manager options

## Goal

Use the pinned Home Manager modules to declare Swappy and Kitty settings in Nix where this preserves current behavior. Ghostty already uses its native `programs.ghostty.settings` and remains unchanged.

## Work units

- [x] Migrate Swappy's eight runtime-supported INI settings into `programs.swappy.settings`; omit the five inert `key_*` entries and remove the source INI after semantic verification — `c73bc0e`.
- [x] Migrate Kitty's scalar settings and keybindings into the native Home Manager module; keep the Catppuccin theme and Python utility scripts as files, preserve the Nushell executable path and current integrations, and avoid adding process reload behavior — `9087878`.
- [x] Verify both host evaluations and generated config semantics, record evidence, and commit each completed work unit — `c73bc0e`, `9087878`.

## Boundaries

- Do not modify `home/gui/ghostty.nix`; its settings are already native. Verify its effective options do not drift.
- For Swappy, preserve all eight values consumed by the pinned Swappy parser and Linux-only package behavior; do not enable additional service/integration behavior. The five `key_*` entries are not read by Swappy 1.8.0 and should not be carried as active settings.
- For Kitty, keep `Catppuccin-Mocha.conf`, `utils/scroll_mark.py`, and `utils/search.py` as managed files.
- Preserve `kitty` shell path as `${pkgs.nushell}/bin/nu`, `shell_integration = no-cursor`, all current scalar settings, and all keybindings.
- Do not enable Bash/Fish/Zsh/Git integrations or change Kitty reload/onChange behavior.
- Do not edit or stage the finished host-module changes under `AGENTS.md`, `modules/`, or `odd/tasks/host-module-organization.md`; do not edit or stage the unrelated `home/core/packages.nix` Git addition.
- Commit only the completed GUI work-unit paths; leave all other dirty paths untouched.
- Do not run NixOS activation or system build/test/switch.

## Kitty verification evidence

- Work-unit commit: `9087878 refactor(gui): declare Kitty settings in Nix`.
- `nix fmt -- --check home/gui/kitty.nix` and `git diff --check -- home/gui/kitty.nix` — passed; formatter printed only the dirty-tree warning.
- Desktop and laptop impure evaluations via `builtins.getFlake ("path:" + builtins.getEnv "PWD")` passed with identical generated Kitty config. All source scalar settings and six keybindings are present, including explicit `kitty_mod ctrl+shift`; theme include is before generated settings; Nushell path is selected and `shell_integration no-cursor` retained.
- `shellIntegration.mode = null`, Bash/Fish/Zsh/Git integrations false, `onChange = ""`, and exactly one `kitty-0.48.2` package were confirmed. Theme and both Python utility assets resolve from their managed source files. Ghostty has no diff.
- Generated differences from the old file are only the Home Manager header, sorted option order, float normalization (`0.93` to `0.930000`), and intended `fish` to Nushell path substitution. The original `home/gui/kitty/kitty.conf` was kept during verification and deleted in `9087878`.
- Initial direct `path:$PWD#...` selector evaluations failed because this Nix CLI treated the path selector as a filesystem path; the corrected impure `builtins.getFlake` evaluations passed for both hosts.

## Swappy verification evidence

- Work-unit commit: `c73bc0e refactor(gui): declare Swappy settings in Nix`.
- `nix fmt -- --check home/gui/swappy.nix` — passed; only the expected dirty Git tree warning (plus an ignored SQLite eval-cache busy warning in one parallel evaluation).
- `git diff --check -- home/gui/swappy.nix` — passed.
- Desktop and laptop evaluations using `nix eval --json "path:$PWD#nixosConfigurations.<host>.config.home-manager.users.piioni" --apply 'home: { settings = home.programs.swappy.settings.Default; packagePresent = builtins.elem home.programs.swappy.package home.home.packages; }'` both passed and returned `swappy-1.8.0`, `packagePresent = true`, and the exact eight parser-supported settings: `$HOME/Pictures/Screenshots`, `hypr-%Y%m%d-%H%M%S.png`, `show_panel = false`, `line_size = 5`, `text_size = 20`, `paint_mode = "brush"`, `early_exit = false`, `fill_shape = false`.
- Upstream Swappy 1.8.0 `src/config.c` (`https://raw.githubusercontent.com/jtheoof/swappy/v1.8.0/src/config.c`) confirms the five `key_*` entries are never read by the app parser. An earlier generic INI parse flagged their inline comments as literal values; source inspection resolved this as inert configuration, and those entries are omitted.
- The original `home/gui/swappy/config` was deleted after semantic verification in `c73bc0e`. The verifier's first scoped cached-diff check returned a Git path-argument error; a follow-up `git diff --cached --check -- home/gui/swappy.nix odd/tasks/gui-native-settings.md home/gui/swappy/config` passed, and the staged deletion was confirmed by status and `git ls-tree HEAD` before commit.

## Final integrated verification

- `nix fmt -- --check home/gui/swappy.nix home/gui/kitty.nix home/gui/ghostty.nix` — passed; only dirty-tree warning.
- `git show --check --oneline c73bc0e` and `git show --check --oneline 9087878` — passed.
- Desktop/laptop targeted Home Manager evaluations via `builtins.getFlake ("path:" + builtins.getEnv "PWD")` — passed; Swappy and Kitty values/packages match, Ghostty remains declarative and unchanged. Assets and source-file removals verified.
- The first `git diff --check` path list included the removed `home/gui/swappy` directory and returned exit 128; corrected scoped checks of existing GUI paths passed. Initial direct Kitty `path:$PWD#...` selectors failed; corrected `builtins.getFlake` evaluations passed. No NixOS build/test/switch/activation was run.
- Native `gentle_review assess` returned `unassessable` because the native command returned empty output (RDD off); writer self-checks and independent read-only verification were completed.
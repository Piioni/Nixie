# Quiet Evaluation Warnings

## Objective
Remove actionable configuration warnings observed during Nixie evaluation while leaving repository-state and transient tooling notices clearly documented.

## Scope

- Preserve the existing Yazi wrapper behavior explicitly.
- Align the pinned Nixvim input with the root nixpkgs generation.
- Replace deprecated `pkgs.system` access with the supported platform path.
- Re-run focused formatting, host evaluation, and Home Manager checks.

## Non-Goals

- A dirty Git tree is not a configuration warning and is resolved only by the user's commit/stash decision.
- SQLite eval-cache contention is transient tooling state; do not delete caches or mutate the environment to hide it.
- Do not activate, switch, commit, or modify unrelated feature work.

## Tasks

- [x] W1 — Set `programs.yazi.shellWrapperName = "yy"` to preserve the current wrapper and silence the state-version migration warning.
- [x] W2 — Update the pinned Nixvim input to a current compatible revision and lock it without changing the root nixpkgs generation.
- [x] W3 — Replace `pkgs.system` in the Helium package lookup with `pkgs.stdenv.hostPlatform.system`.
- [x] W4 — Validate both hosts and Home Manager builds, recording remaining non-actionable notices.

## Acceptance Criteria

- No Yazi legacy-default warning appears.
- No Nixvim/Nixpkgs version mismatch warning appears.
- No deprecated `system` attribute warning appears from Nixie sources.
- Both Home Manager builds and both host checks pass.
- Dirty-tree and transient eval-cache notices are reported separately if present.

## Progress

- W1 complete: Yazi keeps the existing `yy` wrapper explicitly.
- W2 complete: Nixvim is pinned to `bcb5f577a36565bda07d7b81346b73cad8618d16`, compatible with the root nixpkgs generation.
- W3 complete: Helium uses `pkgs.stdenv.hostPlatform.system`.
- W4 complete: focused formatting, both host checks, both Home Manager builds, and warning-filtered evaluation passed.
- Remaining repository notice: Git reports a dirty tree because the feature changes are uncommitted.
- SQLite eval-cache contention is transient tooling state and did not recur during this validation.

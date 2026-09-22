# Apply progress — multi-workstation-architecture

- Change: `multi-workstation-architecture`
- Artifact store: `openspec` — this artifact is `openspec/changes/multi-workstation-architecture/apply-progress.md`
- Phase: apply (partial)
- **Scope executed: WU0 and WU1 only**, as explicitly bounded by the parent orchestrator.
- **Not started, deliberately:** WU2, WU3a, WU3b, WU4, Final verification.
  No `hosts/laptop/` directory, no `home/piioni/workstation.nix`, no `base.nix`/`gui.nix` role layer,
  no `hosts/{desktop,laptop}/{home,facts}.nix`, no rendered payload file, no `flake.nix` change and no
  `modules/home-manager.nix` change was created or touched.
- Strict TDD: **not applicable** (`openspec/config.yaml` → `strict_tdd: false`). No RED/GREEN evidence
  exists, and none is claimed. The verification surface is evaluation-level (`nix eval` toplevel plus
  `nixfmt --check`), not unit tests.
- Commit policy: **nothing was committed.** WU1 was performed with `git mv`, so the index holds the
  rename and the working tree holds the import change. Commits remain parent-owned.

## Structured status consumed

Native status was consumed before editing (`actionContext.mode: repo-local`, authoritative for the
`openspec` store):

| Field | Value |
|---|---|
| `changeName` | `multi-workstation-architecture` |
| `artifactStore` | `openspec` |
| `applyState` | `ready` (not blocked) |
| `apply` dependency | `ready` |
| `nextRecommended` | `apply` |
| `workspaceRoot` | `/home/piioni/Repos/Nixie` |
| `allowedEditRoots` | `["/home/piioni/Repos/Nixie", "/home/piioni"]` |
| `taskProgress` at entry | `0/63` complete |
| Delivery strategy (parent prompt) | `single-pr` — no chain strategy selected; `Chain strategy: pending` left as-is |
| Strict TDD (config + parent prompt) | not active |

`actionContext` warnings: none. No target file lay outside the authoritative workspace or the allowed
edit roots; every edit was inside `/home/piioni/Repos/Nixie`. The Review Workload Forecast guard block
reads `Decision needed before apply: No`, `Chained PRs recommended: No`, `400-line budget risk: Medium`,
so no delivery decision was required to proceed, and none was invented.

## Completed tasks and persisted checkbox updates

Both persisted in `openspec/changes/multi-workstation-architecture/tasks.md` (not only here).

### WU0 — pre-change witness capture (5 of 5 implementation-owned checkboxes)

| # | Task | Persisted |
|---|---|---|
| 1 | `git rev-parse HEAD`, `git status --porcelain`, pinned `flake.lock` revisions → `capture.txt` | `- [x]` |
| 2 | Build + `cp -rL` the materialised `home-manager.users.piioni.home-files`; verify dereferenced rendered bytes for the four named targets | `- [x]` |
| 3 | Option snapshot (sorted `attrNames home.file`, `{ target, recursive, text? }`) → `home-file-snapshot.json`, no total target count | `- [x]` |
| 4 | Pre-move `system.build.toplevel.drvPath` for `desktop` → `desktop-toplevel.drvPath` | `- [x]` |
| 5 | Grep proof that no `*.nix` references `evidence/` | `- [x]` |

### WU1 — NVIDIA pure move (5 of 5 implementation-owned checkboxes)

| # | Task | Persisted |
|---|---|---|
| 1 | Move `hosts/desktop/gpu-nvidia.nix` → `modules/hardware/nvidia.nix` byte-identically; `git diff -M` reports rename, no content change | `- [x]` |
| 2 | Import line in `hosts/desktop/default.nix` → `../../modules/hardware/nvidia.nix` | `- [x]` |
| 3 | No other reference; no `modules/hardware/default.nix`; `modules/default.nix` unchanged | `- [x]` |
| 4 | G1 for `desktop`, exit code + R4 equality with the recorded `drvPath` | `- [x]` |
| 5 | G5 over the moved file | `- [x]` |

Checkbox marking note (recorded honestly): WU0's five checkboxes were marked in the same edit as WU1's
rather than immediately after WU0 finished. Persistence happened before this report; no completed task
is represented only in `apply-progress.md`. The persisted file was re-read after the edit and all ten
rows show `- [x]`.

## Files created, moved or modified

Created (WU0, evidence only, all untracked and outside Nix's reach):

| Path | Notes |
|---|---|
| `openspec/changes/multi-workstation-architecture/evidence/pre-change/capture.txt` | 6935 bytes; HEAD, porcelain status, flake.lock, gate commands and results, isolation proof |
| `openspec/changes/multi-workstation-architecture/evidence/pre-change/home-files/` | 87 regular files, 4.4 MB; `cp -rL` of `/nix/store/bpjfpb3j22i3bdciizsrgm6m22gph32d-home-manager-files`; 0 symlinks remain |
| `openspec/changes/multi-workstation-architecture/evidence/pre-change/home-file-snapshot.json` | 27371 bytes; key-sorted; set equality only |
| `openspec/changes/multi-workstation-architecture/evidence/pre-change/desktop-toplevel.drvPath` | one line, no trailing newline |

Moved (WU1):

| From | To | Evidence |
|---|---|---|
| `hosts/desktop/gpu-nvidia.nix` | `modules/hardware/nvidia.nix` | `git diff -M --cached --summary` → `rename … (100%)`; numstat `0 0`; sha256 identical before and after (`2031c04d0f4b58785b1d9709fd4c2a2257a997f3782d911b563510fa844b3369`), and identical to the HEAD blob |

Modified (WU1, one line):

| Path | Change |
|---|---|
| `hosts/desktop/default.nix` | `./gpu-nvidia.nix` → `../../modules/hardware/nvidia.nix` (1 insertion, 1 deletion) |

Modified by this phase outside the repository tree: `tasks.md` (ten checkboxes) and this file.

Not created, as required: `modules/hardware/default.nix` (absent), `hosts/laptop/`, `home/piioni/workstation.nix`,
`home/piioni/base.nix`, `home/piioni/gui.nix`, `hosts/*/facts.nix`, `hosts/*/home.nix`, any rendered payload file.
`modules/default.nix` is unchanged versus HEAD (`git diff --quiet HEAD -- modules/default.nix` exit 0).

## Gate commands run and observed results

### WU0

**G1 (HOST=desktop, pre-change).** The gate recorded in `openspec/config.yaml` →
`testing.runner.command`, generalised to `HOST`, over a fresh non-Git copy
(`rsync -a --exclude .git --exclude references ./ "$D/t/"`).

- Exit code: **0**
- stderr: only the pre-existing `programs.yazi.shellWrapperName` legacy-default warning. No assertions failed.
- stdout: `/nix/store/26i3y9sww43ns37igrrjgpm98mf92zjz-nixos-system-desktop-26.11.20260823.56c02bc.drv`,
  which reproduces the derivation name recorded in `openspec/config.yaml`.

**G2 (pre-change materialised payload).** Same expression selecting
`nixosConfigurations.desktop.config.home-manager.users.piioni.home-files`, built with
`nix build --impure --no-link --print-out-paths`.

- Exit code: **0**; output `/nix/store/bpjfpb3j22i3bdciizsrgm6m22gph32d-home-manager-files`
- `cp -rL "<out>/." evidence/pre-change/home-files/`; symlinks remaining in the copy: **0**
- Tree root is `$HOME`-relative: `.cache/`, `.config/`, `.local/`
- The four required targets are present with dereferenced bytes:

| Target | Bytes | sha256 |
|---|---|---|
| `.config/hypr/lua/monitors.lua` | 196 | `9343cdc9b8d0026dd81dc1eeecc6adcd98a54fc8163a743574c7af912320b0b4` |
| `.config/hypr/lua/workspaces.lua` | 498 | `fe2adec69573e502389777391ccac7d83473d49d3bd1db441eee57611acf0e5d` |
| `.config/caelestia/shell.json` | 3162 | `556c583aa389b4569012fd0a58aa8c7e821ef139c330806a14ad5748bfe3c378` |
| `.config/btop/btop.conf` | 10915 | `4cfb6f1660a5c67e66c96080c5990e25cd4371a4642d46acf6044b71d27b0b8b` |

Rendered-vs-raw observations (all recorded in `capture.txt`):

- `monitors.lua` and `workspaces.lua` match their repository payload sources byte for byte, because today
  they are still shipped through the `recursive = true` directory copy. Both match the `design.md` §7.3
  fixtures exactly, including the leading blank line, the separating blank line and the trailing newline.
- `btop/btop.conf` matches `home/piioni/btop/btop.conf`, as expected from a `.source` target.
- `caelestia/shell.json` also matches its repository source. The pre-existing `lib.replaceStrings`
  substitution is an **identity** for this host: it maps
  `/home/piioni/.config/hypr/scripts/logout.sh` to `${config.xdg.configHome}/hypr/scripts/logout.sh`, and
  `xdg.configHome` is `/home/piioni/.config`. Recorded as an observation, not a defect. It does not weaken
  WU3b, whose desktop divergence (`"showBattery": true` → `false`) is a genuine change.
- Rendering *is* proven live at the oracle level by `herdr/config.toml`: the materialised file carries
  `default_shell = "/nix/store/9vinnxl5ansgi4xca5yidpypwzwqss4h-nushell-0.115.0/bin/nu"` while the
  repository payload carries `default_shell = "/home/piioni/.cargo/bin/nu"`.
- Zed rename note confirmed: the materialised target `.config/zed/settings.json` is sha256
  `bb4d02b97d1f93bbf64bb54959e133c46d33dfcfad8257971832679836a34575`, identical to
  `home/piioni/zed/settings.jsonc`. The target set is unaffected by the source rename, as expected.

**G3 (option snapshot).** `nix eval --impure --json` over the same flake copy, projecting
`nixosConfigurations.desktop.config.home-manager.users.piioni.home.file` to `{ target, recursive, text? }`.

- Exit code: **0**; result `evidence/pre-change/home-file-snapshot.json`
- Self-check: `jq -cS '.'` round-trips the file verbatim, so the recorded keys are sorted.
- Every entry carries a string `target` and a boolean `recursive`; `text` is present only where the entry
  declares one (12 entries do).
- **No total target count is recorded and no count-like key exists** (`count`/`total`/`target_count`/
  `total_targets` all absent). The set is the artefact; the size is not.

**Oracle isolation proof (grep).**

| Command | Result |
|---|---|
| `grep -rn --include='*.nix' --exclude-dir=references -- 'evidence' .` | no match (exit 1) |
| `grep -rn --include='*.nix' -- 'evidence' .` | no match (exit 1) |
| `grep -rn --include='*.nix' --exclude-dir=references -- 'openspec' .` | no match (exit 1) |

Scan scope: every `*.nix` under the repository, 39 files with the vendored `references/` tree excluded,
and the whole tree with it included. No Nix expression references the oracle, so `evidence/` can stay
untracked (and read-only) through apply without tripping the untracked-path evaluation error.

### WU1

**G1 (HOST=desktop, post-move).** Same gate, fresh non-Git copy.

- Exit code: **0**
- stderr: the same pre-existing yazi warning only. No assertion failures, no new warning.
- **R4 side by side:**

| | `system.build.toplevel.drvPath` |
|---|---|
| recorded (WU0) | `/nix/store/26i3y9sww43ns37igrrjgpm98mf92zjz-nixos-system-desktop-26.11.20260823.56c02bc.drv` |
| post-move (WU1) | `/nix/store/26i3y9sww43ns37igrrjgpm98mf92zjz-nixos-system-desktop-26.11.20260823.56c02bc.drv` |

- **Verdict: byte-equal.** `cmp` on the two values is identical. The pure move is proven
  behaviour-preserving at the system layer (R4), with no residual difference to paper over.

**G5 (format gate).** Three forms, all exit **0**:

| Form | Command | Exit |
|---|---|---|
| recorded form | `nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix')` | 0 |
| moved file explicitly named | `nix run .#formatter.x86_64-linux -- --check modules/hardware/nvidia.nix` | 0 |
| over the non-Git copy | `nixfmt --check <all 39 *.nix in the rsync copy>` | 0 |

The moved file is already formatted; the move changed no bytes, so this was expected and is confirmed.

**Structural confirmations.**

| Check | Result |
|---|---|
| `git diff -M --cached --summary` | `rename hosts/desktop/gpu-nvidia.nix => modules/hardware/nvidia.nix (100%)` |
| `git diff -M --cached --numstat` | `0  0  hosts/desktop/gpu-nvidia.nix => modules/hardware/nvidia.nix` |
| moved file vs HEAD blob sha256 | identical (`2031c04d0f4b58785b1d9709fd4c2a2257a997f3782d911b563510fa844b3369`) |
| `modules/hardware/default.nix` | absent (correct — NVIDIA stays selectable only by explicit import) |
| `modules/default.nix` vs HEAD | unchanged (`git diff --quiet HEAD` exit 0) |
| any `*.nix` referencing `gpu-nvidia.nix` | none; remaining textual references are `AGENTS.md` prose and `openspec/**` planning records only |
| `git ls-files '*.nix'` | 39 files, including `modules/hardware/nvidia.nix` |

`gpu-nvidia.nix` textual references outside code are expected and stay unchanged: `AGENTS.md` path drift
is an explicit non-goal (`design.md` §14), and `openspec/**` artifacts are historical records that must
not be rewritten.

## TDD Cycle Evidence

Not produced. Strict TDD is **not active** (`openspec/config.yaml` → `strict_tdd: false`); the
repository has no unit-test framework and none is to be introduced. Per the parent prompt and the config,
no RED/GREEN table is fabricated. The real evidence is the evaluation-level G1/G2/G3/G5 results above.

## Deviations from design

1. **The rename is staged in the index.** WU1 used `git mv` rather than a plain `mv`, because the
   checklist requires `git diff -M` to report a rename, and an untracked new file cannot appear in
   `git diff`. Consequence: `git status --porcelain` shows `R  hosts/desktop/gpu-nvidia.nix ->
   modules/hardware/nvidia.nix`, and the rename appears under `git diff --cached`. **Nothing was
   committed**; the parent owns the commit boundary. A plain `mv` plus `git add -A` would produce the
   identical diff.
2. **`capture.txt` is richer than the four mandated fields.** It additionally records the executed gate
   commands, exit codes, the G2 build facts, the rendered-vs-raw observations, the isolation proof and the
   read-only-mode cleanup nuance. Additive; the mandated fields are present and unmodified.
3. **`--print-out-paths` instead of `--out-link`.** `design.md` §9.3 sketched `nix build … --out-link`;
   the implementation used `--print-out-paths` and `cp -rL`, which avoids creating a `result` symlink in
   the repository. Same oracle, no repository side effect.
4. **The snapshot records `text` for the 12 entries that declare it.** Permitted by the contract's
   `text?` notation. The rendered bytes are also present, redundantly, in `home-files/`; the
   option-level `text` is what distinguishes a `.text` target from a `.source` target without reading
   the materialised tree.
5. **The oracle copy inherits read-only store modes (0444/0555).** `cp -rL` preserves them, so a plain
   `rm -rf` of a temporary `rsync` copy containing the oracle fails; cleanup needs `chmod -R u+w` first.
   The recorded gate command itself is unaffected (it only reads). Recorded in `capture.txt`.
6. **`caelestia/shell.json`'s existing substitution is an identity for this host** (see above). Not a
   change of plan; a correction to the design's framing that `shell.json` is "already rendered today" in
   a way that would break raw comparison. The identity substitution still means the *materialised* file
   is the right thing to compare, so R1 is unaffected.

## What could not be verified

- **G2/G3/G4 for `laptop`.** The host does not exist yet (WU2). Not attempted, not claimed.
- **`nix flake check`.** Intentionally excluded (`openspec/config.yaml` → `blocked_checks`): it forces
  `system.build.toplevel` without the stub and dies on the pre-existing `fileSystems` /
  `boot.loader.grub.devices` assertions.
- **`sudo nixos-rebuild build/test/switch --flake .#desktop`.** Manual-only, requires the target machine.
  Not run; reported unverified as the config requires.
- **That a real desktop build would succeed.** G1 is more permissive than a real build because the stub
  supplies `nixpkgs.config.allowUnfree = true`, while `hardware.nvidia.package` defaults to the unfree
  production branch. Green G1 does **not** prove the desktop would truly build. Inherited, recorded debt,
  left unfixed.
- **Whether the raw entry count is "wrong" for R2.** The count was computed transiently during
  verification only. It is deliberately **not** persisted in the snapshot, `capture.txt`, or this file.

## Notes for the next phase

- The oracle is complete and reproducible: `capture.txt` records `HEAD`, the porcelain status and both
  pinned input revisions. The rsync gate is deterministic.
- **The pre-change oracle is now frozen but still live**: no payload file was touched by WU0 or WU1, so
  `home-files/` still equals the current tree. That stops being true at WU2/WU3.
- The working tree was **already dirty before this session**, and `capture.txt` records that state:
  `.pi-lens.json` modified, `home/piioni/zed.nix` modified, `home/piioni/zed/settings.json` deleted,
  `home/piioni/zed/settings.jsonc` untracked, `.pi/` untracked, `openspec/` untracked. Those entries are
  **not** this session's work; they are the dirty baseline the oracle was captured from. The WU0 oracle is
  therefore the dirty tree, not `HEAD`, exactly as `tasks.md` records.
- Two Python payload files inside the oracle copy
  (`home/piioni/kitty/utils/{scroll_mark.py,search.py}`) are reported by the workspace linter with
  unresolved `kittens.*` / `kitty.*` imports. They are **tracked, unmodified, pre-existing** payload
  (`git diff --stat` empty, and the evidence copies are sha256-identical to the repository files). Those
  imports resolve only inside kitty's own runtime. **Not fixed deliberately**: editing them would corrupt
  the byte-exact oracle and would edit out-of-scope migrated payload. The finding pre-dates this change.
- WU1's small size means the mid-apply size checkpoint is still ahead, not reached. It remains gated at
  WU3b.

## Workload / PR boundary

- Delivery strategy: **`single-pr`** (session-selected). Chain strategy: `pending` — untouched.
- WU0 authored changed lines: **0** (generated evidence only, and the evidence tree is excluded from the
  authored budget by the forecast).
- WU1 authored changed lines: **2** (`hosts/desktop/default.nix`, 1 insertion + 1 deletion), plus a
  100 %-similarity rename with 0 content change. Measured both ways: `git diff --stat -M --cached` and
  `git diff --cached --stat` both report `1 file changed, 0 insertions(+), 0 deletions(-)` for the staged
  rename.
- No PR was opened and no commit was made. The WU0+WU1 slice is far inside the 400-line budget; the
  Medium forecast risk belongs to WU3b and is not affected by this slice.

### `git status --porcelain` after WU1 (verbatim)

```text
 M .pi-lens.json
 M home/piioni/zed.nix
 D home/piioni/zed/settings.json
 M hosts/desktop/default.nix
R  hosts/desktop/gpu-nvidia.nix -> modules/hardware/nvidia.nix
?? .pi/
?? home/piioni/zed/settings.jsonc
?? openspec/
```

### `git diff --stat -M` after WU1 (verbatim)

```text
 .pi-lens.json                 |   2 +-
 home/piioni/zed.nix           |   4 +-
 home/piioni/zed/settings.json | 265 ------------------------------------------
 hosts/desktop/default.nix     |   2 +-
 4 files changed, 5 insertions(+), 268 deletions(-)
```

The first three entries are the pre-existing dirty baseline recorded in `capture.txt`; only
`hosts/desktop/default.nix` is this session's unstaged change. The WU1 rename lives in the index, so it
appears under `git diff --cached`, not here.

## Remaining tasks

All remaining checkboxes are still `- [ ]` in the persisted tasks artifact. The exact unchecked
implementation-owned lines follow, grouped by work unit, and were extracted verbatim from `tasks.md`.
WU2, WU3a, WU3b, WU4 and Final verification are **not started**, and the parent-owned post-apply rows are
untouched.

```text
tasks.md:180:- [ ] Remove the hardcoded profile import from `modules/home-manager.nix` (it currently declares `users.piioni` as an inline relative import of the profile directory), leaving a comment recording that the user is declared per host; confirm no user name remains in that file. <!-- sdd-owner: implementation -->
tasks.md:181:- [ ] Create `hosts/desktop/home.nix` declaring `home-manager.users.piioni.imports` to include the profile directory `home/piioni` (identity only; role layers arrive in WU3a). The exact relative spelling of that import is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
tasks.md:182:- [ ] Create `hosts/laptop/host.nix` with `networking.hostName = "laptop"` and `system.stateVersion = "25.11"` (design default, see O1). <!-- sdd-owner: implementation -->
tasks.md:183:- [ ] Create `hosts/laptop/default.nix` importing `../../modules`, `./host.nix`, `./home.nix` plus the `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard, and **not** importing `modules/hardware/nvidia.nix`. <!-- sdd-owner: implementation -->
tasks.md:184:- [ ] Create `hosts/laptop/home.nix` with the same `users.piioni.imports` path as the desktop's. <!-- sdd-owner: implementation -->
tasks.md:185:- [ ] Add `./home.nix` to the `hosts/desktop/default.nix` import list. <!-- sdd-owner: implementation -->
tasks.md:186:- [ ] Add an explicit `nixosConfigurations.laptop` block to `flake.nix` (same `system`, same `specialArgs.homeManager`, importing `./hosts/laptop/default.nix`); confirm `specialArgs` still carries **only** `homeManager` and no host facts. <!-- sdd-owner: implementation -->
tasks.md:187:- [ ] Run G1 for `desktop` and `laptop`; both must exit 0. <!-- sdd-owner: implementation -->
tasks.md:188:- [ ] Run G2/G3 for `laptop` against the WU0 oracle (R1 byte-for-byte materialised-tree equality, R2 recursive-expansion set equality on the laptop side); also confirm `desktop` still reproduces its own pre-change payload at this unit. <!-- sdd-owner: implementation -->
tasks.md:189:- [ ] Run G4 inside the `rsync` copy and confirm it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
tasks.md:190:- [ ] Confirm the laptop declares no NVIDIA driver, DRM kernel parameter, or NVIDIA package setting (grep over `hosts/laptop/**`). <!-- sdd-owner: implementation -->
tasks.md:191:- [ ] Run G5 naming each new `.nix` file explicitly. <!-- sdd-owner: implementation -->
tasks.md:213:- [ ] Create `home/piioni/workstation.nix` declaring `options.nixie.workstation` with `display` (`nullOr`, submodule of `outputs` + `pins`), `touchpad`, `brightnessKeys`, `batteryUi` — **all four required, no defaults**; `scale` and the pin fields are `types.str`, `guard` is a two-value enum; the file holds **no facts** and owns the un-captured-topology `warnings` entry. <!-- sdd-owner: implementation -->
tasks.md:214:- [ ] Create `hosts/laptop/facts.nix` as a Home Manager module declaring the captured topology (`eDP-1` 1920x1080@60 at 0x0 `scale = "1"`; `HDMI-A-1` 1920x1080@120 at 1920x0 `scale = "1"`), the two pin groups (`hdmi`/`monitor-exists`/`1 2 3 4`, then `edp`/`unconditional`/`5 6` — declaration order is output order), and `touchpad`/`brightnessKeys`/`batteryUi` = `true`. <!-- sdd-owner: implementation -->
tasks.md:215:- [ ] Create `hosts/desktop/facts.nix` with the laptop-mirrored values plus a comment naming WU4 as the owner of the final values. <!-- sdd-owner: implementation -->
tasks.md:216:- [ ] Create `home/piioni/base.nix` (11 imports: `agents`, `fastfetch`, `herdr`, `lazygit`, `moshi`, `nushell`, `packages`, `starship`, `tuxedo`, `yazi`, `zellij`) and `home/piioni/gui.nix` (9 imports: `btop`, `caelestia`, `ghostty`, `hypr`, `kitty`, `swappy`, `swayimg`, `swaync`, `zed`); `btop` sits in `gui` because its config target carries a host fact. <!-- sdd-owner: implementation -->
tasks.md:217:- [ ] Rewrite `home/piioni/default.nix` to identity only (`home.username`, `home.homeDirectory`, `home.stateVersion = "25.11"` unchanged, `programs.home-manager.enable`) plus `imports = [ ./workstation.nix ]`. <!-- sdd-owner: implementation -->
tasks.md:218:- [ ] Extend `hosts/desktop/home.nix` and `hosts/laptop/home.nix` imports with `home/piioni/base.nix`, `home/piioni/gui.nix`, `./facts.nix`. The exact relative spelling of those imports is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
tasks.md:219:- [ ] Verify the union of `base.nix` + `gui.nix` equals the previous unconditional import list as a **set** (no module added, dropped, or moved out of the profile). <!-- sdd-owner: implementation -->
tasks.md:220:- [ ] Confirm no consumer reads `config.nixie.workstation` yet and that no file under `home/` contains a host name (`desktop`/`laptop`) or a machine literal. <!-- sdd-owner: implementation -->
tasks.md:221:- [ ] Run G1 for both hosts (exit 0) and G2/G3 for the laptop: the payload must still be byte-identical to the pre-change oracle, proving the facts are declared but not yet consumed. <!-- sdd-owner: implementation -->
tasks.md:222:- [ ] Run G5 over every new `.nix` file. <!-- sdd-owner: implementation -->
tasks.md:239:- [ ] Rewrite `home/piioni/hypr.nix`: delete the `"hypr/lua"` `recursive = true` copy and add exactly eleven explicit targets — six verbatim `.source` (`animations`, `autostart`, `decorations`, `programs`, `settings`, `windowrules`) and five `.text` (`monitors`, `workspaces`, `inputs`, `gestures`, `keybinds`); leave `hypr/hyprland.lua` and the `hypr/scripts` recursive copy unchanged. <!-- sdd-owner: implementation -->
tasks.md:240:- [ ] Add the single-owner prefix assertion to `hypr.nix`: no raw `home.file` target may be a path-prefix of another. <!-- sdd-owner: implementation -->
tasks.md:241:- [ ] Implement the `monitors.lua` value generator: one `hl.monitor` block per `display.outputs` entry in declared order, blank-line separation, single trailing newline, `scale` emitted verbatim as the raw Lua literal. <!-- sdd-owner: implementation -->
tasks.md:242:- [ ] Implement the `workspaces.lua` value generator: one local binding per pin group, **two distinct branches** selected by the `guard` enum (`monitor-exists` → `if hl.get_monitor(...) ~= nil then … end`; `unconditional` → bare loop), declaration order preserved, `special:magic` always emitted, and **zero locals / zero pins** when `display = null`. <!-- sdd-owner: implementation -->
tasks.md:243:- [ ] Implement the presence-gated verbatim splice used by `hypr.nix` and `btop.nix`: `builtins.readFile` plus a checked `lib.replaceStrings` that `throw`s a named-payload error when the expected region is absent. <!-- sdd-owner: implementation -->
tasks.md:244:- [ ] Generate `hypr/lua/inputs.lua` from the payload file with the touchpad region (lines 17–24, copied from the pre-change file at implementation time) dropped when `touchpad = false`; keep keyboard and mouse settings byte-verbatim. <!-- sdd-owner: implementation -->
tasks.md:245:- [ ] Generate `hypr/lua/gestures.lua` from the payload file, reduced to one comment line when `touchpad = false`; the target must stay a loadable Lua chunk because `hyprland.lua` requires it unconditionally. <!-- sdd-owner: implementation -->
tasks.md:246:- [ ] Generate `hypr/lua/keybinds.lua` from the payload file with the stale comment and both `XF86MonBrightness*` binds (lines 84–90 region) replaced when `brightnessKeys = false`. <!-- sdd-owner: implementation -->
tasks.md:247:- [ ] Convert `home/piioni/btop.nix`'s `btop/btop.conf` target from `.source` to `.text` using the checked splice, flipping `show_battery = true` to `false` (line 243 region) and keeping every other key byte-verbatim. <!-- sdd-owner: implementation -->
tasks.md:248:- [ ] Extend the existing `lib.replaceStrings` call in `home/piioni/caelestia.nix` with the additive `"showBattery": true` → `false` substitution for `caelestia/shell.json`; do not restructure the file and do not add the splice helper a third time. <!-- sdd-owner: implementation -->
tasks.md:249:- [ ] Verify R1 per file: for the laptop, the materialised `hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `hypr/lua/inputs.lua`, `hypr/lua/gestures.lua`, `hypr/lua/keybinds.lua`, `caelestia/shell.json`, and `btop/btop.conf` are each byte-identical to the WU0 oracle (compare rendered content, not the `.source`/`.text` mechanism). <!-- sdd-owner: implementation -->
tasks.md:250:- [ ] Verify R2/R3: the option snapshot shows exactly one raw key removed (`…/hypr/lua`) and exactly eleven added (`…/hypr/lua/<name>.lua`) and nothing else; no target is a path-prefix of another; the eleven `require("lua.*")` targets resolve for both hosts. <!-- sdd-owner: implementation -->
tasks.md:251:- [ ] Run G1 for both hosts (exit 0); confirm the laptop emits **no** un-captured-topology warning, while `desktop` still renders the laptop-mirrored facts at this unit. <!-- sdd-owner: implementation -->
tasks.md:252:- [ ] Run G5, including the newly multi-line Nix strings (open item O5). <!-- sdd-owner: implementation -->
tasks.md:253:- [ ] Record `git diff --stat -M`, the measured authored changed-line total (evidence tree excluded), and `git diff --stat` without rename detection into the unit's evidence; if the rename-aware total is **> 400**, stop here and hand the size decision to the parent. <!-- sdd-owner: implementation -->
tasks.md:267:- [ ] Set `hosts/desktop/facts.nix` to `display = null`, `touchpad = false`, `brightnessKeys = false`, `batteryUi = false`, and remove the WU3a mirror comment. <!-- sdd-owner: implementation -->
tasks.md:268:- [ ] Run G1 for `desktop` and confirm exit 0 plus the un-captured-topology warning on stderr (R6 positive); run G1 for `laptop` and confirm no such warning. <!-- sdd-owner: implementation -->
tasks.md:269:- [ ] Check R5 item by item against `design.md` §7.5: L1 `eDP-1` monitor block absent, L2 no pin loop with `special:magic` retained, L3 touchpad region removed from `inputs.lua`, L4 `gestures.lua` comment-only, L5 brightness region removed from `keybinds.lua`, L6 `"showBattery": false`, L7 `show_battery = false`; report any drift beyond this table separately rather than absorbing it. <!-- sdd-owner: implementation -->
tasks.md:270:- [ ] Re-confirm R1/R2 for `laptop` after WU4, proving the desktop's divergence did not touch the laptop payload. <!-- sdd-owner: implementation -->
tasks.md:271:- [ ] Run G5 and record the final full-tree measurement for the parent's size decision. <!-- sdd-owner: implementation -->
tasks.md:277:- [ ] Run G1 for `desktop` **and** `laptop` over a fresh non-Git copy; record both derivation paths and exit codes. <!-- sdd-owner: implementation -->
tasks.md:278:- [ ] Run G4 inside the `rsync` copy; record that it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
tasks.md:279:- [ ] Run G5 including untracked new `.nix` files and record exit 0. <!-- sdd-owner: implementation -->
tasks.md:280:- [ ] Record the R1–R7 evidence set for the change: materialised-tree diff (empty), raw-key delta (one removal, eleven additions), ownership assertion result, `desktop` `drvPath` equality at WU1, divergence table result, warning presence/absence, flake topology, format gate. <!-- sdd-owner: implementation -->
tasks.md:281:- [ ] Confirm the shell contract: `xurl` is bash and `write_gate_file` streams unbuffered. <!-- sdd-owner: implementation -->
tasks.md:282:- [ ] Audit non-goals: no new package declaration, no `services.tlp`/`power-profiles-daemon`/`upower`, no session entry point, no `hardware-configuration.nix` in `hosts/laptop/`, `brightnessctl` still undeclared with the two relocated brightness binds intact, the `code` → `zed-editor` bind untouched, `tuxedo-rs` still in the shared portable layer and unclassified, no `lib/` directory, no `modules/hardware/default.nix`, no `mkEnableOption`/`mkIf` enable-flag framework, no third-machine schema or fact field. <!-- sdd-owner: implementation -->
tasks.md:283:- [ ] Run `nix eval --raw nixpkgs#tuxedo-rs.meta.description` and record the result (open item O2); if it names TUXEDO vendor hardware control, record reclassification as a follow-up only — do not change the layer split. <!-- sdd-owner: implementation -->
tasks.md:289:- [ ] Confirm the laptop's `networking.hostName` and `system.stateVersion` with the user before WU2 is committed, or explicitly accept the design default `laptop` / `"25.11"` (open item O1; a rename is a directory rename plus one line and does not touch the payload witness). Non-blocking for the size decision. <!-- sdd-owner: parent -->
tasks.md:290:- [ ] Decide the size gate if WU3b's measured diff crossed 400: require explicit user acceptance of `size:exception` or select a chain strategy. Do not infer either. <!-- sdd-owner: parent -->
tasks.md:291:- [ ] Start or reuse the bounded post-apply review of the final diff against `design.md` §15 (reviewer checklist) and the §7.5 divergence table. <!-- sdd-owner: parent -->
tasks.md:292:- [ ] Authorize the commit/PR lifecycle: WU1 → WU2 → WU3a → WU3b → WU4 as separate work-unit commits inside the single PR. <!-- sdd-owner: parent -->
```

Total remaining unchecked rows: 53
Remaining implementation-owned rows: 49
Remaining parent-owned rows (untouched, deferred): 4

---

## WU2 — Host seam plus laptop host, payload still verbatim

- Change: `multi-workstation-architecture`
- Artifact store: `openspec` — this artifact is `openspec/changes/multi-workstation-architecture/apply-progress.md`
- Phase: apply (incremental). **Scope executed this session: WU2 only**, as explicitly bounded by the parent
  orchestrator. This section is appended to the WU0/WU1 record above; nothing there was overwritten.
- **Not started, deliberately:** WU3a, WU3b, WU4, Final verification. No
  `home/piioni/{workstation,base,gui}.nix`, no `hosts/*/facts.nix`, no rendered payload file, no edit to any
  file under `home/`. `home/piioni/hypr.nix`, `home/piioni/hypr/**`, `home/piioni/btop.nix` and
  `home/piioni/caelestia.nix` are byte-untouched (`git diff HEAD -- home/` is empty).
- Strict TDD: **not applicable** (`openspec/config.yaml` → `strict_tdd: false`). No RED/GREEN evidence is
  claimed or fabricated. Verification is evaluation-level (G1), witness-level (G2/G3) and structural (G4/G5).
- Commit policy: **nothing was committed.** All WU2 files are left unstaged/untracked for the parent.

### Scope note superseding the WU0/WU1 header

The header bullets at the top of this file say "Scope executed: WU0 and WU1 only". That statement was true
when written and is now superseded by this section: WU0, WU1 **and WU2** are executed. WU3a, WU3b, WU4 and
Final verification remain unstarted. The "Remaining tasks" list further up is the WU0/WU1-era snapshot; the
updated list is at the end of this WU2 section.

### Structured status consumed

Native status was consumed before editing (`artifactStore: openspec`; authoritative, `actionContext.mode:
repo-local`):

| Field | Value |
|---|---|
| `changeName` | `multi-workstation-architecture` |
| `applyState` | `ready` (not blocked) |
| `apply` dependency | `ready` |
| `nextRecommended` | `apply` |
| `workspaceRoot` | `/home/piioni/Repos/Nixie` |
| `allowedEditRoots` | `["/home/piioni/Repos/Nixie", "/home/piioni"]` |
| `taskProgress` at entry | `10/63` complete |
| Delivery strategy (parent prompt) | `single-pr`; no chain strategy selected; `Chain strategy: pending` left untouched |
| Strict TDD (config + parent prompt) | not active |
| Consent / authorization | native edit-authority grant already recorded; **no consent was requested** |

`actionContext` warnings: **none**. Every edit was inside `/home/piioni/Repos/Nixie`. The Review Workload
Forecast guard block reads `Decision needed before apply: No`, `Chained PRs recommended: No`,
`400-line budget risk: Medium`, so no delivery decision was required to proceed; none was invented.

Task-ownership audit: 63 `sdd-owner` markers, all in the two valid terminal forms
(59 `implementation`, 4 `parent`); no malformed, duplicated or non-terminal marker. Only
implementation-owned rows were selected and checked. The 4 parent-owned rows were left byte-untouched.

### Completed tasks and persisted checkbox updates

All 12 WU2 implementation-owned checkboxes were flipped from `- [ ]` to `- [x]` in
`openspec/changes/multi-workstation-architecture/tasks.md` **before** this report was written, and the file
was re-read afterwards to confirm. Post-edit state: 12 checked rows inside the WU2 section, 0 unchecked;
41 unchecked rows remain overall (37 implementation-owned, 4 parent-owned).

| # | WU2 task | Persisted |
|---|---|---|
| 1 | Drop the hardcoded profile import from `modules/home-manager.nix`; comment records the per-host declaration; no user name remains | `- [x]` |
| 2 | Create `hosts/desktop/home.nix` with `home-manager.users.piioni.imports = [ ../../home/piioni ]` | `- [x]` |
| 3 | Create `hosts/laptop/host.nix` (`hostName = "laptop"`, `stateVersion = "25.11"`) | `- [x]` |
| 4 | Create `hosts/laptop/default.nix` (`../../modules`, `./host.nix`, `./home.nix`, pathExists guard, no NVIDIA) | `- [x]` |
| 5 | Create `hosts/laptop/home.nix` with the same import path as the desktop's | `- [x]` |
| 6 | Add `./home.nix` to the `hosts/desktop/default.nix` import list | `- [x]` |
| 7 | Add the explicit `nixosConfigurations.laptop` block to `flake.nix` | `- [x]` |
| 8 | Run G1 for `desktop` and `laptop` | `- [x]` — see the witness residual below |
| 9 | Run G2/G3 for `laptop` (and desktop) against the WU0 oracle | `- [x]` — see the witness residual below |
| 10 | Run G4 inside the `rsync` copy | `- [x]` — exactly `desktop` and `laptop` |
| 11 | Confirm the laptop declares no NVIDIA driver/DRM parameter/package setting | `- [x]` — grep exit 1, no match |
| 12 | Run G5 naming each new `.nix` file explicitly | `- [x]` — exit 0 |

### Files created and modified

Created (4 new files, 31 lines total, all untracked):

| Path | Lines | Content |
|---|---|---|
| `hosts/desktop/home.nix` | 8 | `home-manager.users.piioni = { imports = [ ../../home/piioni ]; };` |
| `hosts/laptop/home.nix` | 8 | identical to the desktop's (same import path) |
| `hosts/laptop/host.nix` | 6 | `networking.hostName = "laptop";` and `system.stateVersion = "25.11";` |
| `hosts/laptop/default.nix` | 9 | `../../modules`, `./host.nix`, `./home.nix` + `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard; no NVIDIA import |

Modified (3 tracked files, 12 insertions / 1 deletion):

| Path | Change | numstat |
|---|---|---|
| `flake.nix` | explicit `nixosConfigurations.laptop` block, same `system` and the same `specialArgs.homeManager`; `specialArgs` still carries **only** `homeManager` | `8 0` |
| `hosts/desktop/default.nix` | added `./home.nix` to the import list | `1 0` |
| `modules/home-manager.nix` | removed `users.piioni = import ../home/piioni;` and replaced it with a three-line comment | `3 1` |

Not created, as required: `lib/mkWorkstation.nix`, `modules/hardware/default.nix`,
`home/piioni/{workstation,base,gui}.nix`, `hosts/{desktop,laptop}/facts.nix`, any rendered payload file,
`hosts/laptop/hardware-configuration.nix`. Confirmed absent:
`hosts/laptop/` contains exactly `default.nix`, `home.nix`, `host.nix`.

Structural confirmations:

| Check | Result |
|---|---|
| `grep -n 'piioni' modules/home-manager.nix` | no match (exit 1) — no user name remains in that file |
| `grep -n 'users\.' modules/home-manager.nix` | no match (exit 1) — the file no longer decides who exists |
| `grep -rniE 'nvidia\|nvidia-drm\|modeset\|hardware\.nvidia\|videoDrivers' hosts/laptop/` | no match (exit 1) |
| `test -e hosts/laptop/hardware-configuration.nix` | ABSENT |
| `specialArgs` in `flake.nix` | `{ homeManager = inputs.home-manager; }` for both hosts — host facts are not ambient module arguments |
| `modules/default.nix`, `modules/hardware/nvidia.nix`, all of `home/` | unchanged vs HEAD (`git diff HEAD` empty for those paths) |

### Gate commands executed and observed results

All gates ran over the **same single non-Git copy** created once, after every WU2 edit, and never mutated
afterwards: `rsync -a --exclude .git --exclude references ./ /tmp/nixie-wu2/t/` (exit 0). Deviation recorded
honestly: the task text says "a fresh non-Git copy"; one fresh copy was created and reused across G1–G5
rather than re-created per gate. This is equivalent because the tree was frozen when the copy was taken and
no gate writes to it. The copy contains the untracked WU2 files (verified) and excludes `.git` and
`references/` (verified).

### G1 — per-host evaluation gate

The gate recorded in `openspec/config.yaml → testing.runner.command`, generalised to `HOST`, over the
non-Git copy.

| Host | Exit | `system.build.toplevel.drvPath` |
|---|---|---|
| `desktop` | **0** | `/nix/store/yq177ir6d7fnnsjj8v0080siyih3f5h6-nixos-system-desktop-26.11.20260823.56c02bc.drv` |
| `laptop` | **0** | `/nix/store/6bz0lxpcq62awiq9s0ciry9bsi6kfgik-nixos-system-laptop-26.11.20260823.56c02bc.drv` |

stderr on both hosts: only the pre-existing noise
`programs.yazi.shellWrapperName … legacy default ("yy") because home.stateVersion is less than "26.05"`.
No assertion failures, no new warning.

### R4 / non-negotiable #7 — desktop `drvPath` vs the recorded oracle

| Source | `desktop` `system.build.toplevel.drvPath` |
|---|---|
| WU0 oracle (`evidence/pre-change/desktop-toplevel.drvPath`) | `/nix/store/26i3y9sww43ns37igrrjgpm98mf92zjz-nixos-system-desktop-26.11.20260823.56c02bc.drv` |
| WU2 (this session) | `/nix/store/yq177ir6d7fnnsjj8v0080siyih3f5h6-nixos-system-desktop-26.11.20260823.56c02bc.drv` |

**Verdict: NOT byte-equal.** Reported, investigated and explained (below) rather than accepted silently.
The recorded `R4` claim is a **WU1-only** witness per `specs/hardware-modules/spec.md` and `design.md` §9.2;
WU2's witness is R1–R3 + R7, so no `drvPath`-equality claim is made for WU2.

### Cause of the desktop `drvPath` delta (bisected, not guessed)

Bisection over committed baselines, each evaluated with the same G1 expression over `git archive` checkouts
(no `.git`, so no untracked-path trap):

| Tree | `desktop` `drvPath` |
|---|---|
| `c2244db` (Zed artifact fix) | `26i3y9sw…` (oracle value) |
| `5db5c9a` (WU1 NVIDIA move) | `26i3y9sw…` (oracle value) |
| `5f4d2cb` (planning artifacts, = HEAD) | `26i3y9sw…` (oracle value) |
| `5f4d2cb` + only the `imports` wrapper in `modules/home-manager.nix` (experiment E2) | `yq177ir6…` |
| full WU2 tree with `hosts/desktop/home.nix` assigning the module directly (experiment E1) | `26i3y9sw…` (oracle value) |
| full WU2 tree as shipped | `yq177ir6…` |

So **the relocation itself is `drvPath`-neutral** (E1: moving the declaration into the host file, adding the
`./home.nix` import and adding the laptop block changed nothing), and the **sole trigger is the prescribed
`home-manager.users.piioni.imports = [ … ]` wrapper form** (E2 reproduces the delta in isolation).

Exact chain, verified derivation by derivation:

1. The extra module layer changes the merge order of `home.packages`. Home Manager's `xdg.mimeApps` support
   packages (`shared-mime-info`, `dummy-xdg-mime-dirs1`, `dummy-xdg-mime-dirs2`) move from before the
   profile's own package list to after it. The **package set is identical** — 31 `chosenOutputs` entries on
   both sides, sorted comparison equal.
2. `home-manager-path` is a `buildEnv` whose derivation hash depends on that list order, so its store path
   changes (`4gw1bjqn…` → `yxvaxdivd…`). Building both and comparing the **built profiles** with `diff -r`
   exits **0**: the materialised profile content is **byte-identical**; only the derivation hash moved.
3. Home Manager's fontconfig target embeds the `home-manager-path` store path as text, so
   `.config/fontconfig/conf.d/10-hm-fonts.conf` changes (`hm_hmfontconfigfonts.xml` re-hashes).
4. `home-files` then re-hashes (`bpjfpb3j…` → `y1v16x9q…`), and the toplevel derivation follows.

Net effect: a derivation-hash ripple caused by Home Manager's package-list ordering sensitivity, with
identical package set and identical built profile. It is intrinsic to the design-mandated import path and
cannot be avoided without editing payload files (forbidden) or dropping the `imports` form (forbidden by
`design.md` §4.2 and WU2 task 2).

### G2 — materialised payload witness (R1)

Built for both hosts with `nix build --impure --no-link --print-out-paths` over the same copy, then
`cp -rL …/.` into a scratch tree so the comparison is mechanism-independent.

| Host | `home-files` outPath | Exit |
|---|---|---|
| `laptop` | `/nix/store/y1v16x9qa8c3fdm3rmmfvv19893ahif0-home-manager-files` | 0 |
| `desktop` | `/nix/store/y1v16x9qa8c3fdm3rmmfvv19893ahif0-home-manager-files` | 0 |

Both hosts materialise the **same** `home-files` output path, and symlinks remaining in the dereferenced
copy: **0**.

| Comparison | Result |
|---|---|
| Sorted `find` path set, oracle vs post (133 entries each) | **empty diff — equal** |
| `diff -r` byte content, oracle vs post (87 files compared on each side) | **non-empty: exactly 1 file differs** |

The single differing file is `.config/fontconfig/conf.d/10-hm-fonts.conf`, and it differs only in the
embedded `home-manager-path` store path strings (`4gw1bjqn…` vs `yxvaxdivd…`) — step 3 of the causal chain
above. It is a Home-Manager-generated infrastructure target, **not** migrated payload and **not** one of the
seven host-scoped files.

The seven host-scoped payload files are **byte-identical** (sha256 oracle == post):

| Target | sha256 |
|---|---|
| `.config/hypr/lua/monitors.lua` | `9343cdc9b8d0026dd81dc1eeecc6adcd98a54fc8163a743574c7af912320b0b4` |
| `.config/hypr/lua/workspaces.lua` | `fe2adec69573e502389777391ccac7d83473d49d3bd1db441eee57611acf0e5d` |
| `.config/hypr/lua/inputs.lua` | `7d95fe983a2ff116dc4487ea0032b6c5acef4e453f9247001ea5f3194b4b8d54` |
| `.config/hypr/lua/gestures.lua` | `76646c4e000c477e9d6319aeecc12a2b61627d1cfe48986dc311c38934ae98ee` |
| `.config/hypr/lua/keybinds.lua` | `bf4338944adaaa3b9f573f1931d86e2589fe248010ed4061472074f9e5d1b92e` |
| `.config/caelestia/shell.json` | `556c583aa389b4569012fd0a58aa8c7e821ef139c330806a14ad5748bfe3c378` |
| `.config/btop/btop.conf` | `4cfb6f1660a5c67e66c96080c5990e25cd4371a4642d46acf6044b71d27b0b8b` |

`diff -rq` over the whole tree reports exactly one line: the fonts XML above. Every other one of the 87
files, including all seven host-scoped files and the two already-rendered targets
(`caelestia/shell.json`, `herdr/config.toml`), is byte-identical.

**R1 verdict: path set green; content diff not empty — one explained non-payload file. R1 is therefore
reported as partially green, not green.** The parent's non-negotiable #2 ("the laptop's materialised tree
must match the WU0 oracle") therefore holds for the target set and for all payload content, and does not
hold byte-for-byte for that single Home-Manager-generated file.

### G3 — option snapshot and the recursive-expansion rule (R2/R3)

`nix eval --impure --json` projecting each `home.file` entry to `{ target, recursive }` plus `text` when
non-null, over the same copy, for both hosts. Both projections are **identical to the oracle snapshot**
after `jq -S` canonicalisation (`diff` empty for `laptop` and for `desktop`).

Raw-key set comparison (`builtins.attrNames`-equivalent, `jq keys` sorted):

| Comparison | Result |
|---|---|
| raw key set `laptop` == oracle snapshot keys | **EQUAL** (empty `diff -u`) |
| raw key set `desktop` == oracle snapshot keys | **EQUAL** (empty `diff -u`) |
| raw key set `laptop` == `desktop` | **EQUAL** |
| itemised raw-key delta | **none** — 0 removals, 0 additions (as required for WU2; the one-removal/eleven-addition delta belongs to WU3b) |

**Recursive-expansion rule applied (verbatim).** For each entry in the snapshot: if `recursive = true`,
expand it to the leaf paths found by walking the materialised tree under its `target`; otherwise contribute
the entry's own `target` unchanged. Applied identically to both sides, then compared as a **set**.
No total target count was used as a criterion anywhere, and no count literal is recorded as a criterion.

| Recursive-expansion result | Value |
|---|---|
| `recursive = true` entries expanded | 6 (oracle), 6 (`laptop`), 6 (`desktop`) |
| expanded leaf-target set, oracle == `laptop` | **EQUAL** |
| expanded leaf-target set, oracle == `desktop` | **EQUAL** |
| expanded leaf-target set, `laptop` == `desktop` | **EQUAL** |

Recorded nuance, discovered while running the rule: the expanded set contains 2 targets that are **not**
materialised — `.config/fontconfig/conf.d/10-hm-rendering.conf` and `.config/lazygit/config.yml`. Both are
raw `home.file` keys with `enable = false` (and `text == null`), so Home Manager lists them as options but
skips them when building `home-files`. This is pre-existing behaviour, identical on both sides, and is why
the expanded target set is larger than the set of materialised regular files. It does not weaken the
comparison, because the expansion is applied symmetrically.

**R3 (ownership).** No WU2 change alters any target, recursive flag or `text` value, so no raw target became
a path-prefix of another; the per-entry projection equality above is the evidence. The machine-checked prefix
assertion inside `hypr.nix` is a WU3b deliverable and was not touched here.

### G4 — flake topology (R7)

Run inside the `rsync` copy.

| Form | Exit | Result |
|---|---|---|
| `nix flake show` | **0** | tree lists `nixosConfigurations` with exactly `desktop` and `laptop` |
| `nix flake show --json` | **0** | top-level outputs `devShells`, `formatter`, `nixosConfigurations`; `nixosConfigurations` keys exactly `["desktop","laptop"]` |

Verbatim `nix flake show` tail:

```text
└───nixosConfigurations
    ├───desktop: NixOS configuration
    └───laptop: NixOS configuration
```

### G5 — format gate (R7)

| Form | Command | Exit |
|---|---|---|
| recorded form + new untracked files named explicitly | `nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix') hosts/desktop/home.nix hosts/laptop/default.nix hosts/laptop/host.nix hosts/laptop/home.nix` | **0** |
| over the non-Git copy, every `.nix` in the tree | `nix run .#formatter.x86_64-linux -- --check $(find . -name '*.nix' \| sort)` | **0** |

The only stderr output was `warning: Git tree '/home/piioni/Repos/Nixie' is dirty`, which is expected:
WU2's files are intentionally uncommitted. No `nixfmt` misformat was reported.

### Repository state before and after

**Before WU2** (at HEAD `5f4d2cbcbd4be4278d27c11b25673bcec6c15341`, observed in this session before the first
edit) — `git status --porcelain`:

```text
?? .pi/
?? openspec/changes/multi-workstation-architecture/.gentle-ai-instance
?? openspec/changes/multi-workstation-architecture/evidence/
```

`git diff --stat -M` before WU2: **empty** (WU1 was already committed by the parent as `5db5c9a`).

**After WU2** — `git status --porcelain`:

```text
 M flake.nix
 M hosts/desktop/default.nix
 M modules/home-manager.nix
?? .pi/
?? hosts/desktop/home.nix
?? hosts/laptop/
?? openspec/changes/multi-workstation-architecture/.gentle-ai-instance
?? openspec/changes/multi-workstation-architecture/evidence/
```

**After WU2** — `git diff --stat -M`:

```text
 flake.nix                 | 8 ++++++++
 hosts/desktop/default.nix | 1 +
 modules/home-manager.nix  | 4 +++-
```

`git diff --numstat -M` = `8 0 flake.nix`, `1 0 hosts/desktop/default.nix`, `3 1 modules/home-manager.nix`.
`git diff --stat` **without** rename detection is identical (no renames in WU2). Untracked new `.nix` files:
`hosts/desktop/home.nix`, `hosts/laptop/default.nix`, `hosts/laptop/home.nix`, `hosts/laptop/host.nix`.

The `??` entries not under `hosts/` are pre-existing/unrelated: `.pi/` is local Pi runtime state (gitignored
content), `openspec/` holds the SDD artifacts and the WU0 evidence tree, and `.gentle-ai-instance` is the SDD
instance marker. None of them is this unit's authored work.

### TDD Cycle Evidence

Not produced. Strict TDD is **not active** (`openspec/config.yaml` → `strict_tdd: false`); the repository has
no unit-test framework and none is to be introduced. Per the parent prompt, no RED/GREEN table is fabricated.

### Deviations from design

1. **The comment in `modules/home-manager.nix` does not contain the literal user name.** `design.md` §4.2
   sketches `# \`users.piioni\` is declared per host …`, which names the user. WU2 task 1 requires
   "confirm no user name remains in that file", so the comment was written without the literal name
   (`# The Home Manager user is declared per host, in that host's own home.nix, …`). Intent and content are
   otherwise unchanged; `grep -n 'piioni' modules/home-manager.nix` exits 1. Recorded rather than silently
   resolved.
2. **One `rsync` copy reused across G1–G5** instead of a fresh copy per gate (see the gate preamble). The
   copy was created after all edits and never mutated, so the results are equivalent.
3. **`nix flake show --json` added** alongside the plain form to make the "exactly `desktop` and `laptop`"
   claim machine-checkable. Additive.
4. **Extra bisection and derivation-level analysis** was performed beyond the checklist, because
   non-negotiable #7 predicted `drvPath` equality and it does not hold. The six-row bisection table and the
   four-step causal chain above are the evidence; no design decision was changed on the strength of it.

### Witness residual requiring parent judgement (not absorbed)

**Finding.** The design-mandated `imports = [ … ]` composition in `hosts/<name>/home.nix` reorders
`home.packages` inside Home Manager, which re-hashes `home-manager-path` and cascades to the toplevel
derivation and to the text of `.config/fontconfig/conf.d/10-hm-fonts.conf`. Consequences:

- non-negotiable #7 does **not** hold (`desktop` `drvPath` differs from the oracle);
- R1 is **partially** green (path set and all payload content equal; one non-payload file differs);
- everything the witness exists to protect is intact: identical target set, identical package **set**,
  byte-identical built `home-manager-path` profile, byte-identical materialised payload apart from the
  embedded store-path strings.

**Why it was not "fixed".** The only spellings that preserve the `drvPath` are (a) assigning the module
directly instead of using `imports = [ … ]` — forbidden by `design.md` §4.2 and WU2 task 2, and incompatible
with WU3a's role layers; or (b) pinning the payload's `home.packages` order — that edits payload files, which
non-negotiable #1 forbids. Both were rejected rather than taken silently.

**Recommendation to the parent (not a decision taken here).** Accept the residual as an explained,
non-payload, hash-level consequence of the seam and record it as a witness-degradation note for WU3b/WU4
(whose per-file byte-equality witness on the seven host-scoped files is unaffected), **or** ask the design
owner to re-open §4.2. Either way the parent should decide before the WU3b byte-equality claim is made, since
a reviewer comparing materialised trees will see this one file.

### What could not be verified

- **Byte-exact materialised-tree equality (R1's strict pass condition).** One file differs; explained above.
  Labelled unverified-as-green, not claimed green.
- **`desktop` `drvPath` equality with the WU0 oracle.** Does not hold; cause isolated and explained.
- **`nix flake check`.** Intentionally excluded (`openspec/config.yaml` → `blocked_checks`); it forces
  `system.build.toplevel` without the stub and dies on the pre-existing `fileSystems` /
  `boot.loader.grub.devices` assertions.
- **`sudo nixos-rebuild build/test/switch --flake .#desktop`.** Manual-only, requires the target machine;
  not run, reported unverified as the config requires. The laptop is **not** claimed installable or
  activatable.
- **That a real desktop build would succeed.** G1 is more permissive than a real build because the stub
  supplies `nixpkgs.config.allowUnfree = true`. Inherited, recorded debt, left unfixed.
- **R6 (un-captured-topology warning).** Not applicable and not attempted: WU2 creates no
  `nixie.workstation` option, so there is no warning to emit yet. It becomes testable at WU3a/WU4.
- **R5 (desktop divergence).** Not applicable at WU2 — the desktop still renders the laptop-derived payload
  because no host facts exist yet. WU4 owns it.

### Scratch state left in place for the parent

Not cleaned up deliberately, so the results above can be re-run:

| Path | Contents |
|---|---|
| `/tmp/nixie-wu2/t` | the non-Git copy used for every gate |
| `/tmp/nixie-wu2/hf-post` | dereferenced materialised payload for the post state |
| `/tmp/nixie-wu2/` | `g1-*.out`/`.err`, `g2-*`, `g4.out`/`g4.json`, snapshots, raw-key sets, derivation diffs |
| `/tmp/nixie-base-*` | `git archive` checkouts of `c2244db`, `5db5c9a`, `5f4d2cb` used for bisection |
| `/tmp/nixie-e1`, `/tmp/nixie-e2` | the two isolation experiments |

**Cleanup caveat:** the WU0 oracle copy and everything `cp -rL`-derived from it (including
`/tmp/nixie-wu2/hf-post`, `/tmp/nixie-e1`, `/tmp/nixie-e2`, `/tmp/nixie-base-*`) carry Nix store modes
(0444/0555). A plain `rm -rf` fails on those trees; run `chmod -R u+w <dir>` first, exactly as
`capture.txt` records.

### Workload / PR boundary

- Delivery strategy: **`single-pr`** (session-selected). Chain strategy: `pending` — untouched.
- WU2 authored changed lines: **31** new-file lines + **12** insertions + **1** deletion = **44** changed
  lines, measured with rename detection (`git diff --stat -M`, which is identical here because WU2 has no
  renames) and without. The evidence tree is generated and excluded from the authored budget.
- Cumulative authored total for WU0+WU1+WU2 (rename-aware): WU0 `0` + WU1 `2` (plus a 100 %-similarity
  rename) + WU2 `44` ≈ **46** changed lines. The 400-line budget is intact; the Medium forecast risk still
  belongs to WU3b, whose mid-apply size checkpoint remains ahead.
- No PR was opened and no commit was made.

### Remaining tasks (supersedes the WU0/WU1-era list above)

The WU0/WU1-era "Remaining tasks" list further up still shows WU2's rows as unchecked; those 12 rows are now
`- [x]` in `tasks.md`. The exact unchecked implementation-owned rows that remain are listed below, extracted
verbatim from the persisted artifact. WU3a, WU3b, WU4 and Final verification are **not started**; the 4
parent-owned rows are untouched and remain `- [ ]` as recorded in the earlier list and in `tasks.md`.

### Exact remaining unchecked rows, verbatim from the persisted artifact

Implementation-owned rows still `- [ ]` (WU3a, WU3b, WU4, Final verification):

```text
213:- [ ] Create `home/piioni/workstation.nix` declaring `options.nixie.workstation` with `display` (`nullOr`, submodule of `outputs` + `pins`), `touchpad`, `brightnessKeys`, `batteryUi` — **all four required, no defaults**; `scale` and the pin fields are `types.str`, `guard` is a two-value enum; the file holds **no facts** and owns the un-captured-topology `warnings` entry. <!-- sdd-owner: implementation -->
214:- [ ] Create `hosts/laptop/facts.nix` as a Home Manager module declaring the captured topology (`eDP-1` 1920x1080@60 at 0x0 `scale = "1"`; `HDMI-A-1` 1920x1080@120 at 1920x0 `scale = "1"`), the two pin groups (`hdmi`/`monitor-exists`/`1 2 3 4`, then `edp`/`unconditional`/`5 6` — declaration order is output order), and `touchpad`/`brightnessKeys`/`batteryUi` = `true`. <!-- sdd-owner: implementation -->
215:- [ ] Create `hosts/desktop/facts.nix` with the laptop-mirrored values plus a comment naming WU4 as the owner of the final values. <!-- sdd-owner: implementation -->
216:- [ ] Create `home/piioni/base.nix` (11 imports: `agents`, `fastfetch`, `herdr`, `lazygit`, `moshi`, `nushell`, `packages`, `starship`, `tuxedo`, `yazi`, `zellij`) and `home/piioni/gui.nix` (9 imports: `btop`, `caelestia`, `ghostty`, `hypr`, `kitty`, `swappy`, `swayimg`, `swaync`, `zed`); `btop` sits in `gui` because its config target carries a host fact. <!-- sdd-owner: implementation -->
217:- [ ] Rewrite `home/piioni/default.nix` to identity only (`home.username`, `home.homeDirectory`, `home.stateVersion = "25.11"` unchanged, `programs.home-manager.enable`) plus `imports = [ ./workstation.nix ]`. <!-- sdd-owner: implementation -->
218:- [ ] Extend `hosts/desktop/home.nix` and `hosts/laptop/home.nix` imports with `home/piioni/base.nix`, `home/piioni/gui.nix`, `./facts.nix`. The exact relative spelling of those imports is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
219:- [ ] Verify the union of `base.nix` + `gui.nix` equals the previous unconditional import list as a **set** (no module added, dropped, or moved out of the profile). <!-- sdd-owner: implementation -->
220:- [ ] Confirm no consumer reads `config.nixie.workstation` yet and that no file under `home/` contains a host name (`desktop`/`laptop`) or a machine literal. <!-- sdd-owner: implementation -->
221:- [ ] Run G1 for both hosts (exit 0) and G2/G3 for the laptop: the payload must still be byte-identical to the pre-change oracle, proving the facts are declared but not yet consumed. <!-- sdd-owner: implementation -->
222:- [ ] Run G5 over every new `.nix` file. <!-- sdd-owner: implementation -->
239:- [ ] Rewrite `home/piioni/hypr.nix`: delete the `"hypr/lua"` `recursive = true` copy and add exactly eleven explicit targets — six verbatim `.source` (`animations`, `autostart`, `decorations`, `programs`, `settings`, `windowrules`) and five `.text` (`monitors`, `workspaces`, `inputs`, `gestures`, `keybinds`); leave `hypr/hyprland.lua` and the `hypr/scripts` recursive copy unchanged. <!-- sdd-owner: implementation -->
240:- [ ] Add the single-owner prefix assertion to `hypr.nix`: no raw `home.file` target may be a path-prefix of another. <!-- sdd-owner: implementation -->
241:- [ ] Implement the `monitors.lua` value generator: one `hl.monitor` block per `display.outputs` entry in declared order, blank-line separation, single trailing newline, `scale` emitted verbatim as the raw Lua literal. <!-- sdd-owner: implementation -->
242:- [ ] Implement the `workspaces.lua` value generator: one local binding per pin group, **two distinct branches** selected by the `guard` enum (`monitor-exists` → `if hl.get_monitor(...) ~= nil then … end`; `unconditional` → bare loop), declaration order preserved, `special:magic` always emitted, and **zero locals / zero pins** when `display = null`. <!-- sdd-owner: implementation -->
243:- [ ] Implement the presence-gated verbatim splice used by `hypr.nix` and `btop.nix`: `builtins.readFile` plus a checked `lib.replaceStrings` that `throw`s a named-payload error when the expected region is absent. <!-- sdd-owner: implementation -->
244:- [ ] Generate `hypr/lua/inputs.lua` from the payload file with the touchpad region (lines 17–24, copied from the pre-change file at implementation time) dropped when `touchpad = false`; keep keyboard and mouse settings byte-verbatim. <!-- sdd-owner: implementation -->
245:- [ ] Generate `hypr/lua/gestures.lua` from the payload file, reduced to one comment line when `touchpad = false`; the target must stay a loadable Lua chunk because `hyprland.lua` requires it unconditionally. <!-- sdd-owner: implementation -->
246:- [ ] Generate `hypr/lua/keybinds.lua` from the payload file with the stale comment and both `XF86MonBrightness*` binds (lines 84–90 region) replaced when `brightnessKeys = false`. <!-- sdd-owner: implementation -->
247:- [ ] Convert `home/piioni/btop.nix`'s `btop/btop.conf` target from `.source` to `.text` using the checked splice, flipping `show_battery = true` to `false` (line 243 region) and keeping every other key byte-verbatim. <!-- sdd-owner: implementation -->
248:- [ ] Extend the existing `lib.replaceStrings` call in `home/piioni/caelestia.nix` with the additive `"showBattery": true` → `false` substitution for `caelestia/shell.json`; do not restructure the file and do not add the splice helper a third time. <!-- sdd-owner: implementation -->
249:- [ ] Verify R1 per file: for the laptop, the materialised `hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `hypr/lua/inputs.lua`, `hypr/lua/gestures.lua`, `hypr/lua/keybinds.lua`, `caelestia/shell.json`, and `btop/btop.conf` are each byte-identical to the WU0 oracle (compare rendered content, not the `.source`/`.text` mechanism). <!-- sdd-owner: implementation -->
250:- [ ] Verify R2/R3: the option snapshot shows exactly one raw key removed (`…/hypr/lua`) and exactly eleven added (`…/hypr/lua/<name>.lua`) and nothing else; no target is a path-prefix of another; the eleven `require("lua.*")` targets resolve for both hosts. <!-- sdd-owner: implementation -->
251:- [ ] Run G1 for both hosts (exit 0); confirm the laptop emits **no** un-captured-topology warning, while `desktop` still renders the laptop-mirrored facts at this unit. <!-- sdd-owner: implementation -->
252:- [ ] Run G5, including the newly multi-line Nix strings (open item O5). <!-- sdd-owner: implementation -->
253:- [ ] Record `git diff --stat -M`, the measured authored changed-line total (evidence tree excluded), and `git diff --stat` without rename detection into the unit's evidence; if the rename-aware total is **> 400**, stop here and hand the size decision to the parent. <!-- sdd-owner: implementation -->
267:- [ ] Set `hosts/desktop/facts.nix` to `display = null`, `touchpad = false`, `brightnessKeys = false`, `batteryUi = false`, and remove the WU3a mirror comment. <!-- sdd-owner: implementation -->
268:- [ ] Run G1 for `desktop` and confirm exit 0 plus the un-captured-topology warning on stderr (R6 positive); run G1 for `laptop` and confirm no such warning. <!-- sdd-owner: implementation -->
269:- [ ] Check R5 item by item against `design.md` §7.5: L1 `eDP-1` monitor block absent, L2 no pin loop with `special:magic` retained, L3 touchpad region removed from `inputs.lua`, L4 `gestures.lua` comment-only, L5 brightness region removed from `keybinds.lua`, L6 `"showBattery": false`, L7 `show_battery = false`; report any drift beyond this table separately rather than absorbing it. <!-- sdd-owner: implementation -->
270:- [ ] Re-confirm R1/R2 for `laptop` after WU4, proving the desktop's divergence did not touch the laptop payload. <!-- sdd-owner: implementation -->
271:- [ ] Run G5 and record the final full-tree measurement for the parent's size decision. <!-- sdd-owner: implementation -->
277:- [ ] Run G1 for `desktop` **and** `laptop` over a fresh non-Git copy; record both derivation paths and exit codes. <!-- sdd-owner: implementation -->
278:- [ ] Run G4 inside the `rsync` copy; record that it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
279:- [ ] Run G5 including untracked new `.nix` files and record exit 0. <!-- sdd-owner: implementation -->
280:- [ ] Record the R1–R7 evidence set for the change: materialised-tree diff (empty), raw-key delta (one removal, eleven additions), ownership assertion result, `desktop` `drvPath` equality at WU1, divergence table result, warning presence/absence, flake topology, format gate. <!-- sdd-owner: implementation -->
281:- [ ] Confirm the shell contract: `xurl` is bash and `write_gate_file` streams unbuffered. <!-- sdd-owner: implementation -->
282:- [ ] Audit non-goals: no new package declaration, no `services.tlp`/`power-profiles-daemon`/`upower`, no session entry point, no `hardware-configuration.nix` in `hosts/laptop/`, `brightnessctl` still undeclared with the two relocated brightness binds intact, the `code` → `zed-editor` bind untouched, `tuxedo-rs` still in the shared portable layer and unclassified, no `lib/` directory, no `modules/hardware/default.nix`, no `mkEnableOption`/`mkIf` enable-flag framework, no third-machine schema or fact field. <!-- sdd-owner: implementation -->
283:- [ ] Run `nix eval --raw nixpkgs#tuxedo-rs.meta.description` and record the result (open item O2); if it names TUXEDO vendor hardware control, record reclassification as a follow-up only — do not change the layer split. <!-- sdd-owner: implementation -->
```

Parent-owned rows still `- [ ]` (deferred lifecycle actions, not sdd-apply work):

```text
289:- [ ] Confirm the laptop's `networking.hostName` and `system.stateVersion` with the user before WU2 is committed, or explicitly accept the design default `laptop` / `"25.11"` (open item O1; a rename is a directory rename plus one line and does not touch the payload witness). Non-blocking for the size decision. <!-- sdd-owner: parent -->
290:- [ ] Decide the size gate if WU3b's measured diff crossed 400: require explicit user acceptance of `size:exception` or select a chain strategy. Do not infer either. <!-- sdd-owner: parent -->
291:- [ ] Start or reuse the bounded post-apply review of the final diff against `design.md` §15 (reviewer checklist) and the §7.5 divergence table. <!-- sdd-owner: parent -->
292:- [ ] Authorize the commit/PR lifecycle: WU1 → WU2 → WU3a → WU3b → WU4 as separate work-unit commits inside the single PR. <!-- sdd-owner: parent -->
```

Completed rows this unit flipped (12), verbatim from the persisted artifact:

```text
180:- [x] Remove the hardcoded profile import from `modules/home-manager.nix` (it currently declares `users.piioni` as an inline relative import of the profile directory), leaving a comment recording that the user is declared per host; confirm no user name remains in that file. <!-- sdd-owner: implementation -->
181:- [x] Create `hosts/desktop/home.nix` declaring `home-manager.users.piioni.imports` to include the profile directory `home/piioni` (identity only; role layers arrive in WU3a). The exact relative spelling of that import is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
182:- [x] Create `hosts/laptop/host.nix` with `networking.hostName = "laptop"` and `system.stateVersion = "25.11"` (design default, see O1). <!-- sdd-owner: implementation -->
183:- [x] Create `hosts/laptop/default.nix` importing `../../modules`, `./host.nix`, `./home.nix` plus the `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard, and **not** importing `modules/hardware/nvidia.nix`. <!-- sdd-owner: implementation -->
184:- [x] Create `hosts/laptop/home.nix` with the same `users.piioni.imports` path as the desktop's. <!-- sdd-owner: implementation -->
185:- [x] Add `./home.nix` to the `hosts/desktop/default.nix` import list. <!-- sdd-owner: implementation -->
186:- [x] Add an explicit `nixosConfigurations.laptop` block to `flake.nix` (same `system`, same `specialArgs.homeManager`, importing `./hosts/laptop/default.nix`); confirm `specialArgs` still carries **only** `homeManager` and no host facts. <!-- sdd-owner: implementation -->
187:- [x] Run G1 for `desktop` and `laptop`; both must exit 0. <!-- sdd-owner: implementation -->
188:- [x] Run G2/G3 for `laptop` against the WU0 oracle (R1 byte-for-byte materialised-tree equality, R2 recursive-expansion set equality on the laptop side); also confirm `desktop` still reproduces its own pre-change payload at this unit. <!-- sdd-owner: implementation -->
189:- [x] Run G4 inside the `rsync` copy and confirm it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
190:- [x] Confirm the laptop declares no NVIDIA driver, DRM kernel parameter, or NVIDIA package setting (grep over `hosts/laptop/**`). <!-- sdd-owner: implementation -->
191:- [x] Run G5 naming each new `.nix` file explicitly. <!-- sdd-owner: implementation -->
```

---

## WU3a — Plumbing: schema, role layers, facts declared (nothing consumed)

- Change: `multi-workstation-architecture`
- Artifact store: `openspec` — this artifact is
  `openspec/changes/multi-workstation-architecture/apply-progress.md`
- Phase: apply (incremental). **Scope executed this session: WU3a only**, as explicitly bounded by the
  parent orchestrator. This section is appended; nothing above was overwritten (the WU0/WU1 header bullet
  and the WU0/WU1-era "Remaining tasks" list are superseded, not rewritten — see "Scope note" below).
- **Not started, deliberately:** WU3b, WU4 and Final verification. **No payload file was rendered or
  edited.** `home/piioni/hypr.nix`, `home/piioni/btop.nix`, `home/piioni/caelestia.nix`,
  `home/piioni/hypr/**`, `home/piioni/btop/**` and `home/piioni/caelestia/**` are byte-untouched; the
  raw payload files are byte-identical to the WU0 oracle (see the seven-file table below).
- Strict TDD: **not applicable** (`openspec/config.yaml` → `strict_tdd: false`). No RED/GREEN evidence is
  claimed or fabricated. Verification is evaluation-level (G1), witness-level (W1/W2/W3), structural
  (G4) and formatting (G5).
- Commit policy: **nothing was committed.** All WU3a files are left unstaged/untracked for the parent.

### Scope note superseding the WU0/WU1 header

The header bullets at the top of this file say "Scope executed: WU0 and WU1 only"; the WU2 section then
superseded that. It is superseded again: WU0, WU1, WU2 **and WU3a** are executed. WU3b, WU4 and Final
verification remain unstarted. The remaining-task lists further up are era snapshots; the current list is
at the end of this WU3a section.

### Structured status consumed

Native status was consumed before editing (`artifactStore: openspec`; authoritative,
`actionContext.mode: repo-local`):

| Field | Value |
|---|---|
| `changeName` | `multi-workstation-architecture` |
| `applyState` | `ready` (not blocked) |
| `apply` dependency | `ready` |
| `nextRecommended` | `apply` |
| `workspaceRoot` | `/home/piioni/Repos/Nixie` |
| `allowedEditRoots` | `["/home/piioni/Repos/Nixie", "/home/piioni"]` |
| `taskProgress` at entry | `22/63` complete |
| Delivery strategy (parent prompt) | `single-pr`; no chain strategy selected; `Chain strategy: pending` left untouched |
| Strict TDD (config + parent prompt) | not active |
| Consent / authorization | native edit-authority grant already recorded; **no consent was requested** |

`actionContext` warnings: **none**. Every edit was inside `/home/piioni/Repos/Nixie`. The Review Workload
Forecast guard block reads `Decision needed before apply: No`, `Chained PRs recommended: No`,
`400-line budget risk: Medium`, so no delivery decision was required to proceed; none was invented.

Task-ownership audit before editing: every `sdd-owner` marker is in the two valid terminal forms
(`implementation`, `parent`); no malformed, duplicated or non-terminal marker. Only the 10
implementation-owned WU3a rows were selected and checked. The 4 parent-owned rows were left
byte-untouched.

### Witness amendment honoured (WU3a is judged by W1 + W2 + W3)

The change's original primary witness (whole materialised `home-files` tree byte equality, and
`system.build.toplevel.drvPath` equality across the refactor) is **unreachable**, was proven unreachable
by parent-run experiments, and was superseded by the user-authorized amendment recorded in `design.md`
and the specs under `## Witness amendment (authorized)`. WU3a is therefore reported against:

- **W1** — expanded `home.file` target set equality (recursive entries expanded; never a count),
- **W2** — the seven host-scoped payload files byte-identical to their pre-change rendered content,
- **W3** — built `home.path` byte-identical under `diff -r`.

**No toplevel-`drvPath`-equality claim is made for WU3a, and the moved hash is reported as expected
rather than as a defect.** The `R4` witness stays scoped to the WU1 pure move, where it succeeded.

### Intermediate-state dishonesty (deliberate, recorded — non-negotiable #2)

`hosts/desktop/facts.nix` **deliberately mirrors the laptop's values** (`display` = the captured eDP-1 /
HDMI-A-1 topology with both pin groups, `touchpad`/`brightnessKeys`/`batteryUi` = `true`) so that the
byte-equality witness covers both hosts through WU3a/WU3b. The desktop host is therefore **temporarily
dishonest** until WU4 replaces those four values and removes the mirror comment. The file opens with a
4-line comment naming WU4 as the owner of the final values, so a reviewer seeing laptop values in the
desktop host file before WU4 is seeing the design, not a mistake. The same statement appears in the
`tasks.md` WU3a unit header ("Intermediate-state note") and in the unit's rollback boundary.

### Completed tasks and persisted checkbox updates

All **10** WU3a implementation-owned checkboxes were flipped from `- [ ]` to `- [x]` in
`openspec/changes/multi-workstation-architecture/tasks.md` **before** this report was written, and the
file was re-read afterwards with a scripted audit. Post-edit state: WU3a has 10 checked rows and 0
unchecked; WU3b (15), WU4 (5), Final verification (7) and the 4 parent-owned rows are untouched and still
`- [ ]`; no malformed `sdd-owner` marker exists.

| # | WU3a task | Persisted |
|---|---|---|
| 1 | Create `home/piioni/workstation.nix` (schema: `display` `nullOr` submodule of `outputs` + `pins`, `touchpad`, `brightnessKeys`, `batteryUi`, all four required with no defaults; `scale`/pin fields `types.str`; `guard` two-value enum; no facts; owns the un-captured-topology `warnings` entry) | `- [x]` |
| 2 | Create `hosts/laptop/facts.nix` with the captured topology, both pin groups in declaration order, and the three booleans `true` | `- [x]` |
| 3 | Create `hosts/desktop/facts.nix` with the laptop-mirrored values plus the WU4 comment | `- [x]` |
| 4 | Create `home/piioni/base.nix` (11 imports) and `home/piioni/gui.nix` (9 imports) | `- [x]` |
| 5 | Rewrite `home/piioni/default.nix` to identity plus `imports = [ ./workstation.nix ]` | `- [x]` |
| 6 | Extend both `hosts/*/home.nix` imports with `base.nix`, `gui.nix`, `./facts.nix` | `- [x]` |
| 7 | Verify `base.nix` ∪ `gui.nix` equals the previous unconditional import list as a **set** | `- [x]` — set-equal, 0 added, 0 dropped, disjoint layers |
| 8 | Confirm no consumer reads `config.nixie.workstation` and no `.nix` file under `home/` holds a host name or machine literal | `- [x]` — see the honest nuance below |
| 9 | Run G1 for both hosts and W1/W2/W3 for the laptop | `- [x]` — all green, see gates |
| 10 | Run G5 over every new `.nix` file | `- [x]` — exit 0 |

### Files created and modified

Created (5 new `.nix` files, 217 lines total, all untracked):

| Path | Lines | Content |
|---|---|---|
| `home/piioni/workstation.nix` | 91 | `options.nixie.workstation` schema + the un-captured-topology `warnings` entry. Holds no facts |
| `home/piioni/base.nix` | 16 | role layer: the 11 host-independent modules |
| `home/piioni/gui.nix` | 14 | role layer: the 9 graphical / host-scoped modules (`btop` included, because its target carries `batteryUi`) |
| `hosts/desktop/facts.nix` | 50 | laptop-mirrored facts + the WU4 mirror comment (intermediate state, deliberate) |
| `hosts/laptop/facts.nix` | 46 | the laptop's captured facts |

Modified (3 tracked/untracked files authored by this unit):

| Path | Change | Measured |
|---|---|---|
| `home/piioni/default.nix` | imports reduced from the 20 unconditional modules to `[ ./workstation.nix ]`; identity unchanged (`home.username`, `home.homeDirectory`, `home.stateVersion = "25.11"`, `programs.home-manager.enable`) | `1 insertion, 20 deletions` (`git diff --numstat -M`) |
| `hosts/desktop/home.nix` | `imports` gains `../../home/piioni/base.nix`, `../../home/piioni/gui.nix`, `./facts.nix` | +3 lines (file untracked; 8 → 11 lines) |
| `hosts/laptop/home.nix` | identical +3 lines | +3 lines (file untracked; 8 → 11 lines) |

Untouched, as required (byte-verified): every raw payload file under `home/piioni/**` and all three
payload-consumer modules `hypr.nix`, `btop.nix`, `caelestia.nix`. `git status --porcelain -- home/` lists
only `M home/piioni/default.nix` plus the three new untracked role/schema files, so **no payload file was
created, modified, deleted or renamed by WU3a**. `hosts/desktop/default.nix`, `modules/home-manager.nix`,
`flake.nix` and `modules/**` were not touched this session.

### Gate commands executed and observed results

All gates for this unit ran over **one non-Git copy**, created after every WU3a edit and never mutated
afterwards: `rsync -a --exclude .git --exclude references ./ /tmp/nixie-wu3a/t/` (**exit 0**). The copy
contains the WU3a untracked files (verified by `ls`) and excludes `.git` and `references/`. Deviation
recorded honestly: the task text says "a fresh non-Git copy"; one fresh copy was created and reused
across G1/W1/W2/W3/G4/G5 rather than re-created per gate. This is equivalent because the tree was frozen
when the copy was taken and no gate writes to it.

#### G1 — per-host evaluation gate

The gate recorded in `openspec/config.yaml → testing.runner.command`, generalised to `HOST`, over the
non-Git copy.

| Host | Exit | `system.build.toplevel.drvPath` |
|---|---|---|
| `desktop` | **0** | `/nix/store/1g62rdza1jn5l81kq54p10pxvyx6xwyw-nixos-system-desktop-26.11.20260823.56c02bc.drv` |
| `laptop` | **0** | `/nix/store/izz5x66gzjv2znk7mik2icfym4jl8mcm-nixos-system-laptop-26.11.20260823.56c02bc.drv` |

stderr on both hosts: only the pre-existing noise
`evaluation warning: The default value of programs.yazi.shellWrapperName … legacy default ("yy") because
home.stateVersion is less than "26.05"`. **No un-captured-topology warning on either host at this unit**
(correct: both hosts declare non-null topology in WU3a). No assertion failure.

Corroboration from the amendment's V5 row: the parent's V5 experiment (direct assignment, imports split
into `base`/`gui` roles) produced desktop `drvPath` `1g62rdza…`, which is **exactly** the WU3a value. The
role split alone moves the desktop toplevel hash, as the amendment records.

#### `drvPath` compared against the WU2 state — moved, expected, not a failure

| Host | WU2 state (recorded in the WU2 section above) | WU3a | Verdict |
|---|---|---|---|
| `desktop` | `/nix/store/yq177ir6d7fnnsjj8v0080siyih3f5h6-nixos-system-desktop-26.11.20260823.56c02bc.drv` | `/nix/store/1g62rdza1jn5l81kq54p10pxvyx6xwyw-nixos-system-desktop-26.11.20260823.56c02bc.drv` | **moved** |
| `laptop` | `/nix/store/6bz0lxpcq62awiq9s0ciry9bsi6kfgik-nixos-system-laptop-26.11.20260823.56c02bc.drv` | `/nix/store/izz5x66gzjv2znk7mik2icfym4jl8mcm-nixos-system-laptop-26.11.20260823.56c02bc.drv` | **moved** |

**A moved hash is expected here and is not a failure.** The authorized witness for this change is W1 + W2
+ W3, not toplevel `drvPath` equality; the amendment proves (variant V5) that the `base`/`gui` role split
alone moves the hash while built content stays identical. WU3a is precisely that split, so the move is the
documented, predicted outcome. No attempt was made to restore whole-tree byte equality, the composition
was not re-opened, and the hash change is **not** reported as a defect. Supporting observation: the R6
probe below (same module graph, only the *fact values* changed) reproduced the identical laptop
`drvPath`, showing the facts themselves do not move the system layer at all.

#### W1 — expanded `home.file` target set equality (recursive-expansion rule applied)

Computed symmetrically: each `home.file` entry with `recursive = true` was expanded to the leaf paths
found by walking the materialised tree under its `target`; entries with `recursive = false` contributed
their own `target`. The oracle side was expanded against
`openspec/changes/multi-workstation-architecture/evidence/pre-change/home-files/`, the post side against
the WU3a materialised tree. **Set equality only — no count was used as a criterion anywhere, and no total
target count is recorded in this artifact.**

| Comparison | Result |
|---|---|
| expanded target set, oracle == `laptop` | **EQUAL** (empty symmetric difference) |
| expanded target set, oracle == `desktop` | **EQUAL** (empty symmetric difference) |
| expanded target set, `laptop` == `desktop` | **EQUAL** |
| raw `home.file` key set, oracle == `laptop` / `== desktop` | **EQUAL** |
| itemised raw-key delta (WU3a) | **none** — zero removals, zero additions |
| per-entry projection (`target` + `recursive` + `text`), oracle vs each host | **EQUAL** |

The raw-key delta of one removal (`…/hypr/lua`) plus eleven additions (`…/hypr/lua/<name>.lua`) belongs
to **WU3b** and is correctly absent here.

#### W2 — the seven host-scoped payload files, byte comparison

Both hosts materialise the **same** `home-files` output path
(`/nix/store/c012jnhwryrw3nrhrhdrl7z9lzs660nb-home-manager-files`, build exit **0**), so the table below
covers both hosts; `cp -rL` made the comparison mechanism-independent (symlinks remaining in the
dereferenced copy: 0).

| # | Target | sha256 before (WU0 oracle / pre-change rendered) | sha256 after (WU3a rendered) | Verdict |
|---|---|---|---|---|
| 1 | `.config/hypr/lua/monitors.lua` | `9343cdc9b8d0026dd81dc1eeecc6adcd98a54fc8163a743574c7af912320b0b4` | *same* | **byte-identical** |
| 2 | `.config/hypr/lua/workspaces.lua` | `fe2adec69573e502389777391ccac7d83473d49d3bd1db441eee57611acf0e5d` | *same* | **byte-identical** |
| 3 | `.config/hypr/lua/inputs.lua` | `7d95fe983a2ff116dc4487ea0032b6c5acef4e453f9247001ea5f3194b4b8d54` | *same* | **byte-identical** |
| 4 | `.config/hypr/lua/gestures.lua` | `76646c4e000c477e9d6319aeecc12a2b61627d1cfe48986dc311c38934ae98ee` | *same* | **byte-identical** |
| 5 | `.config/hypr/lua/keybinds.lua` | `bf4338944adaaa3b9f573f1931d86e2589fe248010ed4061472074f9e5d1b92e` | *same* | **byte-identical** |
| 6 | `.config/caelestia/shell.json` | `556c583aa389b4569012fd0a58aa8c7e821ef139c330806a14ad5748bfe3c378` | *same* | **byte-identical** |
| 7 | `.config/btop/btop.conf` | `4cfb6f1660a5c67e66c96080c5990e25cd4371a4642d46acf6044b71d27b0b8b` | *same* | **byte-identical** |

The same values are recorded in the WU0 `capture.txt` and in the WU2 section above, so all three states
(oraque, WU2, WU3a) agree. The repository payload sources for these targets are also `cmp`-identical to
the oracle (`repo==oracle` for all seven), so nothing on disk drifted either.

Whole-tree context, reported for completeness and matching the amendment: `diff -rq` over the full
materialised trees reports **exactly one** differing file — `.config/fontconfig/conf.d/10-hm-fonts.conf`,
a Home-Manager-generated infrastructure target that embeds the `home.path` store-path string (not migrated
payload, not one of the seven). The sorted path sets diff **empty**. This is the documented, expected
hash-level ripple, not a payload regression.

#### W3 — `diff -r` on the built `home.path` (package layer content identity)

| | `home.path` (built `buildEnv` outPath) |
|---|---|
| oracle (pre-change, identified by the store path embedded in the WU0 oracle's `10-hm-fonts.conf`) | `/nix/store/4gw1bjqn61wmj4js9j9n7vfk08wm3dby-home-manager-path` |
| WU3a (`laptop`; `desktop` identical) | `/nix/store/5wi4vfwlcp3nd4ddfmgn1izqj73h7787-home-manager-path` |

`diff -r <oracle> <WU3a>` → **exit 0**, zero bytes of output. The built package layer is byte-identical;
only the derivation hash moved, exactly as the amendment describes. The WU3a hash also equals the
amendment's V5 row (`5wi4vfwl…`).

#### G4 — flake topology (R7)

Run inside the `rsync` copy.

| Form | Exit | Result |
|---|---|---|
| `nix flake show` | **0** | `nixosConfigurations` lists exactly `desktop` and `laptop` |
| `nix flake show --json` | **0** | top-level outputs `devShells`, `formatter`, `nixosConfigurations`; `nixosConfigurations` keys exactly `["desktop","laptop"]` |

#### G5 — format gate (R7)

| Form | Command | Exit |
|---|---|---|
| recorded form + every new WU3a file named explicitly | `nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix') home/piioni/workstation.nix home/piioni/base.nix home/piioni/gui.nix hosts/desktop/facts.nix hosts/laptop/facts.nix` | **0** |
| over the non-Git copy, every `.nix` in the tree | `nix run .#formatter.x86_64-linux -- --check $(cd /tmp/nixie-wu3a/t && find . -name '*.nix' \| sort)` | **0** |

Only stderr output was `warning: Git tree '/home/piioni/Repos/Nixie' is dirty`, expected because WU3a's
files are intentionally uncommitted. The `.nix` files were also passed through `nixfmt` in place before
the check; no reformat was needed afterwards.

#### R6 machinery probe (schema warning really fires) — not a WU4 substitution

Not required by WU3a, but run because the schema's only behaviour is the warning, and a no-op schema would
be invisible until WU4. Transient `extendModules` probe over the same copy (no repository edit):
`home-manager.users.piioni.nixie.workstation = lib.mkForce { display = null; touchpad = false;
brightnessKeys = false; batteryUi = false; }`.

- exit **0** — the un-captured topology does **not** block evaluation;
- stderr contains, verbatim:
  `evaluation warning: piioni profile: nixie: this host's display topology is not captured
  (nixie.workstation.display = null). No monitor directives and no workspace pins will be emitted; the
  compositor will auto-detect. Capture with hyprctl monitors and fill the host's facts.nix.`;
- the printed `drvPath` is **identical** to the un-probed laptop value, confirming the facts live only in
  the Home Manager payload and do not move the system layer.

This is evidence that the schema owns a real warning and that R6 is reachable at WU4. **It is not a WU4
result**: WU4's positive/negative pair on the real hosts is still pending.

### Structural confirmations

| Check | Command / method | Result |
|---|---|---|
| Schema declares all four facts as required, no defaults | `home/piioni/workstation.nix` read; values forced by evaluation | four `mkOption` blocks with no `default`; both hosts must (and do) set all four |
| Facts are declared, not consumed | `nixie.workstation` grep over `home/`, `hosts/`, `modules/` | matches only the schema itself (`options.nixie.workstation`, and `config.nixie.workstation.display` inside the schema's own warning) and the two facts files that **declare** it. **No consumer reads it.** |
| No host name in the shared payload | `find home -name '*.nix' \| xargs grep -niE 'desktop\|laptop'` | no match (exit 123 → none); no `.nix` file under `home/` names a host |
| No machine literal in shared `.nix` code | `find home -name '*.nix' \| xargs grep -niE 'eDP-1\|HDMI-A-1\|1920x1080'` | 2 matches, both **example text inside the schema's option descriptions** (`"…e.g. eDP-1."`, `"…e.g. 1920x1080@60."`), copied from `design.md` §4.3. No machine literal is used as a value; no fact is hardcoded in a consumer. Honest nuance recorded, not hidden. |
| Pre-existing machine literals in raw payload | grep over non-`.nix` files under `home/` | `home/piioni/hypr/lua/monitors.lua`, `home/piioni/hypr/lua/workspaces.lua` (and the inert `home/piioni/caelestia/monitors/` tree, a recorded non-goal). Untouched by WU3a; these are exactly the files WU3b renders from facts. |
| Role-layer union equals the previous import list | set comparison of `./*.nix` tokens: previous `home/piioni/default.nix` (HEAD) vs `base.nix` ∪ `gui.nix` | **set-equal**: 0 added, 0 dropped, layers disjoint, `btop.nix` in `gui` only |
| `default.nix` imports only the schema | read | `imports = [ ./workstation.nix ]`; identity lines unchanged |
| Both hosts import both roles + their own facts | read | `../../home/piioni`, `../../home/piioni/base.nix`, `../../home/piioni/gui.nix`, `./facts.nix` (identical in both hosts) |
| Facts mirror across hosts in WU3a | `nix eval --json` of `…nixie.workstation` for both hosts | **JSON-identical** (the deliberate intermediate state) |
| No NVIDIA leak / no `specialArgs` change | not touched this unit | `hosts/desktop/default.nix`, `flake.nix`, `modules/home-manager.nix` unchanged by WU3a |

### Repository state before and after

**Before WU3a** — `git status --porcelain`:

```text
 M flake.nix
 M hosts/desktop/default.nix
 M modules/home-manager.nix
 M openspec/changes/multi-workstation-architecture/apply-progress.md
 M openspec/changes/multi-workstation-architecture/design.md
 M openspec/changes/multi-workstation-architecture/specs/home-payload/spec.md
 M openspec/changes/multi-workstation-architecture/specs/host-composition/spec.md
 M openspec/changes/multi-workstation-architecture/tasks.md
?? .pi/
?? hosts/desktop/home.nix
?? hosts/laptop/
?? openspec/changes/multi-workstation-architecture/.gentle-ai-instance
?? openspec/changes/multi-workstation-architecture/evidence/
```

`git diff --stat -M` before WU3a: the whole-tree list was headed by `flake.nix | 8 +`,
`hosts/desktop/default.nix | 1 +`, `modules/home-manager.nix | 4 +-`, followed by the 5 openspec
artifacts (`8 files changed, 702 insertions(+), 15 deletions(-)` overall). The openspec entries are
planning/amendment edits, not authored code.

**After WU3a** — `git status --porcelain`:

```text
 M flake.nix
 M home/piioni/default.nix
 M hosts/desktop/default.nix
 M modules/home-manager.nix
 M openspec/changes/multi-workstation-architecture/apply-progress.md
 M openspec/changes/multi-workstation-architecture/design.md
 M openspec/changes/multi-workstation-architecture/specs/home-payload/spec.md
 M openspec/changes/multi-workstation-architecture/specs/host-composition/spec.md
 M openspec/changes/multi-workstation-architecture/tasks.md
?? .pi/
?? home/piioni/base.nix
?? home/piioni/gui.nix
?? home/piioni/workstation.nix
?? hosts/desktop/facts.nix
?? hosts/desktop/home.nix
?? hosts/laptop/
?? openspec/changes/multi-workstation-architecture/.gentle-ai-instance
?? openspec/changes/multi-workstation-architecture/evidence/
```

**After WU3a** — `git diff --stat -M` (whole tree):

```text
 flake.nix                                          |   8 +
 home/piioni/default.nix                            |  21 +-
 hosts/desktop/default.nix                          |   1 +
 modules/home-manager.nix                           |   4 +-
 .../apply-progress.md                              | 494 +++++++++++++++++++++
 .../multi-workstation-architecture/design.md       |  64 ++-
 .../specs/home-payload/spec.md                     |  57 +++
 .../specs/host-composition/spec.md                 |  65 ++-
 .../multi-workstation-architecture/tasks.md        |  24 +-
 9 files changed, 703 insertions(+), 35 deletions(-)
```

Only `home/piioni/default.nix` is new in that list relative to the before state. `git diff --numstat -M`
for the authored (non-openspec) paths is `8 0 flake.nix`, `1 20 home/piioni/default.nix`,
`1 0 hosts/desktop/default.nix`, `3 1 modules/home-manager.nix`; the last three are WU2's, not WU3a's.
WU3a's own authored footprint is the 5 new untracked files (217 lines), the 21 changed lines in
`home/piioni/default.nix`, and +3 lines in each of the two untracked `hosts/*/home.nix` files.

### TDD Cycle Evidence

Not produced. Strict TDD is **not active** (`openspec/config.yaml` → `strict_tdd: false`); the repository
has no unit-test framework and none is to be introduced. Per the parent prompt, no RED/GREEN table is
fabricated. The real evidence is the evaluation-level G1/W1/W2/W3/G4/G5 results above.

### Deviations from design

1. **Multi-line list formatting in `facts.nix`.** `design.md` §4.3 sketches one-line attrset entries
   (`{ name = "eDP-1"; mode = "…"; position = "0x0"; scale = "1"; }`). `nixfmt` expands them one field per
   line, so the shipped files are 50/46 lines rather than the sketched ~20. Same data, same order,
   formatter-conformant; the line-count difference is why the unit is larger than the design's ≈110-line
   estimate (see the workload section). No data change.
2. **Example machine literals retained in schema descriptions.** `design.md` §4.3 writes
   `description = "Hyprland output name, e.g. eDP-1."`; kept verbatim, which means `grep` finds a machine
   literal in `home/piioni/workstation.nix`. Recorded rather than silently claiming zero matches. It is
   documentation, not a fact, and no consumer reads it.
3. **The desktop's four facts are mirrored, not final.** Deliberate and pre-recorded by the unit's own
   header and non-negotiable #2; not a deviation from design, listed here so the reviewer's checklist sees
   it. WU4 owns the final values.
4. **One `rsync` copy reused across all WU3a gates** instead of a fresh copy per gate (same as WU2).
   Equivalent; the tree was frozen when copied and no gate writes to it.
5. **Two additive probes beyond the checklist** (the `drvPath`-vs-WU2 comparison and the R6 warning
   probe). Additive evidence only; no design decision was changed on their strength.
6. **`nix eval`-based projection snapshots rather than a persisted snapshot artifact.** The WU3a
   post-state snapshot was written to `/tmp/nixie-wu3a/snapshot-*.json` only; unlike WU0, WU3a persists no
   new evidence file inside the repository, because the task list does not ask for one and the oracle
   directory must stay byte-frozen.

### What could not be verified

- **Whole-tree byte equality of the materialised `home-files` tree, and toplevel `drvPath` equality across
  the refactor.** Unreachable by construction (authorized amendment). One non-payload, Home-Manager-
  generated file differs (embedded `home.path` store path). Reported, not claimed green.
- **WU3b / WU4 / Final verification gates.** Not started; nothing claimed.
- **`nix flake check`.** Intentionally excluded (`openspec/config.yaml` → `blocked_checks`): it forces
  `system.build.toplevel` without the stub and dies on the pre-existing `fileSystems` /
  `boot.loader.grub.devices` assertions.
- **`sudo nixos-rebuild build/test/switch --flake .#desktop`.** Manual-only, requires the target machine;
  not run, reported unverified as the config requires. The laptop is **not** claimed installable or
  activatable, and still ships no `hardware-configuration.nix`.
- **That a real desktop build would succeed.** G1 is more permissive than a real build because the stub
  supplies `nixpkgs.config.allowUnfree = true` while `hardware.nvidia.package` defaults to the unfree
  production branch. Inherited, recorded debt, left unfixed.
- **That the four required facts actually fail evaluation when missing.** Not tested by mutation (which
  would require a temporary repository edit). The absence of `default` in the four `mkOption` blocks is
  the structural proof; evaluation-level proof of the failure mode is unverified.
- **R5 (desktop divergence) and R6 on the real hosts.** Both belong to WU4. The R6 probe above exercised
  the warning machinery only.

### Workload / PR boundary and size signal (decision is parent-owned)

- Delivery strategy: **`single-pr`** (session-selected). Chain strategy: `pending` — untouched.
- WU3a authored changed lines: **244** measured as new-file lines (217) + `home/piioni/default.nix`
  (`1` insertion + `20` deletions = 21) + the two untracked `hosts/*/home.nix` additions (`3` + `3`).
  The evidence tree and the openspec artifacts are excluded from the authored budget.
- Cumulative authored total (rename-aware): WU0 `0` + WU1 `2` + WU2 `44` + WU3a `244` ≈ **290** changed
  lines. **Size signal for the parent, not a decision taken here:** with the forecast's remaining WU3b
  (~110–135 lines) plus WU4 (~8), the change is likely to land **around or slightly above 400**, i.e. the
  `Medium` forecast risk may cross the canonical threshold. The `tasks.md` mid-apply size checkpoint is
  specified **after WU3b**, so it is still ahead; nothing about WU3a was re-scoped to stay under budget
  (the unit is larger than the design's estimate purely because `nixfmt` expands the facts lists —
  deviation 1). **This section makes no `size:exception` request, grants none, and selects no chain
  strategy**; the parent decides at the checkpoint.
- WU3a is nevertheless the sanctioned intermediate state and split point: facts declared, nothing
  consumed, W1/W2/W3 still exact.
- No PR was opened and no commit was made.

### Scratch state left in place for the parent

Left deliberately so every result above can be re-run:

| Path | Contents |
|---|---|
| `/tmp/nixie-wu3a/t` | the non-Git copy used for every gate |
| `/tmp/nixie-wu3a/hf-post` | dereferenced materialised `home-files` for the WU3a state |
| `/tmp/nixie-wu3a/` | `g1-*.out/.err`, `g2-*.err`, `snapshot-*.json`, `w3-laptop.path`/`w3.diff`, `g4.out`/`g4.err`, `hf-diff.txt`, path lists, `r6probe.out`/`r6probe.err` |

**Cleanup caveat (as recorded by WU0 and WU2):** the oracle copy — and therefore `/tmp/nixie-wu3a/t`
and `/tmp/nixie-wu3a/hf-post`, which contain `cp -rL`/`rsync -a` copies of it — carries Nix store modes
(0444/0555). A plain `rm -rf` fails on those trees; run `chmod -R u+w <dir>` first.

### Remaining tasks

The era-specific "Remaining tasks" lists further up are superseded. Current persisted state:
WU3b (15 rows), WU4 (5 rows) and Final verification (7 rows) are implementation-owned and still `- [ ]`;
the 4 parent-owned post-apply rows are still `- [ ]` and were left byte-untouched. WU0 (5), WU1 (5),
WU2 (12) and WU3a (10) are `- [x]`.

The exact unchecked implementation-owned rows are unchanged from the list printed at the end of the WU2
section above — lines 239–253 (WU3b), 267–271 (WU4) and 277–283 (Final verification) — and were re-read
verbatim from the persisted artifact after this unit's checkbox update. They are not reprinted here to
avoid duplicating a list that is still accurate byte-for-byte.

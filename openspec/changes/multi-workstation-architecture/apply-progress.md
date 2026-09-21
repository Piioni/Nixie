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

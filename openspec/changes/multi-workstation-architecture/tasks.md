# Tasks — multi-workstation-architecture

Host seam, per-host Home Manager payload facts, reusable NVIDIA module, `base` + `gui` role split.
Refactor only: the laptop is **not** made installable by this change.

- Change: `multi-workstation-architecture`
- Store: `openspec` — this artifact is `openspec/changes/multi-workstation-architecture/tasks.md`
- Phase: tasks (no implementation performed here)
- Inputs read: `proposal.md`, `exploration.md`, `design.md`,
  `specs/{host-composition,home-payload,hardware-modules}/spec.md`, `openspec/config.yaml`,
  `flake.nix`, `hosts/desktop/{default,host,gpu-nvidia}.nix`, `modules/home-manager.nix`,
  `home/piioni/default.nix`, `home/piioni/{hypr,btop,caelestia}.nix`
- **Nothing here was executed.** No shell tool exists in this phase. Every gate below is labelled
  unverified and is derived from the recorded gate in `openspec/config.yaml`.
- Strict TDD is **not applicable** (`strict_tdd: false`): NixOS/Home Manager module evaluation has no
  RED/GREEN cycle. **No RED/GREEN evidence exists or is claimed.**

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ≈300–330 authored with rename detection (`git diff --stat -M`); ≈375 raw if the NVIDIA move is counted as delete+add; plus the untracked WU0 evidence tree (generated, excluded from the authored budget) |
| 400-line budget risk | Medium |
| Chained PRs recommended | No |
| Suggested split | Single PR; WU1 → WU2 → WU3a → WU3b → WU4 as internal work-unit commits, with WU3a/WU3b as the pre-sanctioned fallback split point |
| Delivery strategy | single-pr |
| Chain strategy | pending |

```text
Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Medium
```

**Why `No` and not `Yes`.** The honest estimate stays inside the 400-line budget under both
measurements, and the session-selected `single-pr` strategy holds, so no `size:exception` is requested
and none is self-granted. The risk is `Medium`, not `Low`, because the headroom is thin (~25–100 lines
depending on rename detection) and WU3b is the swing factor.

**Mid-apply size checkpoint (mandatory, not optional).** After WU3b, the implementer records
`git diff --stat -M` against the pre-change commit. If that measurement is **> 400**, work stops
before WU4 and the parent must obtain either an explicit `size:exception` acceptance from the user or a
chain decision. Nothing about WU3a/WU3b may be re-scoped silently to stay under budget.

**`Chain strategy: pending` is deliberate.** No chain is selected; the guard value stays `pending`
rather than inventing `stacked-to-main` or `feature-branch-chain`.

## Gate definitions

Every gate runs over a **non-Git copy** of the working tree, because new untracked files are invisible
to Nix (`error: Path '…' in the repository is not tracked by Git`).

**G1 — per-host evaluation gate** (`HOST` = `desktop`, then `laptop`). Full text in
`openspec/config.yaml → testing.runner.command`, generalized to `HOST`:

```bash
set -e
HOST=desktop                                  # then HOST=laptop
D="$(mktemp -d)"; trap 'rm -rf "$D"' EXIT
rsync -a --exclude .git --exclude references ./ "$D/t/"
nix eval --raw --impure --expr "
let
  f = builtins.getFlake \"$D/t\";
  stub = {
    fileSystems.\"/\".device = \"/dev/null\";
    fileSystems.\"/\".fsType = \"ext4\";
    boot.loader.grub.enable = true;
    boot.loader.grub.devices = [ \"/dev/null\" ];
    nixpkgs.config.allowUnfree = true;
  };
in
(f.nixosConfigurations.${HOST}.extendModules { modules = [ stub ]; })
  .config.system.build.toplevel.drvPath"
```

**G2 — payload witness R1/R5.** Same expression, targeting
`.config.home-manager.users.piioni.home-files`, built with `nix build --impure --expr … --out-link`,
then `diff -r "$OUT" openspec/changes/multi-workstation-architecture/evidence/pre-change/home-files`
(symlinks dereferenced). Also compare a sorted `find | sort` path listing.

**G3 — option snapshot R2/R3.** Sorted `builtins.attrNames nixosConfigurations.<host>.config.home-manager.users.piioni.home.file`
via `nix eval --impure --json`, compared against
`evidence/pre-change/home-file-snapshot.json` using the **recursive-expansion rule** (a `recursive = true`
entry expands to the leaf paths under its `source`). Set equality only — **no hardcoded target count**.

**G4 — flake topology R7.** `(cd "$D/t" && nix flake show)` must exit 0 and list exactly
`nixosConfigurations.desktop` and `nixosConfigurations.laptop`.

**G5 — format gate R7.** `nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix')`, plus
any new `.nix` file explicitly named (untracked files are invisible to `nix flake`/`git ls-files`).

## Inherently unverifiable in this environment

Recorded here so no later phase over-claims:

1. **No host is buildable.** `hosts/desktop/hardware-configuration.nix` is intentionally absent and
   `hosts/laptop/` must not ship one, so only **evaluation-level** gates exist.
   `sudo nixos-rebuild build/test/switch --flake .#desktop` is manual-only and must be reported
   unverified. The laptop is **not** claimed installable or activatable.
2. **`nix flake check` is excluded.** It forces `system.build.toplevel` without the stub and dies on the
   pre-existing `fileSystems` / `boot.loader.grub.devices` assertions.
3. **G1 is more permissive than a real build.** The stub supplies `nixpkgs.config.allowUnfree = true`,
   which the tracked tree does not; `hardware.nvidia.package` defaults to the unfree production branch.
   A green G1 therefore does **not** prove the desktop would really build. Left unfixed (recorded debt).
4. **G4 and G5 only see tracked files.** Both must run inside the `rsync` copy or after a unit-sized
   commit; `nixd`/IDE resolution will show new files as missing until they are committed.
5. **WU0 captures the working tree as it is.** If the tree is dirty in a way that affects evaluation,
   the oracle is the dirty tree, not `HEAD`. `capture.txt` must record `git status --porcelain`.
6. **O4 is inherited.** Whether G1 is currently green is inherited from `openspec/config.yaml` and was
   not reproduced in this phase.
7. **No RED/GREEN evidence** (`strict_tdd: false`).

## Ordering constraints (load-bearing)

- **WU0 before WU1.** The pre-change materialised payload and the pre-change `drvPath` exist only until
  the first payload edit; the oracle is unrecoverable afterwards except via git history.
- **WU1 must be independently witnessable** by identical `system.build.toplevel.drvPath`.
- **WU2 must land with the payload still verbatim.** The seam and the payload rendering are separate
  concerns and must not share a unit.
- **WU3a and WU3b are separate work units and separate commits**: plumbing first (schema, roles, direct
  host assignments declared but consumed by nothing), then the seven rendered files.
- **WU4 last**, because it is the only unit that intentionally perturbs the payload content.

---

## WU0 — Pre-change witness capture (hard prerequisite, no repository change)

**Files:** writes only `openspec/changes/multi-workstation-architecture/evidence/pre-change/**`
(`home-files/`, `home-file-snapshot.json`, `desktop-toplevel.drvPath`, `capture.txt`).
**Depends on:** nothing. **Gate:** none required; the deliverable *is* the oracle.
**Rollback boundary:** delete `evidence/pre-change/`; nothing else is affected and no Nix expression
may reference it.
**Commit boundary:** none mandated — the evidence directory is deliberately kept out of Nix's reach and
may stay untracked through apply.

- [x] Record `git rev-parse HEAD`, `git status --porcelain`, and the pinned `flake.lock` input revisions into `openspec/changes/multi-workstation-architecture/evidence/pre-change/capture.txt`, so the oracle is reproducible. <!-- sdd-owner: implementation -->
- [x] Build and copy the pre-change **materialised** payload for `nixosConfigurations.desktop` via `.config.home-manager.users.piioni.home-files` and `cp -rL` it into `evidence/pre-change/home-files/`; verify the copied tree contains the dereferenced rendered bytes for `hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `caelestia/shell.json`, and `btop/btop.conf`. <!-- sdd-owner: implementation -->
- [x] Record the pre-change option snapshot (sorted `attrNames home.file` with `{ target, recursive, text? }` per entry) into `evidence/pre-change/home-file-snapshot.json`; the file must contain **no total target count**. <!-- sdd-owner: implementation -->
- [x] Record the pre-move `system.build.toplevel.drvPath` for `desktop` from G1 into `evidence/pre-change/desktop-toplevel.drvPath`. <!-- sdd-owner: implementation -->
- [x] Confirm no `*.nix` file under the repository references `evidence/` (grep), so the oracle cannot break evaluation and may stay untracked. <!-- sdd-owner: implementation -->

---

## WU1 — NVIDIA pure move

**Files:** `modules/hardware/nvidia.nix` (new, moved verbatim) ← `hosts/desktop/gpu-nvidia.nix`
(deleted); `hosts/desktop/default.nix` (one import line).
**Depends on:** WU0 (the `drvPath` value must exist before the move).
**Gate:** G1 for `desktop`, exit 0, **and** the printed `drvPath` byte-equal to
`evidence/pre-change/desktop-toplevel.drvPath` (R4), plus G5 over the moved file.
**Rollback boundary:** move `modules/hardware/nvidia.nix` back to `hosts/desktop/gpu-nvidia.nix`,
restore the `./gpu-nvidia.nix` import, delete the now-empty `modules/hardware/`; no other unit depends
on it. The revert is checkable via G1 `drvPath` equality against WU0.
**Commit boundary:** one rename-only commit; keep it separate even though it is small, because it is the
only unit whose system-layer witness is exact.

- [x] Move `hosts/desktop/gpu-nvidia.nix` to `modules/hardware/nvidia.nix` byte-identically (no content edits, header `{ config, lib, ... }:` unchanged) and confirm `git diff -M` reports a rename with no content change. <!-- sdd-owner: implementation -->
- [x] Change the import in `hosts/desktop/default.nix` from `./gpu-nvidia.nix` to `../../modules/hardware/nvidia.nix`. <!-- sdd-owner: implementation -->
- [x] Confirm no other file references `gpu-nvidia.nix`, that `modules/hardware/default.nix` was **not** created, and that `modules/default.nix` is unchanged (NVIDIA must stay selectable only by explicit import). <!-- sdd-owner: implementation -->
- [x] Run G1 for `desktop`; record exit code and assert equality with `evidence/pre-change/desktop-toplevel.drvPath` (R4). A difference is a behaviour change to investigate, never to accept. <!-- sdd-owner: implementation -->
- [x] Run G5 over the moved file and confirm it is already formatted. <!-- sdd-owner: implementation -->

---

## WU2 — Host seam plus laptop host, payload still verbatim

**Files:** new `hosts/laptop/default.nix`, `hosts/laptop/host.nix`, `hosts/laptop/home.nix`, new
`hosts/desktop/home.nix`; `hosts/desktop/default.nix` (+1 import); `flake.nix` (second explicit
`nixosSystem` block); `modules/home-manager.nix` (drops the hardcoded user).
**Depends on:** WU1 (desktop's system layer must already be stable/`drvPath`-pinned).
**Gate:** G1 for **both** hosts exit 0; G2/G3 R1–R3 for the laptop against the WU0 oracle; G4 lists
exactly `desktop` and `laptop`; G5 over the new files.
**Rollback boundary:** delete `hosts/laptop/` and `hosts/desktop/home.nix`, restore the hardcoded
profile import in `modules/home-manager.nix`, remove the laptop block from
`flake.nix`, drop the `./home.nix` import. No payload file is touched, so the payload oracle is
unaffected.
**Commit boundary:** one commit — a seam without a second host is not reviewable as behaviour.

- [x] Remove the hardcoded profile import from `modules/home-manager.nix` (it currently declares `users.piioni` as an inline relative import of the profile directory), leaving a comment recording that the user is declared per host; confirm no user name remains in that file. <!-- sdd-owner: implementation -->
- [x] Create `hosts/desktop/home.nix` declaring `home-manager.users.piioni.imports` to include the profile directory `home/piioni` (identity only; role layers arrive in WU3a). The exact relative spelling of that import is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
- [x] Create `hosts/laptop/host.nix` with `networking.hostName = "laptop"` and `system.stateVersion = "25.11"` (design default, see O1). <!-- sdd-owner: implementation -->
- [x] Create `hosts/laptop/default.nix` importing `../../modules`, `./host.nix`, `./home.nix` plus the `lib.optional (builtins.pathExists ./hardware-configuration.nix)` guard, and **not** importing `modules/hardware/nvidia.nix`. <!-- sdd-owner: implementation -->
- [x] Create `hosts/laptop/home.nix` with the same `users.piioni.imports` path as the desktop's. <!-- sdd-owner: implementation -->
- [x] Add `./home.nix` to the `hosts/desktop/default.nix` import list. <!-- sdd-owner: implementation -->
- [x] Add an explicit `nixosConfigurations.laptop` block to `flake.nix` (same `system`, same `specialArgs.homeManager`, importing `./hosts/laptop/default.nix`); confirm `specialArgs` still carries **only** `homeManager` and no host facts. <!-- sdd-owner: implementation -->
- [x] Run G1 for `desktop` and `laptop`; both must exit 0. <!-- sdd-owner: implementation -->
- [x] Run G2/G3 for `laptop` against the WU0 oracle (R1 byte-for-byte materialised-tree equality, R2 recursive-expansion set equality on the laptop side); also confirm `desktop` still reproduces its own pre-change payload at this unit. <!-- sdd-owner: implementation -->
- [x] Run G4 inside the `rsync` copy and confirm it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
- [x] Confirm the laptop declares no NVIDIA driver, DRM kernel parameter, or NVIDIA package setting (grep over `hosts/laptop/**`). <!-- sdd-owner: implementation -->
- [x] Run G5 naming each new `.nix` file explicitly. <!-- sdd-owner: implementation -->

---

## WU3a — Plumbing: schema, role layers, direct facts declared (nothing consumed)

**Files:** new `home/piioni/workstation.nix`, `home/piioni/base.nix`, `home/piioni/gui.nix`; rewritten
`home/piioni/default.nix`; `hosts/{desktop,laptop}/home.nix` (role imports plus direct workstation assignments).
**Depends on:** WU2 (a host must exist to declare facts into).
**Gate:** G1 for both hosts exit 0; G2/G3 R1–R3 unchanged (facts declared but consumed by nothing, so
the payload must still be byte-identical); G5.
**Rollback boundary:** delete the schema and role files, restore the 20 unconditional imports in
`home/piioni/default.nix`, and drop the direct workstation assignments and role imports per host. The
payload files are untouched by this unit.
**Commit boundary:** its own commit. It is the cheapest possible intermediate state (facts declared,
nothing consumed, witness still exact) and the sanctioned split point if the budget tightens.
**Intermediate-state note (deliberate, recorded):** throughout WU3a/WU3b the direct assignment in
`hosts/desktop/home.nix` carries the **laptop-mirrored** values, so WU3b's byte-equality witness covers
both hosts. The desktop is therefore temporarily dishonest; WU4 replaces those values and removes the
mirror comment. Any reviewer seeing laptop values in the desktop host file before WU4 is seeing the
design, not a mistake.

- [x] Create `home/piioni/workstation.nix` declaring `options.nixie.workstation` with `display` (`nullOr`, submodule of `outputs` + `pins`), `touchpad`, `brightnessKeys`, `batteryUi` — **all four required, no defaults**; `scale` and the pin fields are `types.str`, `guard` is a two-value enum; the file holds **no facts** and owns the un-captured-topology `warnings` entry. <!-- sdd-owner: implementation -->
- [x] Assign the captured topology directly in `hosts/laptop/home.nix` (`eDP-1` 1920x1080@60 at 0x0 `scale = "1"`; `HDMI-A-1` 1920x1080@120 at 1920x0 `scale = "1"`), the two pin groups (`hdmi`/`monitor-exists`/`1 2 3 4`, then `edp`/`unconditional`/`5 6` — declaration order is output order), and `touchpad`/`brightnessKeys`/`batteryUi` = `true`. <!-- sdd-owner: implementation -->
- [x] Assign the laptop-mirrored values directly in `hosts/desktop/home.nix` with a comment naming WU4 as the owner of the final values. <!-- sdd-owner: implementation -->
- [x] Create `home/piioni/base.nix` (11 imports: `agents`, `fastfetch`, `herdr`, `lazygit`, `moshi`, `nushell`, `packages`, `starship`, `tuxedo`, `yazi`, `zellij`) and `home/piioni/gui.nix` (9 imports: `btop`, `caelestia`, `ghostty`, `hypr`, `kitty`, `swappy`, `swayimg`, `swaync`, `zed`); `btop` sits in `gui` because its config target carries a host fact. <!-- sdd-owner: implementation -->
- [x] Rewrite `home/piioni/default.nix` to identity only (`home.username`, `home.homeDirectory`, `home.stateVersion = "25.11"` unchanged, `programs.home-manager.enable`) plus `imports = [ ./workstation.nix ]`. <!-- sdd-owner: implementation -->
- [x] Extend `hosts/desktop/home.nix` and `hosts/laptop/home.nix` imports with `home/piioni/base.nix` and `home/piioni/gui.nix`, and assign each host's `nixie.workstation` values directly in the same attrset. The exact relative spelling of the role imports is recorded in `design.md` §4.2. <!-- sdd-owner: implementation -->
- [x] Verify the union of `base.nix` + `gui.nix` equals the previous unconditional import list as a **set** (no module added, dropped, or moved out of the profile). <!-- sdd-owner: implementation -->
- [x] Confirm no consumer reads `config.nixie.workstation` yet and that no file under `home/` contains a host name (`desktop`/`laptop`) or a machine literal. <!-- sdd-owner: implementation -->
- [x] Run G1 for both hosts (exit 0) and G2/G3 for the laptop: the payload must still be byte-identical to the pre-change oracle, proving the facts are declared but not yet consumed. <!-- sdd-owner: implementation -->
- [x] Run G5 over every new `.nix` file. <!-- sdd-owner: implementation -->

---

## WU3b — Hybrid ownership and seven host-scoped rendered files

**Files:** `home/piioni/hypr.nix` (atomic Lua ownership transition + rendering),
`home/piioni/caelestia.nix`, `home/piioni/btop.nix`.
**Depends on:** WU3a (schema and facts must exist).
**Live-dotfile boundary:** direct repository payloads use explicit
`config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/..."` paths.
`hypr/hyprland.lua`, each `hypr/scripts/*` leaf, `caelestia/cli.json`, and btop themes may already use
that ownership. `hypr/lua` remains recursively store-backed until this unit; WU3b must delete that owner
before declaring any leaf. Its six host-independent Lua leaves become direct symlinks, while its five
fact-dependent leaves remain rendered/store-backed. `caelestia/shell.json` stays rendered for runtime path
substitution and later battery divergence; `btop/btop.conf` stays rendered/store-backed for later battery
divergence. This is the one-owner/prefix-preserving hybrid boundary.
**Gate:** G1 for both hosts exit 0; W2 per-file byte equality for the laptop (all seven files); W1 target
set equality, the prefix assertion, no laptop topology warning, and G5. Retain the authorized witness
amendment; do not claim unrun payload verification.
**Rollback boundary:** restore the `"hypr/lua"` recursive `xdg.configFile` entry, revert the three
consumer modules, and delete the two generators — `monitors.lua`, `workspaces.lua`,
`inputs.lua`, `gestures.lua`, `keybinds.lua`, `caelestia/shell.json` and `btop/btop.conf` are untouched
on disk, so the raw payload restores itself.
**Commit boundary:** its own commit, after WU3a. Measure `git diff --stat -M` here (see the mid-apply
size checkpoint).

- [ ] Rewrite `home/piioni/hypr.nix` atomically: delete the `"hypr/lua"` `recursive = true` owner before adding exactly eleven explicit leaves — six direct out-of-store `.source` leaves (`animations`, `autostart`, `decorations`, `programs`, `settings`, `windowrules`) and five rendered `.text` leaves (`monitors`, `workspaces`, `inputs`, `gestures`, `keybinds`). Retain explicit direct ownership for `hypr/hyprland.lua` and every `hypr/scripts/*` leaf; do not restore a recursive script owner. <!-- sdd-owner: implementation -->
- [ ] Add the single-owner prefix assertion to `hypr.nix`: no raw `home.file` target may be a path-prefix of another. <!-- sdd-owner: implementation -->
- [ ] Implement the `monitors.lua` value generator: one `hl.monitor` block per `display.outputs` entry in declared order, blank-line separation, single trailing newline, `scale` emitted verbatim as the raw Lua literal. <!-- sdd-owner: implementation -->
- [ ] Implement the `workspaces.lua` value generator: one local binding per pin group, **two distinct branches** selected by the `guard` enum (`monitor-exists` → `if hl.get_monitor(...) ~= nil then … end`; `unconditional` → bare loop), declaration order preserved, `special:magic` always emitted, and **zero locals / zero pins** when `display = null`. <!-- sdd-owner: implementation -->
- [ ] Implement the presence-gated verbatim splice used by `hypr.nix` and `btop.nix`: `builtins.readFile` plus a checked `lib.replaceStrings` that `throw`s a named-payload error when the expected region is absent. <!-- sdd-owner: implementation -->
- [ ] Generate `hypr/lua/inputs.lua` from the payload file with the touchpad region (lines 17–24, copied from the pre-change file at implementation time) dropped when `touchpad = false`; keep keyboard and mouse settings byte-verbatim. <!-- sdd-owner: implementation -->
- [ ] Generate `hypr/lua/gestures.lua` from the payload file, reduced to one comment line when `touchpad = false`; the target must stay a loadable Lua chunk because `hyprland.lua` requires it unconditionally. <!-- sdd-owner: implementation -->
- [ ] Generate `hypr/lua/keybinds.lua` from the payload file with the stale comment and both `XF86MonBrightness*` binds (lines 84–90 region) replaced when `brightnessKeys = false`. <!-- sdd-owner: implementation -->
- [ ] Keep btop theme leaves as direct out-of-store symlinks and convert only `home/piioni/btop.nix`'s store-backed `btop/btop.conf` target from `.source` to `.text` using the checked splice, flipping `show_battery = true` to `false` (line 243 region) and keeping every other key byte-verbatim. <!-- sdd-owner: implementation -->
- [ ] Keep `caelestia/cli.json` as a direct out-of-store symlink and extend the existing `lib.replaceStrings` call for store-backed `caelestia/shell.json` with the additive `"showBattery": true` → `false` substitution; do not restructure the file and do not add the splice helper a third time. <!-- sdd-owner: implementation -->
- [ ] Verify R1 per file: for the laptop, the materialised `hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `hypr/lua/inputs.lua`, `hypr/lua/gestures.lua`, `hypr/lua/keybinds.lua`, `caelestia/shell.json`, and `btop/btop.conf` are each byte-identical to the WU0 oracle (compare rendered content, not the `.source`/`.text` mechanism). <!-- sdd-owner: implementation -->
- [ ] Verify R2/R3: the option snapshot shows exactly one raw key removed (`…/hypr/lua`) and exactly eleven added (`…/hypr/lua/<name>.lua`) and nothing else; no target is a path-prefix of another; the eleven `require("lua.*")` targets resolve for both hosts. <!-- sdd-owner: implementation -->
- [ ] Run G1 for both hosts (exit 0); confirm the laptop emits **no** un-captured-topology warning, while `desktop` still renders the laptop-mirrored facts at this unit. <!-- sdd-owner: implementation -->
- [ ] Run G5, including the newly multi-line Nix strings (open item O5). <!-- sdd-owner: implementation -->
- [ ] Record `git diff --stat -M`, the measured authored changed-line total (evidence tree excluded), and `git diff --stat` without rename detection into the unit's evidence; if the rename-aware total is **> 400**, stop here and hand the size decision to the parent. <!-- sdd-owner: implementation -->

---

## WU4 — Desktop divergence

**Files:** `hosts/desktop/home.nix` only.
**Depends on:** WU3b (the desktop must already consume direct host assignments before it can diverge).
**Gate:** G1 for both hosts exit 0; R5 item-by-item divergence check; R6 positive for `desktop` and
negative for `laptop`; R1 byte equality for the laptop still exact; G5.
**Rollback boundary:** restore the four laptop-mirrored values in `hosts/desktop/home.nix`; nothing
else is affected.
**Commit boundary:** the final unit; it is the only one that intentionally perturbs the payload.

- [ ] Set the direct `hosts/desktop/home.nix` assignment to `display = null`, `touchpad = false`, `brightnessKeys = false`, `batteryUi = false`, and remove the WU3a mirror comment. <!-- sdd-owner: implementation -->
- [ ] Run G1 for `desktop` and confirm exit 0 plus the un-captured-topology warning on stderr (R6 positive); run G1 for `laptop` and confirm no such warning. <!-- sdd-owner: implementation -->
- [ ] Check R5 item by item against `design.md` §7.5: L1 `eDP-1` monitor block absent, L2 no pin loop with `special:magic` retained, L3 touchpad region removed from `inputs.lua`, L4 `gestures.lua` comment-only, L5 brightness region removed from `keybinds.lua`, L6 `"showBattery": false`, L7 `show_battery = false`; report any drift beyond this table separately rather than absorbing it. <!-- sdd-owner: implementation -->
- [ ] Re-confirm R1/R2 for `laptop` after WU4, proving the desktop's divergence did not touch the laptop payload. <!-- sdd-owner: implementation -->
- [ ] Run G5 and record the final full-tree measurement for the parent's size decision. <!-- sdd-owner: implementation -->

---

## Final verification (apply-owned)

- [ ] Run G1 for `desktop` **and** `laptop` over a fresh non-Git copy; record both derivation paths and exit codes. <!-- sdd-owner: implementation -->
- [ ] Run G4 inside the `rsync` copy; record that it lists exactly `desktop` and `laptop`. <!-- sdd-owner: implementation -->
- [ ] Run G5 including untracked new `.nix` files and record exit 0. <!-- sdd-owner: implementation -->
- [ ] Record the R1–R7 evidence set for the change: materialised-tree diff (empty), raw-key delta (one removal, eleven additions), ownership assertion result, `desktop` `drvPath` equality at WU1, divergence table result, warning presence/absence, flake topology, format gate. <!-- sdd-owner: implementation -->
- [ ] Confirm the shell contract: `xurl` is bash and `write_gate_file` streams unbuffered. <!-- sdd-owner: implementation -->
- [ ] Audit non-goals: no new package declaration, no `services.tlp`/`power-profiles-daemon`/`upower`, no session entry point, no `hardware-configuration.nix` in `hosts/laptop/`, `brightnessctl` still undeclared with the two relocated brightness binds intact, the `code` → `zed-editor` bind untouched, `tuxedo-rs` still in the shared portable layer and unclassified, no `lib/` directory, no `modules/hardware/default.nix`, no `mkEnableOption`/`mkIf` enable-flag framework, no third-machine schema or fact field. <!-- sdd-owner: implementation -->
- [ ] Run `nix eval --raw nixpkgs#tuxedo-rs.meta.description` and record the result (open item O2); if it names TUXEDO vendor hardware control, record reclassification as a follow-up only — do not change the layer split. <!-- sdd-owner: implementation -->

## Post-apply parent actions

Grouped separately; none of these is implementation-owned.

- [ ] Confirm the laptop's `networking.hostName` and `system.stateVersion` with the user before WU2 is committed, or explicitly accept the design default `laptop` / `"25.11"` (open item O1; a rename is a directory rename plus one line and does not touch the payload witness). Non-blocking for the size decision. <!-- sdd-owner: parent -->
- [ ] Decide the size gate if WU3b's measured diff crossed 400: require explicit user acceptance of `size:exception` or select a chain strategy. Do not infer either. <!-- sdd-owner: parent -->
- [ ] Start or reuse the bounded post-apply review of the final diff against `design.md` §15 (reviewer checklist) and the §7.5 divergence table. <!-- sdd-owner: parent -->
- [ ] Authorize the commit/PR lifecycle: WU1 → WU2 → WU3a → WU3b → WU4 as separate work-unit commits inside the single PR. <!-- sdd-owner: parent -->

## Requirements coverage

| Requirement (spec) | Covered by |
|---|---|
| host-composition · Per-Host Composition | WU2, WU3a, Final verification |
| host-composition · Host Identity And State Versions Are Host Data | WU2, WU3a (HM `stateVersion` unchanged) |
| host-composition · Host-Scoped Facts Are Data Consumed By Host-Agnostic Code | WU3a, WU3b |
| host-composition · Cross-Host Payload Equivalence | WU2, WU3a, WU3b, WU4 |
| host-composition · Laptop-Only Facts Are Absent From The Desktop Host | WU4 |
| host-composition · Un-captured Host Topology Is Explicit | WU3a (schema + warning), WU3b (no pins), WU4 |
| host-composition · Refactor Purity And Scope Boundary | Final verification |
| host-composition · Verification Gate And Witness Discipline | Gate definitions, WU1, WU2, WU3b, Final verification |
| home-payload · Home Manager Target Set Stability | WU3a, WU3b (R2/R3) |
| home-payload · Unconditional Hyprland Module Requires Keep Resolving | WU3b |
| home-payload · Host-Scoped Payload Rendering | WU3b (R1) |
| home-payload · Verbatim Regions Outside The Varying Region | WU3b |
| home-payload · Workspace Pin Semantics Are Preserved Per Output | WU3b |
| home-payload · Two Role Layers | WU3a |
| home-payload · `tuxedo-rs` Remains Portable And Unclassified | WU3a, Final verification |
| hardware-modules · NVIDIA Support Is A Reusable Module | WU1, WU2 |
| hardware-modules · The Hardware Extraction Is A Behaviour-Preserving Move | WU1 (R4) |

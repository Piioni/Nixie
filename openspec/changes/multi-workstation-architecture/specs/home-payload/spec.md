# Home Payload Specification

## Purpose

`home/` is the portable Home Manager payload shared by every workstation. `home/default.nix` imports
platform-independent `core`, `tui`, and `gui` category aggregators; `home/hosts/{desktop,laptop}.nix`
holds direct per-machine Home Manager assignments. The payload itself carries no machine-specific literals
while its rendered output on the machine the payload was migrated from stays byte-identical to the migrated
files.

> **Current-layout note.** The historical witness amendment below intentionally retains its earlier
> `base`/`gui` variant labels. Current architecture is `home/{core,tui,gui,hosts}`: `btop.nix` is in `tui`,
> and `hosts/<name>/home.nix` bridges NixOS by importing `../../home` plus its matching host module.

## Requirements

### Requirement: Live-Dotfile Hybrid Ownership Boundary

Direct repository-owned payload files MUST use explicit
`config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/<category>/..."` paths:
Hyprland and Caelestia source paths are under `home/gui/`, while btop source paths are under `home/tui/`.
`hypr/hyprland.lua`, every `hypr/scripts/*` leaf, `caelestia/cli.json`, and btop theme leaves are direct
ownership. Host-dependent or substituted targets remain generated/store-backed: the five fact-dependent
Hyprland Lua regions, `caelestia/shell.json` (runtime-path substitution and later battery divergence), and
`btop/btop.conf` (later battery divergence). This boundary does not alter the authorized witness amendment.

#### Scenario: Recursive Hyprland ownership transitions without overlap

- GIVEN `hypr/lua` is currently owned as one recursive directory
- WHEN WU3b introduces direct and rendered Lua leaves
- THEN it removes the recursive owner before adding any leaf, preserves the one-owner/prefix assertion,
  and gives six host-independent leaves direct ownership while the five fact-dependent leaves remain rendered

#### Scenario: WU4 owns divergence rather than direct-file conversion

- GIVEN the hybrid boundary is established in WU3b
- WHEN desktop-specific values diverge
- THEN WU4 changes only the direct host assignment in `home/hosts/desktop.nix` and does not change ownership of direct payload targets

### Requirement: Home Manager Target Set Stability

The payload MUST expose the same `home.file` target names for every host before and after host-scoping.
A directory-recursive `xdg.configFile` copy MUST NOT coexist with a per-file target for the same path:
where a file inside a recursively copied directory becomes a rendered or direct per-file target, the recursive
copy MUST be removed before explicit per-file entries are introduced, producing identical target names.

#### Scenario: Target names survive replacing the recursive copy

- GIVEN `home/gui/hypr.nix` owns `hypr/lua/<name>.lua` through a recursive copy of `hypr/lua`
- WHEN the changed configuration is evaluated
- THEN the target set still contains one target per Hyprland Lua module with unchanged names and no target path is claimed twice

#### Scenario: Target-set equality is asserted as a sorted set

- GIVEN the acceptance evidence for this payload
- WHEN the target criterion is expressed
- THEN it compares a sorted set of target names and contains no hardcoded target count

### Requirement: Unconditional Hyprland Module Requires Keep Resolving

Every `lua.*` module required unconditionally by `home/gui/hypr/hyprland.lua` MUST remain present as
a rendered or verbatim target after the change. Those modules MUST NOT be deleted: a module that
becomes host-scoped MUST keep its target path so the `require` continues to resolve.

#### Scenario: All required modules resolve for every host

- GIVEN a host's rendered `hypr/` tree
- WHEN the ten `require("lua.*")` statements in `hyprland.lua` are resolved
- THEN every required module file exists at its target path

### Requirement: Host-Scoped Payload Rendering

Host-scoped values MUST be rendered from direct host Home Manager assignments rather than duplicated into per-host copies. The
seven payload files concerned are the monitor module, the workspace module, the input module, the
gesture module, the key-bind module, the shell JSON, and the system-monitor configuration. For the
machine the payload was migrated from, the rendered content of each of those seven files MUST be
byte-identical to the pre-change file content, including the two deliberately dead brightness binds.
That byte-equality is what keeps the payload-verbatim convention usable through the host instead of
through the raw file.

#### Scenario: Migrated-from rendered bytes equal the migrated file bytes

- GIVEN that machine's host data declares today's hardcoded values
- WHEN each of the seven rendered payload files is compared against its pre-change bytes
- THEN every file is byte-identical, checked per file

#### Scenario: The system-monitor target changes mechanism but not content

- GIVEN the system-monitor configuration moves from a source symlink to rendered content
- WHEN content equality is asserted
- THEN the assertion is made on rendered content, not on the symlink mechanism

#### Scenario: The shell JSON substitution stays additive

- GIVEN the shell JSON is rewritten by the shell at runtime
- WHEN the host-scoped value is applied
- THEN the file's structure is unchanged and the value is applied by additive substitution

### Requirement: Verbatim Regions Outside The Varying Region

Where only one region of a payload file varies, every other region MUST remain verbatim: the input
module's keyboard and mouse settings, the key-bind module's remaining binds, and the system-monitor
configuration's non-battery keys.

#### Scenario: Only the varying region is attributable to host data

- GIVEN the migrated-from machine's rendered input and key-bind payloads
- WHEN they are compared against the pre-change files
- THEN only the host-scoped lines differ and every other line is unchanged

### Requirement: Workspace Pin Semantics Are Preserved Per Output

The workspace-to-monitor map MUST come from host data, and the existing difference in failure
semantics MUST be preserved: the external-output pin group MUST stay conditional on the output
existing, while the internal-panel pin group MUST stay unguarded. The two semantics MUST NOT be
unified into a single shared path, because the unguarded internal-panel pin is the one laptop fact
that actually breaks on a host without that output. A host with un-captured topology MUST render no
workspace pins at all.

#### Scenario: The migrated-from machine keeps both semantics

- GIVEN the migrated-from machine's captured topology
- WHEN its workspace module is rendered
- THEN the conditional external-output block and the unguarded internal-panel block are byte-identical to the pre-change file

#### Scenario: Un-captured topology renders no pins

- GIVEN a host whose topology is un-captured
- WHEN its workspace module is rendered
- THEN no workspace-to-monitor pin is emitted

### Requirement: Three Category Aggregators

The profile MUST use exactly three platform-independent category aggregators: `home/core/default.nix` for
shared identity/schema and common tooling, `home/tui/default.nix` for terminal and text-interface
applications, and `home/gui/default.nix` for graphical applications and session configuration.
`home/default.nix` MUST import all three. `btop.nix` MUST remain in `home/tui/`, even though its rendered
configuration consumes `batteryUi`. Category ownership does not relocate host facts: they remain direct
assignments in `home/hosts/{desktop,laptop}.nix`.

#### Scenario: Category composition equals the previous profile

- GIVEN all three category aggregators imported by `home/default.nix` for a host
- WHEN that host's target set and rendered content are compared with the previous profile
- THEN they are equal

This scenario was originally phrased as whole-profile equality ("target set and rendered content … are
equal"). Whole-tree byte equality of the materialised tree is unreachable for any module-graph change (see
"Witness amendment (authorized)" at the end of this file). The operative reading for this scenario is W1
(set-equal expanded target set) plus W2 (the seven host-scoped files byte-identical), never a whole-tree
comparison.

#### Scenario: Host facts remain direct assignments

- GIVEN the three category aggregators and `home/hosts/{desktop,laptop}.nix`
- WHEN their source locations are inspected
- THEN `nixie.workstation` values are direct assignments in the host modules, while the shared category
  modules remain host-agnostic

### Requirement: `tuxedo-rs` Remains Portable And Unclassified

`pkgs.tuxedo-rs` and its configuration payload MUST remain in the shared portable layer for this
change, and its identity MUST be recorded as explicitly unclassified. It MUST NOT be classified as a
form-factor marker on the strength of its name. If its package metadata is later found to name TUXEDO
vendor hardware control, reclassification as laptop-only software is a follow-up, not part of this
change.

#### Scenario: The tool is installed for every host

- GIVEN both hosts
- WHEN their rendered payloads are inspected
- THEN `tuxedo-rs` is installed and its configuration target is present for both hosts

---

## Witness amendment (authorized)

**Provenance.** This amendment was discovered during the `apply` phase, proven by parent-run experiments, and
explicitly authorized by the user. The full finding and its causal analysis are recorded in
`openspec/changes/multi-workstation-architecture/apply-progress.md` (sections *"R4 / non-negotiable #7 —
desktop `drvPath` vs the recorded oracle"*, *"G2 — materialised payload witness (R1)"*, and *"Witness
residual requiring parent judgement (not absorbed)"*), and the operative witness is stated in
`design.md` → `## Witness amendment (authorized)`.

**Superseded criterion (retained, not deleted).** Where this spec compared the whole profile — "that host's
target set and rendered content are compared with the previous profile → they are equal" — as a general
requirement for this change, the whole-tree reading required byte equality of the materialised tree. It also
stood alongside `system.build.toplevel.drvPath` equality across the refactor.

**Why it is unreachable, not missed.** Whole-tree byte equality of the materialised `home-files` tree, and
`system.build.toplevel.drvPath` equality of the toplevel, are unreachable for *any* change that alters the
module graph. This refactor is such a change. The criteria were unreachable as written, not missed.

| Variant | `toplevel` drvPath | `home.path` | entries | content vs oracle |
| --- | --- | --- | --- | --- |
| oracle (pre-change) | `26i3y9sw…` | `4gw1bjqn…` | 1539 | — |
| V0 per-host `imports` wrapper (current WU2 state) | `yq177ir6…` | `yxvaxdivd…` | 1539 | **byte-identical** |
| V1 direct assignment, imports list left intact | `26i3y9sw…` | unchanged | — | — |
| V5 direct assignment, imports split into `base`/`gui` roles | `1g62rdza…` | `5wi4vfwl…` | 1539 | **byte-identical** |

`diff -r` between the oracle's `home.path` and each of the two changed variants exits **0**, with 1539
entries on each side. Three distinct derivation hashes, one identical built content.

**Mechanism.** Home Manager's `buildEnv` for `home.path` is sensitive to the **order** of the package list,
and the shape of the module graph determines that order. The package set is identical; only the ordering
differs, so hashes differ while built content does not. V5 proves the effect is not caused by the `imports`
wrapper: splitting the imports into role layers moves the hash on its own, with the wrapper removed. V1
preserves the hash but cannot express role layers, which is the entire purpose of this change.

**Operative witness (supersedes the whole-profile comparison).**

- **W1 — target set equality.** The expanded `home.file` target set must be **set-equal** to the captured
  pre-change snapshot, applying the recursive-expansion rule for `recursive = true` entries. **Never a
  count**: no total target count may appear as a constant anywhere.
- **W2 — payload byte equality.** The seven host-scoped payload files must be byte-identical to their
  pre-change rendered content.
- **W3 — package layer content identity.** The built `home.path` derivation must be byte-identical to the
  pre-change one under `diff -r`. This witnesses package **content** independently of its hash, which is
  strictly stronger than comparing derivation paths.

**Not weakened — `R4`.** This amendment does not touch the WU1 NVIDIA pure-move `drvPath` equality witness
(`R4` in `design.md` §9.2 and `specs/hardware-modules/spec.md`), which succeeded and stays scoped to the pure
move. It is not a general-purpose witness that later units must satisfy.

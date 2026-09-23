# Host Composition Specification

## Purpose

Nixie composes one NixOS configuration per workstation from a shared `modules/` tree plus a small,
explicit per-host directory. Each system host bridge imports `../../home` and its matching
`home/hosts/<name>.nix` module. Per-machine facts — host identity, display topology, workspace-to-monitor
map, touchpad presence, touchpad gestures, brightness key binds, and battery-UI toggles — are host
data, never constants inside the layer applied to every machine.

This capability exists because the flake previously evaluated *desktop system layer + laptop-derived
Home Manager payload*: the machine named in `hosts/desktop/` was a real desktop, while every
laptop-specific fact lived in the payload applied to all hosts, and no host could express "which
machine am I".

## Requirements

### Requirement: Per-Host Composition

The flake MUST declare each workstation as an explicit `hosts/<name>/` directory that composes the
shared `modules/` tree, its own identity module, a Home Manager bridge importing `../../home` plus
`../../home/hosts/<name>.nix`, and an optional `hardware-configuration.nix` import guarded by an existence
check. `flake.nix` MUST declare one
explicit `nixosSystem` block per host. The configuration MUST NOT introduce a shared host-inventory
helper (for example `lib/mkWorkstation.nix`) or a `mkEnableOption`/`mkIf` enable-flag framework.

#### Scenario: Both workstations evaluate from their own directory

- GIVEN `hosts/desktop/` and `hosts/laptop/` each compose the shared `modules/` tree and declare their own identity
- WHEN `nix flake show` runs over the changed tree
- THEN it exits 0 and lists exactly `nixosConfigurations.desktop` and `nixosConfigurations.laptop`

#### Scenario: No schema exists for an undefined machine

- GIVEN no third workstation has been defined
- WHEN the host directories and the host-data schema are inspected
- THEN no host output, fact field, or composition branch exists for a third machine, and no hybrid-GPU, power-policy, or role axis is pre-built for it

### Requirement: Host Identity And State Versions Are Host Data

Each host MUST declare its own `networking.hostName` and system `stateVersion`, and MUST NOT inherit
another host's identity. The Home Manager payload MUST keep the Home Manager `stateVersion` it has
today (`"25.11"`), because changing it would change Home-Manager-generated targets and break the
behaviour baseline.

#### Scenario: Laptop identity is declared, not inherited

- GIVEN `hosts/laptop/` identity module
- WHEN the laptop host is evaluated
- THEN `config.networking.hostName` is the laptop's declared name, `config.system.stateVersion` is `"25.11"`, and the payload's Home Manager `stateVersion` is `"25.11"`

### Requirement: Host-Scoped Facts Are Data Consumed By Host-Agnostic Code

Every per-machine fact MUST be declared directly in the corresponding `home/hosts/<name>.nix` Home Manager
module and consumed by shared, host-agnostic code. The system host's `home.nix` is a bridge that imports
`../../home` plus that module. Shared consumers MUST NOT branch on a host name and MUST NOT contain
machine-specific literals. Host data destined for the Home Manager layer MUST use that direct per-host Home
Manager assignment and MUST NOT rely on `nixosSystem` `specialArgs`, which do not reach Home Manager
modules. `modules/home-manager.nix` MUST NOT hardcode a single Home Manager import for all hosts. Direct repository dotfiles may use the
live checkout path through explicit out-of-store symlinks, but fact-dependent and substituted targets
remain generated/store-backed; this ownership boundary is specified by home-payload WU3b, while WU4
changes host facts only.

#### Scenario: Facts resolve per host without host-name branching

- GIVEN `home/hosts/{desktop,laptop}.nix` declares different topology, workspace map, touchpad,
  brightness-bind, and battery-UI data
- WHEN each host is evaluated
- THEN each renders its own values and the shared consumers contain no host-name conditional

#### Scenario: Home Manager transport does not cross the `specialArgs` boundary

- GIVEN host data consumed by the Home Manager payload
- WHEN the Home Manager modules are evaluated for either host
- THEN the system bridge imports `../../home` plus the matching direct-assignment module, and evaluation
  reports no undefined variable

### Requirement: Cross-Host Payload Equivalence

Both hosts MUST evaluate the same portable Home Manager payload. Per-host facts MUST change only the
content attributed to them and MUST NOT add, remove, or rename any `home.file` target. The acceptance
witness for this capability MUST be a sorted comparison of the `home.file` target set plus a
per-target content comparison; a target count literal MUST NOT be used as a criterion. Because the
pre-change evaluation was the migrated machine's own configuration, the regression witness MUST be
*new host after* against *recorded pre-change evaluation*, and a desktop-against-desktop comparison
MUST NOT be used as a regression witness.

**Superseded (see "Witness amendment (authorized)").** The requirement's *per-target content comparison*
was a whole-tree byte-equality claim, and it stood alongside `system.build.toplevel.drvPath` equality
across the refactor. The original wording is retained above for history; the operative witness is now
**W1** (set-equal expanded `home.file` target set — never a count) **+ W2** (the seven host-scoped payload
files byte-identical) **+ W3** (built `home.path` byte-identical under `diff -r`).

#### Scenario: The migrated-from machine reproduces the recorded pre-change payload

- GIVEN the recorded pre-change `attrNames home-manager.users.piioni.home.file` and the recorded per-target contents for the pre-change `nixosConfigurations.desktop`
- WHEN the laptop host is evaluated after the change
- THEN the sorted laptop target set equals the recorded snapshot and each target's rendered content equals the recorded pre-change content

The scenario's "each target's rendered content equals the recorded pre-change content" is superseded as a
whole-tree claim by **W1 + W2 + W3** (see "Witness amendment (authorized)" at the end of this file): the
laptop target set must be set-equal (recursive entries expanded), the seven host-scoped payload files must
be byte-identical, and the built `home.path` must be byte-identical under `diff -r`.

#### Scenario: The desktop divergence is judged item by item

- GIVEN the desktop host legitimately differs from its pre-change evaluation
- WHEN the desktop diff is reviewed
- THEN it is checked against the written per-item expectation of laptop-only facts absent, and no conclusion is drawn from "the desktop changed"

### Requirement: Laptop-Only Facts Are Absent From The Desktop Host

The desktop host MUST NOT apply any laptop-only fact. The facts that MUST be absent are the enumerated
inventory: the internal-panel monitor definition, the internal-panel workspace pins, the touchpad
block, the touchpad gestures, the brightness key binds, and the battery-UI toggles in the shell and
system-monitor payloads. The desktop host MUST remain evaluable after losing them; this is a
subtraction of facts about hardware it does not have, not a broken configuration.

#### Scenario: Each enumerated fact is absent, checked individually

- GIVEN the desktop host's rendered Home Manager payload
- WHEN it is inspected against the written per-item expectation
- THEN none of the enumerated facts is present, and any further drift is reported rather than absorbed into "expected difference"

#### Scenario: The desktop host stays evaluable

- GIVEN the desktop host no longer applies touchpad, gesture, brightness, battery, or internal-panel facts
- WHEN the desktop host is evaluated through the project gate
- THEN evaluation succeeds

### Requirement: Un-captured Host Topology Is Explicit

A host whose display topology has not been captured MUST represent it explicitly as an un-captured
value, MUST surface an evaluation warning naming the gap, and MUST produce no monitor directives and
no workspace-to-monitor pins for that host, so the compositor falls back to its own detection.
Invented topology values MUST NOT be added, and an un-captured topology MUST NOT block evaluation.

#### Scenario: The un-captured desktop host auto-detects

- GIVEN the desktop host's topology is un-captured
- WHEN the desktop host is evaluated and its rendered monitor payload is inspected
- THEN evaluation emits a warning naming the un-captured topology and the rendered payload contains no monitor directive and no workspace pin

#### Scenario: Values appear only when captured

- GIVEN a host whose topology has been captured from the machine
- WHEN that host is evaluated
- THEN the rendered payload uses exactly the declared output names, modes, positions, scales, and workspace map

### Requirement: Refactor Purity And Scope Boundary

This change MUST NOT add behaviour; it moves facts to the correct host and introduces the seam. It MUST
NOT add a package declaration, and it MUST NOT add power or battery configuration (`services.tlp`,
`services.power-profiles-daemon`, `services.upower`), a session entry point
(`services.displayManager.*`, `services.greetd`, `programs.hyprland`, `services.xserver.enable`), or
any of the referenced-but-undeclared tools (`brightnessctl`, `cliphist`, `wl-paste`,
`gnome-keyring-daemon`, `nautilus`, `helium`, `code`). It MUST NOT repair the `code` → `zed-editor`
key-bind mismatch. `hosts/laptop/` MUST NOT ship a `hardware-configuration.nix`, and this capability
MUST NOT claim the laptop is installable or activatable.

The boundary has one reason: declaring those packages, or switching the bind, is a *behaviour
addition*, and any behaviour addition breaks the byte-equality witness this refactor depends on. The
relocated brightness binds therefore stay deliberately dead on every host, and that debt is recorded
rather than hidden.

#### Scenario: No behaviour was added

- GIVEN the changed tree
- WHEN package declarations and NixOS service declarations are inspected
- THEN no new package declaration, no power or battery service, and no session entry point was introduced

#### Scenario: The laptop is not declared installable

- GIVEN `hosts/laptop/`
- WHEN its files and the gate result are inspected
- THEN it contains no `hardware-configuration.nix`, the gate reports evaluation only, and no installability or activation claim is made

#### Scenario: Recorded debt stays recorded

- GIVEN the laptop's rendered key binds
- WHEN the brightness binds are inspected
- THEN both binds are present and unchanged while no `brightnessctl` declaration exists, and the undeclared-tool list and the editor bind mismatch remain named follow-up items

### Requirement: Verification Gate And Witness Discipline

Verification MUST use the project's recorded evaluation gate: `system.build.toplevel.drvPath`
evaluated per declared host through `extendModules` with the evaluation-only boot stub, over a
non-Git copy of the working tree. `nix flake check` MUST NOT be used, because it forces the toplevel
without the stub and dies on the pre-existing filesystem and boot-loader assertions. Derivation-path
equality MUST be claimed only for a pure move; when evaluated content legitimately changes, the
witness MUST degrade to the target-set snapshot plus a rendered-content diff — concretely, to **W1 + W2 +
W3** in "Witness amendment (authorized)".

#### Scenario: Every declared host passes the gate

- GIVEN a non-Git copy of the working tree that contains the change's new files
- WHEN the recorded gate command runs once per declared host
- THEN each host evaluates to a derivation path and the command exits 0

#### Scenario: `nix flake check` is excluded

- GIVEN `hosts/desktop/hardware-configuration.nix` is intentionally absent
- WHEN verification is selected
- THEN `nix flake check` is not invoked and the `extendModules` gate is used instead

#### Scenario: The gate's permissiveness is a recorded limitation

- GIVEN the gate stub supplies `nixpkgs.config.allowUnfree = true`, which the tracked tree does not
- WHEN verification results are reported
- THEN the gate is reported as more permissive than a real build and the difference is left unfixed in this change

#### Scenario: Formatting gate

- GIVEN the changed tree
- WHEN `nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix')` runs
- THEN it exits 0

---

## Witness amendment (authorized)

**Provenance.** This amendment was discovered during the `apply` phase, proven by parent-run experiments, and
explicitly authorized by the user. The full finding and its causal analysis are recorded in
`openspec/changes/multi-workstation-architecture/apply-progress.md` (sections *"R4 / non-negotiable #7 —
desktop `drvPath` vs the recorded oracle"*, *"G2 — materialised payload witness (R1)"*, and *"Witness
residual requiring parent judgement (not absorbed)"*), and the operative witness is stated in
`design.md` → `## Witness amendment (authorized)`.

**Superseded criterion (retained, not deleted).** As a general requirement for this change, the original
record required whole-tree byte equality of the materialised `home-files` tree ("a sorted comparison of the
`home.file` target set plus a per-target content comparison", with "each target's rendered content equals the
recorded pre-change content") together with `system.build.toplevel.drvPath` equality across the refactor.

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

**Operative witness (supersedes the whole-tree comparison).**

- **W1 — target set equality.** The expanded `home.file` target set must be **set-equal** to the captured
  pre-change snapshot, applying the recursive-expansion rule for `recursive = true` entries. **Never a
  count**: no total target count may appear as a constant anywhere.
- **W2 — payload byte equality.** The seven host-scoped payload files must be byte-identical to their
  pre-change rendered content.
- **W3 — package layer content identity.** The built `home.path` derivation must be byte-identical to the
  pre-change one under `diff -r`. This witnesses package **content** independently of its hash, which is
  strictly stronger than comparing derivation paths.

**Not weakened — `R4`.** The WU1 NVIDIA pure-move `drvPath` equality witness (`R4` in `design.md` §9.2 and
`specs/hardware-modules/spec.md`) succeeded and is left intact. It is scoped to the pure move it already
witnessed and is not a general-purpose witness that later units must satisfy.

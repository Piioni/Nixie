# Home Payload Specification

## Purpose

`home/piioni/` is the portable Home Manager payload shared by every workstation: CLI/TUI tooling, a
graphical session payload, and raw migrated configuration files kept verbatim. Per-machine facts reach
it as host data, so the payload itself carries no machine-specific literals while its rendered output
on the machine the payload was migrated from stays byte-identical to the migrated files.

## Requirements

### Requirement: Home Manager Target Set Stability

The payload MUST expose the same `home.file` target names for every host before and after host-scoping.
A directory-recursive `xdg.configFile` copy MUST NOT coexist with a per-file target for the same path:
where a file inside a recursively copied directory becomes a rendered per-file target, the recursive
copy MUST be replaced by explicit per-file entries producing identical target names.

#### Scenario: Target names survive replacing the recursive copy

- GIVEN `home/piioni/hypr.nix` owns `hypr/lua/<name>.lua` through a recursive copy of `hypr/lua`
- WHEN the changed configuration is evaluated
- THEN the target set still contains one target per Hyprland Lua module with unchanged names and no target path is claimed twice

#### Scenario: Target-set equality is asserted as a sorted set

- GIVEN the acceptance evidence for this payload
- WHEN the target criterion is expressed
- THEN it compares a sorted set of target names and contains no hardcoded target count

### Requirement: Unconditional Hyprland Module Requires Keep Resolving

Every `lua.*` module required unconditionally by `home/piioni/hypr/hyprland.lua` MUST remain present as
a rendered or verbatim target after the change. Those modules MUST NOT be deleted: a module that
becomes host-scoped MUST keep its target path so the `require` continues to resolve.

#### Scenario: All required modules resolve for every host

- GIVEN a host's rendered `hypr/` tree
- WHEN the ten `require("lua.*")` statements in `hyprland.lua` are resolved
- THEN every required module file exists at its target path

### Requirement: Host-Scoped Payload Rendering

Host-scoped values MUST be rendered from host data rather than duplicated into per-host copies. The
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

### Requirement: Two Role Layers

The profile MUST be split into exactly two role layers: a base layer for portable CLI/TUI tooling and a
graphical layer for the session payload. Importing both layers together MUST be equivalent to the
profile's previous unconditional module list. The base layer MUST NOT carry machine-specific facts. A
three-layer split MUST NOT be introduced while no non-graphical machine is defined.

#### Scenario: Layer composition equals the previous profile

- GIVEN both role layers imported together for a host
- WHEN that host's target set and rendered content are compared with the previous profile
- THEN they are equal

#### Scenario: The graphical layer is the only host-sensitive layer

- GIVEN the two role layers
- WHEN they are inspected for host-scoped facts
- THEN every host-scoped fact attaches to the graphical layer and the base layer is host-independent

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

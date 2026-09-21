# Untangle the desktop system layer from the laptop user payload

This change gives the flake a **second, real host** and a **host seam** so that per-machine facts stop living in the layer applied to every machine. Today the flake evaluates *desktop system layer + laptop user payload*; that hybrid is the defect. The change adds `hosts/laptop/` (the machine the user is actually sitting at) and moves the laptop-only facts out of the portable payload into per-host data.

The single most important thing for a reviewer to understand: **the "no behaviour change" baseline is the laptop, not the desktop.** A naive before/after diff of `hosts/desktop` is expected to be non-empty and represents a *correction*, not a regression. This is stated in full below and is the top risk of the change.

- Change: `multi-workstation-architecture`
- Store: `openspec` — this artifact is `openspec/changes/multi-workstation-architecture/proposal.md`
- Phase: proposal (no spec, design, or tasks written)
- Input: `openspec/changes/multi-workstation-architecture/exploration.md` (current revision) and `openspec/config.yaml`

## Review path

1. Read **§ Problem statement** and **§ The acceptance-criterion inversion** — everything else depends on those two.
2. Skim **§ Decision summary** (7 decisions, one line each, rationale linked).
3. Read **§ Work units and size risk** — this is where the 400-line budget is decided.
4. The rest is detail: affected areas, risks, rollback, success criteria.

## Problem statement

The repository has exactly one host, `hosts/desktop/`, and one unconditional Home Manager payload, `home/piioni/`. But:

- **`hosts/desktop/` is a real desktop machine's host definition** — not the machine in front of the user.
- **The machine in front of the user is a laptop: Lenovo ThinkBook 14 G2 ITL** (Intel Iris Xe only, `BAT1`, `intel_backlight`, touchpad `04F3:3140`).
- **`home/piioni/` was migrated from that laptop's live `~/.config`.**

So the payload carries laptop facts into every host, and the user's own machine cannot be installed from this flake at all. Concretely, today:

| ID | Laptop fact living in the universal payload | Location | Effect on the desktop |
|----|--------------------------------------------|----------|-----------------------|
| L1 | `eDP-1` monitor mode/position/scale | `home/piioni/hypr/lua/monitors.lua` | no-op / warning |
| L2 | workspaces 5–6 pinned to `eDP-1` | `home/piioni/hypr/lua/workspaces.lua:3,11-13` | **real fault** — pinning to a nonexistent output |
| L3 | full `touchpad` block | `home/piioni/hypr/lua/inputs.lua:17-22` | inert |
| L4 | 3-finger workspace gestures | `home/piioni/hypr/lua/gestures.lua` | inert |
| L5 | `XF86MonBrightness*` → `brightnessctl` | `home/piioni/hypr/lua/keybinds.lua:89-90` | inert (and dead on the laptop too — `brightnessctl` is declared nowhere) |
| L6 | `"showBattery": true` | `home/piioni/caelestia/shell.json:32` | inert |
| L7 | `show_battery`, `selected_battery`, `show_battery_watts` | `home/piioni/btop/btop.conf:243,246,249` | inert |

Only **L2 actually breaks** anything today; the rest degrade to no-ops. That matters: the desktop divergence is not cosmetic, but it is also not a crisis — which is why the change must be judged on *structure*, not on the size of the desktop diff.

Why now: the machine being migrated is the laptop, and there is no laptop host. The flake cannot install on the machine in front of the user, and every further per-host fact added without a seam makes the hybrid worse.

## Decision summary

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | Host seam shape | Explicit per-host composition + per-host Home Manager **import path**; host facts as data at the smallest scale; **no `lib/mkWorkstation.nix`**, no enable-flag machinery | See [D1](#d1-host-seam-shape) |
| 2 | Role granularity | **2 layers** (`base` + `gui`); 3 layers rejected | See [D2](#d2-role-granularity) |
| 3 | Dependency gap scope | **Out of scope**, entirely; relocated binds keep their current (dead) behaviour | See [D3](#d3-dependency-gap-scope) |
| 4 | Payload-verbatim convention | Breaks for **7 payload files**; acceptable because the laptop's *rendered output must equal today's bytes* | See [D4](#d4-payload-verbatim-convention) |
| 5 | Desktop's missing display topology | Represented as an explicit **`null` = "not captured"** + `lib.warn`; the consumer emits nothing, so Hyprland auto-detects. Never invented values | See [D5](#d5-desktop-display-topology) |
| 6 | `pkgs.tuxedo-rs` | Treated as **portable application software** for this change, explicitly *unclassified*; flips to laptop-host software if its `meta` shows vendor hardware control | See [D6](#d6-pkgs-tuxedo-rs) |
| 7 | Work units and size | **4 work units inside one PR**; ≈325 changed lines across ~18 files, close to the 400-line budget; a third machine must be a separate change | See § Work units and size risk |

## The acceptance-criterion inversion

**The pure-refactor baseline is the laptop, not the desktop.**

Today's `nixosConfigurations.desktop` = *desktop system layer* + *laptop user payload*. That evaluation **is** the laptop's configuration, because the laptop is the migration source. Therefore:

1. **The new `laptop` host must reproduce, as a sorted set, exactly what `nixosConfigurations.desktop` evaluates today** — the Home Manager `home.file` target set, and per-target content. That is the no-behaviour-change witness, and it is why the laptop host is the *first* deliverable, not a future addition.
2. **The `desktop` host legitimately diverges.** It must *lose* L1–L7, and it needs its own display topology, which exists nowhere in this repository. Its diff is expected to be **non-empty**.
3. **Trap, stated for the verify phase:** any design that compares *desktop before vs desktop after* will read a **correction as a regression**. Compare *new laptop after* against *desktop before*. The desktop diff must be compared against a written per-item expectation (L1–L7 absent), not against "unchanged".

The exploration's stricter form of the witness — copying the NVIDIA module onto the laptop so the toplevel `drvPath` matches — is **not adopted**, and this is deliberate: putting a desktop GPU module on a laptop purely to satisfy a witness would create a fabricated configuration state that then needs its own correction. The two witnesses below prove the same property without inventing state:

- **Laptop witness** (payload): HM `home.file` target-set equality + per-target content equality, laptop-after vs desktop-before.
- **Pure-move witness** (system layer): moving `hosts/desktop/gpu-nvidia.nix` into `modules/` must leave `nixosConfigurations.desktop` `system.build.toplevel.drvPath` **identical** before and after. A move that changes the derivation is a move that changed behaviour.

## Intent

- Make the laptop installable (it currently is not), as the baseline witness.
- Make "which machine am I" an explicit, reviewable input instead of an implicit habit of the payload.
- Make the desktop honest: it loses facts about hardware it does not have.
- Leave the seam cheap to extend to a third machine *later*, without designing that machine now.

## Scope

### In scope

- A `hosts/laptop/` host directory and a `nixosConfigurations.laptop` output.
- A per-host Home Manager seam (`modules/home-manager.nix`) that no longer hardcodes one import for all hosts.
- Extraction of L1–L7 into per-host, host-scoped data, consumed by shared generic code.
- Make `hosts/desktop/` externalise **nothing** of the laptop and carry its own (currently unknown) topology.
- Move `hosts/desktop/gpu-nvidia.nix` to a reusable `modules/hardware/nvidia.nix` by pure move.
- A `base` + `gui` split of the Home Manager profile.

### Out of scope — explicit non-goals

| Non-goal | Reason |
|---|---|
| Any **third machine**, and its speculative axes (hybrid GPU/bus IDs, its power policy, headless/semicapable role, different user/locale/arch) | Not defined. Do not design for an undefined machine. Any such axis is deferred, not stubbed. |
| **Power/battery management** (`tlp`, `upower`, `power-profiles-daemon`, zram, swap) | Greenfield new capability that mutates the machines. This change is architecture; the laptop's behaviour must stay identical, which forbids adding it here. |
| **Session bootstrap** (display manager, greetd, `programs.hyprland`) | Zero precedent in the tree; new capability, not a move. |
| **The dependency gap**: `cliphist`, `wl-paste`/`wl-clipboard`, `gnome-keyring-daemon`, `nautilus`, `helium`, `code`, `grim`, `slurp`, `wf-recorder`, `hyprpicker`, `jq`, `iwgtk`, `pavucontrol`, libnotify | Orthogonal to the seam; every declaration is a behaviour addition that would dirty the laptop witness. Separate, smaller change. |
| The `code` → `zed-editor` keybind correction | Same reason: `zed-editor` is declared but unbound, and `code` is undeclared. It is a one-line *behaviour* fix, so it would break the byte-equality witness on `keybinds.lua`. Recorded as follow-up. |
| **`pkgs.tuxedo-rs` classification** | Cannot be resolved without a shell (see D6). Kept portable and flagged. |
| **`nixpkgs.config.allowUnfree`** | Repo-wide fact, not host data; unverified by execution here. Separate change. |
| `home/piioni/caelestia/monitors/` (L8) cleanup | Laptop-named, content-free (`{}`), referenced by no `.nix` file — it carries no behaviour. |
| `AGENTS.md:20-21` stale reference paths, `.vscode/settings.json` `nixosConfigurations.piioni` drift | Documentation drift, unrelated to the seam. |
| Changing `references/`, adding a gate script, committing the boot stub, unit-test scaffolding, RED/GREEN evidence | Constraint of the harness and of the repository. |

## Affected areas

| Area | Files | Change |
|------|-------|--------|
| Flake topology | `flake.nix` | add `nixosConfigurations.laptop`; keep host blocks explicit |
| HM seam | `modules/home-manager.nix` | per-host import path instead of one hardcoded `import ../home/piioni` |
| New host | `hosts/laptop/{default,host,home,session}.nix` | new, ~4 files |
| Desktop host | `hosts/desktop/{default,host,home,session}.nix` | add host-scoped facts; no laptop facts |
| Hardware module | `hosts/desktop/gpu-nvidia.nix` → `modules/hardware/nvidia.nix` | pure move, content unchanged |
| Payload: monitors | `home/piioni/hypr/lua/monitors.lua` | becomes a consumer of host data (stays a real target — `require("lua.monitors")` is unconditional at `hypr/hyprland.lua:2`) |
| Payload: workspaces | `home/piioni/hypr/lua/workspaces.lua` | workspace→monitor map from host data; preserve the existing guard asymmetry (`HDMI-A-1` guarded, `eDP-1` unguarded) |
| Payload: inputs | `home/piioni/hypr/lua/inputs.lua` | touchpad block host-gated; keyboard/mouse remainder unchanged |
| Payload: gestures | `home/piioni/hypr/lua/gestures.lua` | host-gated (stays required — `hypr/hyprland.lua:8`) |
| Payload: keybinds | `home/piioni/hypr/lua/keybinds.lua` | two brightness binds host-gated |
| Payload: caelestia | `home/piioni/caelestia.nix` | battery toggle host-gated (file is already `lib.replaceStrings`-rendered) |
| Payload: btop | `home/piioni/btop.nix` | battery keys host-gated (**`.source` → `.text`** — the largest verbatim break) |
| Payload: hypr wiring | `home/piioni/hypr.nix` | the recursive `xdg.configFile."hypr/lua"` copy **conflicts** with per-file `.text` targets; this file must switch to explicit per-file entries |
| Profile layering | `home/piioni/default.nix` + new `home/piioni/base.nix`, `home/piioni/gui.nix` | 2 role layers |

## Decisions

### D1. Host seam shape

**Choice:** a per-host composition directory plus a per-host Home Manager module imported by **path**, with host facts as data at the smallest useful scale. No helper file, no `extraSpecialArgs`, no enable-flag framework.

```text
hosts/<name>/default.nix   imports: ../../modules, ./host.nix, [./home.nix], optional hardware-configuration.nix
hosts/<name>/host.nix      system identity: networking.hostName, system.stateVersion
hosts/<name>/home.nix      Home Manager: { imports = [ ../../home/piioni ../../home/piioni/base.nix ../../home/piioni/gui.nix ./session.nix ]; }
hosts/<name>/session.nix   the host-scoped facts: monitor topology, workspace→monitor map,
                           touchpad, gestures, brightness binds, battery-UI toggles, monitor data
```

Rejected alternatives, with reasons:

| Option | Verdict | Why |
|--------|---------|-----|
| A. `lib/mkWorkstation.nix` inventory helper (the `chillone` model) | **Rejected** | It exists mainly to solve *one* problem: transporting host data into Home Manager. The per-host import path solves that with zero new concepts. Against it: AGENTS.md asks for explicit values over abstraction-heavy helper layers in a beginner-facing repo, and a host inventory adds a review surface with no second benefit at 2 hosts. **The parent's earlier `lib/mkWorkstation.nix` idea is therefore deliberately not implemented.** |
| B. Explicit per-host modules, no helper | **Adopted** | Today's shape, deduplicated. Zero new concepts, `nixd`/IDE resolution unchanged, and it side-steps the hard constraint that `specialArgs` from `nixosSystem` **do not reach Home Manager modules** (`modules/home-manager.nix:9`). |
| C. Enable flags (`modules.<x>.enable`) for every axis | **Partially adopted in spirit, not in machinery** | Flags are worth their cost when a fact is known to vary *and* the axis is structural. Here the axes that vary are values (topology, touchpad on/off, battery UI), which the per-host data file expresses directly. Introducing `mkEnableOption`/`mkIf` wrappers across `modules/` would be a genuinely new surface in a repo that has none. |
| D. Defer the seam until host #2 exists | **Rejected** | The laptop is not a future host — it is the machine being migrated and the refactor's own baseline. Deferring means deferring the ability to install on the machine in front of the user. Its honest remnant is kept: **the third machine's seam is deferred.** |

**The one hard constraint this decision honours:** host data destined for the Home Manager layer must travel through `home-manager.extraSpecialArgs`, `home-manager.sharedModules`, or a per-host import *path*. This design uses the import path, which is also what the `well-done` reference does.

**What would change the answer:** a fifth host, or a host that must share data with a standalone `homeConfigurations.*` entry point. At that point the transport problem reappears three times and a helper starts paying for itself.

### D2. Role granularity

**Choice: 2 layers** — `base` (portable CLI/TUI tooling and preferences) and `gui` (graphical session payload: Hyprland, caelestia, terminal emulators, notification/portal tooling, image/screenshot tools).

Reasons:

- It gives the change's own correction a place to be expressed: the desktop's divergence is entirely a graphical-session concern, so the host-scoped facts attach to the `gui` layer while `base` stays host-independent.
- It is the cheapest seam that keeps the baseline witness intact: `base` + `gui` imported together must be equivalent to today's 20 unconditional imports, which the HM target-set snapshot proves.
- **3 layers rejected:** `tui` only becomes a real axis when a machine exists that wants TUI tools without a graphical session. No such machine is defined; the exploration itself records the headless third machine as speculative (S3) and the change's non-goals forbid designing for it.
- If a reviewer judges even the 2-layer split speculative, the fallback is a single profile with no behaviour change; **the acceptance criteria are identical either way**, because they are expressed as target-set and content equality, not as file layout.

**What would change the answer:** a third machine defined as non-graphical → include `tui`; a machine with a non-Hyprland graphical session → `gui` becomes a per-host selection rather than a universal layer.

### D3. Dependency gap scope

**Choice: entirely out of scope.** No package declarations added, no binds repaired.

- It does not change the seam design — the exploration says so explicitly, and this proposal agrees: the gap is a missing-declaration body of work, not an architecture question.
- Every repair is a **behaviour addition**, and this change's laptop witness is *byte-equality of rendered payload*. Declaring `brightnessctl` or swapping `code` → `zed-editor` would break the witness it is supposed to prove.
- The relocated L5 binds therefore **stay dead on purpose**, on every host. This is recorded debt, not hidden debt: the change moves the bind to the laptop's host-scoped keybinds and leaves the missing declaration to the follow-up.
- The gap is sizeable (7 audited tools plus a wider set of screenshot/recording/colour-picker invocations) and deserves its own review budget.

**Consequence to acknowledge:** at the end of this change, no machine's clipboard history, keyring, or brightness keys become functional. If the user's actual outcome is "the laptop's payload runs", that becomes a **prerequisite follow-up**, not part of this change — see the question round.

### D4. Payload-verbatim convention

The convention (`openspec/config.yaml`: payload is "raw migrated configuration kept verbatim") breaks for **7 files**, not one:

| File | Becomes | Verbatim cost |
|------|---------|---------------|
| `hypr/lua/monitors.lua` | rendered from host topology | high — but the laptop's rendered bytes must equal today's |
| `hypr/lua/workspaces.lua` | rendered from host workspace map | high |
| `hypr/lua/inputs.lua` | touchpad block rendered/gated | medium — one block only |
| `hypr/lua/gestures.lua` | rendered/gated | medium — tiny file |
| `hypr/lua/keybinds.lua` | two binds rendered/gated | medium — file is large, change is 2 lines |
| `caelestia/shell.json` | one more `replaceStrings` substitution | **low** — already rendered in `caelestia.nix` |
| `btop/btop.conf` | `.source` → `.text` | **highest** — currently a pure symlink to a verbatim file |

**Why this is acceptable:** the convention exists so the live `~/.config` can still be compared against the migrated payload. Rendering is only acceptable because **the laptop's rendered output must equal today's file content byte-for-byte**, which makes the comparison still possible — through the laptop host rather than through the raw file.

Three constraints the implementation must respect:

1. **Deletion is not an option.** `hypr/hyprland.lua` requires `lua.monitors` (line 2) and `lua.gestures` (line 8) unconditionally. Both target paths must keep existing.
2. **`home/piioni/hypr.nix` must change**, because the recursive `xdg.configFile."hypr/lua".source = ./hypr/lua` copy already owns `hypr/lua/monitors.lua`. Rendering that file separately is a duplicate-target conflict. The recursive copy must become explicit per-file entries producing the *same target names*.
3. **`caelestia/shell.json` is rewritten by the shell at runtime** (recorded work unit 15). Only additive `lib.replaceStrings` substitution is safe; do not restructure the file.

**Explicitly not converted:** whole files where only one key varies. `inputs.lua` keeps its keyboard and mouse settings verbatim; `keybinds.lua` keeps its ~50 other binds verbatim; `btop.conf` keeps every non-battery key verbatim.

### D5. Desktop display topology

**Choice:** the desktop's topology is represented as an explicit **`null` meaning "not captured"**, with a `lib.warn` on evaluation. The generic consumer emits no `hl.monitor` calls and no workspace→monitor pins when data is `null`, so Hyprland falls back to **compositor auto-detection** — a real, safe default rather than invented numbers.

Rejected alternatives:

| Alternative | Verdict | Why |
|---|---|---|
| Keep the current `eDP-1` + `HDMI-A-1` values for the desktop | **Rejected** | Those are laptop facts. Keeping them is inventing a topology and contradicts the entire change. |
| Invent plausible desktop values | **Rejected** | The exploration's premise is that this data exists nowhere. Fabricating it makes the tree dishonest and unreviewable. |
| Make the desktop host fail to evaluate until topology is filled | **Rejected** | It is not "loud", it is blocking: the desktop host must stay evaluable for the gate and for the drift assertion. |
| `null` + `lib.warn` + auto-detect | **Adopted** | Evaluable, honest, loud, and behaviourally safe. The warning is the visible hole. |

**What fills it:** running `hyprctl monitors` on the desktop and writing the values into `hosts/desktop/session.nix`. That is a follow-up unit of the same change or a follow-up change — see the question round.

### D6. `pkgs.tuxedo-rs`

**Choice: treat it as portable application software, and record it as explicitly unclassified.**

- `home/piioni/tuxedo.nix:3` installs `pkgs.tuxedo-rs` with `home/piioni/tuxedo/config.toml`. The config keys (`theme`, `density`, `sort = priority`, `show_left`, `show_line_num`, `show_status_bar`, `show_done`, `show_future`) read like a task/todo UI, not fan/power control.
- Two readings remain open: (a) TUXEDO-laptop vendor hardware control — which would be wrong on a Lenovo ThinkBook *and* on a desktop, making it a laptop-only fact; or (b) a TUI application unrelated to TUXEDO hardware, i.e. portable.
- **Cannot be resolved without a shell** (no way to read `pkgs.tuxedo-rs.meta` in this phase), and fabricating a classification would violate the honesty constraint. Deferring costs nothing: the tool is a single `home.packages` entry.
- **Classifying it as a form-factor marker is explicitly not accepted**, per the exploration's instruction.
- **Condition that flips the decision:** if `meta.description` names TUXEDO vendor/hardware control, it moves to `hosts/laptop/session.nix` (laptop-only software) and the `tuxedo/config.toml` payload target becomes host-scoped. Recorded as a verification item for the design phase.

## Work units and size risk

Delivery strategy for this session is **`single-pr`** with a **400 changed-line** review budget (parent-provided session preflight). Note the discrepancy, resolved in favour of the session preflight: the extension's recorded `.pi/gentle-ai/sdd-preflight.json` still shows `ask-on-risk`, because it was written before the session choices were made. **No `size:exception` is inferred or requested by this proposal.**

Four work units, ordered so each is independently gate-green and the baseline witness is established before it is perturbed:

| WU | Content | Est. lines | Witness it must hold |
|----|---------|-----------|----------------------|
| **WU1** | Pure move: `hosts/desktop/gpu-nvidia.nix` → `modules/hardware/nvidia.nix` + import line in `hosts/desktop/default.nix` | ~45 | `nixosConfigurations.desktop` `toplevel.drvPath` **identical** |
| **WU2** | Host seam + `hosts/laptop/` + `nixosConfigurations.laptop`, with the payload still carrying L1–L7 verbatim | ~70 | HM `home.file` target-set and per-target content: **laptop-after ≡ desktop-before** |
| **WU3** | Extract L1–L7 into `hosts/*/session.nix` + generic consumers (the 7-file rendering work, `hypr.nix` restructure, `base`/`gui` split) | ~150 | Same HM target set; **laptop rendered bytes ≡ pre-change file bytes** for all 7 files |
| **WU4** | Desktop divergence: `hosts/desktop/session.nix` with `null` topology, no touchpad/gestures/brightness/battery facts + per-item drift assertion | ~60 | Desktop evaluates green; desktop's L1–L7 absence matches the written expectation |

**Total ≈325 changed lines across ~18 files.** Honest reading of the size risk:

- This is **inside** the 400-line budget but with little headroom. A move counted without rename detection, or an unexpected wrinkle in the `hypr.nix` target restructure, can push it over.
- The budget is stated per-PR. If the diff crosses 400 at apply time, the correct action is to **re-ask at the size gate** (or split WU3/WU4 into a chain), never to self-grant an exception.
- **The third machine is a separate change.** Adding it (~40–120 lines: host dir, data file, HM module, flake entry) on top of this diff would breach the budget; it is also a non-goal because the machine is undefined.
- Work units are also the natural commit boundaries: each is independently reviewable and each carries its own witness. Keep WU1 separate even though it is small — it is the only unit whose system-layer witness is exact.
- **Mechanical hazard that shapes delivery:** this flake lives in Git, and **any new untracked file fails evaluation hard** (`error: Path 'modules/hardware/nvidia.nix' … is not tracked by Git`). WU1–WU4 all add files. Every evaluation must therefore go through the `rsync` working-tree copy in `openspec/config.yaml` → `testing.runner.command`, or the tree must be committed in unit-sized steps. `nix flake show` and `nixd` do **not** get that mitigation.

## Risks

| Severity | Risk | Mitigation |
|----------|------|-----------|
| **High** | **The inversion trap.** Comparing desktop-before vs desktop-after reads a correction as a regression. | Baseline is *new laptop after ≡ desktop before*. Desktop divergence is checked against a written per-item expectation (L1–L7 absent), not against "no diff". Stated in this proposal as the top risk and repeated in the acceptance criteria. |
| **High** | **Git-tracking trap.** New files are invisible to Nix until tracked; three of four work units add files. | All gates run via the `rsync` copy (which sees untracked files) or after unit-sized commits. Never claim a gate passed on a tree where a new file was untracked. |
| **High** | **Target-conflict regression in `hypr.nix`.** Replacing the recursive `hypr/lua` directory copy with per-file entries can silently change the HM target set. | The HM target-set snapshot is a mandatory acceptance criterion, taken before WU3 and re-checked after. |
| **Medium** | **Laptop byte-equality is not achievable for every fact family.** Especially `btop.conf` (`.source` → `.text`) and `caelestia/shell.json` (runtime-rewritten). | Assert content equality, not mechanism equality: target names must match exactly; `.source` vs `.text` may legitimately differ. Byte-equality is asserted on the *rendered content*. |
| **Medium** | **Desktop topology is unknown.** Every other desktop change is a subtraction; this is an addition with no source. | D5: `null` + `lib.warn` + compositor auto-detect. Never invented values. |
| **Medium** | **Guard asymmetry may be silently unified.** `workspaces.lua` guards `HDMI-A-1` with `hl.get_monitor(...) ~= nil` but uses `eDP-1` unguarded; `monitors.lua` guards nothing. L2 is the one fact that *actually breaks* on the desktop. | The generic generator must preserve both failure semantics deliberately, and the change must state which one it keeps. |
| **Medium** | **`specialArgs` → Home Manager boundary.** Getting transport wrong surfaces as an opaque "undefined variable" at eval time. | Use the per-host import path (D1), which does not cross that boundary at all. |
| **Medium** | **Dependency gap makes this change end with the payload still partly non-functional.** | Documented, not hidden (D3). Surfaced as a question-round item and as a named follow-up. |
| **Low** | **`modules/base/*` and `modules/desktop/*` are untouched**, so locale/SSH/NetworkManager/fonts cannot regress. | — |
| **Low** | **`nixfmt --check` churn** from moves and rendered files. | Format moved content intact; the check is mechanical. |
| **Latent, out of scope** | **No `nixpkgs.config.allowUnfree` exists anywhere**, while the recorded gate stub supplies it — suggesting the real desktop config would fail on the NVIDIA production package's license. | Not part of this change (repo-wide fact, unverified by execution here). Recorded as a named follow-up. |

## Rollback

The change is additive at the host level, so rollback is local and cheap:

1. **Revert the work-unit commits in reverse order.** WU4 and WU3 are the only units that touch the payload; reverting them restores the raw verbatim files and the recursive `hypr/lua` copy.
2. **WU2 removal** returns the flake to a single `nixosConfigurations.desktop` by deleting `hosts/laptop/` and restoring `modules/home-manager.nix`'s single `users.piioni = import ../home/piioni`.
3. **WU1 rollback** moves `modules/hardware/nvidia.nix` back to `hosts/desktop/gpu-nvidia.nix` and restores the import line — witnessed by `drvPath` equality, so the revert is verifiable, not hopeful.
4. **No state to unwind:** nothing is activated on any machine by this change, no `switch` is performed, no data is migrated, no secrets are introduced. Rollback risk is confined to the repository.
5. **Evidence for rollback confidence:** the recorded `home.file` target-set snapshot and the recorded `toplevel.drvPath` values from before the change. Both are cheap and both are already part of the acceptance criteria.

## Success criteria

All criteria are `openspec`-store compatible and do not require the desktop machine to be present.

- [ ] **1. HM target snapshot (strongest).** `builtins.attrNames nixosConfigurations.<host>.config.home-manager.users.piioni.home.file`, sorted, compared against a snapshot taken **before** the change. Criterion is **set equality**, never a hardcoded count — the "50" is recorded in the tree but was not reproduced in the exploration phase.
- [ ] **2. Laptop content witness.** For the **laptop**, every `home.file` target's rendered content equals the pre-change file bytes — including all of L1–L7 and including the two deliberately-dead brightness binds.
- [ ] **3. Pure-move witness.** `nixosConfigurations.desktop` `system.build.toplevel.drvPath` is **identical** before and after WU1 (via the recorded `extendModules` + boot-stub gate).
- [ ] **4. Divergence assertion.** The desktop's L1–L7 absence is asserted item-by-item against a written expectation, so accidental extra drift is visible rather than absorbed into "expected diff".
- [ ] **5. Eval gate green for every host**, via the recorded `rsync` + `extendModules` command from `openspec/config.yaml` — run for **both** `desktop` and `laptop`, not just `desktop`.
- [ ] **6. `nix flake show` succeeds and lists both hosts** (weak — does not force the toplevel, but it is the cheap flake-topology check AGENTS.md orders first).
- [ ] **7. `nixfmt --check $(git ls-files '*.nix')` exits 0** through the system-qualified `nix run .#formatter.x86_64-linux`.
- [ ] **8. Non-goals hold:** no power/session/dependency declarations were added; the laptop's *behaviour* is unchanged apart from the host seam itself.

Explicitly **not** acceptance criteria: `nix flake check` (blocked by design — `hosts/desktop/hardware-configuration.nix` is intentionally absent), `nixos-rebuild build/test/switch` (needs the machine and privileges; must be reported unverified), and any RED/GREEN cycle (`strict_tdd: false`; NixOS module evaluation is the verification surface).

## Verification honesty note

**Nothing in this proposal was executed.** There is no shell/exec tool in this phase. The eval gate, `nix flake show`, and `nixfmt --check` were **not** run here; every statement that the gate is currently green is inherited from `openspec/config.yaml` and the parent's recorded run, and is labelled as such. The line and file references above come from reading the repository, including `flake.nix`, `hosts/desktop/*`, `modules/default.nix`, `modules/desktop.nix`, `modules/home-manager.nix`, `home/piioni/default.nix`, `home/piioni/hypr.nix`, `home/piioni/hypr/hyprland.lua`, `home/piioni/hypr/lua/{monitors,workspaces,inputs,gestures,keybinds}.lua`, `home/piioni/caelestia.nix`, and `home/piioni/btop.nix`. One correction against the brief: `hyprland.lua` is at `home/piioni/hypr/hyprland.lua`, not `home/piioni/hypr/lua/hyprland.lua`. No file outside this proposal was created or modified; nothing was committed; `references/` was read only.

**Strict TDD is not applicable** (`strict_tdd: false`). No RED/GREEN evidence exists or is claimed.

## Proposal question round

No user interview was performed — the orchestrator owns product discovery, and the product decisions above were supplied as confirmed. The questions below are the product/scope unknowns that would reshape this proposal, offered for a single review round. Answering them changes the proposal; skipping them means the stated defaults stand.

**Assumptions currently in force (please confirm or correct):**

| # | Assumption | If wrong |
|---|-----------|----------|
| A1 | The laptop's host name and `system.stateVersion` are user data not present anywhere in the repo. Default until answered: `networking.hostName = "laptop"`, `system.stateVersion = "25.11"` (matching today's only value). | A wrong `stateVersion` is a silent, hard-to-detect behaviour change; the rename is a directory rename. |
| A2 | The desktop's display topology should be left un-captured (`null` + warning + auto-detect) rather than supplied now. | If the user can read `hyprctl monitors` on the desktop, WU4 fills real values and the warning disappears. |
| A3 | The desktop genuinely runs NVIDIA under Wayland today (so WU1 is a pure move and needs no new work). | If `gpu-nvidia.nix` is aspirational or untested, WU1 is not a pure move and its witness must change. |
| A4 | The dependency gap (clipboard history, keyring, brightness keys, and the unbindable `code` key) is acceptable to defer to a separate change. | If "the payload actually runs" is the real outcome the user wants, that change becomes a **prerequisite** to this one, and this change's scope shrinks to the seam only. |
| A5 | No third machine's form factor is decided yet, so no machine-specific axis is designed now. | A decision that the third machine is headless changes the role answer from 2 layers to `base`/`tui`/`gui`. |

**Questions:**

1. **Business outcome:** is the win here "I can finally install *this* machine", or "the architecture is ready for a third machine"? The answer changes whether the desktop divergence — which fixes only L2 in practice — belongs in this change at all.
2. **Desktop topology:** can you capture `hyprctl monitors` on the desktop, or should the repo carry the honest `null`/auto-detect state until then?
3. **Dependency gap as a scope boundary:** is a laptop with working brightness keys, clipboard history, and keyring part of *this* outcome, or a follow-up? (Deferring is what keeps the laptop witness byte-exact.)
4. **Third machine:** is it defined yet — graphical, headless, or semicapable? Only "headless" or "TUI-only" would justify a `tui` layer now.
5. **`tuxedo-rs`:** do you know what this tool is and whether the laptop uses it? If it is a TUXEDO vendor tool, it is a laptop fact and moves to the laptop host in this change.

# Exploration — multi-workstation architecture

- Change: `multi-workstation-architecture`
- Store: `openspec` (repo-local planning home)
- Phase: explore (notes only — no proposal, spec, design, or tasks written). **Corrective re-run** after a gatekeeper finding on §1.4 of the previous revision.
- Repo: `/home/piioni/Repos/Nixie` @ working tree (dirty, uncommitted — no file outside this artifact was modified)
- Date context: nixpkgs `56c02bc00adcf003215cc4bd996d6efaf4cff188`, home-manager `afa6821c70560bb19d1a8c577bff398f7f239869` (`flake.lock`)

---

## PREMISE CORRECTION (read before anything else)

The previous revision of this artifact concluded in §1.4 that "**the host named `desktop` is laptop-class hardware**" and framed "the planned laptop" as a *second* portable machine. **That inverted the real mapping.** The user has confirmed the opposite:

| Statement | Status |
| --- | --- |
| `hosts/desktop/` is the host definition of a **real desktop machine** — a different physical machine, not the one in front of the user | **correct** |
| The machine in front of the user is the **laptop**: Lenovo ThinkBook 14 G2 ITL | **correct** |
| `home/piioni/` (the payload) was migrated **from the laptop's live `~/.config`** | **correct** |

Both of the first two are true simultaneously, and that is exactly the defect: **the flake evaluates a desktop system layer composed with a laptop user payload.** The name `desktop` in `hosts/` names the *target* host; the payload's provenance is the *source* machine. Nothing in the tree says "this payload is the laptop's", so the conflation was invisible.

### Laptop hardware, verified by the user against the live machine

```text
Chassis:          laptop
Hardware Vendor:  Lenovo
Hardware Model:   ThinkBook 14 G2 ITL
Product version:  ThinkBook 14 G2 ITL
CPU:              11th Gen Intel Core i5-1135G7
GPU:              Intel TigerLake-LP GT2 [Iris Xe Graphics]  — ONLY this, no discrete GPU
Battery:          BAT1 (plus ACAD)
Backlight:        intel_backlight
Touchpad:         MSFT0001:01 04F3:3140 Touchpad
```

**Consequence:** the laptop needs **no GPU module at all** — Intel/Mesa is handled by default in NixOS. The NVIDIA axis (`hosts/desktop/gpu-nvidia.nix`) is **desktop-only**.

### The load-bearing corollary — acceptance-criterion inversion

**The pure-refactor baseline is the laptop, not the desktop.** The configuration the flake evaluates *today* is the laptop's configuration, because the laptop is the migration source. Full statement and its consequences are in §8. A naive "desktop before vs desktop after" diff would read a **correction** as a regression.

---

## 0. Method and verification reality (read this before trusting anything below)

What was done this pass: re-read `openspec/config.yaml`, `flake.nix`, all of `hosts/`, all of `modules/`, all 21 modules under `home/piioni/`, and **all 11 files under `home/piioni/hypr/lua/`** exhaustively, plus the payload files needed to verify and complete the laptop-only fact inventory (`caelestia/`, `btop/`, `fastfetch/`, `swaync/`, `herdr/`, `moshi/`, `zed/`, `nushell/`, `kitty/`, `swayimg/`, the three Hyprland scripts). Also re-read `odd/tasks/desktop-dotfiles-migration.md` and `odd/tasks/home-manager-shell-foundation.md` (in-repo provenance evidence for the payload).

What could **not** be done in this phase, stated honestly:

- **I still have no shell/exec tool in this phase.** I could not run the eval gate, `nix flake show`, or `nixfmt --check`. Every "gate is green" statement below is inherited from `openspec/config.yaml` (`testing.runner.command`) and the parent's recorded run (exit 0, ~9.5 s, only the pre-existing `programs.yazi.shellWrapperName` warning). **I did not reproduce it.**
- On the "**50** `home.file` targets" figure: previous revisions flagged it as unconfirmed. It is now **corroborated by recorded evidence in the tree** — `odd/tasks/desktop-dotfiles-migration.md` records the verification line `nix eval .#nixosConfigurations.desktop.config.home-manager.users.piioni.home.file --apply builtins.attrNames` → "50 unique targets and no parent/child prefix pair". My own static reading still counts roughly 42 declared-or-generated targets (20 profile modules; 13 use `xdg.configFile`; 5 configure file-writing programs), the delta being plausibly Home Manager-generated files for `ghostty`, `lazygit`, `starship`, `yazi`, `nushell`. **Treat 50 as recorded-but-not-reproduced-by-me; the acceptance criterion must snapshot the live list (§8), never hardcode the number.**

The eval gate itself is real and usable: it evaluates `system.build.toplevel.drvPath` on `nixosConfigurations.desktop.extendModules { modules = [ <boot stub> ]; }` over an `rsync` copy of the tree (`openspec/config.yaml` → `testing.runner.command`). `nix flake check` must never be used: `hosts/desktop/hardware-configuration.nix` is intentionally absent, so it dies on the `fileSystems` / `boot.loader.grub.devices` assertions.

---

## 1. Current architecture map

```text
flake.nix                     1 host, hardcoded nixosSystem block (lines 19–25); system = "x86_64-linux" (line 9)
hosts/desktop/default.nix     imports = [ ../../modules ./host.nix ./gpu-nvidia.nix ] ++ lib.optional (pathExists ./hardware-configuration.nix) …
hosts/desktop/host.nix        networking.hostName = "desktop"; system.stateVersion = "25.11"
hosts/desktop/gpu-nvidia.nix  38 lines, NVIDIA + Wayland, all overridable values via lib.mkDefault
modules/default.nix           → modules/desktop.nix → modules/base/{fonts,locale,networking,nix,packages,ssh,users}
                                                   → modules/desktop/{audio,fonts}
modules/home-manager.nix      home-manager.users.piioni = import ../home/piioni   (line 9)
home/piioni/default.nix       21 files, 20 imports unconditional; home.username = "piioni" (line 26–27)
```

There is **no** `lib/`, no `vars/`, no per-host data file, no `mkWorkstation`, and no second host directory anywhere in the tracked tree.

### Structural facts that are load-bearing for any seam

1. **`home-manager.users.piioni = import ../home/piioni`** (`modules/home-manager.nix:9`) is a single import of a *directory*, resolved via `home/piioni/default.nix`. It accepts whatever shape `default.nix` returns — currently a module function. The seam has one hard mechanical constraint here: **`specialArgs` from `nixosSystem` do not reach Home Manager modules.** Host data destined for the Home Manager layer must travel through `home-manager.extraSpecialArgs`, `home-manager.sharedModules`, or a per-host import *path*. This is the single most important constraint on the seam design and it is invisible unless you know Home Manager's module wiring.
2. **No session entry point exists in the repository.** There is no `services.displayManager.*`, no `services.greetd`, no `programs.hyprland`, no `services.xserver.enable`. Hyprland enters only as `home.packages = [ pkgs.hyprland ]` (`home/piioni/hypr.nix:3`). So "this machine is graphical" / "this machine logs in how" has **no existing expression to copy**. The role/GUI axis is real, but the repository currently has zero precedent for per-host session bootstrap.
3. **No power or form-factor configuration exists at all.** No `services.upower`, no `services.tlp`, no `services.power-profiles-daemon`, no `services.libinput`, no `hardware.bluetooth`, no zram/swap anywhere in tracked files. The TLP ↔ power-profiles-daemon mutual exclusion (parent finding 6) is therefore a **latent constraint on new work**, not a live conflict inside the current tree. **This is now urgent rather than speculative: the machine being migrated is a battery-powered laptop** (§2).

### 1.4 Two machines, two layers, one hybrid configuration *(replaces the inverted §1.4)*

- `hosts/desktop/` is the **desktop** machine's host definition.
- `home/piioni/` is the **laptop**'s live user configuration, migrated verbatim.
- `nixosConfigurations.desktop` therefore evaluates *desktop system layer* + *laptop user payload*. That hybrid is what exists today; it is the thing the refactor has to untangle.

In-repo evidence that this provenance was already known but never acted on:

- `odd/tasks/desktop-dotfiles-migration.md` goal: "Migrate the user's active **desktop** and application configuration from `~/.config`" — the word "desktop" there names the *target*, while the source machine was in fact the laptop.
- **Work unit 14 of that same file is deferred and is exactly this defect:** "Separate host-specific Hyprland monitor and workspace rules (`hypr/lua/monitors.lua`, `hypr/lua/workspaces.lua`, `caelestia/monitors/`) from the portable user layer."
- Work unit 8 already decided "keep monitor profiles out of the user layer", which is why `caelestia/monitors/` is dead payload (§1.5, L8).

Nothing in the payload text says "this is a laptop", so the conflation stayed invisible. The six-plus facts in §1.5 are the observable residue.

**Open identity (not resolved):** `home/piioni/tuxedo.nix:3` installs `pkgs.tuxedo-rs` (resolved by the migration evidence as `tuxedo-rs-0.3.1`) with `home/piioni/tuxedo/config.toml`. Two readings are both open: (a) TUXEDO-laptop vendor hardware control — which would be *wrong on a Lenovo ThinkBook* and would make it a laptop-only fact; or (b) a TUI application unrelated to TUXEDO hardware — the config keys (`theme`, `density`, `sort = priority`, `show_left`, `show_line_num`, `show_status_bar`, `show_done`, `show_future`) read like a task/todo UI, not fan/power control. I have no shell to resolve the nixpkgs attribute. **Do not classify it as a form-factor marker until the design phase confirms its identity.** Kept out of the L-table below for that reason.

### 1.5 Laptop-only facts baked into the portable user layer

These are facts that describe *the laptop* but live in `home/piioni/`, i.e. in the layer applied to **every** host. Each was verified by reading the file this pass.

| # | Fact | Location | Effect on the desktop host |
| --- | --- | --- | --- |
| L1 | `eDP-1` (internal panel) monitor mode `1920x1080@60`, position `0x0`, scale 1 | `home/piioni/hypr/lua/monitors.lua` (whole file, 12 lines) | `hl.monitor` for a non-existent output — degrades to a Hyprland warning/no-op |
| L2 | `eDP-1` in the workspace→monitor map (`local edp = "eDP-1"`; workspaces `5`,`6` pinned `default = true, persistent = true`) | `home/piioni/hypr/lua/workspaces.lua:3`, applied `:11-13` | **Hard behavioural fault**, not a no-op: workspaces 5 and 6 are permanently pinned to an output that does not exist on the desktop |
| L3 | Complete `touchpad` block (`tap_to_click`, `disable_while_typing`, `natural_scroll`, `clickfinger_behavior`) | `home/piioni/hypr/lua/inputs.lua:17-22` | no touchpad device — inert |
| L4 | Touchpad gestures for workspace switching (`fingers = 3`, horizontal, `action = "workspace"`) | `home/piioni/hypr/lua/gestures.lua` (whole file), `require`d at `home/piioni/hypr/lua/hyprland.lua:8` | no touchpad — inert |
| L5 | `XF86MonBrightnessUp` / `XF86MonBrightnessDown` bound to `brightnessctl` | `home/piioni/hypr/lua/keybinds.lua:89-90` | inert on a desktop — **and dead code on every machine, including the laptop, because `brightnessctl` is declared nowhere (§1.6)** |
| L6 | `"showBattery": true` | `home/piioni/caelestia/shell.json:32` | battery UI element with no battery — inert |
| L7 | `show_battery = true`, `selected_battery = "Auto"`, `show_battery_watts = true` | `home/piioni/btop/btop.conf:243`, `:246`, `:249` | same class as L6; degrades to a no-op when no battery is present |
| L8 | `eDP-1` and `HDMI-A-1` per-monitor profile directories named after the laptop's outputs | `home/piioni/caelestia/monitors/eDP-1/shell.json`, `home/piioni/caelestia/monitors/HDMI-A-1/shell.json` | **laptop-named but content-free (`{}`) and inert:** `caelestia.nix` copies only `cli.json` and `shell.json`; no `.nix` file anywhere references `caelestia/monitors/` (verified by grep over all `*.nix`). It carries no behaviour; it will only matter if monitor data is wired up |

Notes on the table:

- **L7 and L8 are additions found this pass**, beyond the six given in the brief. L7 is the same class of fact as L6 (laptop hardware reflected in the portable layer). L8 is included for completeness but is explicitly *not* behaviour-bearing — it is laptop-named payload, not a laptop fact currently applied.
- **L2 is the only item with a real failure mode on the desktop.** Everything else degrades to a no-op or a warning. This matters for how the divergence is argued: the desktop correction is not purely cosmetic, but only L2 proves it today.
- The previous revision's §6 observation still holds and now sits inside the corrected frame: `workspaces.lua` guards its `HDMI-A-1` usage with `hl.get_monitor(hdmi) ~= nil` while its `eDP-1` usage is unguarded, and `monitors.lua` guards nothing. A shared generator must not silently unify those two failure semantics.

**Checked and deliberately NOT listed (portable — do not pad the table with these):**

- `fastfetch/config.jsonc` `chassis` and `display` modules — runtime-detected device data, zero hardcoded host facts.
- `home/piioni/hypr/lua/inputs.lua` `kb_layout = "us"` — user keymap preference, not form factor.
- `home/piioni/hypr/lua/settings.lua` `misc.vrr = 1` — monitor-capability-adjacent, but not laptop-specific; flag only if the design wants monitor capability in host data.
- `home/piioni/btop/btop.conf:268` `shown_gpus = "nvidia amd intel apple"` — all-vendor string.
- `home/piioni/hypr/lua/keybinds.lua:85-88` `XF86Audio*` binds — keyboard-mediated media keys; present on desktops too.
- `home/piioni/hypr/lua/{animations,decorations,windowrules,programs,autostart}.lua`, `hyprland.lua`, `home/piioni/hypr/scripts/*`, `home/piioni/caelestia/cli.json`, and the `kitty`, `zed`, `zellij`, `ghostty`, `starship`, `swappy`, `swayimg`, `nushell`, `herdr`, `moshi`, `agents/` payloads — read this pass; no hardware facts found.

**Borderline, recorded but not counted (hardware-*presence* toggles, not laptop-*only*):** `shell.json:33-38` (`showBluetooth`, `showNetwork`, `showWifi`), `swaync/config.json:63` (`iwgtk` wi-fi button). Desktops may or may not have these devices, so they are a *capability* question, not a form-factor fact. Left out of L1–L8 to avoid inflating the list.

### 1.6 Referenced-but-undeclared tools (dependency gap) — kept separate from the axis analysis

These tools are referenced by the payload and declared **nowhere** in `home/`, `modules/`, or `hosts/` (verified this pass by grepping every reference and enumerating every `home.packages` / `programs.<x>.package` declaration):

| Tool | References | Declarations |
| --- | --- | --- |
| `brightnessctl` | `hypr/lua/keybinds.lua:89-90` (two binds) | 0 |
| `cliphist` | `hypr/lua/autostart.lua:4-5` | 0 |
| `wl-paste` (package `wl-clipboard`) | `hypr/lua/autostart.lua:4-5` | 0 |
| `gnome-keyring-daemon` | `hypr/lua/autostart.lua:6` | 0 |
| `nautilus` | `hypr/lua/programs.lua:5`, `caelestia/shell.json:65`, `hypr/lua/windowrules.lua:31` | 0 |
| `helium` | `hypr/lua/programs.lua:6`, `hypr/lua/keybinds.lua:52`, `hypr/scripts/helium-clean-singletons.sh` | 0 |
| `code` | `hypr/lua/programs.lua:7` | 0 |

Correctly **declared** and therefore not gaps: `mpv`, `exiftool`, `mediainfo`, `xdg-open` (`xdg-utils`) — all via `home/piioni/yazi.nix` `extraPackages`; `wpctl` — provided by the NixOS `services.pipewire` module (`modules/desktop/audio.nix`).

Two consequences worth carrying forward:

1. **L5's brightness bind is dead code on every machine, including the laptop.** The fact (a brightness key bound to a hardware action) is still laptop-only; the bind itself never worked.
2. **`code` vs `zed`:** `pkgs.zed-editor` *is* declared (`home/piioni/zed.nix:3`) but nothing binds it; the editor binding points at `code`, which is declared nowhere. So the machine has an editor installed that no keybind opens, and a keybind that opens nothing.

Corroboration and delta: `odd/tasks/desktop-dotfiles-migration.md` work unit 16 lists six of these — `helium`, `code`, `cliphist`, `wl-clipboard`, `gnome-keyring`, `nautilus`. It does **not** list `brightnessctl`, so that gap is newly identified here.

**Additional candidate gaps found while grepping (verified references; declaration enumeration over `home/` was complete, so these are genuinely undeclared too, but they are outside the brief's audited table and are reported for the design phase, not as a claim of parity):** `grim`, `slurp` (`keybinds.lua:55` screenshot bind), `wf-recorder`, `hyprpicker`, `jq` (`hypr/scripts/record.sh`, `colorpicker.sh`), `iwgtk` (`swaync/config.json:63`), `pavucontrol` (`caelestia/shell.json:62`), `notify-send`/libnotify (all three scripts). `pwvucontrol`, `nwg-look`, `xwaylandvideobridge` appear only as window *class* matches with no launcher, so they are not gaps. `uwsm` in `logout.sh` is guarded by `command -v` and is intentionally optional.

### 1.7 Payload verbatim convention tension

`openspec/config.yaml` records that `home/piioni/` keeps 77 payload files "raw migrated configuration kept verbatim". §1.5 shows the tension is **larger than one file**: up to six payload files (L1, L2, L3, L4, L5, L6/L7) would need to become host-parameterised. `home/piioni/caelestia/monitors/` (L8) is the same class of host-specific payload and was already deliberately excluded from the migration (work unit 8) — same decision, unresolved. Separately, `caelestia/shell.json` is *already* transformed via `lib.replaceStrings` in `caelestia.nix`, so parameterising L6 is mechanically feasible; but it is also a file the shell rewrites at runtime (work unit 15), which caps how much can be done there.

### 1.8 `references/` is gitignored at `.gitignore:14` *(line number corrected — the previous revision said 11)*

The vendored trees are invisible to both Nix and `git ls-files`. The flake can never import reference code; borrowing is copy-and-rewrite only. Confirmed side effect: they also never pollute the format gate.

---

## 2. Variation axes: corrected known / urgent / speculative split

*(Reshuffled. The previous revision put the whole laptop axis set under "speculative". That was wrong for the same reason §1.4 was wrong: **the laptop is not a future addition, it is the machine being migrated right now**, so its axes are known and urgent. Only the third machine's axes remain speculative.)*

### 2a. Known and urgent — the laptop axes (that machine is being migrated now)

| # | Axis | Evidence today | Status |
| --- | --- | --- | --- |
| U1 | Laptop host identity (`networking.hostName`, `system.stateVersion`) | **no laptop host exists**; only `hosts/desktop/host.nix` | must be created; the name is user data, not derivable |
| U2 | Power / battery policy | nothing anywhere: no `services.upower`, `tlp`, `power-profiles-daemon`, zram, or swap | greenfield, urgent |
| U3 | Backlight control | L5 binds exist; `brightnessctl` undeclared (§1.6) | greenfield and currently broken |
| U4 | Touchpad | L3 + L4 baked into the portable layer | must move out; currently applied to every host |
| U5 | Internal panel topology | L1 + L2 baked into the portable layer | must move out; L2 is a hard fault on the desktop |
| U6 | Battery UI | L6 + L7 baked into the portable layer | must move out or become host-gated |

These were previously labelled speculative (old S2, and part of S5/S6). They are the axes with the **strongest evidence and the nearest deadline** in the whole change.

### 2b. Known — vary per machine, independent of which machine

| # | Axis | Evidence | Varies how |
| --- | --- | --- | --- |
| K1 | Host identity | `hosts/desktop/host.nix:3-5` | `networking.hostName`, `system.stateVersion` differ per machine |
| K2 | Boot / root filesystem | `hosts/desktop/default.nix:8` optional `hardware-configuration.nix` import | already correctly per-host; the one existing seam in the repo |
| K3 | GPU / graphics vendor | `hosts/desktop/gpu-nvidia.nix:1-38` | NVIDIA is **desktop-only**; the laptop needs no module at all (Intel Iris Xe is default-handled) |
| K4 | Monitor topology | `hypr/lua/monitors.lua`, `workspaces.lua` | output names, modes, positions, workspace→monitor map; **the desktop's real topology does not exist anywhere today** |
| K5 | Display-scale / docking | `references/chillone/modules/home/system/kanshi/default.nix` shows the real-world shape (docked/undocked profiles) | not present here yet; now directly relevant because the laptop is the machine being migrated |
| K6 | Graphical vs non-graphical role | `home/piioni/default.nix:3-23` imports all 20 modules unconditionally | no per-host seam exists; §1.2 (no session entry point) applies |
| K7 | System architecture | `flake.nix:9` `system = "x86_64-linux"` | currently single-valued; parameterising is ~3 lines |
| K8 | User account | `modules/base/users.nix:3`, `modules/home-manager.nix:9`, `home/piioni/default.nix:26-27` | single user `piioni`, hardcoded in 3 places |
| K9 | Locale / keymap / timezone | `modules/base/locale.nix` (`Europe/Madrid`, `es_ES.UTF-8`, `console.keyMap = "es"`) | plausibly constant; keymap is the only credible per-machine candidate |

### 2c. Speculative — the third machine only (label every one of these as invented)

- **S1 GPU is hybrid, not discrete.** Undetermined for the *third* machine; note that for the laptop this is now **settled and negative** (Intel only, no discrete GPU). If the third machine were hybrid, `nixos/modules/hardware/video/nvidia.nix` (~lines 519-553) asserts on `intelBusId` / `amdgpuBusId` and conflicts between `sync` and `offload`, so **bus IDs would become mandatory host data**.
- **S2 The third machine's power policy.** Laptop vs desktop implies TLP *or* power-profiles-daemon, never both (`tlp.nix:90`, `power-profiles-daemon.nix:41`). Which one is authoritative is per-host. (The laptop half of this axis has moved to U2; only the third machine's half stays speculative.)
- **S3 The third machine may be headless or semicapable.** Undefined; this is the axis that motivates K6, and it is the least evidenced.
- **S4 Different user / locale / arch.** No evidence; cheap to leave open, expensive to pre-build.
- **S5 `tuxedo-rs` identity.** See §1.4 — unresolved, and deliberately kept out of the fact table.
- **S6 Monitor data may need docking profiles, not a flat list.** `chillone` shows a laptop user with two profiles (docked/undocked) — now plausible for the **laptop** (which genuinely docks/undocks), unproven.

**Guiding principle confirmed:** a module should be created when a **fact varies independently**, not when a file grows long. Applied here, that endorses moving NVIDIA (K3) and monitor data (K4/K5), splitting the profile by role (K6), and — new since the correction — extracting the laptop facts U4-U6 out of the portable payload. It still argues *against* splitting `modules/base/` further or pre-building S1-S4 machinery for the undefined third machine.

---

## 3. What must move, what must stay

*(Re-checked against the corrected premise. The one substantive change is that the "must move" set is no longer just monitor topology — it is the whole laptop fact set from §1.5.)*

**Must move (cross-host facts currently stored in the wrong layer):**

- `hosts/desktop/gpu-nvidia.nix` → a shared hardware module. It is 38 lines of pure NVIDIA/Wayland support, already `mkDefault`-based (`hosts/desktop/gpu-nvidia.nix:19-35`), i.e. authored for overriding. Its only host-specific aspect (whether NVIDIA is present) is a *selector*, not the body. **The laptop simply does not import it.**
- Monitor topology (L1/L2, K4) out of the Home Manager payload into per-host data, consumed by a generic `monitors.lua` (or an equivalent Hyprland-level mechanism). The specific shape is a design question. Constraint: `require("lua.monitors")` at `hyprland.lua:2`, and `require("lua.gestures")` at `hyprland.lua:8`, are unconditional — deletion is not an option; the require targets must keep resolving.
- The touchpad block (L3) and gestures (L4) out of `inputs.lua` / `gestures.lua` into host-scoped data or a laptop-only layer. Note the *rest* of `inputs.lua` (kb_layout, mouse sensitivity/accel, follow_mouse, numlock) is portable and must stay.
- The brightness binds (L5) out of `keybinds.lua` — the two `XF86MonBrightness*` lines only; every other bind in that file is portable.
- The battery UI toggles (L6, L7) out of `caelestia/shell.json` and `btop/btop.conf` into host-scoped data or a laptop-only layer.
- Host data (K1 + the U-axis values and eventual S1/S2 values) into a per-host data file, so the composition stops being the place where facts live.
- The composition shape itself (`hosts/*/default.nix`, `flake.nix:19-25`) so host #2 and #3 do not re-copy it.

**Should stay put:**

- `modules/base/*` and `modules/desktop/*` — already narrow, single-concern, and orthogonal; none of them encodes a host fact. Splitting them further would be splitting for file length, not for variation.
- The `home/piioni/<tool>.nix` tool-per-file layout. Both references organize *by tool* at the module level too (`chillone/modules/home/programs/<tool>/`, `well-done/home/base/core/<tool>.nix`); the disagreement between them is about **profile layering**, not about tool granularity.
- The `lib.optional (builtins.pathExists ./hardware-configuration.nix)` pattern (K2). It is correct, already per-host, and should be the precedent for other optional host facts.
- The payload files themselves, apart from the specific lines in L1-L7. In particular, do **not** convert whole files when only one key (L6) or one block (L3) varies.
- `hypr/lua/inputs.lua`'s keyboard/mouse settings, `keybinds.lua`'s 50-odd other binds, and everything flagged portable in §1.5.

---

## 4. Structural approaches for the host seam (tradeoffs)

### A. Inventory + helper (`lib/mkWorkstation.nix`) — the `chillone` model

`flake.nix` holds `{ desktop = { system; path; homes = [ "base" "gui" ]; }; … }`; a helper maps entries through `nixpkgs.lib.nixosSystem` and injects `specialArgs.host`; each host dir has `default.nix` + `vars.nix` + `hardware.nix`; profiles are separate files imported by name into the Home Manager layer.

- **Pros:** one place to add a host; host data is *data*, not code; `specialArgs.host` gives every module the same vocabulary; the Home Manager layer gets host data through `extraSpecialArgs` in a standalone `homeManagerConfiguration` — the transport problem is solved once, in the helper.
- **Cons:** introduces the abstraction layer AGENTS.md explicitly warns against ("prefer explicit values over abstraction-heavy helper layers"); adds a second configuration entry point (`homeConfigurations.*`) if you follow chillone fully; indirection makes plain-text reasoning harder for a learning repo.
- **Evidence:** `references/chillone/lib/bootstrap.nix` (`mkHost`, `specialArgs = { inherit host … }`, `extraSpecialArgs = { inherit host … }`), `references/chillone/hosts/ryo/vars.nix`, `references/chillone/homes/{default,minimal}.nix`.
- **Re-check vs corrected premise:** the helper's value rises slightly, because the host data to transport is now the whole U-axis set (identity, panel topology, touchpad, backlight, battery), not just monitor blocks. One transport mechanism for all of it is more attractive than six ad-hoc paths.

### B. Explicit per-host modules, no helper — today's shape, deduplicated

Keep one `nixosSystem` block per host in `flake.nix` (3 blocks total), each importing the same `modules/` tree, with the varying facts extracted into per-host data modules and a per-host Home Manager module selected by *path*.

- **Pros:** zero new concepts; matches the existing repo style and AGENTS.md's "explicit over abstract"; `nixd`/IDE resolution keeps working unchanged; side-steps the `specialArgs` vs `extraSpecialArgs` question entirely, because host data reaches Home Manager through the import path (`users.piioni = { imports = [ ../home/piioni <host-home>.nix ]; }`), exactly as `well-done` does with `home/hosts/linux/<name>.nix`.
- **Cons:** `flake.nix` grows ~12 lines per host; a fact that must be consistent across hosts (e.g. NVIDIA defaults) is still shared only by module import, which is fine, but there is no single inventory to review; adding a host is a 3-file-plus-flake edit with no template.
- **Evidence:** `references/well-done/outputs/x86_64-linux/src/idols-ai.nix` (per-host module list + `home/hosts/linux/idols-ai.nix`), `references/well-done/home/base/core/default.nix` (`mylib.scanPaths`).

### C. Option flags instead of roles — the `well-done` model

One shared `imports = [ ../../modules ]` for every host; hosts become thin modules setting `modules.<x>.enable = true;`; shared options gate the corresponding bodies.

- **Pros:** host files become ~10 lines of data/flags; axes are explicit and greppable; scales cleanly past 3 hosts; a missing flag is a lazy evaluation no-op rather than a missing behaviour; the laptop axes (U2-U6: touchpad, backlight, battery-UI, panel) and the eventual hybrid-GPU/power axes fit naturally as flags.
- **Cons:** requires authoring `mkEnableOption`/`mkIf` wrappers — a genuinely new surface in a repo that has none; makes *this repo's* modules more abstract than they are today; risks the "over-splitting" the user warned about if every module gets a flag. It is in tension with the payload-verbatim convention, because flag-gating a block inside a `.lua`/`.json` payload file still requires generating that file's text.
- **Evidence:** `references/well-done/home/linux/gui/base/nvidia.nix` (`options.modules.desktop.nvidia.enable` + `mkIf`), `references/well-done/outputs/x86_64-linux/src/idols-ai.nix` (flags set per host), `references/chillone/modules/nixos/nvidia.nix` (a plain shared module — no flag — the simpler alternative).

### D. Defer the seam until host #2 exists

Keep one `nixosSystem` block; do only the *fact extraction* that is host-independent and add the composition seam when a second machine actually lands.

- **Pros:** smallest diff; no speculative schema for an undefined third machine (S1-S4 all stay open); the pure-refactor acceptance criterion (§8) is easiest to prove when nothing about the topology changes; reduces review surface now.
- **Cons:** the correction has **already reordered this** — the laptop host is not a future addition, it is the machine in front of the user (see §8, sequencing). Option D as originally written ("defer until host #2 exists") now means *deferring the ability to install on the machine you are sitting at*. Its remaining honest form is narrower: extract the laptop facts now, add the third-machine seam later.
- **Evidence:** parents' own findings; `chillone` and `well-done` both demonstrate that the seam costs few lines *once the vocabulary is chosen*, but that choosing the vocabulary is the expensive part.

**Reading of the tradeoffs:** A and C both solve the transport problem cleanly but pay in abstraction that AGENTS.md discourages at this repo's size. B and D pay in repetition but cost nothing conceptually. The cheapest *honest* combination for 2-3 machines is B's transport mechanism (per-host Home Manager import path — no `extraSpecialArgs` needed, matching `well-done`) applied to A's "facts are data" idea at the smallest possible scale (a per-host attrs file, no helper file), with C's flags reserved only for axes that are already known to vary (GUI role, NVIDIA presence, and now the U-axis laptop facts) and **not** pre-built for the third machine's S1-S4. This is a recommendation for the design phase, not a decision — and it is explicitly *not* the parent's planned `lib/mkWorkstation.nix` shape, which should be weighed against it rather than assumed.

---

## 5. Cost estimate (files moved / created / rewritten)

*(Revised upward: the fact set is now the whole laptop inventory, not just monitor topology.)*

Laptop-fact extraction, with the laptop host introduced as the baseline:

- 1 new host dir: `hosts/laptop/{default.nix,host.nix}` (name TBD; U1) (~15 lines)
- 1 move: `hosts/desktop/gpu-nvidia.nix` → `modules/hardware/nvidia.nix` (~40 lines, 1 import line changed in `hosts/desktop/default.nix`; the laptop simply does not import it)
- 1 new: per-host data file (host name, stateVersion, monitor outputs/modes/positions, touchpad block, brightness binds enabled, battery-UI toggles) (~30-45 lines now, was ~20)
- 1 new: generic Hyprland monitor consumer + 2 rewrites (`hypr/lua/monitors.lua` becomes a consumer, `hyprland.lua`/`workspaces.lua` rewrites) (~25 lines)
- 1 rewrite: `home/piioni/hypr/lua/inputs.lua` to source the touchpad block from host data (or gate it) (~10 lines changed)
- 1 rewrite: `home/piioni/hypr/lua/gestures.lua` similarly (or its `require` becomes host-scoped) (~10 lines)
- 1 rewrite: `home/piioni/hypr/lua/keybinds.lua` brightness binds (~5 lines)
- 1 rewrite: `home/piioni/caelestia/shell.json` / `caelestia.nix` for L6 (~5-20 lines, and capped by the runtime-write caveat)
- 1 rewrite: `home/piioni/btop/btop.conf` / `btop.nix` for L7 (~5-20 lines)
- 1 rewrite: `home/piioni/default.nix` split into profile layers (~+30 lines net)
- 1 rewrite: `modules/home-manager.nix` for the per-host seam (~+7 lines)
- 1 rewrite: `flake.nix` for the host seam (~+15 lines)
- 1 rewrite: `hosts/desktop/default.nix`, `hosts/desktop/host.nix` (~+10 lines)
- **≈ 200-280 changed lines across ~14 files.** *(Previous estimate: 160-220 across ~10.)*

Adding the second/third machine: +40-120 lines each (host dir, data file, per-host Home Manager module, flake entry).

**Total for the full 2-3 machine target: ≈ 300-450 changed lines**, and the laptop-fact portion alone now sits close to the 400-line review budget (`openspec/config.yaml` context, review budget rule). Concrete implication for delivery: split into chained work units — (1) extract the laptop facts, (2) add the laptop host as the baseline witness, (3) flip the desktop to its own data, (4) add any third machine — each independently gate-able. Whichever split is chosen, `ask-on-risk` applies at the size gate; I am not deciding chain strategy here.

---

## 6. Risk profile

**High**

- **The inversion trap (new, and the reason for this re-run).** Because the flake evaluates *desktop system layer + laptop payload*, a pure-refactor change moves the laptop facts **out of the desktop host's evaluation** — which is a *correction*, but looks identical to a *regression* in any naive "desktop before vs desktop after" diff. Comparing the wrong pair is the single most likely way the proposal and verify phases go wrong. The correct pair is: **new laptop host after ≡ desktop before** (set equality), and the desktop diff is expected to be non-empty. See §8.
- **Git-tracking trap, twice.** The flake lives in Git: modifying a tracked file is visible to `nix eval` (dirty-tree warning), but *any new untracked file fails evaluation hard* (`error: Path 'modules/hardware/nvidia.nix' … is not tracked by Git`). The refactor necessarily creates new files, so it must be applied in commit-sized steps or always evaluated via the `rsync` gate. `nix flake show` and interactive `nixd` do **not** get the rsync mitigation.
- **Cross-boundary moves.** `hosts/desktop/gpu-nvidia.nix` is currently imported as `./gpu-nvidia.nix` from a host-local path (`hosts/desktop/default.nix:6`). Moving it changes the import path *and* the argument surface it can see (a `modules/` file can no longer assume host-local siblings). With `mkDefault` already in place the semantics survive, but the move must be validated by the eval gate, not by eye.

**Medium**

- **Home Manager module-argument boundary** (§1.1). Choosing `extraSpecialArgs` vs a per-host import path is a one-way-ish design cost; getting it wrong shows up as an opaque "undefined variable" at eval time. The corrected fact set makes this more load-bearing, not less.
- **Behaviour drift in the profile split.** The 42-50 `home.file` targets are the only cheap, complete witness of "the profile still does exactly what it did". Splitting `home/piioni/default.nix` while keeping the payload verbatim must leave the target list identical.
- **The desktop's real display topology does not exist anywhere today.** Unlike every other fact, it cannot be extracted from the tree — there is no data to move, only a hole to fill. Adding the desktop host properly therefore needs that machine (or explicit user-provided values). Any invention here is speculative (S6).
- **Six payload files become host-parameterised.** L1-L7 touch `monitors.lua`, `workspaces.lua`, `inputs.lua`, `gestures.lua`, `keybinds.lua`, `caelestia/shell.json`, `btop/btop.conf`. That is a material step away from the payload-verbatim convention (§1.7), versus the single-file change the previous revision assumed.
- **Different failure semantics across the two files.** `workspaces.lua` guards `HDMI-A-1` with `hl.get_monitor(hdmi) ~= nil` but uses `eDP-1` unguarded; `monitors.lua` guards nothing. A shared generator must not silently unify them, and L2 (unguarded `eDP-1` workspace pinning) is the one fact that *actually breaks* on the desktop.
- **Untestable non-current hosts.** A host without `hardware-configuration.nix` can be *evaluated* (optional import + boot stub) but never *built*; "verification" for the desktop after the flip stops at evaluation.

**Low**

- **`modules/base/*` untouched**, so locale/SSH/NetworkManager/fonts behaviour cannot regress.
- **`nixfmt --check`** is mechanical; a pure move stays formatted if the content is moved intact.

**Latent, worth flagging but out of scope for the refactor:**

- **No `nixpkgs.config.allowUnfree` exists anywhere in the tracked tree**, while the recorded gate stub explicitly supplies `nixpkgs.config.allowUnfree = true` (`openspec/config.yaml`, both `apply.test_command` and `verify.test_command`). That strongly suggests the stub is *required* for the NVIDIA production package to evaluate, i.e. the real `nixosConfigurations.desktop` would fail with an unfree-license error on the actual machine. This is a repo-wide fact (not host data) and should be set once (flake-level or base layer) — but it is **not verified by execution in this phase** (no shell), so treat it as a high-confidence hypothesis to confirm at apply time, not as established fact.
- **The dependency gap in §1.6** is a real body of missing declarations (7+ tools, several of them invoked on every session start). It is deliberately kept out of the axis/modularization analysis: it does not change the seam design, but it does mean the payload currently references behaviour that cannot run.

**Documentation drift found (not to be fixed here):**

- `AGENTS.md:20-21` points at `references/peachy-nixos/` and `references/ryan-nixos/`; the vendored trees are actually `references/chillone/` and `references/well-done/`. AGENTS.md is declared authoritative, so this misdirection is active.
- `.vscode/settings.json` targets `nixosConfigurations.piioni.options`, a configuration that does not exist (`.zed/settings.json` correctly targets `desktop`). Already recorded in `openspec/config.yaml`; a multi-host flake gives a natural fix point.

---

## 7. Reference-configuration evidence (used as evidence, never as template)

`references/` is gitignored vendored material and must never be an edit target.

- **`chillone`** (small: ~33 `.nix` files, 2 hosts, laptop + server): inventory in `flake.nix`, one helper (`lib/bootstrap.nix`) that does `nixosSystem`/`darwinSystem` + `homeManagerConfiguration`, per-host `vars.nix` as pure data, profiles as named files (`homes/default.nix` vs `homes/minimal.nix`) imported by name. Shows the seam at the **minimum viable scale** for 2-3 machines, and shows that the helper exists mainly to solve the `specialArgs`/`extraSpecialArgs` transport problem once. Also shows an honest monitor-data solution for a laptop: `kanshi` docked/undocked profiles as a `home/system` concern — **now directly relevant, since the laptop is the machine being migrated** (U5, S6).
- **`well-done`** (large: ~270 `.nix` files across macOS + Linux): Home Manager organized platform × role (`home/base/{core,tui,gui}`, `home/linux/`, `home/darwin/`), hosts as thin modules setting enable-flags, and per-host hardware data as a file symlinked out-of-store (`home/hosts/linux/idols-ai.nix` → `mkOutOfStoreSymlink "…/hosts/idols-ai/niri-hardware.kdl"`). Shows what the flag/profile organization looks like at 10+ hosts — and shows that a comparable host count here does not justify that machinery. Also worth noting: it keeps `nixos/`-level module options for hardware (`modules.desktop.nvidia.enable`) while `chillone` keeps NVIDIA as a plain unconditional module; both work, the difference is host count.

Scale lesson: the *tool-per-file* layout that both references use at every scale already matches `home/piioni/<tool>.nix`. The only thing that changes with scale is **profile layering** (single profile → role profiles → platform × role) and **how host data is transported**. At 3 machines, role profiles are justified; platform × role is not.

---

## 8. Acceptance criteria for a pure refactor — and the inversion that governs them

### 8.1 The inversion (statement of record)

**The pure-refactor baseline is the laptop, not the desktop.** Today `nixosConfigurations.desktop` evaluates *desktop system layer + laptop user payload*; that evaluation **is** the laptop's configuration. Therefore:

1. A new **laptop** host must reproduce, as a sorted set, exactly what `nixosConfigurations.desktop` evaluates today — **including all of §1.5, L1-L7**, and including today's NVIDIA module, even though the laptop has no discrete GPU. That is the "no behaviour change" witness. The NVIDIA presence in the baseline is not a mistake to fix inside the witness; dropping it is part of the *correction* step, which is a different change.
2. The **desktop** host legitimately diverges: it must *lose* all of L1-L7, and it needs its own display topology, which **does not exist anywhere today** (unknown — presumably to be filled when that machine is at hand).
3. **Trap to state explicitly for proposal and verify:** a naive "desktop before vs desktop after" diff would misread this **correction** as a **regression**. Compare *new laptop after* against *desktop before*; expect the desktop diff to be non-empty and *intended*.

### 8.2 Sequencing consequence

The machine actually being migrated is the **laptop**, but the repository has **no laptop host** — so today's tree cannot install on the machine in front of the user at all. This **reorders the work** relative to the parent's plan (which treated the laptop as a future second machine):

1. **Laptop host first** — it is simultaneously the migration target and the refactor baseline witness.
2. Then split the laptop facts (§1.5) into host data.
3. **Desktop host second** — it is the *divergence*, and it additionally needs real display topology that the repo does not contain.
4. Third machine last, if ever.

### 8.3 Criteria, ranked strongest to weakest

All are `openspec`-store-compatible; none requires the desktop machine.

1. **Home Manager target snapshot (strongest, cheapest).** Evaluate `builtins.attrNames nixosConfigurations.desktop.config.home-manager.users.piioni.home.file`, sort it, and diff against a snapshot taken *before* the refactor. The criterion is **set equality**, not a hardcoded count — the "50" is recorded (see §0) but not reproduced by me. Strongest form: also compare `home.file.<target>.source`/`.text` per target.
2. **Cross-host toplevel witness (the inversion made testable).** Record `system.build.toplevel.drvPath` for the **new laptop host after** and for **`desktop` before**, using the recorded gate command with the boot stub. **Equality proves the pure-refactor witness.** Caveat: only meaningful if the change is a pure move; any content change (e.g. generated `monitors.lua` text) legitimately alters it, in which case fall back to criterion 1 plus a diff of the rendered Lua.
3. **Eval gate stays green** for the changed tree via the recorded `rsync` + `extendModules` command (`openspec/config.yaml` → `testing.runner.command`), run for **every** host, not just `desktop`. Inherited as green today (for `desktop` only); must be re-run in apply/verify.
4. **The desktop's divergence is asserted, not assumed** — the intended desktop diff (L1-L7 absent, own topology present) is written down and checked per item, so an accidental extra drift is visible rather than absorbed.
5. **`nixfmt --check $(git ls-files '*.nix')` exits 0** via `nix run .#formatter.x86_64-linux` (the system-qualified form is required — the bare `.#formatter` fails).
6. **`nix flake show`** succeeds and lists all hosts. Weak (does not force the toplevel), but it is the only cheap check that the *flake topology* is sane, and it is the one AGENTS.md orders first.

Explicitly **not** acceptance criteria: `nix flake check` (blocked by design), `nixos-rebuild build/test/switch` (requires the machine and privileges; must be reported unverified), and any RED/GREEN cycle (`strict_tdd: false`; NixOS module configuration has no unit-test cycle — the eval gate is the verification surface).

---

## 9. Open questions for the design phase (not answered here)

1. Transport for host data into Home Manager: `home-manager.extraSpecialArgs` vs a per-host Home Manager module imported by path (the `well-done` route). The repo's answer determines whether a `host` argument becomes ambient — and it now has to carry seven fact families, not one.
2. Monitor host data shape: per-host attrset rendered to Lua, vs a per-host Lua fragment, vs Hyprland-level `kanshi`-style profiles. Bound by "must keep satisfying `require("lua.monitors")` and `require("lua.gestures")`" and by the payload-verbatim convention.
3. **Is the seam built now (A/B/C) or deferred (D)?** Now that the laptop is the machine being migrated, D's scope has narrowed: extract the laptop facts now, defer only the third machine's seam.
4. **What is the laptop host called**, and what is its `system.stateVersion` / `networking.hostName`? This is user data that no file in the repo contains.
5. **How does the desktop's display topology get filled** — user-provided now, or deferred until that machine is at hand? Everything else in the desktop divergence is a subtraction; this one is an addition with no source.
6. Role granularity: 2 profiles (base/gui) or 3 (base/tui/gui)? `well-done` distinguishes TUI from GUI; is any of the machines headless-with-tools (which would make `tui` a real axis) or is that speculation?
7. L6/L7 placement: host data, a laptop-only profile layer, or a flag? Note `caelestia/shell.json` is rewritten by the shell at runtime (work unit 15), which caps the options.
8. **What is `pkgs.tuxedo-rs` actually** (§1.4), and does it belong in a role profile, host-specific software, or nowhere — given the source machine is a Lenovo ThinkBook and neither machine is stated to be a TUXEDO?
9. Does `nixpkgs.config.allowUnfree` need to be introduced as a repo-wide fact (§6)? If yes, is that part of this refactor or a separate, smaller change?
10. How is the work split so each unit fits the 400-line review budget and each unit is gate-green on its own (the Git-tracking trap makes mid-unit states evaluable only through the rsync gate)? The revised §5 estimate makes this sharper.

---

## 10. Findings that extend or adjust the parent's brief

- Parent findings 2, 3, 4, 5 and the Git/rsync/gate findings (9-11) were **verified and stand**. Parent findings 1, 6, 7 were not re-derived (they are consistent with what I read; nixpkgs assertions were trusted from the parent and `openspec/config.yaml`).
- **CORRECTION (this re-run):** the previous revision's addition "`desktop` is laptop-class hardware (`eDP-1` + `tuxedo-rs`), which changes the framing of 'the planned laptop'" was **wrong** and is retracted. `desktop` is a real desktop machine; the ThinkBook is the laptop; the payload came from the laptop. The eDP-1 evidence was correct *as payload evidence* and wrong *as host evidence* — that conflation is the defect.
- **CORRECTION (this re-run):** the acceptance criterion is **inverted** — the pure-refactor baseline is the laptop (§8.1). Sequencing is reordered: the laptop host is the first deliverable, not a future addition (§8.2).
- **Addition:** the laptop needs **no GPU module at all** (Intel Iris Xe is default-handled); NVIDIA is desktop-only.
- **Addition:** the fact inventory is **larger than the six given** — L7 (`btop` battery UI) is a genuine laptop-only fact of the same class as L6; L8 (`caelestia/monitors/`, laptop-named, content-free, inert) is recorded but explicitly not behaviour-bearing. The list was checked exhaustively across `hypr/lua/` and the rest of the payload, and the portable candidates were deliberately dropped (see §1.5).
- **Addition:** the `specialArgs` → Home Manager boundary constraint (§1.1) is a hard mechanical constraint the brief did not mention and it shaped the entire §4 comparison.
- **Addition:** there is no session entry point and no power configuration anywhere in the tree (§1.2, §1.3) — so the power/role axes are not "pre-existing conflicts to resolve", they are greenfield with zero precedent. This is now urgent, not speculative.
- **Addition:** `monitors.lua` and `gestures.lua` are both `require`d unconditionally by `hyprland.lua`, so "make these host data" cannot be satisfied by deletion.
- **Addition:** of all the laptop facts, **only L2 has a real failure mode on the desktop** (workspaces 5-6 pinned to a non-existent `eDP-1`); the rest degrade to no-ops or warnings.
- **Addition:** the dependency gap (§1.6) makes L5's brightness bind dead code on **every** machine, including the laptop. The gap list is corroborated by `odd/tasks/desktop-dotfiles-migration.md` work unit 16, which lists six of the seven tools; `brightnessctl` is newly identified here.
- **Addition:** `home/piioni/tuxedo.nix` installs a tool whose identity I could not resolve without a shell; the config shape does not look like vendor hardware control. Flagged, not classified.
- **Adjustment/uncertainty:** the "50 `home.file` targets" figure is now corroborated by recorded evidence in `odd/tasks/desktop-dotfiles-migration.md`; make the criterion a snapshot, not a number (§0).
- **Adjustment:** `.gitignore` line for `references/` is 14, not 11 (§1.8).
- **Addition:** the dependency gap is bigger than the audited table (screenshot/recording/colour-picker tooling is also undeclared); reported as candidates, not as parity (§1.6).

---

## 11. Explicit non-goals of this phase

No proposal, spec, design, or tasks were written. No file outside `openspec/changes/multi-workstation-architecture/` was created or modified. `references/` was read only. No `lib/mkWorkstation.nix`, no `modules/hardware/nvidia.nix`, no gate script. Nothing was committed. No file was created for the laptop host or for `tuxedo-rs`.

**Strict TDD remains not applicable** (`strict_tdd: false`) and **no RED/GREEN evidence was fabricated**: NixOS module configuration has no unit-test cycle and the eval gate is the verification surface. **No shell/exec tool was available in this phase**, so the eval gate, `nix flake show`, and `nixfmt --check` were **not** run by me; every gate statement above is inherited from `openspec/config.yaml` and the parent's recorded run.


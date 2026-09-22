# Design — host seam, host-scoped payload facts, reusable NVIDIA module

The change lands as a **second host** (`hosts/laptop/`) plus a **per-host Home Manager import path**, four
declared **host facts** (`display`, `touchpad`, `brightnessKeys`, `batteryUi`) consumed by host-agnostic
payload code, a **pure move** of NVIDIA support into `modules/hardware/nvidia.nix`, and a **two-layer role
split** (`base` + `gui`). The payload's *rendered* output on the migrated-from machine stays byte-identical;
the desktop deliberately loses the laptop facts and carries an explicit `null` topology that warns instead
of inventing values.

- Change: `multi-workstation-architecture`
- Store: `openspec` — this artifact is `openspec/changes/multi-workstation-architecture/design.md`
- Phase: design (no tasks, no implementation)
- Inputs read: `proposal.md`, `specs/{host-composition,home-payload,hardware-modules}/spec.md`,
  `exploration.md`, `openspec/config.yaml`, and the live tree (`flake.nix`, `hosts/desktop/*`, `modules/*`,
  `home/piioni/*`, `home/piioni/hypr/lua/*`), plus Home Manager's own `modules/files.nix`,
  `modules/lib/file-type.nix`, `modules/misc/xdg.nix` from the pinned input in `/nix/store`.
- **Nothing here was executed.** No shell, no eval, no build, no format check. Every command below is
  labelled as unverified and is derived from the recorded gate in `openspec/config.yaml`.

## Review path

1. **§2 The oracle** — why "before" means *desktop-before* and the payload oracle is the *materialised* tree.
   Everything else depends on this.
2. **§6 `hypr.nix` ownership** — the one place this change can silently corrupt the payload.
3. **§7 Rendering** — the seven files, and which two of them are *not* byte-structural.
4. **§9 Witness capture** — what must be recorded *before* the first payload edit.
5. The rest is detail: layout, seam code, role split, per-unit gates, decisions, risks.

---

## 1. Invariants this design serves

| # | Invariant | Consequence |
|---|-----------|-------------|
| I1 | The refactor baseline is **the laptop**: today's `nixosConfigurations.desktop` = desktop system layer + laptop payload, and that evaluation *is* the migrated-from configuration | `laptop-after ≡ desktop-before` at the payload layer. This is the only regression witness |
| I2 | The desktop legitimately **diverges**: it loses every laptop-only fact and its display topology exists nowhere in the repository | A non-empty, *itemised* desktop diff is a correction. Never "unchanged" |

Scope is settled: no third machine, no power/battery services, no session entry point, no new package
declarations, no `code` → `zed-editor` repair, no `hardware-configuration.nix` for any host. The relocated
brightness binds stay deliberately dead and recorded as debt.

---

## 2. The witness oracle

**The oracle is the pre-change *materialised* Home Manager payload, not the raw payload files.**

Three reasons, each verified by reading the pinned Home Manager source:

1. `xdg.configFile.<n>` is merged into `home.file` under the key `"${xdg.configHome}/<n>"`
   (`modules/misc/xdg.nix`), whose `target` has the home directory prefix stripped
   (`modules/lib/file-type.nix`). A **directory** entry written with `recursive = true` is **one** `home.file`
   entry — not one per leaf.
2. `config.home-files` (`modules/files.nix`) is the derivation that actually materialises the payload:
   files are symlinked, recursive directories are expanded with `lndir`. Comparing *its* output is
   mechanism-independent and is the only comparison that means "the same things land in `$HOME` with the
   same bytes".
3. Two targets are **already rendered today** (`caelestia/shell.json` and `herdr/config.toml` go through
   `lib.replaceStrings`). Comparing rendered output against a raw payload file would fail on both, for the
   pre-change tree. The materialised tree has no such trap.

The system-layer witness is separate and narrower: `system.build.toplevel.drvPath` equality is claimed
**only** for the pure move (WU1), never for the payload work.

---

## 3. File layout after the change

```text
flake.nix                                  two explicit nixosSystem blocks (desktop, laptop)
modules/
  default.nix                              unchanged  (base + desktop composition)
  home-manager.nix                         enables HM; no longer declares users.piioni
  base/*, desktop/*                        unchanged
  hardware/nvidia.nix                      MOVED verbatim from hosts/desktop/gpu-nvidia.nix
hosts/
  desktop/
    default.nix                            imports: ../../modules, ./host.nix, ./home.nix,
                                                     ../../modules/hardware/nvidia.nix, optional hardware-config
    host.nix                               networking.hostName = "desktop"; system.stateVersion
    home.nix                               HM seam: imports payload + roles + ./facts.nix
    facts.nix                              host facts: display = null, no touchpad/gestures/brightness/battery
  laptop/                                  NEW
    default.nix                            imports: ../../modules, ./host.nix, ./home.nix, optional hardware-config
    host.nix                               networking.hostName = "laptop"; system.stateVersion = "25.11"
    home.nix                               HM seam: imports payload + roles + ./facts.nix
    facts.nix                              host facts: captured topology + both pin groups, touchpad, ...
home/piioni/
  default.nix                              identity (username, homeDirectory, HM stateVersion) + fact schema
  workstation.nix                          NEW — host-fact schema and the un-captured-topology warning
  base.nix                                 NEW — role layer: 11 host-independent modules
  gui.nix                                  NEW — role layer: 9 graphical / host-scoped modules
  btop.nix, caelestia.nix, hypr.nix        rewritten to consume host facts (3 consumers)
  hypr/lua/{monitors,workspaces,inputs,gestures,keybinds}.lua    unchanged on disk; five targets become rendered
  ... (all other payload files untouched)
```

Layout notes:

- **`facts.nix`, not the proposal's working name `session.nix`.** The change has *no* session entry point
  (explicit non-goal), so a file called `session.nix` would name a concept this change deliberately does not
  introduce. Renamed; scope unchanged.
- **No `modules/hardware/default.nix`.** `modules/default.nix` must keep importing nothing NVIDIA-related, so
  that a host selects NVIDIA only by importing the file explicitly (spec: hardware-modules).
- **No `lib/`, no inventory helper, no `mkEnableOption` framework** (proposal D1; spec forbids it).

---

## 4. The host-data seam

### 4.1 Transport: the per-host import path

| Mechanism | Verdict | Why |
|---|---|---|
| Per-host Home Manager import path (`hosts/<name>/home.nix` sets `home-manager.users.piioni.imports`) | **Adopted** | Zero new concepts; facts reach HM modules without crossing the `specialArgs` boundary at all; `nixd` resolution unchanged |
| `home-manager.extraSpecialArgs` | Rejected | Allowed by the spec, but makes the fact bundle an *ambient* module argument: consumers receive it by argument name rather than by declared option, and a host that forgets it fails as "undefined variable" instead of "option not defined". The repo has no other ambient argument |
| `nixosSystem` `specialArgs` | **Not used for the user layer** | Confirmed hard constraint: `specialArgs` reach the NixOS module class only. Facts are consumed inside Home Manager. `specialArgs` keeps exactly its current job — carrying the `homeManager` flake input into `modules/home-manager.nix` |
| `home-manager.sharedModules` | Rejected | Shares *modules* across users, not *values* across hosts |
| `lib/mkWorkstation.nix` | Rejected (proposal D1) | Exists to solve this one transport problem; AGENTS.md asks for explicit values over abstraction-heavy helpers |

### 4.2 The exact composition that replaces `users.piioni = import ../home/piioni`

`modules/home-manager.nix` — the hardcoded user disappears; the system layer no longer decides who exists:

```nix
{ homeManager, ... }:
{
  imports = [
    homeManager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # `users.piioni` is declared per host in hosts/<name>/home.nix, together with that
    # host's facts file, so the user layer travels through a per-host import path.
  };
}
```

`hosts/laptop/home.nix` (and the identical `hosts/desktop/home.nix`):

```nix
{ ... }:
{
  home-manager.users.piioni = {
    imports = [
      ../../home/piioni          # identity + fact schema
      ../../home/piioni/base.nix # role: host-independent portable tooling
      ../../home/piioni/gui.nix  # role: graphical + host-scoped payload
      ./facts.nix                # this host's facts (declares nixie.workstation)
    ];
  };
}
```

`hosts/<name>/facts.nix` is a **Home Manager** module and is therefore imported by `home.nix`, never by
`hosts/<name>/default.nix` (which is a NixOS module). The four paths are file-relative, so
`./facts.nix` resolves inside the host directory.

### 4.3 The fact schema — `home/piioni/workstation.nix`

Declares the vocabulary, holds **no facts**, and owns the un-captured-topology warning. Shape (final text may
be reformatted by `nixfmt`):

```nix
{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  output = types.submodule {
    options = {
      name = mkOption { type = types.str; description = "Hyprland output name, e.g. eDP-1."; };
      mode = mkOption { type = types.str; description = "Hyprland mode string, e.g. 1920x1080@60."; };
      position = mkOption { type = types.str; description = "Hyprland position string, e.g. 0x0."; };
      scale = mkOption {
        type = types.str;
        description = "Raw Lua literal emitted for `scale`; Hyprland reads it as a float.";
      };
    };
  };

  pin = types.submodule {
    options = {
      var = mkOption { type = types.str; description = "Lua local binding name used inside the pin block."; };
      output = mkOption { type = types.str; description = "Output name this pin group targets."; };
      guard = mkOption {
        type = types.enum [ "monitor-exists" "unconditional" ];
        description = "Failure semantics of this pin group; the two are rendered by distinct branches.";
      };
      workspaces = mkOption { type = types.listOf types.str; description = "Workspace names to pin."; };
    };
  };

  display = types.submodule {
    options = {
      outputs = mkOption { type = types.listOf output; description = "Captured display outputs, in declaration order."; };
      pins = mkOption { type = types.listOf pin; description = "Captured workspace pin groups, in declaration order."; };
    };
  };
in
{
  options.nixie.workstation = {
    display = mkOption {
      type = types.nullOr display;
      description = "Captured display topology. `null` means NOT CAPTURED (no directives, no pins, compositor auto-detects).";
    };
    touchpad = mkOption { type = types.bool; description = "This machine has a touchpad."; };
    brightnessKeys = mkOption { type = types.bool; description = "This machine has backlight brightness keys."; };
    batteryUi = mkOption { type = types.bool; description = "This machine has a battery whose level is shown in the UI."; };
  };

  config = {
    warnings = lib.optional (config.nixie.workstation.display == null) ''
      nixie: this host's display topology is not captured
      (nixie.workstation.display = null). No monitor directives and no workspace pins
      will be emitted; the compositor will auto-detect. Capture with `hyprctl monitors`
      and fill the host's facts.nix.
    '';
  };
}
```

Design points, each chosen deliberately:

- **No defaults.** All four facts are *required*. A host that forgets one fails evaluation with
  "option used but not defined" instead of silently inheriting a class of behaviour. Both hosts declare all
  four, including the explicit `false`s, so the divergence is visible in the host file.
- **`display = null` is a value, not an omission** (proposal D5). It is the only sanctioned representation of
  "not captured".
- **The warning is the schema's job, not the host's.** A generic warning fires for *any* host with
  `display = null`, names the gap, and needs no host identity — so the payload does not reach into
  `osConfig` (which would couple the portable payload to NixOS). It uses Home Manager's supported
  `warnings` channel, which the module-check wrapper prints to stderr during evaluation.
- **`scale` is a string, not a number.** Nix renders floats as `1.000000`, which would break byte equality;
  declaring the raw Lua literal removes the formatting question. Rejected: `types.float`/`types.number`
  plus `toString` — cannot guarantee the laptop's `scale = 1`.
- **Enum-typed `guard`.** A typo in the guard can no longer silently change failure semantics.
- **No assertion that a `pin.output` exists in `display.outputs`.** With `guard = "monitor-exists"` a stale
  output is already harmless, and the check is not worth its lines at this size. Recorded, not hidden.

### 4.4 Fact data per family

| Fact | Type | Laptop | Desktop | Consumed by |
|---|---|---|---|---|
| `display` | `null`, or the captured `{ outputs; pins; }` object | two outputs (`eDP-1` 1920x1080@60 at 0x0, `HDMI-A-1` 1920x1080@120 at 1920x0) + two pin groups | `null` | `hypr.nix` (monitors + workspaces) |
| `touchpad` | bool | `true` | `false` | `hypr.nix` (inputs block, gestures file) |
| `brightnessKeys` | bool | `true` | `false` | `hypr.nix` (two binds) |
| `batteryUi` | bool | `true` | `false` | `caelestia.nix`, `btop.nix` |

The laptop's declaration (excerpt; exact text in `hosts/laptop/facts.nix`):

```nix
nixie.workstation = {
  display = {
    outputs = [
      { name = "eDP-1";    mode = "1920x1080@60";  position = "0x0";    scale = "1"; }
      { name = "HDMI-A-1"; mode = "1920x1080@120"; position = "1920x0"; scale = "1"; }
    ];
    pins = [
      { var = "hdmi"; output = "HDMI-A-1"; guard = "monitor-exists"; workspaces = [ "1" "2" "3" "4" ]; }
      { var = "edp";  output = "eDP-1";    guard = "unconditional";  workspaces = [ "5" "6" ]; }
    ];
  };
  touchpad = true;
  brightnessKeys = true;
  batteryUi = true;
};
```

**No payload module may contain a host name or a machine literal.** Consumers read
`config.nixie.workstation.*` only. Verified by grep after implementation: `home/` must contain no host-name
conditional.

---

## 5. Role layering: `base` + `gui`

Two layers, imported *together* by every host. Membership is decided by **host sensitivity**, which is what
the spec's scenarios test, and the split of the previous 20 unconditional imports is:

| Layer | Modules (11 + 9 = 20) | Rule |
|---|---|---|
| `base.nix` | `agents`, `fastfetch`, `herdr`, `lazygit`, `moshi`, `nushell`, `packages`, `starship`, `tuxedo`, `yazi`, `zellij` | Must stay valid on a machine with no display, no touchpad and no battery; reads no `nixie.workstation` field |
| `gui.nix` | `btop`, `caelestia`, `ghostty`, `hypr`, `kitty`, `swappy`, `swayimg`, `swaync`, `zed` | Graphical session payload **plus** every module whose rendered target carries a host fact |

`home/piioni/default.nix` keeps only identity + schema:

```nix
{ ... }:
{
  imports = [
    ./workstation.nix
  ];

  home.username = "piioni";
  home.homeDirectory = "/home/piioni";
  home.stateVersion = "25.11";   # unchanged: changing it would change generated targets

  programs.home-manager.enable = true;
}
```

**Known asymmetry, stated rather than hidden:** `btop` is a TUI tool (which reads like `base`) but its
`btop.conf` target carries the `batteryUi` fact (which forces it into `gui`). One role layer, not two, wins:
the spec requires every host-scoped fact to attach to the graphical layer. Rejected alternative: splitting
`btop`'s package and themes (`base`) from its config target (`gui`) — that fragments the tool-per-file
convention and doubles the review surface for a naming objection.

Rejected: **three layers**. `tui` becomes a real axis only when a non-graphical machine exists; none is
defined. Rejected: **importing both roles from `default.nix`** — then role selection stops being visible in
the host file, and the split buys nothing structurally.

---

## 6. `hypr.nix`: eleven explicit targets and the ownership proof

### 6.1 Live-dotfile boundary and WU3b transition

| Target | Current authorized ownership | WU3b ownership |
|---|---|---|
| `hypr/hyprland.lua` | direct out-of-store symlink | direct out-of-store symlink |
| `hypr/scripts/*` | one explicit direct out-of-store symlink per script | one explicit direct out-of-store symlink per script |
| `hypr/lua` | one `recursive = true` store-backed directory owner | **deleted before leaf declarations** |
| `hypr/lua/{animations,autostart,decorations,programs,settings,windowrules}.lua` | covered only by the recursive owner | six explicit direct out-of-store symlink leaf targets |
| `hypr/lua/{monitors,workspaces,inputs,gestures,keybinds}.lua` | covered only by the recursive owner | five rendered/store-backed `.text` leaf targets |

Direct repository-owned payloads use
`config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/..."`.
The current recursive `hypr/lua` owner is deliberately retained as the only safe intermediate state: no
leaf may be added beneath it. WU3b's atomic ownership transition first removes that recursive entry, then
introduces all eleven explicit leaves and retains the prefix assertion below. `hypr/hyprland.lua` and the
script leaves are safe to convert now because they have no generated child target. Outside Hyprland,
`caelestia/cli.json` and the btop theme leaves are direct out-of-store symlinks; `caelestia/shell.json`
remains rendered for its runtime-path substitution and later battery divergence, while `btop/btop.conf`
remains store-backed until WU3b renders its later battery divergence. No other module declares anything
under `hypr/` (verified: `hypr.nix` is the sole owner of `hypr/**`).

### 6.2 Why "shadowed" would be silently wrong

Read from Home Manager's pinned source, not assumed:

- `home.file` is `attrsOf submodule` with `recursive` and `target` per *declared* key
  (`modules/lib/file-type.nix`); `config.home-files` inserts each entry (`modules/files.nix`), and on an
  existing path it prints `File conflict for file '<target>'` to stderr and **continues** — it does not fail
  the build.
- The module's own duplicate assertion compares **exact `target` strings** only. A directory target
  `.config/hypr/lua` and a file target `.config/hypr/lua/monitors.lua` are different strings, so that
  assertion does **not** fire.

Therefore, if the recursive copy stayed and per-file targets were added, the key ordering
(dir before child) would make the recursive copy win and the **rendered** file would be silently discarded —
while the laptop content witness still passed. That is the trap this design closes twice: delete the
recursive copy, and assert the invariant.

### 6.3 The machine-checked single-owner proof

In `hypr.nix` (the only file where the hazard exists; the check is general over the whole target set):

```nix
assertions =
  let
    targets = lib.mapAttrsToList (_: v: v.target) config.home.file;
    isPrefixOfAnother = t: lib.any (o: o != t && lib.hasPrefix "${o}/" t) targets;
  in
  [
    {
      assertion = !(lib.any isPrefixOfAnother targets);
      message = ''
        home.file: one target path is a prefix of another. A recursive directory copy
        coexists with a per-file target for the same path, which home-manager resolves
        silently in favour of whichever entry is inserted first. Remove the recursive copy.
      '';
    }
  ];
```

Together with Home Manager's exact-duplicate assertion this proves **one owner per target**, and the eleven
rendered/verbatim entries are enumerated statically in `hypr.nix` (an enumerated list, never a count).

### 6.4 Every `require` keeps resolving

`home/piioni/hypr/hyprland.lua` lines 2–12 hold **eleven** `require("lua.*")` calls
(`monitors, programs, decorations, animations, inputs, settings, gestures, keybinds, windowrules,
workspaces, autostart`) — the brief said ten; the extra one does not change the design. `lua/keybinds.lua:1`
adds `require("lua.programs")`. All eleven module targets exist for **both** hosts after the change:
the five host-scoped ones are rendered (never deleted), and the un-captured host renders a comment-only
file, which is still a loadable Lua chunk.

---

## 7. Rendering the seven host-scoped payload files

### 7.1 Mechanisms per file

| Target | Laptop (fact present / captured) | Desktop (`false` / `null`) | Mechanism | Byte equality for the laptop |
|---|---|---|---|---|
| `hypr/lua/monitors.lua` | generated: one `hl.monitor` block per captured output, in declared order | comment-only file | **value generator** | verified against the oracle |
| `hypr/lua/workspaces.lua` | generated: locals block + one block per pin group + fixed `special:magic` rule | generated with zero pins (identical code path) | **value generator** | verified against the oracle |
| `hypr/lua/inputs.lua` | `builtins.readFile` | same file with the touchpad region spliced out | **presence-gated verbatim** | **structural** |
| `hypr/lua/gestures.lua` | `builtins.readFile` | one comment line | **presence-gated verbatim** | **structural** |
| `hypr/lua/keybinds.lua` | `builtins.readFile` | same file with the brightness region replaced | **presence-gated verbatim** | **structural** |
| `caelestia/shell.json` | today's `replaceStrings` expression, unchanged | plus `"showBattery": true` → `false` | **additive substitution** | **structural** |
| `btop/btop.conf` | `builtins.readFile` | `show_battery = true` → `false` | **presence-gated verbatim** | **structural** |

**Five of the seven are byte-identical by construction**: when the fact is present the target content *is*
`builtins.readFile <payload file>` (or, for `shell.json`, the unchanged pre-existing expression), so no
transformation runs at all. Only `monitors.lua` and `workspaces.lua` are generated for the laptop, and those
two are byte-verified against the captured oracle (§9, R1).

### 7.2 Presence-gated verbatim, and a loud splice

```nix
# shape, inside hypr.nix / btop.nix
keepOrDrop =
  region: text:
  if lib.hasInfix region text then
    lib.replaceStrings [ region ] [ "" ] text
  else
    throw "payload drifted: expected region not found in ${toString ./hypr/lua/inputs.lua}";
```

- The checked splice is used in `hypr.nix` and `btop.nix`. A region that no longer matches the payload
  fails evaluation with a precise message instead of silently leaving the desktop with the laptop's file —
  AGENTS.md forbids silent failure patterns, and a silent no-op would be indistinguishable from success.
- `caelestia.nix` extends its **existing** `lib.replaceStrings` call with the battery substitution rather
  than introducing the helper a third time: the file is already rendered that way, and a hard failure there
  would be triggered by a runtime-rewritten payload file. The per-item divergence check (R5) still catches a
  no-op.
- Regions are copied **from the pre-change file at implementation time**; this document cites only their
  line ranges so it cannot drift from the bytes:
  - `inputs.lua` lines **17–24** (`        -- Touchpad` … `        },`), dropped entirely.
  - `keybinds.lua` lines **84–90** (the stale comment *and* both brightness binds), replaced by a comment
    naming only the remaining volume binds — otherwise the desktop keeps a comment advertising a bind it no
    longer has.
  - `btop/btop.conf` line **243** region `show_battery = true` → `false`. The keys are *disabled*, not
    deleted: deleting them would fall back to btop's built-in defaults, which are not known to be `false`.
  - `caelestia/shell.json` `"showBattery": true` → `false`, for the same reason (absence would fall back to
    the shell's own default).

### 7.3 The two generators

`monitors.lua` (captured): one block per `display.outputs` entry, joined by one blank line, ending with a
single newline. The pre-change file is exactly:

```lua
hl.monitor({
  output = "eDP-1",
  mode = "1920x1080@60",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "1920x1080@120",
  position = "1920x0",
  scale = 1,
})
```

`workspaces.lua` (captured) keeps **both failure semantics, on purpose**:

```lua
local hdmi = "HDMI-A-1"
local edp = "eDP-1"

if hl.get_monitor(hdmi) ~= nil then          -- guard = "monitor-exists"
  for _, ws in ipairs({ "1", "2", "3", "4" }) do
    hl.workspace_rule({ workspace = ws, monitor = hdmi, default = true, persistent = true })
  end
end

for _, ws in ipairs({ "5", "6" }) do         -- guard = "unconditional"
  hl.workspace_rule({ workspace = ws, monitor = edp, default = true, persistent = true })
end

hl.workspace_rule({                          -- host-independent, always emitted
  workspace = "special:magic",
  gaps_in = 1,
  gaps_out = 1,
  border_size = 3,
  animation = "slidevert",
})
```

Rules the generator must obey, and why each exists:

1. **Two distinct branches**, selected by the enum — `monitor-exists` emits the `if … then … end` wrapper,
   `unconditional` emits the bare loop. They are never unified into one loop with an optional guard, which is
   the "silently unified semantics" defect the spec forbids.
2. **A local binding per pin group** (`var`) because the pre-change file references `hdmi`/`edp` twice each
   and byte equality is a hard criterion; the variable name is not derivable from the output name, so it is
   host data.
3. **Declaration order is output order.** `pins` is ordered `HDMI` group first, then `eDP`, matching the file
   — a `mapAttrsToList`-style sort would reorder it and fail the oracle.
4. **`null` topology produces zero locals and zero pins** — structurally, because there are no outputs and no
   pin groups to iterate. The `special:magic` rule is host-independent and stays. No separate "desktop
   branch" exists in the generator, so there is nothing to keep in sync.
5. **Whitespace skeleton is a fixture, not a style choice.** The pre-change file begins with a blank line and
   separates sections with a blank line; the generated text must reproduce that, including the trailing
   newline. The oracle (§9, R1) decides; the implementer iterates against it.

If the generator cannot reproduce the laptop's bytes without contortion, the sanctioned fallback is a
**template**: the pre-change file with the host's literals substituted via `replaceStrings`. It only supports
the output set present in the template, so it would be recorded as a limitation, and the generator remains
the preferred answer.

### 7.4 Why `.text` is byte-faithful

Verified in the pinned sources, so byte equality is not a hope:

- `home.file.<n>.text` is `types.lines` = `separatedString "\n"`, i.e. `concatStringsSep "\n"` of the
  definitions. With **exactly one** owner per target (guaranteed by §6.3) the merge is the identity: no
  trailing-newline normalisation, no stripping.
- Home Manager then builds the content with `pkgs.writeTextFile`, whose builder does
  `printf "%s" "$text" > "$target"` (`pkgs/build-support/trivial-builders/default.nix`) — an exact write.
- The leaf in `home-files` is a symlink to that store file, so the materialised bytes are the rendered bytes.

This is a second reason single ownership matters: two owners writing `text` for one target would be joined by
a newline, silently changing the file's bytes.

### 7.5 Desktop divergence — what is expected, item by item

| # | Pre-change laptop fact | Desktop after | Checked by |
|---|---|---|---|
| L1 | `eDP-1` monitor block | absent (`monitors.lua` has no `hl.monitor`) | R5 |
| L2 | workspaces 5–6 pinned to `eDP-1`; 1–4 pinned to `HDMI-A-1` | no pin loop at all; `special:magic` rule retained | R5 |
| L3 | touchpad block | region removed from `inputs.lua` | R5 |
| L4 | three-finger workspace gestures | `gestures.lua` comment-only | R5 |
| L5 | two `XF86MonBrightness*` binds (dead on every machine) | region removed from `keybinds.lua` | R5 |
| L6 | `"showBattery": true` | `false` | R5 |
| L7 | `show_battery = true` | `false` | R5 |

Plus the addition with no source: the desktop's own topology is `null` + warning + compositor auto-detect
(proposal D5). Any drift **beyond** this table must be reported, never absorbed into "expected difference".

---

## 8. NVIDIA extraction (WU1)

- `hosts/desktop/gpu-nvidia.nix` → `modules/hardware/nvidia.nix`, content **byte-identical** (38 lines,
  `{ config, lib, ... }:` header unchanged — both module classes supply those arguments).
- `hosts/desktop/default.nix`: the import changes from `./gpu-nvidia.nix` to
  `../../modules/hardware/nvidia.nix`.
- `hosts/laptop/default.nix` does **not** import it: Intel Iris Xe is default-handled, and the spec requires a
  host without NVIDIA hardware to evaluate with no NVIDIA driver, kernel parameter or package setting.
- No aggregate `modules/hardware/default.nix`, and no change to `modules/default.nix`, so NVIDIA cannot leak
  into a host by accident.
- Overridable defaults (`lib.mkDefault`) are preserved by the pure move; a host may still override them.

Verified by reading the tree: `gpu-nvidia.nix` is referenced only from `hosts/desktop/default.nix`, and no
`modules/` file assumes host-local siblings.

**Witness:** the desktop's `system.build.toplevel.drvPath` must equal the value recorded in WU0. This is the
only derivation-path-equality claim in the change; the payload units explicitly do **not** make it.

---

## 9. Witness capture (WU0) and comparison rules

### 9.1 WU0 — capture before the first edit

WU0 changes no repository file. It runs over an `rsync` copy of the working tree (untracked files included)
and records, under `openspec/changes/multi-workstation-architecture/evidence/pre-change/`:

| Artifact | Content | Why it must exist before WU3 |
|---|---|---|
| `home-files/` | `cp -rL` of the built `home-manager.users.piioni.home-files` output: the materialised payload paths **and bytes** | The strongest oracle. After the first payload edit it is unrecoverable except by `git stash`/checkout |
| `home-file-snapshot.json` | sorted `attrNames home.file` with `{ target, recursive, text? }` per entry | Secondary, option-level key comparison |
| `desktop-toplevel.drvPath` | the recorded gate's output for `desktop` | WU1's pure-move witness |
| `capture.txt` | `git rev-parse HEAD`, `git status --porcelain`, and the pinned flake input revisions | Makes the oracle reproducible |

The evidence directory is **not referenced from any Nix expression**, so it may stay untracked during apply
without tripping the "untracked path" evaluation error.

### 9.2 Comparison rules

| # | Rule | Pass condition |
|---|---|---|
| R1 | **Primary payload witness.** Materialised tree comparison, *laptop-after* vs *pre-change desktop*: sorted path set + byte-for-byte content (`diff -r`, dereferencing symlinks) | Empty output for both `find`-diff and `diff -r` **(superseded as a whole-tree acceptance criterion — see "Witness amendment (authorized)"; the operative witness is W1 + W2 + W3)** |
| R2 | **Option-level witness.** Sorted `attrNames home.file`, after the **recursive-expansion rule**: an entry with `recursive = true` expands to the leaf paths under its `source`; all other entries contribute their own key | Set equality, plus an itemised raw-key delta of exactly one removal (`…/hypr/lua`) and exactly eleven additions (`…/hypr/lua/<name>.lua`) and nothing else |
| R3 | **Ownership.** No raw target is a path-prefix of another | Payload assertion (§6.3) passes; snapshot re-check agrees |
| R4 | **Pure move (WU1 only).** Desktop `toplevel.drvPath` | Byte-equal to `desktop-toplevel.drvPath` |
| R5 | **Divergence.** Desktop materialised content against the §7.5 table | Every enumerated item absent/disabled; **any** other drift reported separately |
| R6 | **Warning.** Desktop gate stderr | Contains the un-captured-topology warning; the laptop's gate does not |
| R7 | **Structural checks.** `nix flake show` lists exactly `desktop` and `laptop`; recorder contains the raw-key delta and gate commands and must never contain a hardcoded total target count; `nixfmt --check` exits 0 | As stated |

**R1 superseded.** The R1 pass condition above (empty output for both `find`-diff and `diff -r` over the whole
materialised tree) is unreachable for any change that alters the module graph — a Home-Manager-generated
`home-files` file embeds the `home.path` store path, and the pre-change `system.build.toplevel.drvPath`
equality is unreachable for the same reason. The original wording is kept above for history and is
superseded by the operative witness **W1 + W2 + W3** in the "Witness amendment (authorized)" section at the
end of this document. `R4` is unaffected: it is scoped to the WU1 pure move, succeeded, and is not weakened.

### 9.3 Commands (all unverified — no shell in this phase)

Per-host evaluation gate, generalised from `openspec/config.yaml → testing.runner.command` (the recorded
command only names `desktop`; every unit must run it for **both** hosts, over a **non-Git copy**):

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
  .config.system.build.toplevel.drvPath" > /dev/null
```

Payload materialisation + R1 (the same expression, `.config.home-manager.users.piioni.home-files`, built with
`nix build --impure --expr … --out-link`), then:

```bash
diff -r "$D/hf-laptop" openspec/changes/multi-workstation-architecture/evidence/pre-change/home-files
```

Option snapshot for R2:

```bash
nix eval --impure --json --expr "
let f = builtins.getFlake \"$D/t\"; in
builtins.attrNames
  f.nixosConfigurations.laptop.config.home-manager.users.piioni.home.file" | sort
```

Flake topology and formatting — note that `nix flake show` **and** `nixfmt --check` see only *tracked* files,
so for any unit that adds files they must also run over the `rsync` copy (or after a unit-sized commit):

```bash
(cd "$D/t" && nix flake show)
nix run .#formatter.x86_64-linux -- --check $(git ls-files '*.nix')   # plus any untracked new .nix file
```

### 9.4 Gate limitations — recorded, not fixed here

- **`nix flake check` stays excluded**: it forces the toplevel without the stub and dies on the pre-existing
  `fileSystems` / `boot.loader.grub.devices` assertions, because `hosts/desktop/hardware-configuration.nix`
  is intentionally absent.
- **The recorded gate is more permissive than a real build.** The stub supplies
  `nixpkgs.config.allowUnfree = true`, which the tracked tree does not; `hardware.nvidia.package` defaults to
  the unfree production branch. A real desktop build would likely fail on the licence. Repo-wide fact,
  out of scope, recorded as a follow-up. The laptop does not import NVIDIA, so it is closer to buildable.
- **New untracked files are invisible to Nix.** Therefore mid-unit states are evaluable only through the
  `rsync` gate or after unit-sized commits, and `nixd`/IDE resolution will show new files as missing until
  they are committed.
- **The `home-files` build is cheap** (lndir + text writers): it does not build the kernel, the bootloader or
  NVIDIA. That is what makes R1 affordable as a per-unit witness.
- `nixos-rebuild build/test/switch` remain **manual-only and unverified** in this environment, and the laptop
  is explicitly **not** claimed installable (no `hardware-configuration.nix`).

---

## 10. Work units: files, lines, gates

| WU | Files touched | Est. changed lines | Gate that proves it green | Witness |
|---|---|---|---|---|
| **WU0** (prerequisite, no repo change) | none; writes `evidence/pre-change/**` | 0 | none needed | Oracle exists and is reproducible |
| **WU1** NVIDIA pure move | `modules/hardware/nvidia.nix` (new, 38) ← `hosts/desktop/gpu-nvidia.nix` (deleted), `hosts/desktop/default.nix` (1 line) | ≈5 with `git -M`, ≈78 raw (no rename detection) | Gate for **desktop** | **R4**: `drvPath` identical |
| **WU2** host seam + laptop host, payload still verbatim | new `hosts/laptop/{default,host,home}.nix`, new `hosts/desktop/home.nix`, `hosts/desktop/default.nix` (+1), `flake.nix` (+9), `modules/home-manager.nix` (−1/+1) | ≈56 | Gate for **both hosts** | **R1–R3 + R7**: laptop-after ≡ desktop-before; flake lists two hosts |
| **WU3a** plumbing: schema + roles + facts declared | new `home/piioni/{workstation,base,gui}.nix` + `hosts/{laptop,desktop}/facts.nix`; rewritten `home/piioni/default.nix`; `hosts/*/home.nix` (+3 each) | ≈110 | Gate for **both hosts** | **R1–R3**: facts declared but consumed by nothing, so the payload is still byte-identical |
| **WU3b** hybrid ownership + render the seven files | `home/piioni/hypr.nix` (ownership transition + render), `caelestia.nix`, `btop.nix` | ≈125 | Gate for **both hosts** | **W1–W3**, one-owner/prefix assertion, and no laptop topology warning; desktop still runs on laptop-mirrored facts |
| **WU4** desktop divergence | `hosts/desktop/facts.nix` (4 values) | ≈8 | Gate for **both hosts** | **R5 + R6**: per-item absence and the topology warning |

**Budget accounting (honest).** Total ≈ 300 changed lines with rename detection, ≈ 375 without — inside the
400-line budget for `single-pr`, but the headroom is thin and WU3b is the swing factor. Two consequences,
both already chosen by earlier phases:

- **WU3's internal split (3a/3b) is the sanctioned boundary.** If the measured diff
  (`git diff --stat -M` against the pre-change commit) crosses 400 at that point, the correct action is to
  **stop and ask at the size gate** (or chain WU3b+WU4 onto a second PR). No `size:exception` is inferred,
  requested or self-granted.
- WU3a is worth its own commit even when the budget is fine: it is the cheapest possible intermediate state
  (facts declared, nothing consumed, witness still exact).

**Sequencing is load-bearing.** WU0 must run before WU3a/WU3b; once the payload files are rewritten the
pre-change bytes exist only in the evidence directory or in `git` history. WU2 must precede WU3 so that a
host exists that can express the oracle on the *new* side; WU4 comes last because it is the only unit that
intentionally perturbs the payload.

Every unit is gate-green on its own, and every unit's gate runs over the `rsync` copy because WU1–WU3b add
files.

---

## 11. Decision log

| # | Decision | Section | Chief rejected alternative |
|---|---|---|---|
| D-A | Transport host facts through the per-host HM import path; `specialArgs` keeps only `homeManager` | §4.1 | `extraSpecialArgs` (ambient), `lib/mkWorkstation.nix` (proposal D1) |
| D-B | Four **required** facts with no defaults; `display = null` is an explicit value | §4.3 | Optional facts with `false`/`null` defaults (silently inherits behaviour) |
| D-C | Warning lives in the schema and uses HM `warnings` | §4.3 | `lib.warn` in each host's facts (per-host duplication), reading `osConfig` from the payload (layer violation) |
| D-D | `scale` is a raw Lua string | §4.3 | `types.float` + `toString` (float formatting breaks byte equality) |
| D-E | `base`/`gui` membership is decided by host sensitivity; `btop` therefore sits in `gui` | §5 | Splitting `btop` across layers; three layers (nothing headless exists) |
| D-F | The `hypr/lua` recursive copy is **deleted**; eleven explicit targets own the same on-disk paths | §6 | Keeping the copy and relying on Home Manager's duplicate assertion (cannot catch a prefix overlap) |
| D-G | Single ownership is machine-checked by a prefix assertion in `hypr.nix` | §6.3 | Trusting the target snapshot alone (a conflict is invisible in the key set) |
| D-H | Presence-gated verbatim (`readFile` or checked splice) for five files; generators for the two value files | §7 | Full templates for all seven (larger diff, same risk); marker comments inside the payload (changes bytes) |
| D-I | Recursive-directory **expansion rule** defines the option-level target-set comparison; the primary witness is the materialised tree | §2, §9.2 | Comparing raw `home.file` keys (would report a mechanism change as a target change) |
| D-J | Evidence lives under `openspec/changes/…/evidence/` and is never referenced from Nix | §9.1 | Committing the oracle and reading it from Nix (untracked-file trap; couples verification to the tree) |

---

## 12. Risks

| Severity | Risk | Mitigation |
|---|---|---|
| High | **Generator cannot reproduce the laptop's bytes** for `monitors.lua`/`workspaces.lua` (blank lines, ordering, float rendering) | Five of seven files avoid generation entirely; the two generators are anchored to a captured oracle, the whitespace skeleton is copied from the fixture, and `pins`/`outputs` are ordered lists. Bounded template fallback recorded in §7.3 |
| High | **Silent target conflict** if the recursive copy survives | §6.2 evidence + §6.3 assertion + R3 |
| High | **Oracle lost** by starting the payload work first | WU0 is a prerequisite with its own evidence directory and commit-order rule (§10) |
| Medium | `nix flake show` / `nixfmt --check` only see tracked files, so a unit can look green while a new file is unformatted | Both are run over the `rsync` copy or after a unit-sized commit (§9.3) |
| Medium | Desktop divergence read as regression | I1/I2, the oracle direction in §2 and R1 vs R5 |
| Medium | Required facts make an intermediate state fail evaluation loudly (a host that forgot `facts.nix`) | Deliberate: the failure names the missing option; WU3a adds both hosts' facts in one commit |
| Medium | The desktop's real topology stays unknown | `null` + warning + auto-detect; filling it is a follow-up with `hyprctl monitors` |
| Low | Line budget overstated by rename detection | Report both measurements; 3a/3b boundary is the split point |
| Latent, out of scope | No `nixpkgs.config.allowUnfree` in the tracked tree while the gate stub supplies it | Recorded, not fixed (§9.4) |

---

## 13. Rollback

1. Revert work units in reverse order. WU4 and WU3b are the only units that alter payload content; reverting
   them restores the raw files and the recursive `hypr/lua` copy.
2. WU3a removal restores the 20 unconditional imports and deletes the schema, roles and facts.
3. WU2 removal deletes `hosts/laptop/`, restores `users.piioni = import ../home/piioni`, and drops the
   desktop's `home.nix`; the flake returns to one host.
4. WU1 rollback moves the NVIDIA module back and restores the import line — verified by `drvPath` equality
   against the recorded value, so the revert is checkable rather than hopeful.
5. Nothing is activated, migrated or published by this change: rollback risk is confined to the repository.
   The evidence directory can be deleted with no effect on evaluation.

---

## 14. Out of scope, recorded debt, open items

**Explicit non-goals (unchanged from the proposal):** any third machine and its axes; power/battery
services; session entry point; the dependency gap and all package declarations; the `code` → `zed-editor`
mismatch; `caelestia/monitors/` (L8, inert); `nixpkgs.config.allowUnfree`; AGENTS.md path drift; gate scripts;
`references/`.

**Recorded debt that stays recorded:** the two relocated brightness binds remain dead on every host
(`brightnessctl` is declared nowhere); `tuxedo-rs` stays portable and **explicitly unclassified** — it must
not be classified as a form-factor marker, and if
`nix eval --raw nixpkgs#tuxedo-rs.meta.description` names TUXEDO vendor hardware control, reclassification is
a follow-up, not part of this change.

**Open items the implementer must not silently resolve:**

| # | Item | Handling |
|---|---|---|
| O1 | The laptop's real `networking.hostName` / `system.stateVersion` are user data not present in the repo (proposal A1) | Design default: `laptop` / `"25.11"`. Confirm with the user; a rename is a directory + one-line change and does not touch the payload witness |
| O2 | `pkgs.tuxedo-rs.meta.description` | Unverified (no shell); check at apply time |
| O3 | The desktop's topology | Deliberately `null`; capture separately |
| O4 | Whether the recorded gate is currently green | Inherited from `openspec/config.yaml`; must be re-run for both hosts |
| O5 | `nixfmt` behaviour inside the new multi-line strings | Unverified; the format gate decides |

---

## 15. Reviewer checklist

- [ ] I1/I2 accepted: the regression witness is `laptop-after ≡ desktop-before`, at the payload layer.
- [ ] The oracle is the materialised `home-files` tree, captured before the first payload edit.
- [ ] `modules/home-manager.nix` no longer names the user; each host declares it via its own import path.
- [ ] Facts are required, live in `hosts/<name>/facts.nix`, and no consumer contains a host name.
- [ ] The `hypr/lua` recursive copy is gone; eleven targets own the same paths; the prefix assertion is present.
- [ ] Five of seven files are byte-identical by construction; the two generators are diffed against the oracle.
- [ ] The guard asymmetry survives as two branches, and `display = null` emits no directives and no pins.
- [ ] The desktop's diff is checked item by item, and its warning is visible in the gate output.
- [ ] No package declaration, no power/session configuration, no `hardware-configuration.nix` was added.
- [ ] No hardcoded total-target count appears in the design, tasks, or evidence.

## Key Learnings

1. Home Manager's `home.file` holds one entry per declared key, so a `recursive = true` directory is a single target and a child file target never trips Home Manager's exact-string duplicate assertion.
2. A recursive directory target plus a per-file target for a path inside it makes `home-files` print a `File conflict` message and keep the directory's version, silently discarding the rendered file.
3. Home Manager's `.text` route is byte-faithful because `types.lines` with a single definition is the identity and `writeTextFile` writes with `printf "%s"`.
4. Nix renders floats as six decimals, so any byte-exact Lua numeric literal must be declared as a string rather than `types.float`.
5. The strongest refactor witness for this repo is the materialised `home-files` tree, because two payload targets (`caelestia/shell.json`, `herdr/config.toml`) are already rendered today.

---

## Witness amendment (authorized)

**Provenance.** This amendment was discovered during the `apply` phase, proven by parent-run experiments, and
explicitly authorized by the user. The full finding and its causal analysis are recorded in
`openspec/changes/multi-workstation-architecture/apply-progress.md` (sections *"R4 / non-negotiable #7 —
desktop `drvPath` vs the recorded oracle"*, *"Cause of the desktop `drvPath` delta (bisected, not
guessed)"*, *"G2 — materialised payload witness (R1)"*, and *"Witness residual requiring parent judgement
(not absorbed)"*). This section is the operative witness; the superseded criterion is kept below for history.

**Superseded criterion (retained, not deleted).** As a general requirement for this change, the original
record required:

> **R1 — Primary payload witness.** Materialised tree comparison, *laptop-after* vs *pre-change desktop*:
> sorted path set + byte-for-byte content (`diff -r`, dereferencing symlinks) → empty output for both
> `find`-diff and `diff -r`
>
> plus `system.build.toplevel.drvPath` equality across the refactor.

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

**Operative witness (supersedes R1).**

- **W1 — target set equality.** The expanded `home.file` target set must be **set-equal** to the captured
  pre-change snapshot, applying the recursive-expansion rule for `recursive = true` entries. **Never a
  count**: no total target count may appear as a constant anywhere.
- **W2 — payload byte equality.** The seven host-scoped payload files must be byte-identical to their
  pre-change rendered content.
- **W3 — package layer content identity.** The built `home.path` derivation must be byte-identical to the
  pre-change one under `diff -r`. This witnesses package **content** independently of its hash, which is
  strictly stronger than comparing derivation paths.

**Not weakened — `R4`.** The `drvPath` equality witness for the WU1 NVIDIA pure move (`R4`, §9.2, and the
§8 witness) **succeeded** and is left intact. It is scoped to the pure move it already witnessed and is not
a general-purpose witness that later units must satisfy.

# Hardware Modules Specification

## Purpose

Machine-specific hardware support is a reusable module under `modules/`, not a detail of one host
directory. A host selects hardware support by importing it; hosts without that hardware do not import
it and carry no trace of it.

## Requirements

### Requirement: NVIDIA Support Is A Reusable Module

NVIDIA and Wayland support MUST live in a reusable module under `modules/`. A host with NVIDIA hardware
MUST import it; a host without NVIDIA hardware MUST NOT import it and MUST evaluate with no NVIDIA
driver, kernel parameter, or NVIDIA package setting applied. The module MUST keep its existing
overridable defaults and MUST NOT gain new behaviour.

#### Scenario: The desktop applies NVIDIA support

- GIVEN the desktop host imports the module
- WHEN the desktop host is evaluated
- THEN the NVIDIA video driver, the DRM kernel parameters, the graphics settings, and the NVIDIA settings are present

#### Scenario: A host without NVIDIA hardware evaluates without it

- GIVEN a host that does not import the module
- WHEN that host is evaluated
- THEN no NVIDIA video driver, DRM kernel parameter, or NVIDIA package setting is present

#### Scenario: Overridable values remain overridable

- GIVEN the module declares its values as overridable defaults
- WHEN a host overrides one of them
- THEN the host's value wins

### Requirement: The Hardware Extraction Is A Behaviour-Preserving Move

Moving the desktop's NVIDIA support from its host directory into `modules/` MUST be a pure move:
content unchanged apart from the import path, and the desktop's `system.build.toplevel.drvPath` MUST
be identical before and after the move, evaluated with the project gate. A difference in the
derivation path MUST be treated as a behaviour change and investigated rather than accepted.

#### Scenario: Derivation path is unchanged by the move

- GIVEN the recorded pre-move `system.build.toplevel.drvPath` for the desktop host
- WHEN the desktop host is evaluated after the move
- THEN the derivation path is identical

#### Scenario: The equality witness is not over-claimed

- GIVEN a change that legitimately alters evaluated content, such as rendered payload text or a target that gains rendered content
- WHEN the derivation path differs
- THEN the witness degrades to the Home Manager target-set snapshot plus a rendered-content diff, and no derivation-path equality is claimed

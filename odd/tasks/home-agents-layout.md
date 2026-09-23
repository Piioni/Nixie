# Consolidate Home Manager core and agent resources

## Goal

Simplify Home Manager categories by folding terminal/TUI modules into `home/core`, while moving agent and skill resources into a dedicated sibling `home/agents` directory discoverable by Pi and Claude Code.

## Target layout

```text
home/
├── default.nix
├── core/       # shared system/user foundation and terminal workflow
├── agents/     # portable shared skills, linked to supported tool locations
├── gui/
└── hosts/
```

## Work units

- [x] 1. Merge all modules and supporting data from `home/tui` into `home/core`; update aggregators and live source prefixes; remove the obsolete TUI category. Commit: pending.
- [ ] 2. Move existing repository-managed agent skills from `home/core/agents*` to sibling `home/agents`; wire the portable skills to existing `~/.config/agents/skills`, Pi's documented `~/.agents/skills`, and Claude Code's existing `~/.claude/skills` locations.
- [ ] 3. Verify source resolution, Home Manager evaluation for both hosts, module ownership, and commit the focused refactor.

## Verification record

- Nix formatting check passed for changed modules; `git diff --cached --check` passed.
- Both desktop and laptop Home Manager activation evaluations passed (impure), returning the same generation derivation.
- All previous TUI modules are imported once from core; `home/tui/` and active `home/tui/` references are gone.
- Only existing Yazi legacy-default warnings remain.

## First-cut scope

- Use only the repository's existing versioned skills as shared portable resources.
- Do not copy or overwrite the full local `~/.pi/agent` or `~/.claude` directories.
- Leave Pi/Claude settings, credentials, sessions, caches, project histories, plugins, hooks, local SDD agents/commands, and generated/synced skills untouched for a later explicitly scoped task.
- Keep the existing `~/.config/agents/skills` targets working.
- Preserve desktop/laptop settings, app options, target paths, and Home Manager identity.

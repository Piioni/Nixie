# Parameterize the Home Manager user

## Goal

Use one username value for the NixOS system account and the Home Manager user, and derive the Home Manager directory as `/home/<username>`.

## Work units

- [x] 1. Define one username at the flake boundary and pass it to NixOS modules and Home Manager modules; use it for the system account.
- [x] 2. Use the same value for the Home Manager user bridge and shared `home.username`/`home.homeDirectory`; make the user-specific Zed Dart path derive from the configured home directory.
- [x] 3. Verify formatting and evaluate both hosts' account/Home Manager identity; document and commit the feature as `9fb7ae2` (`refactor(home): parameterize user identity`).

## Verification evidence

- Project `nixfmt --check`: passed for all seven changed Nix files.
- `git diff --check`: passed.
- Impure evaluation of desktop and laptop confirmed NixOS and Home Manager use `piioni`, with HM home directory `/home/piioni`.
- Evaluated Zed settings retain the expected Dart path and keymap source.

## Boundaries

- Keep the current configured username `piioni`; parameterization must not change the effective account.
- Apply the value to both NixOS and Home Manager, not Home Manager alone.
- Derive `/home/${username}` rather than maintaining an independent directory value.
- Preserve desktop/laptop differences and all application behavior except removal of the hard-coded username from the Zed Dart path.
- Do not change unrelated references to `/home/piioni` in documentation or generated/editor metadata.

# Nixie

## Desktop sessions

Both `desktop` and `laptop` provide selectable **Hyprland** and **Niri** entries through
Noctalia Greeter. The greeter does not force either session.

- **Niri** and **Hyprland** both start the same Noctalia shell configuration once
  per selected session, including its bar, control center, idle and lock behavior,
  ProtonVPN plugin, avatar, and bundled wallpaper collection.
- No SwayNC module is active, so Noctalia provides notifications in both sessions.

The Noctalia assets are tracked under `home/gui/noctalia-assets/`; the configuration
has no runtime dependency on the ignored `references/` directory. Nushell config,
environment, and autoload files use pure module-relative sources, so edits require a
Home Manager rebuild to take effect; they are no longer live-linked to a nonexistent
`/home/piioni/nix-config` checkout.

Validate either host without activating it:

```bash
nix flake show
nix eval --raw .#nixosConfigurations.desktop.config.services.greetd.settings.default_session.command
nix eval --raw .#nixosConfigurations.laptop.config.services.greetd.settings.default_session.command
nix build .#nixosConfigurations.desktop.config.home-manager.users.piioni.home.activationPackage --no-link
```

{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
in
{
  home.packages = with pkgs; [
    nodejs_22
    pnpm
    bun
    python3
    uv
    # rustup manages toolchains in ~/.rustup; run `rustup default stable` once.
    rustup
    gcc
    gnumake
    pkg-config
  ];

  home.sessionVariables = {
    # Global installs must land outside the read-only Nix store.
    NPM_CONFIG_PREFIX = "${home}/.local/share/npm";
    PNPM_HOME = "${home}/.local/share/pnpm";
    BUN_INSTALL = "${home}/.bun";
    # Prefer the Nix Python; uv may still download others a project pins.
    UV_PYTHON_PREFERENCE = "system";
  };

  home.sessionPath = [
    "${home}/.local/bin"
    "${home}/.local/share/npm/bin"
    "${home}/.local/share/pnpm"
    "${home}/.bun/bin"
    "${home}/.cargo/bin"
  ];
}

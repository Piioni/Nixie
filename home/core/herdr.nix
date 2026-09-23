{ pkgs, lib, ... }:
{
  home.packages = [ pkgs.herdr ];

  # Herdr was pointing at the imperative Cargo Nushell; use the declarative one.
  xdg.configFile."herdr/config.toml".text =
    lib.replaceStrings [ "@NUSHELL@" ] [ "${pkgs.nushell}/bin/nu" ]
      (builtins.readFile ./herdr/config.toml);
}

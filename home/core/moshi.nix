{ pkgs, ... }:
let
  tomlFormat = pkgs.formats.toml { };
in
{
  home.packages = [ pkgs.moshi ];

  xdg.configFile."moshi/config.toml".source = tomlFormat.generate "moshi-config.toml" {
    gateway = {
      always_on_discovery = false;
      usage_collection = false;
      scan_ports = [ ];
    };
  };
}

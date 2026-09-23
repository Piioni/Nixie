{
  pkgs,
  lib,
  config,
  ...
}:
let
  zjstatus = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.23.0/zjstatus.wasm";
    hash = "sha256-4AaQEiNSQjnbYYAh5MxdF/gtxL+uVDKJW6QfA/E4Yf8=";
  };
in
{
  home.packages = [ pkgs.zellij ];

  xdg.configFile = {
    "zellij/config.kdl".text =
      lib.replaceStrings
        [ "/usr/bin/fish" "/usr/bin/nvim" ]
        [ "${pkgs.nushell}/bin/nu" "${config.programs.nixvim.build.package}/bin/nvim" ]
        (builtins.readFile ./zellij/config.kdl);

    "zellij/zjstatus.wasm".source = zjstatus;

    "zellij/layouts/default.kdl".text =
      lib.replaceStrings
        [ "file:/home/piioni/.config/zellij/zjstatus.wasm" ]
        [ "file:${config.xdg.configHome}/zellij/zjstatus.wasm" ]
        (builtins.readFile ./zellij/layouts/default.kdl);
  };
}

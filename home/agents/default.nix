{ config, lib, ... }:
let
  skillsPath = "${config.nixie.home.repositoryRoot}/home/agents/skills";
in
{
  imports = [
    ./claude-code.nix
    ./pi-coding-agent.nix
    ./opencode.nix
    ./herdr.nix
    ./moshi.nix
    ./cli.nix
  ];

  # One live link per skill directory, so new files in a skill need no Nix change.
  xdg.configFile = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "agents/skills/${name}" {
      source = config.lib.file.mkOutOfStoreSymlink "${skillsPath}/${name}";
    }
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./skills));

  home.file = {
    ".agents/skills".source = config.lib.file.mkOutOfStoreSymlink skillsPath;
    ".claude/skills/show-me".source = config.lib.file.mkOutOfStoreSymlink "${skillsPath}/show-me";
  };
}

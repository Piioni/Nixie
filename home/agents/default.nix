{ config, ... }:
let
  skillsPath = "${config.nixie.home.repositoryRoot}/home/agents/skills";
in
{
  imports = [
    ./claude-code.nix
    ./pi-coding-agent.nix
    ./opencode.nix
  ];

  xdg.configFile = {
    "agents/skill/guided-learning/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/guided-learning/SKILL.md";
    "agents/skills/domain-modeling/ADR-FORMAT.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/domain-modeling/ADR-FORMAT.md";
    "agents/skills/domain-modeling/CONTEXT-FORMAT.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/domain-modeling/CONTEXT-FORMAT.md";
    "agents/skills/domain-modeling/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/domain-modeling/SKILL.md";
    "agents/skills/grilling/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/grilling/SKILL.md";
    "agents/skills/grill-me/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/grill-me/SKILL.md";
    "agents/skills/grill-with-docs/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/grill-with-docs/SKILL.md";
    "agents/skills/show-me/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${skillsPath}/show-me/SKILL.md";
  };

  home.file = {
    ".agents/skills".source = config.lib.file.mkOutOfStoreSymlink skillsPath;
    ".claude/skills/show-me".source = config.lib.file.mkOutOfStoreSymlink "${skillsPath}/show-me";
  };
}

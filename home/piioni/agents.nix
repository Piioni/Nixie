{ config, ... }:
{
  xdg.configFile = {
    "agents/skill/guided-learning/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skill/guided-learning/SKILL.md";
    "agents/skills/domain-modeling/ADR-FORMAT.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/domain-modeling/ADR-FORMAT.md";
    "agents/skills/domain-modeling/CONTEXT-FORMAT.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/domain-modeling/CONTEXT-FORMAT.md";
    "agents/skills/domain-modeling/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/domain-modeling/SKILL.md";
    "agents/skills/grilling/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/grilling/SKILL.md";
    "agents/skills/grill-me/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/grill-me/SKILL.md";
    "agents/skills/grill-with-docs/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/grill-with-docs/SKILL.md";
    "agents/skills/show-me/SKILL.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/piioni/agents/skills/show-me/SKILL.md";
  };
}

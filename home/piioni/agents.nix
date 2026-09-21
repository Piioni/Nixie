{ ... }:
{
  xdg.configFile = {
    "agents/skill" = {
      source = ./agents/skill;
      recursive = true;
    };

    "agents/skills" = {
      source = ./agents/skills;
      recursive = true;
    };
  };
}

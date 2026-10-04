{ config, ... }:
let
  link = path: config.lib.file.mkOutOfStoreSymlink "${sourceRoot}/${path}";
  sourceRoot = "${config.nixie.home.repositoryRoot}/home/agents/claude-code-config";
in
{
  programs.claude-code.enable = true;

  home.file = {
    ".claude/CLAUDE.md".source = link "CLAUDE.md";
    ".claude/output-styles/gentleman.md".source = link "output-styles/gentleman.md";
    ".claude/statusline.sh".source = link "statusline.sh";
  };
}

{ config, lib, ... }:
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

  # Claude Code, gentle-ai, herdr and moshi-hook all rewrite settings.json, so it
  # must stay writable: seed it once from the tracked template, never overwrite it.
  home.activation.seedClaudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.claude/settings.json" ]; then
      run rm -f "$HOME/.claude/settings.json"
      run install -Dm644 ${./claude-code-config/settings.json} "$HOME/.claude/settings.json"
    fi
  '';
}

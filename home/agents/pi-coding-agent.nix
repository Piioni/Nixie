{ config, ... }:
let
  sourceRoot = "${config.nixie.home.repositoryRoot}/home/agents/pi-agent-config";
  skillSymlinkPaths = [
    "skills/domain-modeling"
    "skills/grill-me"
    "skills/grill-with-docs"
    "skills/grilling"
    "skills/guided-learning"
    "skills/show-me"
  ];
  trackedPaths = [
    ".gitignore"
    "agents/jd-fix-agent.md"
    "agents/jd-judge-a.md"
    "agents/jd-judge-b.md"
    "agents/review-readability.md"
    "agents/review-reliability.md"
    "agents/review-resilience.md"
    "agents/review-risk.md"
    "extensions/claude-project-adapter/index.ts"
    "extensions/claude-project-adapter/package-lock.json"
    "extensions/claude-project-adapter/package.json"
    "extensions/claude-project-adapter/src/commands.ts"
    "extensions/claude-project-adapter/src/config.ts"
    "extensions/claude-project-adapter/src/frontmatter.ts"
    "extensions/claude-project-adapter/src/hooks.ts"
    "extensions/claude-project-adapter/src/index.ts"
    "extensions/claude-project-adapter/src/project.ts"
    "extensions/claude-project-adapter/src/rules.ts"
    "extensions/claude-project-adapter/test/hooks.test.ts"
    "extensions/claude-project-adapter/tsconfig.json"
    "extensions/herdr-agent-state.ts"
    "extensions/moshi-hooks.ts"
    "extensions/moshi-permission-bridge/index.ts"
    "extensions/moshi-permission-bridge/package.json"
    "extensions/moshi-permission-bridge/src/index.ts"
    "extensions/moshi-permission-bridge/tsconfig.json"
    "extensions/package.json"
    "extensions/pi-tool-display/config.json"
    "extensions/piioni-shell/index.ts"
    "extensions/piioni-shell/package.json"
    "extensions/piioni-shell/src/changes-overlay.ts"
    "extensions/piioni-shell/src/changes.ts"
    "extensions/piioni-shell/src/footer.ts"
    "extensions/piioni-shell/src/index.ts"
    "extensions/piioni-shell/src/prompt.ts"
    "extensions/piioni-shell/src/usage-overlay.ts"
    "extensions/piioni-shell/src/working-messages.ts"
    "extensions/piioni-shell/tsconfig.json"
    "extensions/ui-overhaul/index.ts"
    "extensions/ui-overhaul/package-lock.json"
    "extensions/ui-overhaul/package.json"
    "extensions/ui-overhaul/src/assistant-code-controls.ts"
    "extensions/ui-overhaul/src/code-blocks.ts"
    "extensions/ui-overhaul/src/code-copy.ts"
    "extensions/ui-overhaul/src/index.ts"
    "extensions/ui-overhaul/src/language-icons.ts"
    "extensions/ui-overhaul/src/lifecycle.ts"
    "extensions/ui-overhaul/src/markdown.ts"
    "extensions/ui-overhaul/src/prototype-patches.ts"
    "extensions/ui-overhaul/src/rendering.ts"
    "extensions/ui-overhaul/src/state.ts"
    "extensions/ui-overhaul/src/terminal.ts"
    "extensions/ui-overhaul/src/tool-message.ts"
    "extensions/ui-overhaul/src/types.ts"
    "extensions/ui-overhaul/src/user-message.ts"
    "extensions/ui-overhaul/test/assistant-code-controls.test.ts"
    "extensions/ui-overhaul/test/code-blocks.test.ts"
    "extensions/ui-overhaul/test/code-copy.test.ts"
    "extensions/ui-overhaul/test/tool-message.test.ts"
    "extensions/ui-overhaul/test/ui-overhaul.test.ts"
    "extensions/ui-overhaul/tsconfig.json"
    "extensions/verify-types.sh"
    "mcp-adapter.json"
    "pi-vcc-config.json"
    "skills/domain-modeling"
    "skills/grill-me"
    "skills/grill-with-docs"
    "skills/grilling"
    "skills/guided-learning"
    "skills/pi-customization/SKILL.md"
    "skills/show-me"
    "subagents.json"
    "themes/catppuccin-mocha.json"
  ];
in
{
  programs.pi-coding-agent.enable = true;

  # Let pi-tool-display own the built-in tool renderers instead of gentle-pi's quiet-tools.
  home.sessionVariables.GENTLE_PI_QUIET_TOOLS = "0";

  home.file = builtins.listToAttrs (
    map (path: {
      name = ".pi/agent/${path}";
      value = {
        source = config.lib.file.mkOutOfStoreSymlink "${sourceRoot}/${path}";
      }
      // (if builtins.elem path skillSymlinkPaths then { force = true; } else { });
    }) trackedPaths
  );
}

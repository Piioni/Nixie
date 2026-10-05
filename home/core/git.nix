{
  config,
  userfullname,
  useremail,
  ...
}:
{
  programs.git = {
    enable = true;
    ignores = [
      ".atl/"
      ".zed"
      ".teach/"
      ".opencode/"
      "odd/"
      ".pi/"
      "**/.claude/settings.local.json"
      ".pi-lens-probe-home/"
      ".fvm"
    ];
    settings = {
      # Personal identity by default; the include below switches to the work identity.
      user = {
        name = "Piioni";
        email = "rangelc.juane@gmail.com";
      };
      alias = {
        staash = "stash --all";
        rblame = "blame -w -C -C -C";
        wdiff = "diff --word-diff";
        safe-push = "push --force-with-lease --force-if-includes";
        l = "log --graph --pretty=format:'%C(yellow)%h%C(reset) %C(green)%ar%C(reset) %C(bold blue)%an%C(reset)%C(red)%d%C(reset) %s'";
      };
      init.defaultBranch = "main";
      apply.whitespace = "fix";
      column.ui = "auto";
      branch.sort = "-committerdate";
      tag.sort = "version:refname";
      commit.verbose = true;
      help.autocorrect = "prompt";
      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };
      merge.conflictStyle = "zdiff3";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      rerere = {
        enabled = true;
        autoupdate = true;
      };
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      pull.rebase = true;
      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };
    };
    # Work identity for every repository under ~/Sipos.
    includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/Sipos/";
        contents.user = {
          name = userfullname;
          email = useremail;
        };
      }
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };
}

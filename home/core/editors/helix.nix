{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    package = pkgs.helix;
    settings = {
      editor = {
        # Display & cursor
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        scrolloff = 8;

        # Use system clipboard by default.
        default-yank-register = "+";
        soft-wrap.enable = true;

        # Completion / formatting
        auto-format = true;
        preview-completion-insert = true;
        completion-timeout = 5;
        idle-timeout = 200;
        end-of-line-diagnostics = "hint";

        # Save to disk on focus loss and after idle.
        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 2000;
          };
        };

        # LSP: inlay hints, signature help, progress, and status messages.
        lsp = {
          display-messages = true;
          display-progress-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
        };

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };

        # Buffers tab strip, menu borders, and status line layout.
        bufferline = "multiple";
        popup-border = "menu";
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "workspace-diagnostics"
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-type"
            "file-encoding"
            "file-line-ending"
          ];
          separator = "│";
          diagnostics = [
            "error"
            "warning"
            "info"
          ];
          workspace-diagnostics = [
            "error"
            "warning"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        # Show dotfiles in the picker; project-wide ignores still apply.
        file-picker.hidden = false;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };

      keys.normal = {
        space.space = ":reload-all";
        esc = [
          "collapse_selection"
          "keep_primary_selection"
        ];
        space.w = ":w";
        space.q = ":q";

        # Useful Vim keybindings.
        "$" = "goto_line_end";
        "0" = "goto_line_start";

        # Zellij owns Ctrl+o (session mode), so jump_backward moves to Ctrl+Shift+o.
        "C-S-o" = "jump_backward";
      };
    };
  };
}

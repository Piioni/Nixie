# Environment variables.
$env.MANPAGER = "sh -c 'sed -u -e \"s/\\x1B\\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.TERMINAL = "ghostty"


# FZF defaults.
$env.FZF_DEFAULT_OPTS = "--color=bg+:#25394D,bg:-1,spinner:#F5E0DC,hl:#F38BA8 --color=fg:#CDD6F4,header:#F38BA8,info:#F5E0DC,pointer:#F5E0DC --layout=reverse --height=90% --preview-window noborder"

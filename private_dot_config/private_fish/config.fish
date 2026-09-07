# ~/.config/fish/config.fish
# Main Fish shell configuration — sourced for each new shell instance.
# Guarded by __fish_config_loaded so re-sourcing is a no-op (idempotent startup).
# Related: PATH/env lives in conf.d/00_env.fish (fish_add_path, idempotent),
# fzf keybindings in conf.d/fzf.fish (fzf_configure_bindings), and
# plugin declarations in fish_plugins (managed by fisher).

if set -q __fish_config_loaded
    exit
end
set -g __fish_config_loaded

if status is-interactive
    # Interactive-only prompt: initialize starship when installed.
    # `type -q` guard makes this a no-op on machines without starship,
    # keeping non-interactive / CI startup fast.
    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
end

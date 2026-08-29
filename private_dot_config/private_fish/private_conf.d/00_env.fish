complete --command kubecolor --wraps kubectl

set -gx LANG zh_CN.UTF-8
set -gx LC_ALL zh_CN.UTF-8

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 0
set -gx HOMEBREW_NO_ENV_HINTS 1

fish_add_path -g /opt/homebrew/bin \
    /opt/homebrew/sbin \
    /usr/local/bin \
    $HOME/.local/bin \
    $HOME/.cargo/bin \
    $HOME/.local/share/uv/bin

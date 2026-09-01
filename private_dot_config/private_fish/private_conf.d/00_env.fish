# ~/.config/fish/conf.d/00_env.fish
# Environment variables and PATH setup.
# Loaded automatically by Fish from conf.d (lexicographic order; 00_ prefix ensures early load).
# Guarded by __fish_env_loaded so re-sourcing does not duplicate PATH entries or re-register completions.

if set -q __fish_env_loaded
    exit
end
set -g __fish_env_loaded

# PATH injection — fish_add_path is idempotent (no duplicates on repeated sourcing).
# Prepends in order; first entry wins when binaries shadow each other.
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin /usr/local/bin $HOME/.local/bin
# $HOME/.cargo/bin           # Rust cargo binaries, when use curl install rustup
# $HOME/.local/share/uv/bin  # uv (Python) tool binaries


# kubecolor wraps kubectl for colorized output; only register completion when binary exists.
type -q kubecolor; and complete --command kubecolor --wraps kubectl

# Locale — ensure consistent UTF-8 handling across tools.
set -gx LANG zh_CN.UTF-8
set -gx LC_ALL zh_CN.UTF-8

# Editor — prefer nvim for interactive editing and visual mode.
set -gx EDITOR nvim
set -gx VISUAL nvim

# Homebrew — suppress hints/auto-update noise; keep cleanup on (0 = enabled).
set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx HOMEBREW_NO_INSTALL_CLEANUP 0
set -gx HOMEBREW_NO_ENV_HINTS 1


# clang — ensure clang binaries are in PATH.

# cpp — ensure C++ binaries are in PATH.

# rust — ensure Rust binaries are in PATH.

# zig -- ensure Zig binaries are in PATH.

# jvm-lang — ensure jvm binaries are in PATH.
## java 

## kotlin


# javascript runtime
## node — ensure Node.js binaries are in PATH.

## bun — ensure Bun binaries are in PATH.

## deno — ensure Deno binaries are in PATH.

# python — ensure Python binaries are in PATH.

# golang — ensure Go binaries are in PATH and GOPATH is set.
# set -gx GOROOT ~/.local/share/mise/installs/go/1.27.0
set -gx GOPROXY https://goproxy.cn,direct
set -gx GOPATH $HOME/.local/share/go
fish_add_path $GOPATH/bin

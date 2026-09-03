# ~/.config/fish/conf.d/fzf.fish
# fzf.fish key bindings and search integration (patrickf1/fzf.fish via fisher).
# Installs default fzf keybindings via fzf_configure_bindings (see functions/fzf_configure_bindings.fish).
# Guarded so re-sourcing is a no-op; skips entirely when non-interactive and not in CI
# to keep shell startup fast. Uninstall hook cleans bindings and vars on `fisher remove`.

if set -q __fish_fzf_loaded
    exit
end
set -g __fish_fzf_loaded

# fzf.fish is only meant for interactive use. Skip config to speed up non-interactive shells
# unless running in CI (where interactive checks are needed for tests).
if not status is-interactive && test "$CI" != true
    exit
end

# Capture shell variable state for _fzf_search_variables preview.
# Because of fish scoping rules, we must snapshot variables before entering fzf.
# Uses psub (process substitution) to store `set --show` and `set --names` in temp files;
# the filenames are passed as args. Global so fzf_configure_bindings and tests can reference it.
set --global _fzf_search_vars_command '_fzf_search_variables (set --show | psub) (set --names | psub)'

# Install default mnemonic bindings (ctrl-alt-f for directory, ctrl-r for history, etc.)
# Override via `fzf_configure_bindings --directory=...` in config.fish if needed.
fzf_configure_bindings

# Clean up bindings and variables when the plugin is removed via fisher.
# Autoloaded _fzf_* helper functions are not erased here (not easily accessible after unbinding).
function _fzf_uninstall --on-event fzf_uninstall
    _fzf_uninstall_bindings

    set --erase _fzf_search_vars_command
    functions --erase _fzf_uninstall _fzf_migration_message _fzf_uninstall_bindings fzf_configure_bindings
    complete --erase fzf_configure_bindings

    set_color cyan
    echo "fzf.fish uninstalled."
    echo "You may need to manually remove fzf_configure_bindings from your config.fish if you were using custom key bindings."
    set_color normal
end

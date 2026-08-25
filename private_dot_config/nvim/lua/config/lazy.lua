-- Lazy.nvim Configuration
-- This file configures lazy.nvim, the Neovim plugin manager.
-- It sets up plugin loading, defaults, installation, and update checking.

-- Bootstrap lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specification setup
require("lazy").setup({
    -- Specify plugins to load
    spec = {
        -- Add LazyVim and import its default plugins
        { "LazyVim/LazyVim",                                import = "lazyvim.plugins" },
        { import = "lazyvim.plugins.extras.lang.typescript" },
        { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.lang.rust" },
        { import = "lazyvim.plugins.extras.lang.go" },
        { import = "lazyvim.plugins.extras.lang.cmake" },
        { import = "lazyvim.plugins.extras.lang.docker" },
        { import = "lazyvim.plugins.extras.lang.yaml" },
        { import = "lazyvim.plugins.extras.lang.markdown" },
        { import = "lazyvim.plugins.extras.ui.mini-animate" },
        -- Import/override with your custom plugins
        { import = "plugins" },
    },

    -- Default settings for all plugins
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded.
        -- Your custom plugins will load during startup.
        -- Set to `true` to have all custom plugins lazy-loaded by default.
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin
        -- that support versioning, have outdated releases, which may break your
        -- Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins
        -- that support semver
    },

    -- Plugin installation settings
    install = {
        -- Automatically install colorschemes when LazyVim starts
        colorscheme = { "tokyonight", "habamax" },
    },

    -- Plugin update checking
    checker = {
        -- Enable or disable automatic plugin update checking
        enabled = true,
        -- Notify on update (set to false to disable notifications)
        notify = false,
    }, -- automatically check for plugin updates

    -- Performance settings
    performance = {
        -- Disable some built-in RTP plugins for improved startup speed
        rtp = {
            disabled_plugins = {
                -- "gzip",         -- Compression plugin
                -- "matchit",      -- Matchit plugin for :%s
                -- "matchparen",   -- Match paren highlighting
                -- "netrwPlugin",  -- Netrw plugin
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

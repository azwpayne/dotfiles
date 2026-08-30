-- ~/.config/nvim/lua/config/lazy.lua
-- Bootstrap lazy.nvim and configure all plugins via LazyVim.
-- Entry point required by init.lua (`require("config.lazy")`).

-- Bootstrap lazy.nvim into stdpath("data")/lazy/lazy.nvim if missing.
-- Uses shallow, blobless clone of the stable branch for speed.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core + default plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- Language & UI extras (source of truth; lazyvim.json `extras: []` is runtime metadata).
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
    -- Custom specs from lua/plugins/*.lua
    { import = "plugins" },
  },

  defaults = {
    lazy = false, -- custom plugins load at startup; set true to lazy-load all by default
    version = false, -- always latest git commit; version tags are often stale
  },

  install = {
    colorscheme = { "tokyonight", "habamax" }, -- fallback during first install before plugins load
  },

  checker = {
    enabled = true, -- auto-check for plugin updates
    notify = false, -- silent; see :Lazy check manually
  },

  performance = {
    rtp = {
      disabled_plugins = {
        -- Kept enabled: gzip, matchit, matchparen, netrwPlugin (needed by plugins/editing).
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- ~/.config/nvim/lua/config/autocmds.lua
-- Custom autocmds loaded on the VeryLazy event (after LazyVim defaults).
-- LazyVim already defines its own autocmds; this file only adds user overrides.
-- Each autocmd uses a dedicated augroup with { clear = true } so reloading
-- the config does not duplicate handlers.

-- Highlight yanked text briefly for visual feedback.
-- TextYankPost fires for any yank (including normal-mode `yy`), not just visual.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("user_yank_highlight", { clear = true }),
  desc = "Highlight yanked text with IncSearch (300ms)",
  callback = function()
    vim.highlight.on_yank({ timeout = 300, higroup = "IncSearch" })
  end,
})

-- Keep splits proportional when the terminal window is resized.
vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("user_resize_splits", { clear = true }),
  desc = "Equalize all splits on VimResized",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Show cursorline only in Normal mode; hide it while typing.
-- LazyVim enables cursorline by default; this toggles it off on InsertEnter.
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("user_cursorline_toggle", { clear = true }),
  desc = "Hide cursorline in Insert mode, restore in Normal mode",
  callback = function(ev)
    vim.opt.cursorline = ev.event == "InsertLeave"
  end,
})

-- NOTE: Python indentation (tabstop=4 / shiftwidth=4 / expandtab) is already
-- set globally in lua/config/options.lua and applies to every filetype.
-- A dedicated FileType autocmd for `python` would be redundant unless you
-- need a per-filetype override (e.g. different width). Add it here only
-- when you diverge from the global default.

-- Autocmd Configuration
-- This file contains custom autocmds for the Neovim setup.
-- Autocmds are automatically loaded on the VeryLazy event.

--
-- Highlight on yank (copy); TextYankPost fires for any-mode yanks (normal yy included), not just visual
-- When text is yanked, briefly highlight it using the IncSearch highlight group
-- to provide visual feedback that the yank was registered.
-- A timeout of 300ms ensures the highlight doesn't persist too long.
--

vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank({ timeout = 300, higroup = 'IncSearch' })
    end
})

--
-- Resize splits when window is resized
-- Creates an augroup called "ResizeWindows" that will be cleared before use.
-- On VimResized event (fires when window is resized), equalize all tabs
-- to ensure splits maintain proper proportions after resizing.
--


vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("ResizeWindows", { clear = true }),
    pattern = "*",
    callback = function()
        vim.cmd("tabdo wincmd =")
    end
})

--
-- Highlight cursor line only in normal mode (not while inserting)
-- Toggles cursorline highlighting during insert/exit insert mode.
-- When entering insert mode, cursorline is disabled; when leaving, it's re-enabled.
-- This prevents the cursor line from being highlighted while typing.
vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
    group = vim.api.nvim_create_augroup("HighlightCursorLine", { clear = true }),
    pattern = "*",
    callback = function(ev)
        vim.opt.cursorline = (ev.event == "InsertLeave")
    end
})

--
-- Set tab and indentation settings for Python files
-- Apply Python-specific indentation when FileType is "python".
-- Sets tabstop to 4 spaces, shiftwidth to 4, and uses expandtab for spaces.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("FileTypeSettings", { clear = true }),
    pattern = "python",
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.expandtab = true
    end
})

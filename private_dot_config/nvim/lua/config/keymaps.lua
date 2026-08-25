-- Keymap Configuration
-- This file contains custom key mappings for the Neovim setup.
-- Mappings are loaded after default LazyVim keymaps, so you can override
-- or extend the default behavior.

--
-- Leader key custom mappings

-- Toggle Undotree
-- Opens the undotree toggle which shows a visual history of changes
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {
    desc = "Toggle Undotree"
})

-- Exit insert mode by pressing jk
-- A convenient alternative to pressing the Escape key, especially for touch typists
vim.keymap.set("i", "jk", "<ESC>") -- exit insert mode by pressing jk

--
-- Additional recommended keymaps

-- Clear search highlights
-- Removes the highlight from search results when pressing <leader><space>
vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<CR>", {
    desc = "Clear search highlights"
})

-- Split window vertically
-- Split the current window into two vertical panes
vim.keymap.set("n", "<leader>sv", "<C-w>v", {
    desc = "Split window vertically"
})

-- Split window horizontally
-- Split the current window into two horizontal panes
vim.keymap.set("n", "<leader>sh", "<C-w>s", {
    desc = "Split window horizontally"
})

-- Close current buffer
-- Closes the current buffer while keeping the window layout intact
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", {
    desc = "Close current buffer"
})

-- Format code with LSP
-- Formats the current file using the language server protocol
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, {
    desc = "Format code with LSP"
})

-- Toggle relative line numbers
-- Switches between absolute and relative line numbering
vim.keymap.set("n", "<leader>rl", "<cmd>set relativenumber!<CR>", {
    desc = "Toggle relative line numbers"
})

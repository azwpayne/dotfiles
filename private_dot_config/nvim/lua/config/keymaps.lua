-- =============================================================================
-- keymaps.lua — 自定义键位 (chezmoi: lua/config/keymaps.lua)
-- =============================================================================
-- Description : 在 LazyVim 默认之后加载，可直接覆盖上游键位；全部带 desc 供
--               which-key 与 :map 查询，使用 vim.keymap.set（noremap+silent）。
-- Usage       : Leader 为 <Space>（LazyVim 默认）；按 <leader> 等待 which-key
-- Guards      : 无；键位定义幂等，重复加载覆盖同名映射
-- Last Updated: 2026-09-04 — 补全文件头、分组注释、收敛 desc 约束说明
-- Author      : Payne
-- =============================================================================
-- Custom keymaps loaded *after* LazyVim defaults, so you can override LazyVim here.
-- All mappings include `desc` for which-key and `:map`. Uses vim.keymap.set
-- (noremap + silent by default).

-- Insert mode: `jk` as quick Escape — hands stay on home row.
vim.keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- Normal mode — leader mappings

-- Clear hlsearch highlight without disabling hlsearch globally.
vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

-- Splits (discoverable via leader; same as <C-w>v / <C-w>s).
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })

-- Buffer: close current buffer, keep window layout (complements LazyVim's bufdelete).
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Close current buffer" })

-- Toggle relative numbers (useful for pair/mob or presentations).
vim.keymap.set("n", "<leader>rl", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative line numbers" })

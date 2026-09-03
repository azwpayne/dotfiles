-- =============================================================================
-- options.lua — 全局编辑器选项 (chezmoi: lua/config/options.lua)
-- =============================================================================
-- Description : 覆盖 LazyVim 默认的全局 vim.opt（仅增量覆盖，其余沿用上游）。
--               分组：行号、缩进、显示滚动、搜索、真彩与标尺；剪贴板/补全
--               刻意不覆盖（上游默认更优，见下方说明）。
-- Usage       : 在 LazyVim defaults 之后加载，值在此覆盖同名项；`:h <option>`
-- Guards      : 无外部依赖；所有选项幂等，重复加载安全
-- Last Updated: 2026-09-04 — 大规模工作流审计修复：移除 clipboard/completeopt
--               覆盖（前者破坏上游 SSH 感知默认，后者与上游逐字相同）
-- Author      : Payne
-- =============================================================================
-- Global editor options. Loaded *after* LazyVim's defaults, so values here
-- override LazyVim where they overlap. See `:h <option>` for details.
-- Only overrides and additions are set here; LazyVim handles the rest.

-- Clipboard / completion: deliberately NOT overridden. LazyVim's defaults are
-- smarter than static values here:
--   clipboard   — upstream is SSH-aware (empty over SSH_CONNECTION, enabling
--                 the OSC52 provider); a bare `unnamedplus` would break remote
--                 sessions, so it was removed from this file.
--   completeopt — upstream default is exactly `menu,menuone,noselect`; the
--                 former duplicate override (mislabeled as a customization)
--                 was removed.

-- Line numbers: absolute on current line + relative elsewhere for fast motions (e.g. 5j).
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation: 4-space spaces, no hard tabs. Global default; overrides per-filetype
-- can be added in autocmds.lua if a language needs a different width.
vim.opt.tabstop = 4 -- display width of <Tab>
vim.opt.shiftwidth = 4 -- size of >> / << and autoindent step
vim.opt.expandtab = true -- insert spaces instead of <Tab>
vim.opt.smartindent = true -- C-like smart indent (autoindent's smarter cousin)
vim.opt.autoindent = true -- copy indent from current line on new line

-- Display & scrolling
vim.opt.wrap = false -- no soft wrap; use `gq` or `:set wrap` per-buffer if needed
vim.opt.scrolloff = 8 -- keep 8 lines above/below cursor for context while scrolling
vim.opt.termguicolors = true -- 24-bit RGB required for tokyonight/catppuccin
vim.opt.colorcolumn = "100" -- ruler at 100 cols as line-length guide

-- Search: case-insensitive unless pattern contains uppercase; highlight + live preview.
vim.opt.ignorecase = true
vim.opt.smartcase = true -- overrides ignorecase when search contains uppercase
vim.opt.hlsearch = true -- highlight all matches (clear with <leader><space>)
vim.opt.incsearch = true -- show matches incrementally while typing
vim.opt.inccommand = "nosplit" -- live preview of :s/// in buffer (no split window)
vim.opt.showmatch = true -- briefly jump to matching bracket when cursor is on one

-- ~/.config/nvim/lua/config/options.lua
-- Global editor options. Loaded *after* LazyVim's defaults, so values here
-- override LazyVim where they overlap. See `:h <option>` for details.
-- Only overrides and additions are set here; LazyVim handles the rest.

-- Clipboard: share yank/paste with OS (requires clipboard provider: pbcopy/xclip).
vim.opt.clipboard = "unnamedplus"

-- Completion: show menu even for a single item, don't auto-select first entry.
-- Lets blink.cmp control selection explicitly (noselect + menuone).
vim.opt.completeopt = "menu,menuone,noselect"

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

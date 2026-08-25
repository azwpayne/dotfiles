-- Options Configuration
-- This file contains user-configurable options for the Neovim setup.
-- Modify these settings to customize your editor behavior.

--
-- General appearance and behavior
vim.opt.clipboard = "unnamedplus"             -- Use system clipboard
-- Enables the system clipboard so Neovim can copy/paste to/from the system clipboard.

vim.opt.completeopt = "menu,menuone,noselect" -- Better completion experience
-- Improves the completion experience by setting better menu options:
-- - menu: Show completion menu
-- - menuone: Show menu even when there's only one match
-- - noselect: Don't automatically select the first match

--
-- Line numbers and display settings
-- Set relative line numbers for easier navigation
vim.opt.number = true                         -- Show absolute line number
vim.opt.relativenumber = true                 -- Show relative line numbers
-- Displays both the absolute line number of the current line and relative
-- line numbers for other lines, making it easier to jump to specific lines.

--
-- Set tab and indentation settings
vim.opt.tabstop = 4                           -- Number of spaces that a <Tab> in the file counts for
vim.opt.shiftwidth = 4                        -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true                      -- Use spaces instead of tabs
vim.opt.smartindent = true                    -- Use smart indentation
vim.opt.autoindent = true                     -- Use auto indentation
vim.opt.wrap = false                          -- Disable line wrapping
vim.opt.scrolloff = 8                         -- Keep 8 lines visible when scrolling
-- Ensures at least 8 lines are visible above and below the cursor when scrolling,
-- making it easier to maintain context within the file.

--
-- Search settings
-- Improve search functionality and user experience
vim.opt.ignorecase = true                     -- Ignore case when searching
vim.opt.smartcase = true                      -- Override ignorecase if search contains uppercase letters
vim.opt.hlsearch = true                       -- Highlight search results
vim.opt.incsearch = true                      -- Show search results as you type
vim.opt.inccommand = "nosplit"                -- Show the effects of a command incrementally
vim.opt.showmatch = true                      -- Show matching brackets when text indicator is over them
-- These settings work together to provide a powerful search experience:
-- - ignorecase/smartcase: Smart case-insensitive searching
-- - hlsearch: Highlights all search results in the file
-- - incsearch: Moves the cursor to the match as you type, showing incremental results
-- - showmatch: Briefly jumps to matching bracket when the cursor is over them

--
-- Color scheme and visual settings
vim.opt.termguicolors = true                  -- Enable 24-bit RGB colors in the terminal
-- Enables true color support (24-bit RGB) which is required for many colorschemes
-- to display colors correctly in the terminal.

vim.opt.colorcolumn = "100"                   -- Line length marker at 100 columns
-- Highlights column 100 to serve as a visual marker for line length limits,
-- helping to keep code within a reasonable width.
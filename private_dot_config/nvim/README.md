# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim) — deployed via [chezmoi](https://www.chezmoi.io/) from `private_dot_config/nvim/` → `~/.config/nvim/`.

> **chezmoi 视角**：本文件随 `nvim/**` 部署到 `~/.config/nvim/README.md`。仓库级一致性校验（extras 清单 / 44 锁定 / 选项与键位逐行核对）见 [`docs/neovim.md`](../../docs/neovim.md)，二者互补不重复；改动配置以 `lua/config/*.lua` 与 `lazy-lock.json` 为权威。

## Overview

This is a Neovim configuration based on LazyVim, designed to provide a modern,
highly customizable editor experience with sensible defaults and a great out-of-the-box
setup. This configuration is managed as static files (no templates) and has been
enhanced with comprehensive comments throughout `lua/config/*.lua`.

- **Target**: Neovim ≥ 0.9 (verified on 0.12)
- **Manager**: [lazy.nvim](https://github.com/folke/lazy.nvim) with commit-level lock (`lazy-lock.json`, 44 plugins)
- **Extras**: 10 extras (9 `lang.*` + 1 `ui.mini-animate`, see `lua/config/lazy.lua`)
- **Style**: `stylua.toml` — Spaces, width 2, column 120; `catppuccin` as default colorscheme (via `lua/plugins/example.lua`)

## Installation

### Recommended: via chezmoi (this dotfiles repo)

```bash
# 1. Preview and apply (source is ~/.local/share/chezmoi)
chezmoi diff
chezmoi apply

# 2. Start Neovim — first launch bootstraps lazy.nvim and installs 44 plugins (needs network)
nvim
# :Lazy sync  — if you add plugins later
# :checkhealth — verify LSP / treesitter / provider health
```

No separate `git clone` is needed; `chezmoi apply` already places this directory at `~/.config/nvim/`.

### Standalone (without chezmoi)

If you use this `nvim/` directory outside chezmoi:

```bash
# 1. Backup existing config (optional but recommended)
mv ~/.config/nvim ~/.config/nvim.bak

# 2. Clone / copy this directory
git clone <your-fork-url> ~/.config/nvim
# or: cp -r private_dot_config/nvim ~/.config/nvim

# 3. Start Neovim (auto-bootstrap)
nvim
```

## Structure

```
~/.config/nvim/  (source: private_dot_config/nvim)
├── init.lua                  → require("config.lazy") only
├── lua/
│   ├── config/
│   │   ├── lazy.lua          bootstrap + spec (LazyVim + 10 extras + plugins)
│   │   ├── options.lua       global options (clipboard / numbers / 4-space indent / search / truecolor)
│   │   ├── keymaps.lua       custom keymaps (loaded after LazyVim defaults)
│   │   └── autocmds.lua      autocmds (loaded on VeryLazy)
│   └── plugins/
│       └── example.lua       example specs (effective: catppuccin / trouble / telescope / cmp-emoji / pyright / treesitter / mason)
├── lazy-lock.json            44 plugins locked by commit (reproducible)
├── lazyvim.json              LazyVim metadata (extras=[], news 11866, version 8 — extras empty is expected, real list is in lazy.lua)
├── stylua.toml               Spaces 2 / 120 columns
├── .gitignore                ignores tag / log / data
├── .neoconf.json             neoconf / lua_ls project settings
├── LICENSE                   MIT (LazyVim starter)
└── README.md                 this file
```

See [`docs/neovim.md`](../../docs/neovim.md) for the full chezmoi mapping (`dot_gitignore` → `.gitignore`, etc.) and `.chezmoiignore` notes.

## Features

### Extras (lua/config/lazy.lua — 10)

```lua
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
```

9 language extras + `mini-animate`. LSP / formatting / lint are handled by mason + nvim-lspconfig + conform + nvim-lint; mason prompts to install the server on first open of the relevant filetype. `lazyvim.json` `extras: []` is expected — LazyVim writes that file at runtime; the source of truth is `lazy.lua`.

### Locked Plugins (lazy-lock.json — 44)

`LazyVim`, `SchemaStore.nvim`, `blink.cmp`, `bufferline.nvim`, `catppuccin`, `cmake-tools.nvim`,
`conform.nvim`, `crates.nvim`, `flash.nvim`, `friendly-snippets`, `fzf-lua`, `gitsigns.nvim`,
`grug-far.nvim`, `lazy.nvim`, `lazydev.nvim`, `lualine.nvim`, `markdown-preview.nvim`,
`mason-lspconfig.nvim`, `mason.nvim`, `mini.ai`, `mini.animate`, `mini.icons`, `mini.pairs`,
`neo-tree.nvim`, `noice.nvim`, `nui.nvim`, `nvim-cmp`, `nvim-lint`, `nvim-lspconfig`,
`nvim-treesitter`, `nvim-treesitter-textobjects`, `nvim-ts-autotag`, `persistence.nvim`,
`plenary.nvim`, `render-markdown.nvim`, `rustaceanvim`, `snacks.nvim`, `telescope.nvim`,
`todo-comments.nvim`, `tokyonight.nvim`, `trouble.nvim`, `ts-comments.nvim`,
`venv-selector.nvim`, `which-key.nvim`.

> Update via `:Lazy update` (syncs lock file) / `:Lazy restore` (rollback). The shell `update-all` (brew/mise/sdk/…) does **not** touch Neovim plugins — the two channels are independent.

### Plugin Highlights (from lua/plugins/example.lua)

- **catppuccin** — set as LazyVim default `colorscheme` (overrides tokyonight)
- **trouble.nvim** — `use_diagnostic_signs = true`
- **telescope.nvim** — `<leader>fp` "Find Plugin File" + `horizontal / prompt_position=top / ascending` layout
- **nvim-cmp** — `cmp-emoji` source appended
- **nvim-lspconfig** — `pyright` enabled; `tsserver` example kept commented (use the `lang.typescript` extra instead)
- **nvim-treesitter** — `ensure_installed` includes bash/html/javascript/json/lua/markdown/markdown_inline/python/query/regex/tsx/typescript/vim/yaml (tsx/typescript appended twice via `list_extend`)
- **mason.nvim** — `ensure_installed` includes stylua / shellcheck / shfmt / flake8
- **lualine.nvim** — appends `😄` component (second spec is an empty override placeholder)
- *(commented, inactive)*: gruvbox, mini.starter, dap.python, gitsigns/json extras — keep as templates.

### Built-in Settings (lua/config/options.lua)

- **Line numbers**: `number` + `relativenumber` (absolute current, relative others)
- **Indent**: `tabstop=4` `shiftwidth=4` `expandtab` `smartindent` `autoindent` `wrap=false` (4-space)
- **Scroll**: `scrolloff=8`
- **Clipboard**: `unnamedplus` (system clipboard)
- **Completion**: `completeopt=menu,menuone,noselect`
- **Search**: `ignorecase` + `smartcase` + `hlsearch` + `incsearch` + `inccommand=nosplit` + `showmatch` (smart case, incremental highlight)
- **Colors**: `termguicolors` + `colorcolumn="100"` (true color, 100-column ruler)
- **Cursorline**: highlighted only in Normal mode (toggled via `InsertEnter`/`InsertLeave` autocmd)

### Key Mappings (lua/config/keymaps.lua)

Leader is `<Space>` (LazyVim default). Custom mappings loaded after defaults (so you can override):

| Keymap            | Mode | Action                      | Description                  |
| ----------------- | ---- | --------------------------- | ---------------------------- |
| `<leader>u`       | n    | `UndotreeToggle`            | Toggle Undotree ⚠️ (see note) |
| `jk`              | i    | `<ESC>`                     | Exit insert mode             |
| `<leader><space>` | n    | `<cmd>nohlsearch<CR>`       | Clear search highlights      |
| `<leader>sv`      | n    | `<C-w>v`                    | Split window vertically      |
| `<leader>sh`      | n    | `<C-w>s`                    | Split window horizontally    |
| `<leader>bd`      | n    | `<cmd>bdelete<CR>`          | Close current buffer         |
| `<leader>f`       | n    | `vim.lsp.buf.format`        | Format code with LSP         |
| `<leader>rl`      | n    | `<cmd>set relativenumber!<CR>` | Toggle relative line numbers |

> **Note**: `<leader>u` requires `mbbill/undotree` which is **not** in `lazy-lock.json` nor in `lua/plugins/`. Pressing it now yields `E492: Not an editor command`. Add `return { "mbbill/undotree" }` under `lua/plugins/` and run `:Lazy sync` to enable.

All other keys are LazyVim defaults (flash, neo-tree, snacks, bufferline, which-key, etc.). Press `<leader>` and wait for which-key to see the full list; full reference at [lazyvim.org/keymaps](https://www.lazyvim.org/keymaps).

### Autocmds (lua/config/autocmds.lua)

| Event | Group | Pattern | Action |
| ----- | ----- | ------- | ------ |
| `TextYankPost` | — | `*` | Highlight yank 300 ms with `IncSearch` |
| `VimResized` | `ResizeWindows` | `*` | `tabdo wincmd =` — equalize splits |
| `InsertEnter`/`InsertLeave` | `HighlightCursorLine` | `*` | Cursorline only in Normal mode |
| `FileType` | `FileTypeSettings` | `python` | Force `tabstop=4` `shiftwidth=4` `expandtab` |
| `BufWritePre` | `FormatOnSave` | `*.lua,*.py,*.js` | `vim.lsp.buf.format({ async=false })` on save |

## Customization

#### Adding Plugins

Create new files in `lua/plugins/` (or edit `lua/plugins/example.lua`). Every spec under `lua/plugins/` is auto-loaded by lazy.nvim:

```lua
-- lua/plugins/my.lua
return { "mbbill/undotree", cmd = "UndotreeToggle" }
```

The guard `-- if true then return {} end` at the top of `example.lua` is currently **commented out** (specs are active). Uncomment it to disable the file and use it as a pure template.

#### Modifying Options

Edit `lua/config/options.lua` for globals, or override via the `opts` field in a plugin spec.

#### Key Mappings

Add custom maps in `lua/config/keymaps.lua` (loaded after LazyVim defaults, so you can override). Use `desc` for which-key hints:

```lua
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
```

## Updating & Health

- **Check**: `:Lazy` — plugin status; `:checkhealth` — LSP / treesitter / providers.
- **Update**: `:Lazy update` (updates `lazy-lock.json`) · **Restore**: `:Lazy restore` · **Sync**: `:Lazy sync`.
- **Checker**: `lua/config/lazy.lua` sets `checker.enabled=true, notify=false` (silent background check).
- **Shell**: `update-all` / `auto_update` in `private_dot_config/zsh/aliases.zsh` cover brew/mise/sdk/… **only** — run `:Lazy update` separately for Neovim.

## Relationship to docs/neovim.md

- This README = **applied view** (`~/.config/nvim/README.md`) — installation, features, keymaps, settings.
- [`docs/neovim.md`](../../docs/neovim.md) = **repository view** — source structure, file-by-file mapping, extras provenance, lock verification, autocmd groups, and the `update-all` boundary.
- Both share the same numbers: **10 extras (9 lang + mini-animate)** and **44 locked plugins**; conflicts — `lua/config/*.lua` + `lazy-lock.json` win.

## License

MIT — See the [LICENSE](LICENSE) file for details.

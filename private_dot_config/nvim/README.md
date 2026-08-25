# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).

## Overview

This is a Neovim configuration based on LazyVim, designed to provide a modern,
highly customizable editor experience with sensible defaults and a great out-of-the-box
setup. This configuration has been enhanced with comprehensive comments and
documentation throughout the codebase.

## Installation

1. **Backup existing config** (optional but recommended):

```bash
mv ~/.config/nvim ~/.config/nvim.bak
```

1. **Clone this repository**:

```bash
git clone https://github.com/user/lazyvim-config.git ~/.config/nvim
```

2. **Start Neovim**:
   The first launch will automatically install plugins and set up the configuration.

## Features

### Default Plugins & Configuration

- **lazy.nvim** - Modern Neovim plugin manager
- **LazyVim** - Batteries-included Neovim distribution
- **Treesitter** - Language syntax highlighting and more
- **nvim-lspconfig** - Language server protocol configuration
- **telescope** - Fuzzy finder for files, grep, and more
- **lualine** - Status line plugin
- **which-key** - Keybinding popup helper
- **indent-blankline** - Visual indentation guides

### Enhanced Configuration

This configuration now includes:
- Comprehensive JSDoc-style comments in all Lua config files
- Detailed keymap descriptions with usage context
- Well-documented autocmd groups and their purposes
- Clear option explanations for easy customization

### Key Mappings

| Keymap            | Description                  |
| ----------------- | ---------------------------- |
| `<leader>u`       | Toggle Undotree              |
| `<leader><space>` | Clear search highlights      |
| `<leader>sv`      | Split window vertically      |
| `<leader>sh`      | Split window horizontally    |
| `<leader>bd`      | Close current buffer         |
| `<leader>f`       | Format code with LSP         |
| `<leader>rl`      | Toggle relative line numbers |

### Built-in Settings

- **Line numbers**: Relative line numbers with absolute current line
- **Tab completion**: 4-space tabs with smart indentation
- **Clipboard**: System clipboard integration
- **Search**: Smart case-insensitive searching with incremental highlighting
- **Colors**: True color support (24-bit RGB)

### Plugin Highlights

- **nvim-cmp**: Autocompletion with emoji support
- **trouble.nvim**: Diagnostic visualization
- **mason.nvim**: LSP/DAP/package installer
- **nvim-tree**: File explorer (if enabled)
- **gitsigns**: Git signs in the sign column

### Customization

#### Adding Plugins

Add your plugins to `lua/plugins/example.lua` or create new files in the
`lua/plugins/` directory. The config already includes:

- Plugin imports from `lazyvim.plugins`
- Custom plugin imports from `plugins`

#### Modifying Options

Edit `lua/config/options.lua` for global options, or use LazyVim's `opts`
field in your plugin specs.

#### Key Mappings

Add custom keymaps in `lua/config/keymaps.lua`. The file is loaded after
default LazyVim keymaps, so you can override or extend them.

## License

MIT - See the [LICENSE](LICENSE) file for details.
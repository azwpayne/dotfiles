# Neovim：LazyVim 配置

`private_dot_config/nvim/` 是基于 [LazyVim](https://www.lazyvim.org/) starter 的
Neovim 配置，目标 Neovim ≥ 0.9（本机验证版本 0.12）。

## 目录结构

```
nvim/
├── init.lua                  入口：仅 require("config.lazy")
├── lazy-lock.json            46 个插件的 commit 级锁定（可复现环境）
├── lazyvim.json              LazyVim 元数据（extras 为空、news 已读至 11866、version 8）
├── stylua.toml               Lua 格式化规则（Spaces 2 宽 120 列）
├── dot_gitignore             忽略 tag/log/data 等
├── dot_neoconf.json
└── lua/
    ├── config/
    │   ├── lazy.lua          lazy.nvim bootstrap 与插件 spec（含 9 个 extras + plugins 导入）
    │   ├── options.lua       全局选项
    │   ├── keymaps.lua       自定义键位（在 LazyVim 默认之后加载，可直接覆盖）
    │   └── autocmds.lua      自动命令（VeryLazy 时加载）
    └── plugins/example.lua   自定义插件 spec（往此目录加文件即生效，含示例配置）
```

> 本文档聚焦 chezmoi 视角的配置说明；编辑器功能全貌与安装步骤见
> 应用后的 `~/.config/nvim/README.md`，二者互补不重复。

## 启用的语言 Extras（lua/config/lazy.lua）

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

共 9 个 extras + `{ import = "plugins" }` 自定义目录。LSP/格式化/lint 由 LazyVim 内置的
mason + nvim-lspconfig + conform + nvim-lint 组合处理；首次打开对应语言文件时 mason
会提示安装相应 server。`lazyvim.json` 中 `extras` 数组当前为空（LazyVim 运行时写入），
不代表未启用 extras。

## 关键设置（lua/config/options.lua）

| 类别 | 配置 | 说明 |
| --- | --- | --- |
| 剪贴板 | `clipboard = "unnamedplus"` | 与系统剪贴板互通 |
| 行号 | `number` + `relativenumber` | 绝对行号 + 相对行号 |
| 补全 | `completeopt = "menu,menuone,noselect"` | 更好补全体验 |
| 缩进 | `tabstop=4` `shiftwidth=4` `expandtab` `smartindent` `autoindent` `wrap=false` | 4 空格缩进 |
| 滚动 | `scrolloff = 8` | 上下保留 8 行上下文 |
| 搜索 | `ignorecase` + `smartcase` + `hlsearch` + `incsearch` + `inccommand=nosplit` + `showmatch` | 智能大小写、增量高亮 |
| 视觉 | `termguicolors` + `colorcolumn="100"` | 真彩 + 100 列标线 |

## 插件管理策略（lazy.lua）

- `defaults.lazy = false`：自定义插件默认启动时加载；`version = false` 跟随最新 commit（不锁 semver）。
- `install.colorscheme = { "tokyonight", "habamax" }`。
- `checker.enabled = true, notify = false`：后台静默检查更新，不弹通知。
- `performance.rtp.disabled_plugins = { "tarPlugin", "tohtml", "tutor", "zipPlugin" }` 四项禁用来加速启动。
- **复现**：换机器后首次启动按 `lazy-lock.json` 安装同版本插件（当前 46 条，见下）。
- **升级**：`:Lazy update` 更新并同步 lock 文件；回滚用 `:Lazy restore`。

### lazy-lock.json（46 个）

当前锁定：`LazyVim`、`SchemaStore.nvim`、`blink.cmp`、`bufferline.nvim`、`catppuccin`、`cmake-tools.nvim`、
`conform.nvim`、`crates.nvim`、`flash.nvim`、`friendly-snippets`、`fzf-lua`、`gitsigns.nvim`、
`grug-far.nvim`、`lazy.nvim`、`lazydev.nvim`、`lualine.nvim`、`markdown-preview.nvim`、
`mason-lspconfig.nvim`、`mason.nvim`、`mini.ai`、`mini.animate`、`mini.icons`、`mini.pairs`、
`neo-tree.nvim`、`noice.nvim`、`nui.nvim`、`nvim-cmp`、`nvim-lint`、`nvim-lspconfig`、
`nvim-treesitter`、`nvim-treesitter-textobjects`、`nvim-ts-autotag`、`persistence.nvim`、
`plenary.nvim`、`render-markdown.nvim`、`rustaceanvim`、`snacks.nvim`、`telescope.nvim`、
`todo-comments.nvim`、`tokyonight.nvim`、`trouble.nvim`、`ts-comments.nvim`、
`venv-selector.nvim`、`which-key.nvim` 共 46 个，均为 `branch: main/master` + commit 锁定。

### stylua.toml / example.lua 补充

- `stylua.toml`：`indent_type = "Spaces"`, `indent_width = 2`, `column_width = 120`。
- `lua/plugins/example.lua` 为示例 spec，默认返回空 spec，仅演示如何覆盖 LazyVim、
  配置 trouble、nvim-cmp、telescope、lspconfig、treesitter、lualine、mason 等。

## 自定义键位速查（lua/config/keymaps.lua）

Leader 键为空格（LazyVim 默认），以下为叠加的自定义项（在 LazyVim 默认之后加载）：

| 键位 | 模式 | 动作 | 说明 |
| --- | --- | --- | --- |
| `<leader>u` | n | `UndotreeToggle` | 打开/关闭 Undotree |
| `jk` | i | `<ESC>` | 替代 Esc 退出插入模式 |
| `<leader><space>` | n | `<cmd>nohlsearch<CR>` | 清除搜索高亮 |
| `<leader>sv` | n | `<C-w>v` | 垂直分屏 |
| `<leader>sh` | n | `<C-w>s` | 水平分屏 |
| `<leader>bd` | n | `<cmd>bdelete<CR>` | 关闭当前 buffer |
| `<leader>f` | n | `vim.lsp.buf.format` | LSP 格式化当前文件 |
| `<leader>rl` | n | `<cmd>set relativenumber!<CR>` | 切换相对行号 |

其余键位沿用 LazyVim 默认（`<leader><space>` 面板、flash 跳转、neo-tree 等），
可用 `<leader>` 停顿唤出 which-key 查看全部。

## 自动命令（lua/config/autocmds.lua）

| 事件 | 分组 | 动作 |
| --- | --- | --- |
| `TextYankPost` | — | yank 后 300ms `IncSearch` 高亮反馈 |
| `VimResized` | `ResizeWindows` | 窗口尺寸变化后 `tabdo wincmd =` 均分所有分屏 |
| `InsertEnter` / `InsertLeave` | `HighlightCursorLine` | 仅普通模式高亮 `cursorline`（插入时关闭） |
| `FileType python` | `FileTypeSettings` | 局部强制 `tabstop=4` `shiftwidth=4` `expandtab` |
| `BufWritePre` `*.lua,*.py,*.js` | `FormatOnSave` | 保存前 `vim.lsp.buf.format({ async = false })` 同步格式化 |

## 与 private_dot_config/nvim/README.md 的分工

- 本文档（`docs/neovim.md`）：chezmoi 仓库视角，说明源文件结构、extras 清单、选项/键位/autocmds 与仓库实际一致性、lock 数量与 checker 策略。
- `private_dot_config/nvim/README.md`：应用后视角，面向新机器安装与功能概览（基于 LazyVim starter 模板，含备份、克隆、首次启动流程及插件特性介绍）。

二者互补不矛盾；改动配置时以 `lua/config/*.lua` 与 `lazy-lock.json` 为权威来源。

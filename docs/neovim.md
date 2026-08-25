# Neovim：LazyVim 配置

`private_dot_config/nvim/` 是基于 [LazyVim](https://www.lazyvim.org/) starter 的
Neovim 配置，目标 Neovim ≥ 0.9（本机验证 0.12）。源目录通过 `chezmoi apply` 渲染为
`~/.config/nvim/`（静态文件，无模板），首次启动由 `lua/config/lazy.lua` 自动 bootstrap
`lazy.nvim` 并按 `lazy-lock.json` 安装插件。

> **文档分工**：本文档是 chezmoi 仓库视角（结构 / extras / 选项 / 键位 / autocmds 与仓库实值逐行一致）；
> 编辑器面向用户的安装与功能概览见 [`private_dot_config/nvim/README.md`](../private_dot_config/nvim/README.md)
> （仓库内文档，由 `**/README.md` 排除、不部署到 `~/.config/nvim/README.md`），二者互补不重复，详细分工见文末。

## 目录结构

实际文件（`private_dot_config/nvim/**` → `~/.config/nvim/**`，`dot_*` 按 chezmoi 规则还原为 dotfile）：

```
nvim/  (private_dot_config/nvim → ~/.config/nvim)
├── init.lua                  入口：仅 require("config.lazy")
├── lua/
│   ├── config/
│   │   ├── lazy.lua          lazy.nvim bootstrap 与插件 spec（含 10 个 extras（9 lang + mini-animate）+ plugins 导入）
│   │   ├── options.lua       全局选项（clipboard / number / completeopt / tab 4 等）
│   │   ├── keymaps.lua       自定义键位（在 LazyVim 默认之后加载，可直接覆盖）
│   │   └── autocmds.lua      自动命令（VeryLazy 时加载）
│   └── plugins/
│       └── example.lua       自定义插件 spec（往此目录加文件即生效，含已生效的示例配置）
├── lazy-lock.json            44 个插件的 commit 级锁定（可复现环境，branch: main/master + commit）
├── lazyvim.json              LazyVim 元数据（extras 为空、news 已读至 11866、version 8；见下文说明）
├── stylua.toml               Lua 格式化规则（Spaces 2 宽 120 列）
├── dot_gitignore             → .gitignore  忽略 tag / log / data 等运行时产物
├── dot_neoconf.json          → .neoconf.json  LSP 项目级设置（neoconf / lua_ls 配置）
├── LICENSE                   上游 LazyVim starter 原件（Apache-2.0）；**/LICENSE 排除，不部署
└── README.md                 仓库内文档（LazyVim starter 模板）；**/README.md 排除，不部署
```

> 完整映射与忽略规则见 [layout.md](layout.md)；`.chezmoiignore` 已修复为按目标名匹配的 `**/README.md` / `**/LICENSE`，
> 本目录的 `README.md` 与 `LICENSE` 不再随 `nvim/**` 部署（历史上的 `**/REAMDME.md` 拼写失配已修复）。
> `LICENSE` 为上游 LazyVim starter 原件（Apache-2.0，与根 LICENSE 同哈希；nvim/README.md 中
> "MIT" 的旧表述与上游实发内容不符，上游与根 LICENSE 均为 Apache-2.0）。

## 启用的 Extras（lua/config/lazy.lua）

`lua/config/lazy.lua` 中 `spec` 逐行导入（与文件实值完全一致）：

```lua
{ "LazyVim/LazyVim", import = "lazyvim.plugins" },
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
{ import = "plugins" },
```

共 **10 个 extras**（9 个 `lang.*`: typescript / json / python / rust / go / cmake / docker / yaml / markdown
+ 1 个 `ui.mini-animate`）+ `{ import = "plugins" }` 自定义目录。
LSP / 格式化 / lint 由 LazyVim 内置的 mason + nvim-lspconfig + conform + nvim-lint 组合处理；
首次打开对应语言文件时 mason 会提示安装相应 server。

`lazyvim.json` 中 `extras` 为空数组是预期行为——该文件由 LazyVim 运行时写入（当前仅持久化 `news.NEWS.md=11866`
与 `version=8`），不代表未启用 extras；真实启用清单以 `lazy.lua` 的 `import` 为准。

## 关键设置（lua/config/options.lua）

逐项与 `options.lua` 实值一致（节选核心，注释与取值均保留原语义）：

| 类别 | 配置（`vim.opt`） | 说明 |
| --- | --- | --- |
| 剪贴板 | `clipboard = "unnamedplus"` | 与系统剪贴板互通 |
| 行号 | `number = true` + `relativenumber = true` | 绝对行号 + 相对行号，便于跳行 |
| 补全 | `completeopt = "menu,menuone,noselect"` | menu / menuone / noselect 三件套 |
| 缩进 | `tabstop = 4` `shiftwidth = 4` `expandtab = true` `smartindent` `autoindent` `wrap = false` | 4 空格缩进，不折行 |
| 滚动 | `scrolloff = 8` | 上下保留 8 行上下文 |
| 搜索 | `ignorecase` + `smartcase` + `hlsearch` + `incsearch` + `inccommand = "nosplit"` + `showmatch` | 智能大小写、增量高亮、括号匹配 |
| 视觉 | `termguicolors = true` + `colorcolumn = "100"` | 真彩 24-bit + 100 列标线 |

> 其余视觉/缩进细节（如 Python `FileType` 局部 4 空格）见下文 autocmds；`cursorline` 仅在普通模式高亮（`InsertEnter/Leave` 切换）。

## 插件管理策略（lua/config/lazy.lua）

- **bootstrap**：`vim.fn.stdpath("data") .. "/lazy/lazy.nvim"` 不存在时执行
  `git clone --filter=blob:none --branch=stable https://github.com/folke/lazy.nvim.git`，失败时 `nvim_echo` 报错并 `os.exit(1)`；
  无论是否新克隆，随后均 `vim.opt.rtp:prepend(lazypath)`，幂等可重复启动。
- `defaults.lazy = false`：自定义插件默认启动时加载；`version = false` 跟随最新 commit（不锁 semver，`version = "*"` 为注释备选）。
- `install.colorscheme = { "tokyonight", "habamax" }`：首次安装时自动尝试这两套配色。
- `checker.enabled = true, notify = false`：后台静默检查更新，不弹通知。
- `performance.rtp.disabled_plugins = { "tarPlugin", "tohtml", "tutor", "zipPlugin" }` 四项禁用来加速启动（其余 `gzip/matchit/matchparen/netrwPlugin` 保持注释未禁用）。
- **复现**：换机器后首次 `nvim` 按 `lazy-lock.json` 安装同版本插件（当前 44 条，见下节）。
- **升级 / 回滚**：`:Lazy update` 更新并同步 lock 文件；`:Lazy restore` 回滚到 lock 锁定版本；`:Lazy sync` 一键清理/安装/更新。
- **与 shell `update-all` 无关联**：`private_dot_config/zsh/aliases.zsh` 中的 `update-all` 仅覆盖 `brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise` 六项，不触及 Neovim 插件；两者更新通道相互独立（`auto_update` 为其中 5 项子集，亦不含 Neovim）。

### lazy-lock.json（44 个）

验证：`python3 -c "import json; print(len(json.load(open('private_dot_config/nvim/lazy-lock.json'))))"` → `44`。
当前锁定（按字母序，均为 `branch: main/master` + commit）：

`LazyVim`、`SchemaStore.nvim`、`blink.cmp`、`bufferline.nvim`、`catppuccin`、`cmake-tools.nvim`、
`conform.nvim`、`crates.nvim`、`flash.nvim`、`friendly-snippets`、`fzf-lua`、`gitsigns.nvim`、
`grug-far.nvim`、`lazy.nvim`、`lazydev.nvim`、`lualine.nvim`、`markdown-preview.nvim`、
`mason-lspconfig.nvim`、`mason.nvim`、`mini.ai`、`mini.animate`、`mini.icons`、`mini.pairs`、
`neo-tree.nvim`、`noice.nvim`、`nui.nvim`、`nvim-cmp`、`nvim-lint`、`nvim-lspconfig`、
`nvim-treesitter`、`nvim-treesitter-textobjects`、`nvim-ts-autotag`、`persistence.nvim`、
`plenary.nvim`、`render-markdown.nvim`、`rustaceanvim`、`snacks.nvim`、`telescope.nvim`、
`todo-comments.nvim`、`tokyonight.nvim`、`trouble.nvim`、`ts-comments.nvim`、
`venv-selector.nvim`、`which-key.nvim` 共 44 个。

> 清单与 `lazy-lock.json` 实值一一对应；新增/删除插件后需提交更新后的 lock 文件以保持可复现。

### stylua.toml / example.lua 补充

- `stylua.toml`：`indent_type = "Spaces"`、`indent_width = 2`、`column_width = 120`（与文件实值一致）。
- `lua/plugins/example.lua`：
  - 顶部守卫 `-- if true then return {} end` 当前为**注释状态**（守卫未生效），故文件内示例配置**实际生效**；如只想当模板用，应取消该行注释。
  - 已生效的示例包括：`LazyVim/LazyVim` 强制 `colorscheme = "catppuccin"`；`trouble.nvim` 的 `use_diagnostic_signs = true`；
    `telescope.nvim` 的 `<leader>fp` "Find Plugin File"（`cwd = require("lazy.core.config").options.root`）及 `horizontal / prompt_position=top / ascending` 布局；
    `nvim-cmp` 追加 `cmp-emoji` 源；`nvim-lspconfig` 的 `pyright = {}`；`nvim-treesitter` 的 `ensure_installed`（bash/html/javascript/json/lua/markdown/markdown_inline/python/query/regex/tsx/typescript/vim/yaml）及后续 `vim.list_extend` 对 `tsx/typescript` 的重复追加；
    `mason.nvim` 的 `ensure_installed`（stylua / shellcheck / shfmt / flake8）；`lualine.nvim` 的 `😄` 组件追加与全量覆盖两段示例（后者为空表占位）。
  - 注释中未生效的示例：`gruvbox.nvim`、`tsserver + typescript.nvim`、`mini.starter`、`dap.python`、`gitsigns` extras、`jsonls/schemastore` 等，仅作模板参考。

## 自定义键位速查（lua/config/keymaps.lua）

Leader 为空格（LazyVim 默认），以下为本仓库在 LazyVim 默认之后叠加的自定义项（与 `keymaps.lua` 实值一致；`desc` 如实保留，仅 `jk` 一项源文件未设 `desc`）：

| 键位 | 模式 | 动作 | 说明（`desc`） |
| --- | --- | --- | --- |
| `<leader>u` | n | `vim.cmd.UndotreeToggle` | Toggle Undotree（⚠️ 见下方注意） |
| `jk` | i | `<ESC>` | 替代 Esc 退出插入模式 |
| `<leader><space>` | n | `<cmd>nohlsearch<CR>` | Clear search highlights |
| `<leader>sv` | n | `<C-w>v` | Split window vertically |
| `<leader>sh` | n | `<C-w>s` | Split window horizontally |
| `<leader>bd` | n | `<cmd>bdelete<CR>` | Close current buffer |
| `<leader>f` | n | `vim.lsp.buf.format` | Format code with LSP |
| `<leader>rl` | n | `<cmd>set relativenumber!<CR>` | Toggle relative line numbers |

> **注意 — `<leader>u` 依赖缺失**：`lazy-lock.json` 未锁定 `mbbill/undotree` 且 `lua/plugins/` 下无对应 spec，直接按下会报 `E492: Not an editor command: UndotreeToggle`。
> 如需使用，请在 `lua/plugins/` 下新增独立 spec，例如 `return { "mbbill/undotree" }`，再 `:Lazy sync`。

其余键位沿用 LazyVim 默认（flash 跳转、neo-tree、snacks 面板、bufferline、which-key 等），
可用 `<leader>` 停顿唤出 which-key 查看全部。详尽的 LazyVim 默认键位见 [LazyVim 官网](https://www.lazyvim.org/keymaps)。

## 自动命令（lua/config/autocmds.lua）

与 `autocmds.lua` 实值一致（均在 `VeryLazy` 之后加载）：

| 事件 | 分组（`augroup`） | 模式/范围 | 动作 |
| --- | --- | --- | --- |
| `TextYankPost` | —（无分组，可考虑加入 `augroup` 以便清理） | `*` | yank 后 300ms `IncSearch` 高亮反馈（`vim.highlight.on_yank({ timeout=300, higroup="IncSearch" })`） |
| `VimResized` | `ResizeWindows`（`clear = true`） | `*` | `tabdo wincmd =` 均分所有 tab 的分屏 |
| `InsertEnter` / `InsertLeave` | `HighlightCursorLine` | `*` | 仅普通模式高亮 `cursorline`（`InsertEnter` 关闭，`InsertLeave` 开启） |
| `FileType` | `FileTypeSettings` | `python` | 局部强制 `tabstop=4` `shiftwidth=4` `expandtab` |
| `BufWritePre` | `FormatOnSave` | `*.lua,*.py,*.js` | 保存前 `vim.lsp.buf.format({ async = false })` 同步格式化 |

> `TextYankPost` 目前未建 `augroup`，重复 `source` 时会叠加回调，建议后续补 `nvim_create_augroup("YankHighlight", { clear = true })`。

## 与 private_dot_config/nvim/README.md 的分工

- 本文档（`docs/neovim.md`）：**chezmoi 仓库视角**，面向维护者，逐行核对源文件与目标路径、extras 清单、选项/键位/autocmds 实值、lock 数量与 checker 策略、与 shell `update-all` 的边界。
- `private_dot_config/nvim/README.md`（仓库内文档，由 `**/README.md` 排除、不再部署到 `~/.config/nvim/README.md`）：**应用后视角**，面向新机器使用者，基于 LazyVim starter 模板的安装步骤、功能概览、键位与设置速览，术语与本文档保持一致（10 extras / 44 锁定 / 键位 8 项等）。

二者互补不矛盾；改动配置时以 `lua/config/*.lua` 与 `lazy-lock.json` 为权威来源。
术语统一：`extras` 指 `lazyvim.plugins.extras.*` 的 `import`；`lazy-lock.json` 为 commit 级锁定；`checker` 指 `lazy.lua` 的更新检查。

## 参见

- [仓库结构与映射](layout.md) · [安装与验证](getting-started.md) · [维护流程](maintenance.md)
- 子目录 README（仓库内，不部署）：[`private_dot_config/nvim/README.md`](../private_dot_config/nvim/README.md)
- 上游文档：[LazyVim](https://www.lazyvim.org/) · [lazy.nvim](https://github.com/folke/lazy.nvim)

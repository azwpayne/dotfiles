# Neovim：LazyVim 配置

`private_dot_config/nvim/` 是基于 [LazyVim](https://www.lazyvim.org/) starter 的
Neovim 配置，目标 Neovim ≥ 0.9（本机验证版本 0.12）。

## 目录结构

```
nvim/
├── init.lua                  入口：仅 require("config.lazy")
├── lazy-lock.json            44 个插件的 commit 级锁定（可复现环境）
├── lazyvim.json              LazyVim 元数据（extras 记录、news 已读状态）
├── stylua.toml               Lua 格式化规则
└── lua/
    ├── config/
    │   ├── lazy.lua          lazy.nvim bootstrap 与插件 spec
    │   ├── options.lua       全局选项
    │   ├── keymaps.lua       自定义键位（在 LazyVim 默认之后加载，可直接覆盖）
    │   └── autocmds.lua      自动命令（VeryLazy 时加载）
    └── plugins/example.lua   自定义插件 spec（往此目录加文件即生效）
```

## 启用的语言 Extras（lazy.lua）

typescript · json · python · rust · go · cmake · docker · yaml · markdown，
外加 `mini-animate`（光标/滚动动画）。

LSP/格式化/lint 由 LazyVim 内置的 mason + nvim-lspconfig + conform + nvim-lint 组合处理；
首次打开对应语言文件时 mason 会提示安装相应 server。

## 关键设置

| 类别 | 配置 |
| --- | --- |
| 剪贴板 | `clipboard = unnamedplus`（与系统剪贴板互通） |
| 行号 | 绝对行号 + 相对行号 |
| 缩进 | tab = 4 空格、`expandtab`、smartindent |
| 搜索 | ignorecase + smartcase + 高亮增量搜索 |
| 视觉 | truecolor、100 列标线、scrolloff = 8 |

## 插件管理策略

- `defaults.lazy = false`：自定义插件默认启动时加载；`version = false` 跟随最新 commit。
- `checker.enabled = true, notify = false`：后台静默检查更新，不弹通知。
- rtp 精简：禁用 `tarPlugin` / `tohtml` / `tutor` / `zipPlugin` 加速启动。
- **复现**：换机器后首次启动按 `lazy-lock.json` 安装同版本插件。
- **升级**：`:Lazy update` 更新并同步 lock 文件；回滚用 `:Lazy restore`。

## 自定义键位速查（keymaps.lua）

Leader 键为空格（LazyVim 默认），以下为叠加的自定义项：

| 键位 | 模式 | 动作 |
| --- | --- | --- |
| `<leader>u` | n | 打开/关闭 Undotree |
| `jk` | i | 替代 Esc 退出插入模式 |
| `<leader><space>` | n | 清除搜索高亮 |
| `<leader>sv` / `<leader>sh` | n | 垂直 / 水平分屏 |
| `<leader>bd` | n | 关闭当前 buffer |
| `<leader>f` | n | LSP 格式化当前文件 |

其余键位沿用 LazyVim 默认（`<leader><space>` 面板、flash 跳转、neo-tree 等），
可用 `<leader>` 停顿唤出 which-key 查看全部。

## 自动命令（autocmds.lua）

- `TextYankPost`：yank 后 300ms 高亮反馈；
- `VimResized`：窗口尺寸变化后自动均分所有分屏；
- `InsertEnter/InsertLeave`：仅普通模式下高亮光标行；
- `FileType python`：局部强制 4 空格缩进；
- `BufWritePre`（`*.lua` / `*.py` / `*.js`）：保存前 LSP 格式化（同步）。

## 使用说明文档

应用后的 `~/.config/nvim/README.md` 含完整功能介绍与安装步骤；
上游参考：<https://github.com/LazyVim/starter>。

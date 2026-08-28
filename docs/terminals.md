# 终端：Ghostty（主力）与 Alacritty（备用）

两套配置共用 `JetBrainsMono Nerd Font Mono`（字号均为 15），可独立安装、互不依赖。Ghostty 为日常主力（支持热重载、Quick Terminal），Alacritty 为轻量备用。

> **分工**：本文件只记录终端模拟器自身配置。提示符与配色方案的完整定义（`palette = 'catppuccin_mocha'`、powerline `format`、各段样式与符号）见 [shell.md — Starship 提示符](shell.md#starship-提示符starshiptoml)，本文仅保留 `theme = Catppuccin Mocha` 与之呼应的说明，不重复 Starship 细节。

---

## Ghostty — `private_dot_config/ghostty/config`

配置文件路径 `~/.config/ghostty/config`，查看最终生效值：`ghostty +show-config`（`--default --docs` 可对照默认值）。
> 注：`ghostty` CLI 不默认在 PATH 中，需先在 Ghostty 菜单 → "Install CLI tool" 安装；或用全路径 `/Applications/Ghostty.app/Contents/MacOS/ghostty`。
文件含较多注释掉的备用方案（`fish -l`、`tmux`、`Dracula+` 等），下表仅列生效值。

### 环境与启动

| 配置                               | 值                 | 说明                                                                                       |
| ---------------------------------- | ------------------ | ------------------------------------------------------------------------------------------ |
| `env`                              | `LANG=zh_CN.UTF-8` | 显式声明中文 UTF-8，避免远端/脚本 locale 回退；与 `dot_zshrc:7` 的 `export LANG=zh_CN.UTF-8` 一致 |
| `command`                          | `/bin/zsh -l`      | 登录 shell 启动；`fish -l` / `tmux new -As main` 已注释备用                                |
| `window-inherit-working-directory` | `true`             | 新标签页/分屏继承当前目录，保持上下文                                                      |
| `window-inherit-font-size`         | `true`             | 新 surface 继承字号                                                                        |

### 外观

| 配置                                                                      | 值                                            | 说明                                                        |
| ------------------------------------------------------------------------- | --------------------------------------------- | ----------------------------------------------------------- |
| `theme`                                                                   | `Catppuccin Mocha`                            | 与 Starship 调色板呼应；`Dracula+` / `Warm Neon` 已注释备用 |
| `font-family`                                                             | `JetBrainsMono Nerd Font Mono`                | Nerd Font 变体，提供 powerline/OS/目录图标字形              |
| `font-size`                                                               | `15`                                          | 与 Alacritty `size = 15` 一致                               |
| `font-feature`                                                            | `+calt`                                       | 上下文连字                                                  |
| `font-thicken` / `font-thicken-strength`                                  | `true` / `1`                                  | macOS 加粗渲染                                              |
| `alpha-blending`                                                          | `linear`                                      | 线性透明度混合，配合毛玻璃更平滑                            |
| `adjust-cell-height` / `adjust-cell-width`                                | `2` / `-1`                                    | 微调行高/字间距，适配 Nerd Font 字形                        |
| `background-opacity` / `background-blur-radius`                           | `0.92` / `20`                                 | 轻毛玻璃效果                                                |
| `window-padding-x` / `window-padding-y`                                   | `12` / `12` + `window-padding-balance = true` | 文字不贴边，四边均衡                                        |
| `window-theme`                                                            | `auto`                                        | 跟随系统明暗                                                |
| `window-decoration` / `macos-window-shadow` / `macos-titlebar-proxy-icon` | `true` / `false` / `hidden`                   | 保留原生装饰但去阴影、隐藏标题栏代理图标                    |
| `cursor-style` / `cursor-style-blink` / `cursor-opacity` / `cursor-color` | `block` / `true` / `0.8` / `#ff0000`          | 块状闪烁光标，红色                                          |
| `mouse-hide-while-typing`                                                 | `true`                                        | 输入时自动隐藏指针                                          |
| `mouse-scroll-multiplier`                                                 | `1.0`                                         | 滚轮保持原速                                                |
| `resize-overlay`                                                          | `never`                                       | 调整窗口时不显示浮层                                        |
| `window-save-state`                                                       | `always`                                      | 重启恢复窗口布局                                            |
| `window-width` / `window-height`                                          | `0` / `0`                                     | 自适应默认尺寸                                              |

### 键位

与 `config` 中 `keybind` 逐条核对（16 条生效 + 1 条注释）：

| 按键                                  | 动作                             | 对应配置                                                            |
| ------------------------------------- | -------------------------------- | ------------------------------------------------------------------- |
| `Cmd+T`                               | 新建标签页                       | `cmd+t=new_tab`                                                     |
| `Cmd+W`                               | 关闭当前 surface                 | `cmd+w=close_surface`                                               |
| `Cmd+Shift+←` / `Cmd+Shift+→`         | 上一个 / 下一个标签页            | `previous_tab` / `next_tab`                                         |
| `Cmd+D`                               | 右分屏                           | `new_split:right`                                                   |
| `Cmd+Shift+D`                         | 下分屏                           | `new_split:down`                                                    |
| `Cmd+Alt+←` / `→` / `↑` / `↓`         | 在分屏间移动焦点                 | `goto_split:left` / `right` / `top` / `bottom`                      |
| `Cmd+Shift+E`                         | 均分分屏                         | `equalize_splits`                                                   |
| `Cmd+Shift+F`                         | 放大/还原当前分屏                | `toggle_split_zoom`                                                 |
| `Cmd+Plus` / `Cmd+Minus` / `Cmd+Zero` | 字号 +1 / −1 / 复位              | `increase_font_size:1` / `decrease_font_size:1` / `reset_font_size` |
| `Ctrl+\``（全局）                     | 呼出/收起 Quake 风格下拉快速终端 | `global:ctrl+grave_accent=toggle_quick_terminal`                    |

> 重新加载配置 `reload_config` 的 `# keybind = cmd+shift+comma=reload_config` 行虽已注释，但它是 Ghostty v1.3.1 的内置默认键位（本配置未执行 `keybind = clear`），`Cmd+Shift+,` 重载依然生效；注释行仅是重复声明默认键位。如需禁用可 `keybind = clear` 后重绑。

### 安全与 macOS 专项

| 配置                                  | 值                 | 说明                                                                                               |
| ------------------------------------- | ------------------ | -------------------------------------------------------------------------------------------------- |
| `macos-option-as-alt`                 | `right`            | 仅右 Option 作为 Alt，左 Option 保留用于输入特殊字符；另有 `# macos-option-as-alt = true` 注释备用 |
| `clipboard-read` / `clipboard-write`  | `allow`            | 允许读写系统剪贴板                                                                                 |
| `clipboard-paste-protection`          | `true`             | 粘贴保护（多行粘贴前确认）                                                                         |
| `clipboard-paste-bracketed-safe`      | `true`             | bracketed paste 安全校验                                                                           |
| `clipboard-trim-trailing-spaces`      | `true`             | 自动去行尾空格                                                                                     |
| `copy-on-select`                      | `clipboard`        | 选中即复制到系统剪贴板                                                                             |
| `quit-after-last-window-closed`       | `true`             | 关闭最后窗口即退出                                                                                 |
| `confirm-close-surface`               | `false`            | 关闭 surface 不二次确认                                                                            |
| `auto-update` / `auto-update-channel` | `check` / `stable` | 异步检查稳定版更新，不阻塞启动                                                                     |

**Quick Terminal（下拉终端）：**

| 配置                                | 值     | 说明                                             |
| ----------------------------------- | ------ | ------------------------------------------------ |
| `quick-terminal-position`           | `top`  | 顶部下拉                                         |
| `quick-terminal-screen`             | `main` | 主屏显示（去重后唯一赋值，即去重前的实际生效值） |
| `quick-terminal-autohide`           | `true` | 失焦自动收起                                     |
| `quick-terminal-animation-duration` | `0.15` | 动画 150ms                                       |

### 性能与存储

| 配置                  | 值                   | 说明                                             |
| --------------------- | -------------------- | ------------------------------------------------ |
| `scrollback-limit`    | `67108864`（64MB）   | 宽裕回滚，约 64 × 1024 × 1024 字节               |
| `image-storage-limit` | `268435456`（256MB） | Kitty Graphics Protocol 图像上限，适配 16GB 机型 |
| `gtk-single-instance` | `true`               | Linux 单实例优化（macOS 下无影响）               |

> ✅ **重复键已清理（行为不变）**：历史上 9 个键（`font-thicken`、`font-thicken-strength`、`adjust-cell-height`、`mouse-hide-while-typing`、`macos-option-as-alt`、`macos-window-shadow`、`quick-terminal-screen`、`quick-terminal-animation-duration`、`resize-overlay`）曾有重复赋值，已按 Ghostty「末次赋值生效」语义去重为单次赋值：保留末次值、删除前面的重复行，去重后的实际行为与去重前完全一致（唯一值有分歧的 `quick-terminal-screen` 保留生效值 `main`）。16 条 `keybind` 多绑定属有意设计，未动。

---

## Alacritty — `private_dot_config/alacritty/alacritty.toml`

轻量备用，`Dracula` 配色底。与 Ghostty 互为独立配置，切换无需改另一文件。

### 基础

| 配置                          | 值                   | 说明                                                                                                                                     |
| ----------------------------- | -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| `env.TERM`                    | `xterm-256color`     | 兼容远端主机着色                                                                                                                         |
| `window.startup_mode`         | `Fullscreen`         | 启动即全屏                                                                                                                               |
| `window.blur`                 | `true`               | 毛玻璃                                                                                                                                   |
| `window.option_as_alt`        | `OnlyRight`          | 仅右 Option 作 Alt，与 Ghostty `right` 策略一致                                                                                          |
| `selection.save_to_clipboard` | `true`               | 选中即复制                                                                                                                               |
| `terminal.shell`              | 无生效值（均已注释） | 实际启动登录用户的默认 `$SHELL`（本机为 zsh），与 Ghostty 显式指定 `/bin/zsh -l` 不同；`fish` 直启 / `tmux attach` 等 3 种方案已注释备用 |

> `window.dimensions` / `window.decorations` / `scrolling` 等段在文件中已注释，保持默认。

### 字体

与 Ghostty 共用 `JetBrainsMono Nerd Font Mono`，`size = 15`（已核对与 Ghostty `font-size = 15` 一致）：

```toml
[font]
size = 15
normal = { family = "JetBrainsMono Nerd Font Mono", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font Mono", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font Mono", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font Mono", style = "Bold Italic" }
```

### 配色（Dracula）

| 组               | 值                                                                                                                                     |
| ---------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `colors.primary` | `background 0x282a36` / `foreground 0xf8f8f2`                                                                                          |
| `colors.cursor`  | `background 0x44475a` / `foreground 0xf8f8f2`                                                                                          |
| `colors.normal`  | `black 0x21222c` `red 0xff5555` `green 0x50fa7b` `yellow 0xf1fa8c` `blue 0xbd93f9` `magenta 0xff79c6` `cyan 0x8be9fd` `white 0xbfbfbf` |
| `colors.bright`  | `black 0x4d4d4d` `red 0xff6e67` `green 0x5af78e` `yellow 0xf4f99d` `blue 0xcaa9fa` `magenta 0xff92d0` `cyan 0x9aedfe` `white 0xe6e6e6` |
| `colors.dim`     | 与 `normal` 各项相同（`black 0x21222c` … `white 0xbfbfbf`）                                                                            |

> 已与 `alacritty.toml` 的 `[colors]` 逐值核对；`dim` 刻意复用 `normal` 调色。

### 键位

与 `[keyboard].bindings` 逐条核对（2 条屏蔽 + 1 条全屏）：

| 按键        | 动作               | 说明                          |
| ----------- | ------------------ | ----------------------------- |
| `Cmd+Enter` | `ToggleFullscreen` | 切换全屏                      |
| `Cmd+T`     | `None`（屏蔽）     | 避免误开新窗口，复用交给 tmux |
| `Cmd+N`     | `None`（屏蔽）     | 同上                          |

文件中另有 5 条注释掉的备选绑定（`ToggleSimpleFullscreen` / `Ctrl+N` / `Fn+F` 等）及 3 种 `terminal.shell` 方案，需要时取消注释即可切换。

---

## 字体安装与校验

```bash
brew install --cask font-jetbrains-mono-nerd-font
ghostty +show-config            # 查看 Ghostty 最终生效值（CLI 需先经 Ghostty 菜单 "Install CLI tool" 安装，
                                #   或用全路径 /Applications/Ghostty.app/Contents/MacOS/ghostty）
ghostty +show-config --default --docs | grep -E "font-family|theme|background-opacity"
alacritty --help | head         # 确认 Alacritty 可执行
```

两个终端均要求 Nerd Font 变体——Starship 提示符与 `lsd`（含 fzf 预览）等工具依赖其中的图标字形（powerline 箭头、OS logo、目录图标）。Starship 渲染细节与调色板说明见 [shell.md](shell.md)。

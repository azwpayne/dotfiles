# 终端：Ghostty（主力）与 Alacritty（备用）

两套配置共用 `JetBrainsMono Nerd Font Mono` 与 256 色，可独立安装、互不依赖。Ghostty 为日常主力（支持热重载、Quick Terminal），Alacritty 为轻量备用。

## Ghostty — `private_dot_config/ghostty/config`

配置文件路径 `~/.config/ghostty/config`，查看最终生效值：`ghostty +show-config`（`--default --docs` 可对照默认值）。

### 环境与启动

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `env` | `LANG=zh_CN.UTF-8` | 显式声明中文 UTF-8，避免远端/脚本 locale 回退 |
| `command` | `/bin/zsh -l` | 登录 shell 启动；`fish -l` / `tmux new -As main` 已注释备用 |
| `window-inherit-working-directory` | `true` | 新标签页/分屏继承当前目录，保持上下文 |
| `window-inherit-font-size` | `true` | 新 surface 继承字号 |

### 外观

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `theme` | `Catppuccin Mocha` | 与 starship 调色板呼应；`Dracula+` / `Warm Neon` 已注释备用 |
| `font-family` / `font-size` | `JetBrainsMono Nerd Font Mono` / `15` | `font-feature = +calt` 连字；`font-thicken = true` + `font-thicken-strength = 1`（macOS 加粗渲染） |
| `alpha-blending` | `linear` | 线性透明度混合，配合毛玻璃更平滑 |
| `adjust-cell-height` / `adjust-cell-width` | `2` / `-1` | 微调行高/字间距，适配 Nerd Font 字形 |
| `background-opacity` / `background-blur-radius` | `0.92` / `20` | 轻毛玻璃效果 |
| `window-padding-x/y` | `12` + `window-padding-balance = true` | 文字不贴边，四边均衡 |
| `window-theme` | `auto` | 跟随系统明暗 |
| `window-decoration` / `macos-window-shadow` / `macos-titlebar-proxy-icon` | `true` / `false` / `hidden` | 保留原生装饰但去阴影、隐藏标题栏代理图标 |
| `cursor-style` / `cursor-style-blink` / `cursor-opacity` | `block` / `true` / `0.8` | 块状闪烁光标；`cursor-color = #ff0000` |
| `mouse-hide-while-typing` | `true` | 输入时自动隐藏指针 |
| `mouse-scroll-multiplier` | `1.0` | 滚轮保持原速 |
| `resize-overlay` | `never` | 调整窗口时不显示浮层 |
| `window-save-state` | `always` | 重启恢复窗口布局 |
| `window-width/height` | `0` / `0` | 自适应默认尺寸 |

### 键位

与 `config` 中 `keybind` 逐条一致：

| 按键 | 动作 | 对应配置 |
| --- | --- | --- |
| `Cmd+T` | 新建标签页 | `cmd+t=new_tab` |
| `Cmd+W` | 关闭当前 surface | `cmd+w=close_surface` |
| `Cmd+Shift+←` / `Cmd+Shift+→` | 上一个 / 下一个标签页 | `previous_tab` / `next_tab` |
| `Cmd+D` | 右分屏 | `new_split:right` |
| `Cmd+Shift+D` | 下分屏 | `new_split:down` |
| `Cmd+Alt+←/→/↑/↓` | 在分屏间移动焦点 | `goto_split:left/right/top/bottom` |
| `Cmd+Shift+E` | 均分分屏 | `equalize_splits` |
| `Cmd+Shift+F` | 放大/还原当前分屏 | `toggle_split_zoom` |
| `Cmd+Plus` / `Cmd+Minus` / `Cmd+Zero` | 字号 +1 / −1 / 复位 | `increase_font_size:1` / `decrease_font_size:1` / `reset_font_size` |
| `Ctrl+\``（全局） | 呼出/收起 Quake 风格下拉快速终端 | `global:ctrl+grave_accent=toggle_quick_terminal` |

> 重新加载配置 `reload_config`（`Cmd+Shift+,`）在文件中已注释，当前版本需重启或依赖自动热重载。

### 安全与 macOS 专项

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `macos-option-as-alt` | `right` | 仅右 Option 作为 Alt，左 Option 保留用于输入特殊字符 |
| `clipboard-read` / `clipboard-write` | `allow` | 允许读写系统剪贴板 |
| `clipboard-paste-protection` | `true` | 粘贴保护（多行粘贴前确认） |
| `clipboard-paste-bracketed-safe` | `true` | bracketed paste 安全校验 |
| `clipboard-trim-trailing-spaces` | `true` | 自动去行尾空格 |
| `copy-on-select` | `clipboard` | 选中即复制到系统剪贴板 |
| `quit-after-last-window-closed` | `true` | 关闭最后窗口即退出 |
| `confirm-close-surface` | `false` | 关闭 surface 不二次确认 |
| `auto-update` / `auto-update-channel` | `check` / `stable` | 异步检查稳定版更新，不阻塞启动 |

**Quick Terminal（下拉终端）：**

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `quick-terminal-position` | `top` | 顶部下拉 |
| `quick-terminal-screen` | `main`（最后生效） | 跟随主屏（文件较早处为 `mouse`，以最后一次为准） |
| `quick-terminal-autohide` | `true` | 失焦自动收起 |
| `quick-terminal-animation-duration` | `0.15` | 动画 150ms |

### 性能与存储

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `scrollback-limit` | `67108864`（64MB） | 宽裕回滚，约 64 * 1024 * 1024 字节 |
| `image-storage-limit` | `268435456`（256MB） | Kitty Graphics Protocol 图像上限，适配 16GB 机型 |
| `gtk-single-instance` | `true` | Linux 单实例优化 |

> ⚠️ **重复键提醒：** 文件中存在多处重复定义，Ghostty 以**最后一次出现为准**并可能告警。已知的重复项：`font-thicken` / `font-thicken-strength` / `adjust-cell-height` / `mouse-hide-while-typing` / `macos-option-as-alt` / `quick-terminal-screen` / `quick-terminal-animation-duration` / `resize-overlay` / `macos-window-shadow`。修改时请顺手合并去重，避免歧义。

---

## Alacritty — `private_dot_config/alacritty/alacritty.toml`

轻量备用，`Dracula` 配色底。

### 基础

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `env.TERM` | `xterm-256color` | 兼容远端主机着色 |
| `window.startup_mode` | `Fullscreen` | 启动即全屏 |
| `window.blur` | `true` | 毛玻璃 |
| `window.option_as_alt` | `OnlyRight` | 同 Ghostty 的左右 Option 策略，仅右 Option 作 Alt |
| `selection.save_to_clipboard` | `true` | 选中即复制 |
| `terminal.shell` | 无生效值（各选项均已注释） | 实际启动登录用户的默认 `$SHELL`（本机为 zsh），与 Ghostty 显式指定 `/bin/zsh -l` 不同；如需固定，取消对应注释即可 |

### 字体

与 Ghostty 共用 `JetBrainsMono Nerd Font Mono`，`size = 15`：

```toml
[font]
size = 15
normal = { family = "JetBrainsMono Nerd Font Mono", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font Mono", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font Mono", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font Mono", style = "Bold Italic" }
```

### 配色（Dracula）

| 组 | 值 |
| --- | --- |
| `colors.primary` | `background 0x282a36` / `foreground 0xf8f8f2` |
| `colors.cursor` | `background 0x44475a` / `foreground 0xf8f8f2` |
| `colors.normal` | `black 0x21222c` `red 0xff5555` `green 0x50fa7b` `yellow 0xf1fa8c` `blue 0xbd93f9` `magenta 0xff79c6` `cyan 0x8be9fd` `white 0xbfbfbf` |
| `colors.bright` | `black 0x4d4d4d` `red 0xff6e67` `green 0x5af78e` `yellow 0xf4f99d` `blue 0xcaa9fa` `magenta 0xff92d0` `cyan 0x9aedfe` `white 0xe6e6e6` |
| `colors.dim` | 与 `normal` 各项相同（`black 0x21222c` … `white 0xbfbfbf`） |

### 键位

| 按键 | 动作 | 说明 |
| --- | --- | --- |
| `Cmd+Enter` | `ToggleFullscreen` | 切换全屏 |
| `Cmd+T` | `None`（屏蔽） | 避免误开新窗口，复用交给 tmux |
| `Cmd+N` | `None`（屏蔽） | 同上 |

文件中保留了大量注释掉的备选 `terminal.shell` 方案（`fish` 直启、`tmux attach || tmux new -t ...` 等），需要时取消注释即可切换。

## 字体安装

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

两个终端均要求 Nerd Font 变体——starship 提示符与 `lsd`（含 fzf 预览）等工具依赖其中的图标字形（powerline 箭头、OS logo、目录图标）。

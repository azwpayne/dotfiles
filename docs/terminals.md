# 终端：Ghostty（主力）与 Alacritty（备用）

两套配置共用 JetBrainsMono Nerd Font Mono 字体与 256 色，可独立安装、互不依赖。

## Ghostty — `private_dot_config/ghostty/config`

主力终端。热重载：**Cmd+Shift+,**；查看最终生效值：`ghostty +show-config`。

### 外观

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `theme` | Catppuccin Mocha | 与 starship 调色板呼应；支持自动明暗切换的写法已注释备用 |
| `font-family` / `font-size` | JetBrainsMono Nerd Font Mono / 15 | `font-thicken = true`（macOS 加粗渲染）+ `alpha-blending = linear` |
| `background-opacity` | 0.92 + `background-blur-radius = 20` | 轻毛玻璃效果 |
| `window-padding-x/y` | 12（balance） | 文字不贴边 |
| `window-save-state` | always | 重启恢复窗口布局 |
| `cursor` | block，闪烁，opacity 0.8 | 输入时自动隐藏鼠标指针 |
| `scrollback-limit` | 64MB | `image-storage-limit = 256MB` 防 Kitty 图形协议占满显存 |

### 键位

| 按键 | 动作 |
| --- | --- |
| Cmd+T / Cmd+W | 新建标签页 / 关闭当前 surface |
| Cmd+Shift+←/→ | 上一个 / 下一个标签页 |
| Cmd+D / Cmd+Shift+D | 右分屏 / 下分屏 |
| Cmd+Alt+方向键 | 在分屏间移动焦点 |
| Cmd+Shift+E / Cmd+Shift+F | 均分分屏 / 放大当前分屏 |
| Cmd+Plus / Cmd+Minus / Cmd+0 | 字号 +1 / −1 / 复位 |
| **Ctrl+`（全局）** | 呼出 Quake 风格下拉快速终端（顶部，跟随主屏） |

### macOS 专项与安全

- `macos-option-as-alt = right`：仅右 Option 作为 Alt，左 Option 留给特殊字符输入。
- 隐藏标题栏代理图标、无窗口阴影；`quit-after-last-window-closed = true`。
- 剪贴板防护三件套开启：粘贴保护、bracketed paste 校验、去除行尾空格；
  `copy-on-select = clipboard`。

> ⚠️ 文件中存在少量重复键（如 `font-thicken`、`quick-terminal-screen`、
> `resize-overlay`），Ghostty 以最后一次出现为准并可能告警。修改时建议顺手合并。

## Alacritty — `private_dot_config/alacritty/alacritty.toml`

轻量备用。配色为 Dracula 底（primary bg `0x282a36`）。

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `TERM` | xterm-256color | 兼容远端主机着色 |
| `startup_mode` | Fullscreen | 启动即全屏 |
| `window.blur` | true | 毛玻璃 |
| `option_as_alt` | OnlyRight | 同 Ghostty 的左右 Option 策略 |
| `selection.save_to_clipboard` | true | 选中即复制 |
| 键位 | Cmd+Enter 切换全屏；Cmd+T/N 屏蔽 | 避免误开新窗口，复用交给 tmux |

文件中保留了大量注释掉的备选 shell 方案（fish 直启、tmux 自动 attach 等），
需要时取消注释即可切换。

## 字体安装

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

两个终端均要求 Nerd Font 变体——starship 提示符与 lsd/exa 类工具依赖其中的
图标字形（powerline 箭头、OS logo、目录图标）。

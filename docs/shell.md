# Shell 栈：Zsh / Zim / Starship / Fish

## 启动链路

交互式 zsh 启动时按以下顺序执行（`~/.zshrc` 即仓库中的 `dot_zshrc`）：

```
zsh -l
 └─ ~/.zshrc
     ├─ ① Zim 引导块：下载 zimfw（如缺失）→ zimfw init → source ~/.zim/init.zsh
     │     （compinit、语法高亮、自动建议、fzf-tab 均由 Zim 模块在此完成）
     ├─ ② PATH 追加：~/bin → /opt/homebrew/bin → /opt/homebrew/sbin
     │     → /usr/local/bin → ~/.local/bin；以及 rustup/cargo
     ├─ ③ 工具 eval：
     │     eval "$(zoxide init zsh)"
     │     eval "$(mise activate zsh)"
     │     eval "$(starship init zsh)"      ← 提示符最终归 Starship
     │     eval "$(fzf --zsh)"              ← 与 fzf.zsh 内重复一次，冗余但无害
     │     eval "$(brew shellenv)"
     ├─ ④ source ~/.config/zsh/aliases.zsh  ← 导出 $EDITOR/$VISUAL
     ├─ ⑤ source ~/.config/zsh/fzf.zsh      ← 依赖④的 $EDITOR 展开 Ctrl-O 绑定
     └─ ⑥ source ~/.config/zsh/sdk.zsh      ← 无条件加载（文件头注释称“可选”，以实际代码为准）
```

**顺序即语义**：同名定义后加载者生效。典型例子是短别名 `k`——`sdk.zsh`
在 kubectl 存在时定义 `k='kubectl'`，因此 `aliases.zsh` 有意不定义 `k`。
三个模块的内部契约（依赖、函数速查、破坏性命令警告）详见
[`private_dot_config/zsh/README.md`](../private_dot_config/zsh/README.md)。

## Zim 模块清单（dot_zimrc）

| 分组 | 模块 | 作用 |
| --- | --- | --- |
| 环境 | `environment` `git` `input` `termtitle` `utility` | 基础选项、git 别名、按键、终端标题、utility 着色 |
| 提示符 | `duration-info` `git-info` `prompt-pwd` `asciiship` | 为 prompt 准备的信息模块 + ASCII 主题 |
| 补全 | Homebrew site-functions（ARM/Intel 路径自适应）→ `zsh-completions` → `completion` | compinit 及补全定义 |
| 收尾 | `fast-syntax-highlighting` → `history-substring-search` → `zsh-autosuggestions` → `Aloxaf/fzf-tab` | 必须最后初始化的高亮/历史搜索/建议/fzf 化补全 |

> ⚠️ **asciiship 实际被覆盖**：`.zshrc` 中 `eval "$(starship init zsh)"` 发生在
> Zim 初始化之后，实际生效的提示符是 Starship。`.zimrc` 里的 asciiship 及其信息
> 模块保留着（duration-info 等仍可能被其他用途引用），但不会显示为提示符。
> 如想切回纯 Zim 风格，注释掉 starship 的 eval 即可。

## Starship 提示符（starship.toml）

- 主题：Catppuccin Mocha palette（另内置 frappe/latte/macchiato 三套备用调色板，
  改顶部 `palette = '...'` 一行即可切换）。
- 单行 powerline 布局（format 开头的换行产生一个空行，`line_break` 已禁用）：

```
 OS → 用户名 → 目录 → git 分支/状态 → 语言版本(c rust go nodejs bun php java kotlin haskell python) → conda → 时间
 ❯        （绿色=上条命令成功，红色=失败）
```

- 目录段启用常用目录图标替换（Documents/Downloads/Music/Pictures/Developer）。
- `cmd_duration` 显示毫秒，超过 45s 触发系统通知。
- 已用 starship 1.26 实测渲染正常。

## fzf 集成要点（fzf.zsh）

- 安装前缀探测顺序：`/opt/homebrew/opt/fzf` → `/usr/local/opt/fzf` → `~/.fzf` → `/usr`，
  结果缓存到 `~/.fzf_prefix_cache`；缓存指向的前缀失效时自愈重建。
- 文件列表默认 `fd`（深度 5、含隐藏、排除 .git/node_modules/.venv/dist/build 等），
  未装 fd 时回退 `rg`。
- 全局键位：Ctrl-R 历史（`--scheme=history`）、Ctrl-T 文件、Alt-C 目录；
  预览窗内 Ctrl-O 用 nvim 打开、Ctrl-E 用 code 打开、Ctrl-Y 复制路径。
- 交互函数速查：`frg`（内容搜索跳转 nvim 行号）、`fkill`（选进程杀掉）、
  `ftm`（tmux 会话切换/创建）、`flf`/`flkill`/`flnet`/`fluser`（lsof+fzf 系列）。

## Fish 的角色

Fish 不是登录 shell（Ghostty/Alacritty 默认启动 `/bin/zsh -l`），配置刻意保持最小：

- `config.fish` 只有空的 interactive 存根；
- `completions/` 下三条符号链接指向 OrbStack App 内置的 docker/kubectl/orbctl
  fish 补全脚本（chezmoi `symlink_` 条目），OrbStack 升级后补全自动跟随；
- `conf.d/`、`functions/` 用 `.keep` 占位保留结构。

如需把 Fish 转正为主 shell，需要自行补齐与 zsh 栈等价的工具初始化。

# Shell 栈：Zsh / Zim / Starship / Fish

## 启动链路

交互式 zsh 启动时按以下顺序执行（`~/.zshrc` 即仓库中的 `dot_zshrc`）：

```
zsh -l
 └─ ~/.zshrc
     ├─ ① Zim 引导块：下载 zimfw（如缺失）→ zimfw init → source ~/.zim/init.zsh
     │     （compinit、语法高亮、自动建议、fzf-tab 均由 Zim 模块在此完成）
     ├─ ② PATH 追加：~/bin → /opt/homebrew/bin → /opt/homebrew/sbin
     │     → /usr/local/bin → ~/.local/bin
     ├─ ③ 工具 eval（严格按此顺序）：
     │     eval "$(zoxide init zsh)"
     │     eval "$(mise activate zsh)"
     │     eval "$(starship init zsh)"      ← 提示符最终归 Starship
     │     eval "$(fzf --zsh)"              ← 与 fzf.zsh 内重复一次，冗余但无害
     │     eval "$(brew shellenv)"
     │     export PATH="$(brew --prefix rustup)/bin:$HOME/.cargo/bin:$PATH"
     │     （rustup/cargo 路径以前缀方式追加到 PATH 最前）
     ├─ ④ for file in ~/.config/zsh/aliases.zsh ~/.config/zsh/fzf.zsh; do source "$file"; done
     │     ├─ aliases.zsh  ← 导出 $EDITOR/$VISUAL，供下一步使用
     │     └─ fzf.zsh      ← 依赖 $EDITOR 展开 Ctrl-O 绑定
     └─ ⑤ source ~/.config/zsh/sdk.zsh      ← 无条件加载
           （文件末尾注释称"可选/需取消注释"，与实际代码不符，以代码为准）
```

**顺序即语义**：同名定义后加载者生效。典型例子是短别名 `k`——`sdk.zsh`
在 kubectl 存在时定义 `k='kubectl'`（含 `command -v` 守卫），因此 `aliases.zsh` 有意不定义 `k`。
三个模块的内部契约（依赖、函数速查、破坏性命令警告）详见
[`private_dot_config/zsh/README.md`](../private_dot_config/zsh/README.md)。

> **环境变量说明**：`dot_zshrc` 顶部 `export LANG=en_US.UTF-8` 已**生效**，
> 统一将 locale 固定为 `en_US.UTF-8`（与 Ghostty 中 `LANG=zh_CN.UTF-8` 互补：
> 终端侧中文、shell 侧英文，避免远端/脚本 locale 回退）。`$EDITOR`/`$VISUAL` 等
> 编辑器变量不在此导出，而由 `aliases.zsh` 统一导出（见下文）。

## Zim 模块清单（dot_zimrc）

与 `dot_zimrc` 逐行核对，结果如下：

| 分组 | 模块 | 作用 |
| --- | --- | --- |
| 环境 | `environment` `git` `input` `termtitle` `utility` | 基础选项、git 别名、按键绑定、终端标题、utility 着色（ls/grep/less） |
| 提示符 | `duration-info` `git-info` `prompt-pwd` `asciiship` | 为 prompt 准备的信息模块 + ASCII 主题（实际被 Starship 覆盖，见下） |
| 补全 | `zimfw/homebrew` → 条件 `site-functions`（`$HOMEBREW_PREFIX/share/zsh/site-functions` 优先，`/usr/local/share/zsh/site-functions` 兜底 Intel）→ `zsh-users/zsh-completions --fpath src` → `completion` | Homebrew 补全路径自适应 + 额外补全定义 + compinit |
| 收尾 | `zdharma-continuum/fast-syntax-highlighting` → `zsh-users/zsh-history-substring-search` → `zsh-users/zsh-autosuggestions` → `Aloxaf/fzf-tab` | 必须最后初始化的高亮 / 历史子串搜索 / 自动建议 / fzf 化补全菜单 |

补充说明：

- `ZSH_AUTOSUGGEST_MANUAL_REBIND=1` 在 `dot_zshrc` 中已设置，因 `zsh-autosuggestions` 为末尾模块之一，可提升性能。
- `ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)` 配置 `fast-syntax-highlighting`。

> ⚠️ **asciiship 实际被覆盖**：`.zshrc` 中 `eval "$(starship init zsh)"` 发生在
> Zim 初始化之后，实际生效的提示符是 Starship。`.zimrc` 里的 `asciiship` 及其信息
> 模块保留着（`duration-info` 等仍可能被其他用途引用），但不会显示为提示符。
> 如想切回纯 Zim 风格，注释掉 starship 的 eval 即可。

## Starship 提示符（starship.toml）

- **主题**：Catppuccin Mocha（`palette = 'catppuccin_mocha'`），另内置 `catppuccin_frappe` / `catppuccin_latte` / `catppuccin_macchiato` 三套备用调色板，改顶部 `palette` 一行即可切换。
- **单行 powerline 布局**：`format` 首行空字符串产生一个空行分隔，`[line_break] disabled = true` 因此实际为单行渲染，段间用 `` / `` / `` 电源线符号衔接：

```
 OS → 用户名 → 目录 → git 分支/状态 → 语言版本(c/rust/golang/nodejs/bun/php/java/kotlin/haskell/python) → conda → 时间
 ❯        （绿色=上条命令成功，红色=失败；vim 模式下显示 ❮）
```

各段细节（与 `starship.toml` 一一对应）：

| 段 | 配置要点 |
| --- | --- |
| `os` | `disabled = false`，`bg:red fg:crust`，含 Windows/Ubuntu/MacOS 等 18 个符号映射 |
| `username` | `show_always = true`，`bg:red fg:crust` |
| `directory` | `bg:peach fg:crust`，`truncation_length = 3`，`truncation_symbol = …/`，`substitutions` 替换 Documents→󰈙、Downloads→、Music→󰝚、Pictures→、Developer→󰲋 |
| `git_branch` / `git_status` | 均为 `bg:yellow fg:crust`，符号 `` |
| 语言段 | `c` `rust` `golang` `nodejs` `bun` `php` `java` `kotlin` `haskell` `python` 均为 `bg:green fg:crust`，各有 Nerd Font 符号；`python` 额外显示 `(#$virtualenv)` |
| `conda` | `fg:crust bg:sapphire`，符号 `  `，`ignore_base = false` |
| `time` | `disabled = false`，`bg:lavender fg:crust`，`time_format = "%R"`，符号 `` |
| `character` | `success_symbol = [❯](bold fg:green)` / `error_symbol = [❯](bold fg:red)`，另有 `vimcmd_*` 变体 |
| `cmd_duration` | `show_milliseconds = true`，`format = " in $duration "`，`bg:lavender`，`show_notifications = true`，`min_time_to_notify = 45000`（45s 触发系统通知） |

已用 starship 1.26 实测渲染正常。

## fzf 集成要点（fzf.zsh）

> 本节与 `fzf.zsh` 逐行核对：前缀探测、fd 主 / rg 兜底、全局键位、交互函数。

### 前缀探测与缓存

探测顺序（与 `fzf.zsh` 第 1 节一致）：

1. `/opt/homebrew/opt/fzf`（Apple Silicon）
2. `/usr/local/opt/fzf`（Intel）
3. `~/.fzf`（git 安装方式）
4. `/usr`（Linux 发行版仓库，需 `-x /usr/bin/fzf`）

结果缓存到 `~/.fzf_prefix_cache`（已被 `.gitignore` 忽略）。下次启动若
`$FZF_PREFIX/bin/fzf` 不可执行，则自动删除缓存并重新探测（自愈）。探测成功
后若 `$PATH` 未包含 `$FZF_PREFIX/bin` 则追加。最后执行 `command -v fzf && eval "$(fzf --zsh)"`
加载官方按键绑定与补全（fzf 缺失时静默跳过）。

### 文件/目录列表命令

| 变量 | 主力（fd 存在时） | 兜底（fd 缺失时） |
| --- | --- | --- |
| `FZF_DEFAULT_COMMAND` | `fd --max-depth=5 --type f --hidden --follow --exclude={.git,node_modules,.idea,.venv,.cache,dist,build,.pyc,.DS_Store,.gitignore,.gitmodules,.gitkeep,.gitlab,.gitlab-ci.yaml,*.zip,*.apk,*.so,.keep}` | `rg --files --hidden --follow --glob '!.git' --glob '!node_modules' --glob '!.venv'` |
| `FZF_ALT_C_COMMAND` | `fd --max-depth=5 --type d --follow --exclude=...` | `rg --files --null \| xargs -0 dirname \| sort -u` |
| `FZF_CTRL_T_COMMAND` | 与 `FZF_DEFAULT_COMMAND` 保持一致（置于 fd 回退判断之后，确保回退值同步） | 同左 |

### 全局键位与选项

`FZF_DEFAULT_OPTS`（已在 fzf 0.74.3 实测行内 `#` 注释可解析）：

- 布局：`--height=80% --layout=reverse --border=rounded --cycle --info=inline-right --multi --ansi --preview-window=right:50%:wrap`
- 绑定：`ctrl-/:change-preview-window` / `ctrl-o:execute($EDITOR {} &> /dev/tty)`（`$EDITOR` 由 `aliases.zsh` 导出，source 时展开） / `ctrl-e:execute(code {} &> /dev/tty)` / `ctrl-y:execute-silent(echo {} | pbcopy)+abort` / `ctrl-p:toggle-preview` / `ctrl-a:select-all` / `ctrl-d:deselect-all` / `ctrl-r:toggle-sort`
- 颜色：`fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899`
- 保留 Tab/Shift-Tab 默认多选切换行为，不重绑定为纯移动。

专项：

- `FZF_CTRL_R_OPTS`：`--sort --scheme=history --prompt='history>'`（`--scheme=history` 需 fzf 0.35+）
- `FZF_CTRL_T_OPTS`：`--preview='if [ -d {} ]; then lsd --tree --depth 5 ... | head -50; else bat --color=always --style=header,grid --line-range :100 {}; fi' --prompt='files>' --multi`
- `FZF_ALT_C_OPTS`：`--preview 'lsd --tree --depth 5 --color=always --icon=always {} | head -50' --prompt='dir>'`

### 交互函数

| 函数 | 用途 | 依赖 |
| --- | --- | --- |
| `frg [pattern]` | `rg --line-number --color=always --smart-case` 管道至 fzf，按 `:` 分隔，`bat --highlight-line` 预览，回车 `nvim '{1}' +{2}` 定位行号 | rg, fzf, bat, nvim |
| `fkill [signal]` | `ps -ef \| fzf -m \| awk '{print $2}' \| xargs kill -9`（默认 -9） | fzf |
| `find_large_files [size]` | `fd -t f -S "+$size" -X du -h {} \| sort -k1hr`，默认 `100M` | fd, du |
| `ftm [session]` | tmux 会话 fzf 选择/创建/切换（`switch-client` vs `attach-session` 自动判断） | tmux, fzf |
| `flf` | `lsof \| fzf --preview "$LSOF_PREVIEW"` 浏览打开文件 | lsof, fzf |
| `flkill` | `lsof \| fzf` 选进程提取 PID 后 `kill -9`（安全确认） | lsof, fzf |
| `flnet` | `lsof -i \| fzf` 仅显示 TCP/UDP 连接 | lsof, fzf |
| `fluser [user]` | `lsof -u "$user" \| fzf` 按用户过滤（默认 `$USER`） | lsof, fzf |

其中 `LSOF_PREVIEW='pid=$(echo {} \| awk "{print \$2}"); [ -n "$pid" ] && ps -fp "$pid" || echo "No PID"'` 为共享预览片段。

### fzf-tab

仅当 `[[ -r "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" ]]` 时加载，并配置：

- `zstyle ':completion:*:git-checkout:*' sort false`
- `zstyle ':completion:*:descriptions' format '[%d]'`
- `zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}` / `menu no`
- `zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always --icon=always $realpath'`
- `zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept` + `use-fzf-default-opts yes` + `switch-group '<' '>'`

## Fish 的角色

Fish 不是登录 shell（Ghostty/Alacritty 默认启动 `/bin/zsh -l`），仓库中对应
`private_dot_config/private_fish/`（chezmoi `private_` 前缀，部署后为 `~/.config/fish/`）：

| 路径（仓库） | 部署后 | 内容 |
| --- | --- | --- |
| `private_fish/config.fish` | `~/.config/fish/config.fish` | 仅含空的 `if status is-interactive ... end` 存根 |
| `private_fish/private_completions/symlink_*.fish` | `~/.config/fish/completions/*.fish` | 三条符号链接指向 OrbStack 内置补全：`docker.fish`、`kubectl.fish`、`orbctl.fish`（`chezmoi symlink_` 条目，源路径 `/Applications/OrbStack.app/.../Resources/completions/fish/*.fish`），OrbStack 升级后补全自动跟随 |
| `private_fish/private_conf.d/.keep` | `~/.config/fish/conf.d/` | 占位保留结构 |
| `private_fish/private_functions/.keep` | `~/.config/fish/functions/` | 占位保留结构 |

配置刻意保持最小。如需把 Fish 转正为主 shell，需要自行补齐与 zsh 栈等价的
工具初始化（zoxide/mise/starship/fzf/brew shellenv 等）。

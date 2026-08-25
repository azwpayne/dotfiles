# 安装与快速开始

本文档说明如何在一台新的 macOS（Apple Silicon）机器上，用本仓库还原完整的开发环境。

## 1. 安装 Homebrew、chezmoi 与字体

```bash
# Homebrew（若未安装，Apple Silicon 默认前缀 /opt/homebrew）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install chezmoi
brew install --cask font-jetbrains-mono-nerd-font   # Ghostty/Alacritty/Neovim 都依赖该字体
```

> `chezmoi` ≥ 2.x、`brew`、`font-jetbrains-mono-nerd-font` 是唯三需要在 `chezmoi apply` **之前**就绪的前置；
> 其余工具均可在 apply 之后按需补装（有守卫，未安装时静默跳过，不阻断启动）。

## 2. 应用配置

```bash
# 方式 A：从远程仓库初始化并立即应用（新机器首选）
chezmoi init --apply <user>/<repo>

# 方式 B：源目录已在本机（~/.local/share/chezmoi）时
chezmoi diff     # 先预览
chezmoi apply

exec zsh   # 重启 shell 使全部配置生效（或重新打开终端）
```

### .chezmoiignore 的影响

新机器执行 `chezmoi apply` 时，根目录的 `.chezmoiignore` 会自动**跳过**以下内容不渲染到 `$HOME`
（见 [layout.md](layout.md)）：

- `README.md` / `LICENSE` / `docs/**` —— 仓库文档仅留在源目录，不污染目标机
- `*.local` / `*.bak` / `**/dot_DS_Store` / `node_modules/` 等本地覆盖与构建产物
- `*token*` / `*secret*` / `*credential*` 等敏感文件名匹配

因此 `chezmoi diff` 中不会出现 `docs/` 的新增，`chezmoi doctor` 亦不会告警缺失——属预期行为。
如需排查可执行 `chezmoi ignored` / `chezmoi status` 查看被忽略列表。

## 3. 首次启动会发生什么

| 组件 | 行为 | 触发时机 |
| --- | --- | --- |
| Zim 框架 | `~/.zshrc` 检测 `~/.zim/zimfw.zsh` 缺失时经 `curl`/`wget` 自动下载，随后 `zimfw init` 安装 `dot_zimrc` 中声明的全部模块（environment/git/input/termtitle/utility/duration-info/git-info/prompt-pwd/asciiship/homebrew/zsh-completions/completion/fast-syntax-highlighting/history-substring-search/autosuggestions/fzf-tab） | 首次启动 zsh |
| PATH / brew | `eval "$(brew shellenv)"` 注入 `/opt/homebrew/bin` 等；`export PATH` 追加 `~/bin` `~/.local/bin` `~/.cargo/bin` 等 | 每次启动 zsh |
| zoxide / mise / starship / fzf | `eval "$(zoxide init zsh)"` / `eval "$(mise activate zsh)"` / `eval "$(starship init zsh)"` / `eval "$(fzf --zsh)"` 接管对应功能 | 每次启动 zsh |
| zsh 三模块 | 按序 `source ~/.config/zsh/aliases.zsh` → `fzf.zsh`（含 fzf 前缀探测与 `~/.fzf_prefix_cache` 缓存）→ `sdk.zsh`（pnpm/SDKMAN/Go/Rust/Docker/kubectl 均有守卫） | 每次启动 zsh |
| Neovim | 首次运行 `nvim` 时 lazy.nvim 自动 bootstrap 并按 `lazy-lock.json` 安装 44 个插件（需要网络） | 首次运行 nvim |
| mise 工具链 | `mise activate` 已挂接；按需执行 `mise install` 安装 `~/.config/mise/config.toml` 声明的 bun/deno/go/node/pnpm（均为 `latest`） | 手动执行 |

> `~/.zshrc` 中 `sdk.zsh` 为无条件 `source`（注释称“可选”与实际不一致，以代码为准）；
> `fzf.zsh` 内会再次 `eval "$(fzf --zsh)"`，与 `~/.zshrc` 中的一次重复但无害。

## 4. 依赖清单

### 启动必需（缺失会导致功能明显退化或报错）

| 工具 | 用途 | 安装 |
| --- | --- | --- |
| `fzf` | Ctrl-R/Ctrl-T/Alt-C 及所有 `f*` 函数（`frg`/`fkill`/`ftm`/`fl*`） | `brew install fzf` |
| `fzf-tab` | 补全菜单模糊化（Zim 模块 `Aloxaf/fzf-tab`） | Homebrew formula 方式供给，由 zimfw 加载 |
| `starship` | 提示符（`starship.toml` Catppuccin Mocha） | `brew install starship` |
| `zoxide` | `z` 目录跳转 | `brew install zoxide` |
| `mise` | 运行时管理（bun/deno/go/node/pnpm） | `brew install mise` |
| `fd` | fzf 默认文件列表命令（缺省回退 `rg`） | `brew install fd` |
| `ripgrep` (`rg`) | `frg` 内容搜索、fd 缺省时的回退 | `brew install ripgrep` |

> `fd` 未安装时 `fzf.zsh` 自动回退到 `rg --files`；`fzf` 本身缺失时按键绑定与 `f*` 函数均不可用但不阻断 shell 启动（有 `command -v` 守卫）。

### 体验增强（别名/函数指向的目标，未安装时对应别名退化）

```bash
brew install bat lsd htop fastfetch neovim tmux yazi gh lazygit tldr coreutils \
             kubecolor uv rustup
```

- `coreutils` 提供 `nproc`（`makes`/`xargsp` 半核并行依赖它）
- `bat`/`lsd`/`htop` 分别接管 `cat`/`ls`/`top`；脚本中需要原生行为用 `command cat` 等
- `gh` 配合 `~/.ssh/config` 的 `Host github.com → ssh.github.com:443` 与 `dot_gitconfig` 的 `socks5://127.0.0.1:7890` 代理共同保证 GitHub 可达

### 有守卫的可选组件（未安装时静默跳过）

SDKMAN（Java）、Android NDK（`/opt/homebrew/share/android-ndk`）、Docker、kubectl（含 kubecolor 包装 `k`）、pnpm、`~/.cargo/env`、`onproxy` 函数。

### 终端模拟器（二选一即可，建议都装）

```bash
brew install --cask ghostty alacritty
```

两者均在 `font-jetbrains-mono-nerd-font` 就绪后开箱可用；Ghostty 为主力，Alacritty 为备用。

## 5. 应用后验证清单

逐项确认还原成功：

```bash
# chezmoi 本身（先看）
chezmoi doctor                       # 各项检查通过；.chezmoiignore 导致 docs/README 等不计入 diff 属正常
chezmoi diff                         # 应用后应为空（或仅剩有意保留的本地差异）
chezmoi ignored                      # 确认 docs/、README.md 等在忽略列表

# shell 栈
zsh -n ~/.zshrc ~/.config/zsh/*.zsh # 语法检查无报错
zsh -ic 'exit'                       # 干净启动无报错
zsh -ic 'type k; echo $EDITOR'       # k -> kubectl（kubecolor 包装）；EDITOR=nvim
starship prompt                      # 渲染 powerline 提示符无报错

# fzf（含前缀缓存）
zsh -ic 'echo $FZF_DEFAULT_COMMAND'  # 以 fd 开头（fd 缺失则以 rg 开头）
cat ~/.fzf_prefix_cache              # 应为 /opt/homebrew/opt/fzf（Apple Silicon）
zsh -ic 'type frg fkill ftm'         # fzf 交互函数已加载

# mise
mise ls                              # 列出 bun/deno/go/node/pnpm（未 install 时提示安装）
mise doctor                          # 可选：检查 mise 健康度

# 编辑器
nvim --headless +qa                  # 无插件加载错误；首次运行会触发 lazy.nvim 安装需联网

# SSH / GitHub 可达性
cat ~/.ssh/config                    # 顶部含 Include ~/.orbstack/ssh/config，github.com 走 ssh.github.com:443
git config --get-regexp proxy        # github.com 指向 socks5://127.0.0.1:7890
```

全部通过后即可进入日常使用；更多维护流程见 [maintenance.md](maintenance.md)，完整映射见 [layout.md](layout.md)。

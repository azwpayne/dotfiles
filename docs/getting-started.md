# 安装与快速开始

本文档说明如何在一台新的 macOS（Apple Silicon）机器上，用本仓库还原完整的开发环境。

## 1. 安装 Homebrew、chezmoi 与字体

```bash
# Homebrew（若未安装，Apple Silicon 默认前缀 /opt/homebrew）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install chezmoi
brew install --cask font-jetbrains-mono-nerd-font   # Ghostty / Alacritty / Neovim 均依赖该字体
```

> `chezmoi` ≥ 2.x、`brew`、`font-jetbrains-mono-nerd-font` 是唯三需要在 `chezmoi apply` **之前**就绪的前置；
> 其余工具均可在 `apply` 之后按需补装：`zoxide` / `mise` / `starship` / `fzf` / `brew` 的 `eval` 在 `~/.zshrc` 中无守卫，缺失时启动会报一行 `command not found`（不阻断）；其余加载点（`sdk.zsh`、`fzf.zsh` 按键绑定等）均有 `command -v` / 目录存在守卫，未安装时静默跳过。

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

新机器执行 `chezmoi apply` 时，根目录的 `.chezmoiignore` 会自动**跳过**以下内容不渲染到 `$HOME`（见 [layout.md](layout.md)）：

- `README.md` / `LICENSE` / `docs/` / `docs/**` —— 仓库文档仅留在源目录，不污染目标机
- `dot_gitconfig`（以及 `**/dot_git`）—— 不随 chezmoi 部署（本地差异保留），`apply` 后**不会生成 `~/.gitconfig`**
- `*.local` / `*.local.*` / `*.bak` / `**/dot_DS_Store` / `node_modules/` / `.pnpm-store/` 等本地覆盖与构建产物
- `*token*` / `*secret*` / `*credential*` / `*client_secret*` 等敏感文件名匹配

> 源文件中嵌套 README 的排除模式实际写作 `**/REAMDME.md`（REAMDME 为拼写错误，不匹配任何文件、未生效），因此嵌套的 `README.md` / `LICENSE` **并未被排除**：`private_dot_config/nvim/README.md`、`nvim/LICENSE`、`private_dot_config/zsh/README.md` 会随 `apply` 部署到 `~/.config/` 下；根级 `README.md` / `LICENSE` 的排除不受影响。详见 [layout.md](layout.md)。

因此 `chezmoi diff` 中不会出现 `docs/` 的新增，`chezmoi doctor` 亦不会告警缺失——属预期行为。
如需排查可执行 `chezmoi ignored` / `chezmoi status` 查看被忽略列表。

### 网络与代理前提

GitHub 可达性依赖**本机代理在线**。`dot_gitconfig` 中三处 `proxy`（`[http "https://github.com"]` / `[https "https://github.com"]` / `[ssh "ssh.github.com"]`）均为 `socks5://127.0.0.1:5376`，`private_dot_ssh/config` 的 `ProxyCommand` 探测端口同为 `5376`。两侧行为不同：

- **git（HTTPS）**：代理为固定配置、无直连回退——代理离线时对 GitHub 的操作会卡住或报 `Connection refused`；
- **SSH**：`ProxyCommand` 先探测 `127.0.0.1:5376`，在线时经 SOCKS5 代理连接，离线自动退回直连；
- 首次启动 `zsh` 时 `zimfw` 拉取模块走 HTTPS（新机默认无 `~/.gitconfig`，即直连），通常不受影响。

排查代理是否监听 `5376` 端口：

```bash
nc -z 127.0.0.1 5376 && echo ok || echo "proxy not listening on 5376"
```

或临时取消代理后重试。

## 3. 首次启动会发生什么

| 组件 | 行为 | 触发时机 |
| --- | --- | --- |
| `fish` / `pi` | `private_dot_config/private_fish/config.fish` 为空模板、`private_dot_pi/**`（pi agent 配置）直接生效，均随 `apply` 写入 `$HOME`；本文档只覆盖 `zsh` 栈，其余见 [layout.md](layout.md) | 首次启动 `fish` / `pi` 时 |
| Zim 框架 | `~/.zshrc` 检测 `~/.zim/zimfw.zsh` 缺失时经 `curl` / `wget` 自动下载，随后 `zimfw init` 安装 `dot_zimrc` 中声明的全部模块（`environment` / `git` / `input` / `termtitle` / `utility` / `duration-info` / `git-info` / `prompt-pwd` / `asciiship` / `homebrew` / `site-functions` / `zsh-completions` / `completion` / `fast-syntax-highlighting` / `history-substring` / `autosuggestions` / `fzf-tab`） | 首次启动 `zsh` |
| `PATH` / `brew` | `eval "$(brew shellenv)"` 注入 `/opt/homebrew/bin` 等；`export PATH` **前置** `~/bin:/opt/homebrew/bin:…` 及 `~/.local/bin`、`~/.cargo/bin` 等到 `$PATH` 最前 | 每次启动 `zsh` |
| `zoxide` / `mise` / `starship` / `fzf` | `eval "$(zoxide init zsh)"` / `eval "$(mise activate zsh)"` / `eval "$(starship init zsh)"` / `eval "$(fzf --zsh)"` 接管对应功能 | 每次启动 `zsh` |
| `zsh` 三模块 | 按序 `source ~/.config/zsh/aliases.zsh` → `fzf.zsh`（含 `fzf` 前缀探测与 `~/.fzf_prefix_cache` 缓存）→ `sdk.zsh`（`pnpm` / `SDKMAN` / `Go` / `Rust` / `Docker` / `kubectl` 均有守卫） | 每次启动 `zsh` |
| Neovim | 首次运行 `nvim` 时 `lazy.nvim` 自动 `bootstrap` 并按 `lazy-lock.json` 安装 44 个插件（需网络） | 首次运行 `nvim` |
| `mise` 工具链 | `mise activate` 已挂接；按需执行 `mise install` 安装 `~/.config/mise/config.toml` 声明的 `bun` / `deno` / `go` / `node` / `pnpm`（均为 `latest`） | 手动执行 |

> `~/.zshrc` 中 `sdk.zsh` 为无条件 `source`（注释称“可选”/“excluding sdk.zsh for lazy loading”与实际不一致，以代码为准）；
> `fzf.zsh` 内会再次 `eval "$(fzf --zsh)"`，与 `~/.zshrc` 中的一次重复但无害。详见 [shell.md](shell.md)。

## 4. 依赖清单

### 启动必需（缺失会导致功能明显退化或报错）

| 工具 | 用途 | 安装 |
| --- | --- | --- |
| `fzf` | `Ctrl-R` / `Ctrl-T` / `Alt-C` 及所有 `f*` 函数（`frg` / `fkill` / `ftm` / `fl*`） | `brew install fzf` |
| `fzf-tab` | 补全菜单模糊化（Zim 模块 `Aloxaf/fzf-tab`） | 无需手动安装，由 `zimfw` 按 `dot_zimrc` 的 `zmodule Aloxaf/fzf-tab` 首次启动时自动安装并加载 |
| `starship` | 提示符（`starship.toml` Catppuccin Mocha） | `brew install starship` |
| `zoxide` | `z` 目录跳转 | `brew install zoxide` |
| `mise` | 运行时管理（`bun` / `deno` / `go` / `node` / `pnpm`） | `brew install mise` |
| `fd` | `fzf` 默认文件列表命令 | `brew install fd` |
| `ripgrep` (`rg`) | `frg` 内容搜索、`fd` 缺失时的回退 | `brew install ripgrep` |

> `fd` 未安装时 `fzf.zsh` 自动回退到 `rg --files`；`fzf` 本身缺失时按键绑定与 `f*` 函数均不可用，但不阻断 shell 启动（有 `command -v` 守卫）。
> 若另行通过 Homebrew 安装了 `fzf-tab`，`fzf.zsh` 会额外 `source` Homebrew 版 `/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh`（后加载者生效）。

### 体验增强（别名 / 函数指向的目标，未安装时对应别名退化）

```bash
brew install bat lsd htop fastfetch neovim tmux yazi gh lazygit tldr coreutils \
             kubecolor uv rustup
```

- `coreutils` 提供 `nproc`（`makes` / `xargsp` 半核并行依赖它）
- `bat` / `lsd` / `htop` 分别接管 `cat` / `ls` / `top`；脚本中需要原生行为时用 `command cat` 等
- `gh` 配合 `~/.ssh/config` 的 `Host github.com → ssh.github.com:443` 与 `dot_gitconfig` 的 `socks5://127.0.0.1:5376` 代理共同保证 GitHub 可达。代理已统一为 `5376`，不再区分 `7890`（详见 [dev-tools.md](dev-tools.md) 中的代理配置说明）。

按需补装（别名 / 函数指向的目标，未装时对应功能退化）：

```bash
# Python lint：ruff_auto 函数的目标
brew install ruff
# Android 逆向：jdx / scr 别名的目标（jadx-gui / scrcpy）
brew install jadx scrcpy
```

另需注意：VS Code 及其 `code` CLI 是 `fzf` 的 `Ctrl-E` 绑定、`git config editor = 'code'` 以及 `clp_cfg` / `cla_cfg` 别名的目标，未安装时上述功能退化。

### 有守卫的可选组件（未安装时静默跳过）

SDKMAN（Java）、Android NDK（`/opt/homebrew/share/android-ndk`）、Docker、`kubectl`（`k` → `kubectl` 别名；已装 `kubecolor` 时由 `kubectl()` 函数透明包装彩色输出）、`pnpm`、`~/.cargo/env`、`onproxy` 函数。

### 终端模拟器（二选一即可，建议都装）

```bash
brew install --cask ghostty alacritty
```

两者均在 `font-jetbrains-mono-nerd-font` 就绪后开箱可用；Ghostty 为主力，Alacritty 为备用。详见 [terminals.md](terminals.md)。

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
git config --get-regexp proxy        # 应为 socks5://127.0.0.1:5376（与 SSH ProxyCommand 5376 统一）
                                     # 仅当已手工恢复/合并 ~/.gitconfig 时才有输出，因 .chezmoiignore 不自动部署 dot_gitconfig；
                                     # 也可直接校验源文件：
                                     # git config --file ~/.local/share/chezmoi/dot_gitconfig --get-regexp proxy
```

> **日常更新速览**：`private_dot_config/zsh/aliases.zsh` 提供 `auto_update`（按工具守卫逐项 `brew_update` / `sdk_update` / `rust_update` / `tldr_update` / `uv_update`，5 项，不含 `mise`）与更细粒度的 `update-all [brew|mise|rustup|tldr|uv|sdk]`（关联数组 6 项，支持参数过滤、失败计数与耗时统计，**已覆盖 `mise`**）；验证通过后可按需执行 `zsh -ic 'auto_update'` 或 `zsh -ic 'update-all'`，详见 [maintenance.md](maintenance.md) 与 [dev-tools.md](dev-tools.md) 的对比表及 `aliases.zsh` 源码。

全部通过后即可进入日常使用；更多维护流程见 [maintenance.md](maintenance.md)，完整映射见 [layout.md](layout.md)。


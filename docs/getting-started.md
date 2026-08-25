# 安装与快速开始

本文档说明如何在一台新的 macOS（Apple Silicon）机器上，用本仓库还原完整的开发环境。

## 1. 安装 chezmoi 与基础工具

```bash
# Homebrew（若未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install chezmoi
brew install --cask font-jetbrains-mono-nerd-font   # Ghostty/Alacritty/Neovim 都依赖该字体
```

## 2. 应用配置

```bash
# 方式 A：从远程仓库初始化并立即应用
chezmoi init --apply <user>/<repo>

# 方式 B：源目录已在本机（~/.local/share/chezmoi）时
chezmoi apply

exec zsh   # 重启 shell 使全部配置生效
```

## 3. 首次启动会发生什么

| 组件 | 行为 |
| --- | --- |
| Zim 框架 | `~/.zshrc` 检测到 `~/.zim/zimfw.zsh` 缺失时自动下载，随后 `zimfw init` 安装全部模块 |
| Starship / zoxide / mise / fzf / brew | 由 `~/.zshrc` 中的 `eval "$(... init ...)"` 接管 |
| Neovim | 首次运行 `nvim` 时 lazy.nvim 自动 bootstrap 并按 `lazy-lock.json` 安装 44 个插件（需要网络） |
| mise 工具链 | `mise activate` 已挂接；按需执行 `mise install` 安装声明的 bun/deno/go/node/pnpm |

## 4. 依赖清单

### 启动必需（缺失会导致功能明显退化或报错）

| 工具 | 用途 | 安装 |
| --- | --- | --- |
| `fzf` | Ctrl-R/Ctrl-T/Alt-C 及所有 `f*` 函数 | `brew install fzf` |
| `fzf-tab` | 补全菜单模糊化（Zim 模块） | `brew install fzf-tab` |
| `starship` | 提示符 | `brew install starship` |
| `zoxide` | `z` 目录跳转 | `brew install zoxide` |
| `mise` | 运行时管理 | `brew install mise` |
| `fd` | fzf 默认文件列表命令（缺省回退 rg） | `brew install fd` |
| `ripgrep` | `frg` 内容搜索、fd 缺省时的回退 | `brew install ripgrep` |

### 体验增强（别名/函数指向的目标）

```bash
brew install bat lsd htop fastfetch neovim tmux yazi gh lazygit tldr coreutils \
             kubecolor uv rustup
```

- `coreutils` 提供 `nproc`（`makes`/`xargsp` 半核并行依赖它）
- `bat`/`lsd`/`htop` 分别接管 `cat`/`ls`/`top`；脚本中需要原生行为用 `command cat` 等

### 有守卫的可选组件（未安装时静默跳过）

SDKMAN（Java）、Android NDK、Docker、kubectl、pnpm、`~/.cargo/env`。

### 终端模拟器（二选一即可，建议都装）

```bash
brew install --cask ghostty alacritty
```

## 5. 应用后验证清单

逐项确认还原成功：

```bash
# shell 栈
zsh -ic 'exit'                       # 干净启动无报错
zsh -ic 'type k; echo $EDITOR'       # k -> kubectl（包装 kubecolor）；EDITOR=nvim
starship prompt                      # 渲染 powerline 提示符无报错

# fzf
zsh -ic 'echo $FZF_DEFAULT_COMMAND'  # 以 fd 开头
cat ~/.fzf_prefix_cache              # 应为 /opt/homebrew/opt/fzf

# 编辑器
nvim --headless +qa                  # 无插件加载错误

# chezmoi 本身
chezmoi doctor                       # 各项检查通过
chezmoi diff                         # 应用后应为空（或仅剩有意保留的本地差异）
```

更多日常维护内容见 [maintenance.md](maintenance.md)。

# Dotfiles

基于 [chezmoi](https://www.chezmoi.io/) 管理的 macOS（Apple Silicon）个人开发环境配置。

本仓库是 chezmoi 的**源目录**（source directory，位于 `~/.local/share/chezmoi`），
通过 `chezmoi apply` 将文件渲染到 `$HOME` 下对应位置。全部为静态文件——没有模板、
没有脚本，所见即所得；通过 `.chezmoiignore` 将根级与嵌套的 `README.md` / `LICENSE`、`docs/`、
`*.local` / `*.bak` 等仅供仓库查阅或本地覆盖的文件排除在部署之外，避免污染目标 HOME 目录。

## ✨ 特性总览

| 领域 | 方案 | 说明 |
| --- | --- | --- |
| Shell | Zsh + [Zim](https://zimfw.sh/) + 自有模块 | `aliases.zsh` / `fzf.zsh` / `sdk.zsh` 三模块化加载；`update-all` 批量更新（`brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise`，支持参数过滤与失败计数） |
| Fish | Fish + [Fisher](https://github.com/jorgebucaran/fisher) + Starship | 辅助 shell（非登录）；`fish_plugins` 锁定 14 个插件（fzf.fish / forgit / autopair / done 等），`conf.d` 设定 LANG/EDITOR 等环境，补全含 OrbStack docker/kubectl/orbctl 符号链接 |
| 提示符 | [Starship](https://starship.rs/) | Catppuccin Mocha powerline 风格 |
| 模糊搜索 | fzf + fzf-tab + fd | Ctrl-R 历史、Ctrl-T 文件、Alt-C 目录、`frg`/`fkill`/`ftm`/`fl*` 交互函数 |
| 终端 | Ghostty（主力）/ Alacritty（备用） | JetBrainsMono Nerd Font Mono，Catppuccin / Dracula 配色 |
| 编辑器 | Neovim + [LazyVim](https://www.lazyvim.org/) | 10 个 extras（9 语言 + 1 UI，见 `lua/config/lazy.lua`），插件版本由 `lazy-lock.json` 锁定 |
| 运行时管理 | mise | 多运行时一键切换（工具清单见 `private_dot_config/mise/config.toml`） |
| Git 工作流 | git + gh (CLI) | LFS、GitHub 走本地 SOCKS5 代理、`push.default=current` + `autoSetupRemote` |
| SSH | OpenSSH `~/.ssh/config` | `ssh.github.com:443` + 自适应 `ProxyCommand`（探活 `127.0.0.1:5376` SOCKS5，失败直连）+ OrbStack `Include` |
| AI Agent | pi coding agent | 受限运行环境：文件系统与网络沙箱、细粒度权限矩阵与工作流分层（并发/进度/模型），详见 `private_dot_pi/` 配置与 [dev-tools.md](docs/dev-tools.md) |

## 🚀 快速开始

### 前置要求

- macOS（Apple Silicon 优先；Intel 路径在 zsh/fzf 模块中有兼容分支）
- [Homebrew](https://brew.sh/)
- chezmoi ≥ 2.x：`brew install chezmoi`
- 字体：[JetBrainsMono Nerd Font Mono](https://www.nerdfonts.com/)：
  `brew install --cask font-jetbrains-mono-nerd-font`

完整依赖清单见 [docs/getting-started.md](docs/getting-started.md)。

### 新机器安装

先把本仓库推送到你自己的 Git 远程，然后：

```bash
chezmoi init --apply <user>/<repo>   # 克隆源目录并立即应用
exec zsh                             # 重启 shell
```

首次启动 Zsh 会自动下载 [zimfw](https://github.com/zimfw/zimfw) 并初始化模块；
首次打开 Neovim 会自动 bootstrap lazy.nvim 并安装全部插件（需要网络）。

### 本机重新应用

源目录已就位时：

```bash
chezmoi diff     # 先预览将要发生的变更
chezmoi apply    # 确认无误后应用
```

日常修改配置请走「编辑源 → diff → apply → commit」流程，
详见 [docs/maintenance.md](docs/maintenance.md)。

## 📁 仓库结构与目标映射

chezmoi 命名约定：`dot_` → 隐藏目录/文件（`.` 开头），`private_` → 权限收紧（目录 `0700` / 文件 `0600`），
`symlink_` → 符号链接（文件内容即链接目标）。完整逐文件映射见
[docs/layout.md](docs/layout.md)。

```text
~/.local/share/chezmoi                    应用到 $HOME
├── .chezmoiignore                     →  (不部署) 过滤根级与嵌套 README.md / LICENSE、docs/ 与 *.local / *.bak / *token* 等，避免污染家目录
├── .gitignore                         →  (git 侧) 忽略 .vscode / .git / node_modules / **/.DS_Store / *.log 等
├── dot_zshrc                          →  ~/.zshrc                     Zsh 入口：Zim 引导 + 工具 eval + 模块加载
├── dot_zimrc                          →  ~/.zimrc                     Zim 模块清单
├── dot_gitconfig                      →  ~/.gitconfig                 用户信息 / 代理 / LFS / push 行为
├── dot_gitignore_global               →  ~/.gitignore_global          全局忽略规则
├── dot_codex/
│   └── private_config.toml            →  ~/.codex/config.toml         cc-switch 本地代理配置（0600，详见 dot_codex/private_config.toml）
├── private_dot_config/
│   ├── zsh/                           →  ~/.config/zsh/               ★ 三模块 zsh 配置（含独立 README，不部署）
│   │   ├── aliases.zsh                →  ~/.config/zsh/aliases.zsh
│   │   ├── fzf.zsh                    →  ~/.config/zsh/fzf.zsh
│   │   ├── sdk.zsh                    →  ~/.config/zsh/sdk.zsh
│   │   ├── dot_gitignore              →  ~/.config/zsh/.gitignore
│   │   └── README.md                  →  (不部署) 模块文档，由 **/README.md 排除
│   ├── starship.toml                  →  ~/.config/starship.toml      Starship 提示符
│   ├── ghostty/config                 →  ~/.config/ghostty/config     Ghostty 终端
│   ├── alacritty/alacritty.toml       →  ~/.config/alacritty/alacritty.toml  Alacritty 备用
│   ├── mise/config.toml               →  ~/.config/mise/config.toml   mise 工具链
│   ├── nvim/                          →  ~/.config/nvim/              LazyVim 配置（含 lazy-lock.json / stylua.toml）
│   └── private_fish/                  →  ~/.config/fish/              Fish 辅助配置（Starship + Fisher 14 插件清单）
│       ├── config.fish                →  ~/.config/fish/config.fish
│       ├── fish_plugins                →  ~/.config/fish/fish_plugins     Fisher 14 插件清单
│       ├── private_completions/       →  ~/.config/fish/completions/  symlink_docker/kubectl/orbctl.fish → OrbStack
│       └── private_conf.d/, private_functions/ → conf.d（00_env/fzf 初始化）与 functions/（fzf.fish 插件函数）
├── private_dot_ssh/
│   └── private_config                 →  ~/.ssh/config                ★ GitHub 走 ssh.github.com:443 + 自适应 SOCKS5 ProxyCommand（含 OrbStack Include；~/.ssh 目录 0700）
└── private_dot_pi/
    ├── private_agent/                 →  ~/.pi/agent/                 pi coding agent 主配置（目录 0700）
    │   ├── settings.json              →  ~/.pi/agent/settings.json     pi coding agent 主题/扩展/默认 provider/tools/model/代理
    │   ├── sandbox.json               →  ~/.pi/agent/sandbox.json     文件系统与网络沙箱策略
    │   ├── landstrip.json             →  ~/.pi/agent/landstrip.json   子代理与任务权限
    │   └── extensions/pi-permission-system/config.json → 细粒度工具权限矩阵（允许优先：默认 allow，敏感路径/高危命令 deny）
    └── workflows/
        ├── settings.json              →  ~/.pi/workflows/settings.json 工作流设置（并发/进度面板）
        └── model-tiers.json           →  ~/.pi/workflows/model-tiers.json 三档模型分层（成本分级）
```

> 根级 `README.md` / `LICENSE` / `docs/` 与全部嵌套 `README.md` / `LICENSE`（含 `zsh/README.md`、`nvim/README.md`、`nvim/LICENSE`）均由 `.chezmoiignore`（`**/README.md`、`**/LICENSE` 等按目标名书写的模式）排除、不部署；历史上的 `**/REAMDME.md` 拼写失配与 `dot_git`/`dot_DS_Store`/`dot_gitconfig` 源名失配已修复，`managed` 目标数随鱼 shell 配置扩容曾达 81（纳入 `.config/fish/fish_variables` 后为 82，详见 [layout.md](layout.md) 目标映射）；核心 chezmoi 目标保持 55 不变（不含 fish 相关），后续去重又清理了被更宽模式覆盖的冗余行，目标数不再单调变化。

## 📚 文档索引

| 文档 | 内容 |
| --- | --- |
| [docs/getting-started.md](docs/getting-started.md) | 安装步骤、必需/推荐/可选依赖、应用后验证清单 |
| [docs/layout.md](docs/layout.md) | 全部源文件 → 目标路径映射、chezmoi 命名约定详解 |
| [docs/shell.md](docs/shell.md) | Zsh 启动链路、Zim 模块、Starship 提示符、Fish 的角色 |
| [docs/terminals.md](docs/terminals.md) | Ghostty 与 Alacritty 配置详解与键位表 |
| [docs/neovim.md](docs/neovim.md) | LazyVim 结构、extras、键位、插件锁定与升级 |
| [docs/dev-tools.md](docs/dev-tools.md) | git / gh / mise / codex / pi agent 配置说明 |
| [docs/maintenance.md](docs/maintenance.md) | 日常维护流程、常用命令、验收清单、常见问题 |
| [private_dot_config/zsh/README.md](private_dot_config/zsh/README.md) | zsh 三模块内部契约（加载顺序、依赖、函数速查） |
| [private_dot_config/nvim/README.md](private_dot_config/nvim/README.md) | Neovim/LazyVim 使用说明 |

> 索引与 `docs/` 目录保持一致（7 篇主文档 + 2 篇子目录 README），新增配置请同步更新 [docs/layout.md](docs/layout.md)。

## 🔒 安全与隐私

- 敏感度较高的路径使用 `private_` 前缀收紧权限：目录 `0700`（如 `~/.ssh/`、
  `~/.pi/agent/`、`~/.config/fish/`），文件 `0600`（如 `private_` 前缀的 `~/.codex/config.toml`）。
- `~/.config/gh/` 下的 `config.yml` 与 `hosts.yml` 均由 `gh auth login`
  在目标机器上生成，含凭据，不入仓库。
- pi agent 的沙箱与权限策略显式拒绝读取 `*.env`、`~/.ssh/*`、`~/.aws/*` 等，
  并禁止 `sudo` / `rm` 类命令——细节见 [docs/dev-tools.md](docs/dev-tools.md)。
- `dot_gitconfig` 与 `private_dot_ssh/private_config` 中包含本地代理地址（`socks5://127.0.0.1:5376`，git 一处（gitconfig 单条代理行）与 SSH 探测均统一为 5376，仅对 `github.com`/`ssh.github.com` 生效）
  与个人身份信息，公开 fork 前请先脱敏。

## 🧾 环境

- 目标平台：macOS (Apple Silicon)，Homebrew 前缀 `/opt/homebrew`
- 已验证版本（2026-08）：chezmoi v2.72 · zsh 5.9 · fzf 0.74.3 · starship 1.26 · Neovim 0.12
- 维护者：[azwpayne](https://github.com/azwpayne)

## License

Apache-2.0 - See the [LICENSE](LICENSE) file for details.

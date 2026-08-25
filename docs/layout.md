# 文件映射与命名约定

本仓库是 chezmoi 的源目录（`~/.local/share/chezmoi`）。chezmoi 通过文件名前缀编码目标路径与属性，
`chezmoi apply` 时按规则渲染到 `$HOME`。

## chezmoi 命名约定速查

| 前缀 | 含义 | 本仓库示例 |
| --- | --- | --- |
| `dot_` | 目标名以 `.` 开头（隐藏目录/文件） | `dot_zshrc` → `~/.zshrc` |
| `private_` | 目标权限设为 `0600`（仅所有者可读写） | `private_dot_ssh/config` → `~/.ssh/config` (0600) |
| `symlink_` | 目标是符号链接，**文件内容即链接指向的路径** | `symlink_docker.fish` 内容为一行 OrbStack 路径 |
| `empty_` | 目标为空文件（占位保证目录存在） | `private_empty_config.toml` → `~/.codex/empty_config.toml` |
| （无前缀） | 原样同名复制 | `starship.toml` → `~/.config/starship.toml` |

前缀可叠加，如 `private_dot_config` = 隐藏目录 + 该目录本身权限 0700，`private_dot_ssh` 同理。

> 注：`private_dot_config` 下未加 `private_` 的子项（如 `zsh/`、`nvim/`、`alacritty/`、`ghostty/`、`mise/`）保持默认 0644；
> 只有显式带 `private_` 的条目（`private_fish/`、`private_dot_ssh/`、`private_dot_pi/`）才收紧为 0600。

## 完整映射表

### Shell 与 Git

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | Zim 引导、PATH、工具 eval（zoxide/mise/starship/fzf/brew）、模块加载入口（aliases→fzf→sdk） |
| `dot_zimrc` | `~/.zimrc` | Zim 模块清单（仅供 zimfw 读取，非 shell 启动时 source） |
| `dot_gitconfig` | `~/.gitconfig` | 用户/代理（github.com 走 socks5://127.0.0.1:5376）/LFS/push 行为 — ⚠️ 当前被 `.chezmoiignore` 排除，不随 `chezmoi apply` 部署，仅作本地参考快照 |
| `dot_gitignore_global` | `~/.gitignore_global` | 全局忽略（.DS_Store、IDE、日志等） |

### SSH

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_ssh/config` | `~/.ssh/config` (0600) | OrbStack `Include ~/.orbstack/ssh/config` 置顶 + `Host github.com` 走 `ssh.github.com:443` + SOCKS5 自适应（`nc -z 127.0.0.1:5376` 探测，有则 `-X 5 -x 127.0.0.1:5376` 否则直连） |

### ~/.config/zsh/

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | 别名与通用函数（`auto_update`、`update-all`、`y`、`ruff_auto` 等）；`update-all` 支持 `brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise` 选择性更新（可传参指定目标，未传参则全量；`auto_update` 为旧版全量兼容入口，`update-all` 为新版支持 `mise` 且可单目标更新） |
| `private_dot_config/zsh/fzf.zsh` | `~/.config/zsh/fzf.zsh` | fzf 前缀探测/缓存、全局选项、Ctrl-R/T/Alt-C 及 `frg`/`fkill`/`ftm`/`fl*` 函数 |
| `private_dot_config/zsh/sdk.zsh` | `~/.config/zsh/sdk.zsh` | SDK 环境与补全（pnpm/SDKMAN(可选)/Android NDK/Python(uv)/Go/Rust/Docker/kubectl+kubecolor） |
| `private_dot_config/zsh/dot_gitignore` | `~/.config/zsh/.gitignore` | 忽略运行时产物（`*.zwc`、`.fzf_prefix_cache`、`.DS_Store`） |
| `private_dot_config/zsh/README.md` | `~/.config/zsh/README.md` | 模块内部文档（加载顺序契约、函数速查） |

### 终端与提示符

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Catppuccin Mocha powerline 提示符（已核验：palette 与 format 与实际一致） |
| `private_dot_config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 主终端配置（JetBrainsMono Nerd Font Mono，`command = /bin/zsh -l`，Catppuccin Mocha 主题） |
| `private_dot_config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty 备用配置（Dracula 配色、`xterm-256color`、JetBrainsMono Nerd Font Mono） |

### 编辑器与开发工具

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/nvim/**` | `~/.config/nvim/**` | LazyVim 配置（`init.lua` + `lua/config/*` + `lua/plugins/*`，含 `lazy-lock.json` 锁定 44 个插件、`lazyvim.json`（extras 清单当前为空）、`stylua.toml`） |
| `private_dot_config/nvim/README.md` | `~/.config/nvim/README.md` | LazyVim 上游模板自带，随 `nvim/**` 部署（当前因 `.chezmoiignore` 中 `**/REAMDME.md` 拼写错误未被排除） |
| `private_dot_config/nvim/LICENSE` | `~/.config/nvim/LICENSE` | LazyVim 上游模板自带，随 `nvim/**` 部署 |
| `private_dot_config/nvim/dot_gitignore` | `~/.config/nvim/.gitignore` | 忽略插件数据等运行时目录 |
| `private_dot_config/nvim/dot_neoconf.json` | `~/.config/nvim/.neoconf.json` | neoconf 本地配置 |
| `private_dot_config/mise/config.toml` | `~/.config/mise/config.toml` | bun/deno/go/node/pnpm = latest |
| `dot_codex/private_empty_config.toml` | `~/.codex/empty_config.toml` (0600) | 空占位文件，保证 `~/.codex/` 目录存在 |

> `~/.config/gh/config.yml` 与 `hosts.yml` 由 `gh auth login` 在目标机生成，含凭据，**不入库**（见下文“不在仓库内的重要文件”）。

### Fish（辅助）

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/private_fish/config.fish` | `~/.config/fish/config.fish` (0600) | 最小交互配置（空壳） |
| `.../private_completions/symlink_docker.fish` | `~/.config/fish/completions/docker.fish` | 符号链接 → OrbStack 内置补全 |
| `.../private_completions/symlink_kubectl.fish` | `~/.config/fish/completions/kubectl.fish` | 同上 |
| `.../private_completions/symlink_orbctl.fish` | `~/.config/fish/completions/orbctl.fish` | 同上 |
| `.../private_conf.d/.keep`、`.../private_functions/.keep` | 对应 `.keep` | 占位保留空目录结构 |

> Fish 在本环境中不是登录 shell，仅用于偶尔使用时获得 docker/kubectl/orbctl 补全；
> Ghostty 显式指定 `command = /bin/zsh -l`；Alacritty 未设置 shell（跟随系统登录 shell）。

### pi coding agent（四件套 + workflows）

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_pi/private_agent/settings.json` | `~/.pi/agent/settings.json` (0600) | 完整字段：`theme: dark`、`lastChangelogVersion: 0.84.3`、`hideThinkingBlock: false`、`defaultProvider: opencode`、`defaultModel: muse-spark-1.2-contributor-free`、`defaultThinkingLevel: xhigh`、7 个 npm 包（`pi-web-access`/`pi-subagents`/`@quintinshaw/pi-dynamic-workflows`/`@narumitw/pi-btw`/`@narumitw/pi-goal`/`pi-landstrip`/`@gotgenes/pi-permission-system`） |
| `private_dot_pi/private_agent/sandbox.json` | `~/.pi/agent/sandbox.json` (0600) | 文件系统与网络沙箱策略（`denyRead` 含 `/Users` `/etc` 等、`denyWrite` 含 `**/.env` `~/.ssh` 等、`allowNetwork: true`、`allowLocalBinding: false`、`allowedDomains: *.githubusercontent.com`/`*.github.com`/`github.com`） |
| `private_dot_pi/private_agent/landstrip.json` | `~/.pi/agent/landstrip.json` (0600) | 子代理上限 `maxSubagents: 8`（`toolFilesystemPolicy: sandbox`，任务权限 `*` deny、`review` allow） |
| `private_dot_pi/private_agent/extensions/pi-permission-system/config.json` | `~/.pi/agent/extensions/pi-permission-system/config.json` (0600) | 工具级权限矩阵（`read/write/edit/bash/path` 细粒度 allow/deny/ask，禁 `sudo`/`rm`/`mv` 等） |
| `private_dot_pi/workflows/settings.json` | `~/.pi/workflows/settings.json` (0600) | workflow 运行时配置：进度面板并发上限 `progressPanelMaxAgents: 8`，与 `landstrip.json` 的 `maxSubagents: 8` 职责分离 |

## .chezmoiignore —— 源目录有、目标没有的唯一例外

本仓库**唯一**的非静态机制是根目录的 `.chezmoiignore`。它本身**不会**被 `chezmoi apply` 到 `$HOME`
（chezmoi 始终忽略点文件中的该文件名），作用是在源目录中**排除**部分文件不参与渲染：

```gitignore
# 本地覆盖与备份
*.local
*.local.*
*.bak
**/REAMDME.md        # ← 拼写错误，预期 **/README.md，未生效
README.md            # 仅根目录
LICENSE              # 仅根目录
docs/
docs/**
**/dot_git
dot_gitconfig
**/dot_DS_Store

# 敏感信息
*token*
*secret*
*credential*
*client_secret*

# 构建产物
node_modules/
.pnpm-store/
```

效果：`chezmoi diff` / `chezmoi apply` 会自动跳过文档、本地覆盖、敏感文件名匹配与构建产物。
注意：根级模式 `README.md` / `LICENSE` 仅匹配源目录根，不匹配嵌套路径——因此
`~/.config/nvim/README.md` 与 `~/.config/nvim/LICENSE` 仍会随 `nvim/**` 部署到目标机；
本应用于排除嵌套 README/LICENSE 的规则在文件中误写为 `**/REAMDME.md`（typo，正确应为 `**/README.md` 且需追加 `**/LICENSE`），暂未生效。详见 [getting-started.md](getting-started.md)。

## 仓库特性说明

- **纯静态、无模板/脚本**：没有 `*.tmpl` 模板、`.chezmoidata.*` 数据、`run_*` 脚本；
  唯一例外是上述 `.chezmoiignore`（排除而非生成，原因见上）。所有机器 `chezmoi apply` 拿到同一套内容；
  如需按机器差异化，再引入模板即可。
- **运行时产物不入库**：`~/.config/zsh/.gitignore` 和 `~/.config/nvim/.gitignore`
  分别忽略 `*.zwc`、`.fzf_prefix_cache` 及插件数据目录。
- **不在仓库内的重要文件**：
  - `~/.config/gh/hosts.yml` / `config.yml`——由 `gh auth login` 生成，含凭据，切勿加入仓库；
  - `~/.zim/`——由 zimfw 自动管理（`dot_zimrc` 仅为其配置）；
  - `~/.ssh/` 除 `config` 外的密钥——均被 `private_dot_ssh` 的 0600 与 `.chezmoiignore` 的 `*secret*` 等规则双重保护；
  - Neovim 插件本体（`~/.local/share/nvim/`）——由 lazy.nvim 按 `lazy-lock.json` 安装。

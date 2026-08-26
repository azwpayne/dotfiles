# 文件映射与命名约定

本仓库是 chezmoi 的源目录（`~/.local/share/chezmoi`）。chezmoi 通过文件名前缀编码目标路径与属性，
`chezmoi apply` 时按规则渲染到 `$HOME`。

## chezmoi 命名约定速查

| 前缀 | 含义 | 本仓库示例 |
| --- | --- | --- |
| `dot_` | 目标名以 `.` 开头（隐藏目录/文件） | `dot_zshrc` → `~/.zshrc` |
| `private_` | 目标仅所有者可访问：文件 0600、目录 0700 | `private_dot_ssh/config` → `~/.ssh/config` (0600) |
| `symlink_` | 目标是符号链接，**文件内容即链接指向的路径** | `symlink_docker.fish` 内容为一行 OrbStack 路径 |
| `empty_` | 目标为空文件（占位保证目录存在） | `private_empty_config.toml` → `~/.codex/config.toml` |
| （无前缀） | 原样同名复制 | `starship.toml` → `~/.config/starship.toml` |

前缀可叠加，如 `private_dot_config` = 隐藏目录 + 该目录本身权限 0700，`private_dot_ssh` 同理。

> 注：`private_` 前缀只作用于它直接修饰的那一级——目录得 0700、文件得 0600，目录内未再带前缀的子项保持默认 0644。
> 实测（stat）：`~/.config`、`~/.config/fish`、`~/.pi`、`~/.pi/agent` 均为 0700，而其内部文件（`config.fish`、
> `~/.pi/agent/*.json` 等）均为 0644；仅文件本身带前缀的 `~/.ssh/config` 与 `~/.codex/config.toml` 为 0600。

## 完整映射表

### Shell 与 Git

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | Zim 引导、PATH、工具 eval（zoxide/mise/starship/fzf/brew）、模块加载入口（aliases→fzf→sdk） |
| `dot_zimrc` | `~/.zimrc` | Zim 模块清单（仅供 zimfw 读取，非 shell 启动时 source） |
| `dot_gitconfig` | `~/.gitconfig` | 用户/代理（github.com 走 socks5://127.0.0.1:5376）/LFS/push 行为；`core.excludesfile = ~/.gitignore_global`（`~` 由 git 原生展开，无用户名硬编码）。旧版 `.chezmoiignore` 中按源名书写的 `dot_gitconfig` 行从不匹配任何目标、未生效，现该行已删除，本文件正常随 `apply` 部署 |
| `dot_gitignore_global` | `~/.gitignore_global` | 全局忽略（.DS_Store、IDE、日志等） |

### SSH

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_ssh/config` | `~/.ssh/config` (0600) | OrbStack `Include ~/.orbstack/ssh/config` 置顶 + `Host github.com` 走 `ssh.github.com:443` + SOCKS5 自适应（`nc -z 127.0.0.1:5376` 探测，有则 `-X 5 -x 127.0.0.1:5376` 否则直连） |

### ~/.config/zsh/

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | 别名与通用函数（`update-all`、`auto_update`、`y`、`ruff_auto` 等）；`update-all` 为关联数组 6 目标 `brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise`，支持传参过滤、失败计数与耗时统计；`auto_update` 为兼容旧习惯的一键入口（可选 `onproxy` 切代理后直接委托 `update-all`，覆盖目标一致，均含 `mise`） |
| `private_dot_config/zsh/fzf.zsh` | `~/.config/zsh/fzf.zsh` | fzf 前缀探测/缓存、全局选项、Ctrl-R/T/Alt-C 及 `frg`/`fkill`/`ftm`/`fl*` 函数 |
| `private_dot_config/zsh/sdk.zsh` | `~/.config/zsh/sdk.zsh` | SDK 环境与补全（pnpm/SDKMAN(可选)/Android NDK/Python(uv)/Go/Rust/Docker/kubectl+kubecolor） |
| `private_dot_config/zsh/dot_gitignore` | `~/.config/zsh/.gitignore` | 忽略运行时产物（`*.zwc`、`.fzf_prefix_cache`、`.DS_Store`） |
| `private_dot_config/zsh/README.md` | —（不部署） | 模块内部文档（加载顺序契约、函数速查）；由 `**/README.md` 排除，仅仓库内查阅 |

### 终端与提示符

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Catppuccin Mocha powerline 提示符（`palette = 'catppuccin_mocha'` + 自定义 format） |
| `private_dot_config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 主终端配置（JetBrainsMono Nerd Font Mono，`command = /bin/zsh -l`，Catppuccin Mocha 主题） |
| `private_dot_config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty 备用配置（Dracula 配色、`xterm-256color`、JetBrainsMono Nerd Font Mono） |

### 编辑器与开发工具

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/nvim/**` | `~/.config/nvim/**` | LazyVim 配置（`init.lua` + `lua/config/*` + `lua/plugins/*`，含 `lazy-lock.json` 锁定 44 个插件、`lazyvim.json`（extras 清单当前为空）、`stylua.toml`） |
| `private_dot_config/nvim/README.md` | —（不部署） | LazyVim 上游模板自带；由 `**/README.md` 排除，仅仓库内查阅（历史排除模式误写为 `**/REAMDME.md` 未生效，已修复） |
| `private_dot_config/nvim/LICENSE` | —（不部署） | 上游 LazyVim starter 原件（Apache-2.0，与根 LICENSE 同哈希）；由 `**/LICENSE` 排除 |
| `private_dot_config/nvim/dot_gitignore` | `~/.config/nvim/.gitignore` | 忽略插件数据等运行时目录 |
| `private_dot_config/nvim/dot_neoconf.json` | `~/.config/nvim/.neoconf.json` | neoconf 本地配置 |
| `private_dot_config/mise/config.toml` | `~/.config/mise/config.toml` | bun/deno/go/node/pnpm = latest |
| `dot_codex/private_empty_config.toml` | `~/.codex/config.toml` (0600) | 空占位文件，保证 `~/.codex/` 目录存在 |

> `~/.config/gh/config.yml` 与 `hosts.yml` 由 `gh auth login` 在目标机生成，含凭据，**不入库**（见下文“不在仓库内的重要文件”）。

### Fish（辅助）

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/private_fish/config.fish` | `~/.config/fish/config.fish` (0644) | 最小交互配置（空壳；所在目录 `private_fish/` 本身为 0700） |
| `.../private_completions/symlink_docker.fish` | `~/.config/fish/completions/docker.fish` | 符号链接 → OrbStack 内置补全 |
| `.../private_completions/symlink_kubectl.fish` | `~/.config/fish/completions/kubectl.fish` | 同上 |
| `.../private_completions/symlink_orbctl.fish` | `~/.config/fish/completions/orbctl.fish` | 同上 |
| `.../private_conf.d/.keep`、`.../private_functions/.keep` | 对应 `.keep` | 占位保留空目录结构 |

> Fish 在本环境中不是登录 shell，仅用于偶尔使用时获得 docker/kubectl/orbctl 补全；
> Ghostty 显式指定 `command = /bin/zsh -l`；Alacritty 未设置 shell（跟随系统登录 shell）。

### pi coding agent（四件套 + workflows）

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_pi/private_agent/settings.json` | `~/.pi/agent/settings.json` (0644) | 完整字段：`theme: dark`、`lastChangelogVersion: 0.84.3`、`hideThinkingBlock: true`、`defaultProvider: zai-coding-cn`、`defaultModel: glm-5.3`、`defaultThinkingLevel: max`、7 个 npm 包（`pi-web-access`/`pi-subagents`/`@quintinshaw/pi-dynamic-workflows`/`@narumitw/pi-btw`/`@narumitw/pi-goal`/`pi-landstrip`/`@gotgenes/pi-permission-system`） |
| `private_dot_pi/private_agent/sandbox.json` | `~/.pi/agent/sandbox.json` (0644) | 文件系统与网络沙箱策略（`denyRead` 含 `/Users` `/etc` 等、`denyWrite` 含 `**/.env` `~/.ssh` 等、`allowNetwork: false`、`allowLocalBinding: false`、`allowedDomains: *.githubusercontent.com`/`*.github.com`/`github.com`） |
| `private_dot_pi/private_agent/landstrip.json` | `~/.pi/agent/landstrip.json` (0644) | 子代理上限 `maxSubagents: 5`（`toolFilesystemPolicy: sandbox`，任务权限 `*`: ask、`review`: allow） |
| `private_dot_pi/private_agent/extensions/pi-permission-system/config.json` | `~/.pi/agent/extensions/pi-permission-system/config.json` (0644) | 工具级权限矩阵（`read/write/edit/bash/path` 细粒度 allow/deny/ask，禁 `sudo`/`rm`/`mv` 等） |
| `private_dot_pi/workflows/settings.json` | `~/.pi/workflows/settings.json` (0644) | workflow 运行时配置：默认并发 `defaultConcurrency: 10`、进度面板并发/展示上限 `progressPanelMaxAgents: 8`，与 `landstrip.json` 的 `maxSubagents: 5` 职责不同、相互独立 |

> 权限实测（stat）：`private_dot_pi`/`private_agent` 目录前缀使 `~/.pi`、`~/.pi/agent` 为 0700，其内文件（含 `extensions/**`）均为 0644；
> `workflows/` 目录无 `private_` 前缀，`~/.pi/workflows` 为 0755。

## .chezmoiignore —— 排除部分源文件不参与部署

根目录的 `.chezmoiignore` 本身**不会**被 `chezmoi apply` 到 `$HOME`
（chezmoi 对该文件名特殊处理），作用是在源目录中**排除**部分文件不参与渲染。实文如下：

```gitignore
# 本地覆盖与备份
*.local
*.local.*
*.bak
**/README.md
**/LICENSE
docs/
**/.DS_Store

# 敏感信息
*token*
*secret*
*credential*

# 构建产物
node_modules/
.pnpm-store/
```

效果（按目标名匹配）：`chezmoi diff` / `chezmoi apply` 自动跳过根级与任意嵌套的 `README.md`、
`LICENSE`（含 `zsh/README.md`、`nvim/README.md`、`nvim/LICENSE`）、`docs/`、任意 `.DS_Store`，
以及匹配 `*.local` / `*.bak` / `*token*` 等敏感与构建产物模式的文件。

✅ 历史失配已修复（2026-08 收口）：旧版按**源名**书写了 `**/dot_git` / `**/dot_DS_Store` / `dot_gitconfig`
（模式按目标名匹配，从不命中 `.git` / `.DS_Store` / `.gitconfig`，均未生效），且 `**/README.md`
误拼为 `**/REAMDME.md`——现全部改写为目标名形式、删除无效行 `dot_gitconfig` 并追加 `**/LICENSE`。
`dot_gitconfig` → `~/.gitconfig` 恢复其本来的正常部署语义；`chezmoi managed`
目标数由 59 降至 55（不再包含嵌套 README×2、`nvim/LICENSE`）。后续去重又删除了被更宽模式
覆盖或已无对应文件的冗余行（根级 `README.md` / `LICENSE`、`docs/**`、`**/.git`、`*client_secret*`、
两条 `**.md` 与已不存在的 `REPO-INSIGHT.md`），`managed` 目标数保持 55 不变。

## 仓库特性说明

- **纯静态、无模板/脚本**：没有 `*.tmpl` 模板、`.chezmoidata.*` 数据、`run_*` 脚本；
  唯一例外是上述 `.chezmoiignore`（排除而非生成，原因见上）。所有机器 `chezmoi apply` 拿到同一套内容；
  如需按机器差异化，再引入模板即可。
- **运行时产物不入库**：`~/.config/zsh/.gitignore` 和 `~/.config/nvim/.gitignore`
  分别忽略 `*.zwc`、`.fzf_prefix_cache` 及插件数据目录。
- **仅服务于仓库管理、不部署的文件**：根目录的 `.gitignore` 与 `.chezmoiignore` 被 chezmoi 默认忽略（源目录中点开头文件不参与 apply）；根级 `README.md`、`LICENSE`、`docs/`（本文档所在）以及全部嵌套 `README.md` / `LICENSE`（如 `zsh/README.md`、`nvim/README.md`、`nvim/LICENSE`）被 `.chezmoiignore` 排除。
- **不在仓库内的重要文件**：
  - `~/.config/gh/hosts.yml` / `config.yml`——由 `gh auth login` 生成，含凭据，切勿加入仓库；
  - `~/.zim/`——由 zimfw 自动管理（`dot_zimrc` 仅为其配置）；
  - `~/.ssh/` 除 `config` 外的密钥——不在仓库内，`.chezmoiignore` 的 `*secret*`/`*token*` 等模式可防止误入库；
  - Neovim 插件本体（`~/.local/share/nvim/`）——由 lazy.nvim 按 `lazy-lock.json` 安装。

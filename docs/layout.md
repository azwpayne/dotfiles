# 文件映射与命名约定

本仓库是 chezmoi 的源目录。chezmoi 通过文件名前缀编码目标路径与属性，
`chezmoi apply` 时按规则渲染到 `$HOME`。

## chezmoi 命名约定速查

| 前缀 | 含义 | 本仓库示例 |
| --- | --- | --- |
| `dot_` | 目标名以 `.` 开头（隐藏目录/文件） | `dot_zshrc` → `~/.zshrc` |
| `private_` | 目标权限设为 `0600`（仅所有者可读写） | `private_dot_config/gh/private_config.yml` |
| `symlink_` | 目标是符号链接，**文件内容即链接指向的路径** | `symlink_docker.fish` 内容为一行 OrbStack 路径 |
| （无前缀） | 原样同名复制 | `starship.toml` → `~/.config/starship.toml` |

前缀可叠加，如 `private_dot_config` = 隐藏目录 + 目录内文件默认 0600。

> 注：`private_dot_config` 下未加 `private_` 的子项（如 zsh、nvim）保持默认 0644；
> 只有显式带 `private_` 的条目才收紧权限。

## 完整映射表

### Shell 与 Git

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `dot_zshrc` | `~/.zshrc` | Zim 引导、PATH、工具 eval、模块加载入口 |
| `dot_zimrc` | `~/.zimrc` | Zim 模块清单（zimfw 配置，非启动时 source） |
| `dot_gitconfig` | `~/.gitconfig` | 用户/代理/LFS/push 行为 |
| `dot_gitignore_global` | `~/.gitignore_global` | 全局忽略（.DS_Store、IDE、日志等） |

### ~/.config/zsh/

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/zsh/aliases.zsh` | `~/.config/zsh/aliases.zsh` | 别名与通用函数 |
| `private_dot_config/zsh/fzf.zsh` | `~/.config/zsh/fzf.zsh` | fzf 探测/选项/交互函数 |
| `private_dot_config/zsh/sdk.zsh` | `~/.config/zsh/sdk.zsh` | SDK 环境与补全 |
| `private_dot_config/zsh/dot_gitignore` | `~/.config/zsh/.gitignore` | 忽略运行时产物（`*.zwc`、`.fzf_prefix_cache`） |
| `private_dot_config/zsh/README.md` | `~/.config/zsh/README.md` | 模块内部文档 |

### 终端与提示符

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/starship.toml` | `~/.config/starship.toml` | Catppuccin Mocha powerline 提示符 |
| `private_dot_config/ghostty/config` | `~/.config/ghostty/config` | Ghostty 主终端配置 |
| `private_dot_config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | Alacritty 备用配置 |

### 编辑器与开发工具

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/nvim/**` | `~/.config/nvim/**` | LazyVim 配置（含 `lazy-lock.json` 版本锁定） |
| `private_dot_config/nvim/dot_gitignore` | `~/.config/nvim/.gitignore` | 忽略插件数据等运行时目录 |
| `private_dot_config/mise/config.toml` | `~/.config/mise/config.toml` | bun/deno/go/node/pnpm = latest |
| `private_dot_config/gh/private_config.yml` | `~/.config/gh/config.yml` | GitHub CLI（0600） |
| `dot_codex/private_empty_config.toml` | `~/.codex/empty_config.toml` | 空占位文件，保证目录存在（0600） |

### Fish（辅助）

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_config/private_fish/config.fish` | `~/.config/fish/config.fish` | 最小交互配置（空壳） |
| `.../private_completions/symlink_docker.fish` | `~/.config/fish/completions/docker.fish` | 符号链接 → OrbStack 内置补全 |
| `.../private_completions/symlink_kubectl.fish` | `~/.config/fish/completions/kubectl.fish` | 同上 |
| `.../private_completions/symlink_orbctl.fish` | `~/.config/fish/completions/orbctl.fish` | 同上 |
| `.../private_conf.d/.keep`、`.../private_functions/.keep` | 对应 `.keep` | 占位保留空目录结构 |

> Fish 在本环境中不是登录 shell，仅用于偶尔使用时获得 docker/kubectl/orbctl 补全；
> Ghostty/Alacritty 的默认 shell 均为 zsh。

### pi coding agent

| 源文件 | 目标路径 | 说明 |
| --- | --- | --- |
| `private_dot_pi/private_agent/settings.json` | `~/.pi/agent/settings.json` | 默认模型/主题/pi 包列表 |
| `private_dot_pi/private_agent/sandbox.json` | `~/.pi/agent/sandbox.json` | 文件系统与网络沙箱策略 |
| `private_dot_pi/private_agent/landstrip.json` | `~/.pi/agent/landstrip.json` | 子代理上限与任务权限 |
| `private_dot_pi/private_agent/extensions/pi-permission-system/config.json` | `~/.pi/agent/extensions/pi-permission-system/config.json` | 工具级权限矩阵 |

## 仓库特性说明

- **纯静态**：没有 `*.tmpl` 模板、`.chezmoidata.*` 数据、`run_*` 脚本或
  `.chezmoiignore`。所有机器拿到同一套内容；如需按机器差异化，再引入模板即可。
- **运行时产物不入库**：`~/.config/zsh/.gitignore` 和 `~/.config/nvim/.gitignore`
  分别忽略 `*.zwc`、`.fzf_prefix_cache` 及插件数据目录。
- **不在仓库内的重要文件**：
  - `~/.config/gh/hosts.yml`——由 `gh auth login` 生成，含凭据，切勿加入仓库；
  - `~/.zim/`——由 zimfw 自动管理；
  - Neovim 插件本体（`~/.local/share/nvim/`）——由 lazy.nvim 按 lock 文件安装。

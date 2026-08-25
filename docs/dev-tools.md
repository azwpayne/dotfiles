# 开发工具链：git / gh / mise / codex / pi agent

## Git — `dot_gitconfig` → `~/.gitconfig`

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `core.editor` | code | 提交信息等用 VS Code 编辑 |
| `init.defaultBranch` | main | 新仓库默认分支 |
| `core.autocrlf` | input | 跨平台换行处理 |
| `core.excludesfile` | `~/.gitignore_global` | 全局忽略规则（见下） |
| `filter.lfs` | git-lfs 四件套 | LFS 支持 |
| `[user]` | azwpayne / paynewu0719@gmail.com | 个人身份（fork 公开后注意脱敏） |
| `http/https "https://github.com"` | socks5://127.0.0.1:7890 | **仅** github.com 走本地代理 |
| `ssh "ssh.github.com"` | 同上 | SSH over 443 也走代理 |
| `push.default` | current + autoSetupRemote | push 当前分支并自动建立上游 |
| `safe.directory` | * | 信任所有目录（容器/挂载盘场景） |

> 注：文件中 `[push]` 段下的 `rebase = true` 不是标准 git 键，会被静默忽略；
> 若想让 pull 一律变基，应设置 `pull.rebase = true`。

全局忽略规则（`dot_gitignore_global`）：`.DS_Store`、IDE 目录（`.idea`/`.vscode`）、
编辑器交换文件（`*.swp` 等）、日志、Python 缓存（`__pycache__/`、`*.venv`）、
`node_modules/`、构建产物（`dist/ build/ target/`）等。

## GitHub CLI — `private_dot_config/gh/private_config.yml`

- `git_protocol: https` 为默认值；但 `hosts.yml` 中按主机覆盖为 `ssh`
  （hosts.yml 由目标机器的 `gh auth login` 生成，不进仓库）。
- 别名：`gh co` = `pr checkout`。
- `pager` / `browser` 留空跟随环境变量；spinner 动画开启。
- 配合 zsh 中的 `gopen`（= `gh browse`）在浏览器打开当前仓库。

## mise — `private_dot_config/mise/config.toml`

声明五个工具均为 `latest`：**bun · deno · go · node · pnpm**。
`~/.zshrc` 已 `eval "$(mise activate zsh)"`，常用命令：

```bash
mise ls            # 查看已安装版本
mise install       # 安装声明的全部工具
mise use -g node@lts   # 固定某工具全局版本（会改写 config.toml，记得提交）
```

## Codex — `dot_codex/private_empty_config.toml`

指向 `~/.codex/empty_config.toml` 的空文件占位，仅用于保证目录存在且权限正确，
无实际配置内容。

## pi coding agent — `private_dot_pi/private_agent/`

为 [pi](https://github.com/earendil-works/pi-coding-agent) 编码代理准备的受限运行环境，
四个文件各司其职（整体 0600 权限）：

### settings.json

主题 dark；默认 provider `opencode` + model `x-preview-f-free`；thinking level max；
启用 7 个包：pi-web-access、pi-subagents、pi-dynamic-workflows、pi-btw、pi-goal、
pi-landstrip、pi-permission-system。

### sandbox.json —— 文件系统与网络沙箱

- shell 可读宿主文件系统，但显式 deny 读 `/Users`、`/home`、`/etc`、`/var`、`/tmp` 等大范围路径
  （工作依赖 cwd 白名单放行）；写白名单仅限项目目录、`/dev/null`、`/tmp` 及 npm/cargo/cache。
- 写黑名单保护 `.env*`、`*.pem`、`*.key`、`~/.ssh`、shell rc 文件、本沙箱配置自身。
- **网络默认关闭**（`allowNetwork: false`），需要联网的工具须显式放行。

### landstrip.json —— 子代理与任务权限

子代理上限 16；任务级权限除 `review` 外一律 deny——防止 agent 自行派生执行类子代理。

### extensions/pi-permission-system/config.json —— 工具级权限矩阵

| 类别 | 策略示例 |
| --- | --- |
| read | 默认 allow；deny `*.env`、`~/.ssh/*`、`~/.aws/*`、`~/.gnupg/*`（`.env.example` 放行） |
| write / edit | 默认 ask；敏感路径同上 deny |
| bash | 只读命令（pwd/ls/cat/echo/mkdir/touch/cd）allow；`sudo`、`rm`、`mv`、`dd`、`mkfs` deny；git 只读命令 allow，`git add`/`commit -m` allow，`push`/`reset --hard`/`clean -fd` 需确认 |
| mcp / skill | 默认 ask |

这套策略的目标：让 agent 能完成日常编码任务，同时杜绝误删、密钥外泄与未授权推送。

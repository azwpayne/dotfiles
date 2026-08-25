# 开发工具链：git / gh / mise / codex / pi agent

## Git — `dot_gitconfig` → `~/.gitconfig`

| 配置 | 值 | 说明 |
| --- | --- | --- |
| `core.editor` | `'code'` | 提交信息等用 VS Code 编辑 |
| `init.defaultBranch` | `main` | 新仓库默认分支 |
| `core.autocrlf` | `input` | 仅提交时转 LF，检出不转 |
| `core.excludesfile` | `/Users/payne/.gitignore_global` | 全局忽略规则（见下） |
| `filter.lfs` | `smudge`/`clean`/`process`+`required true` | git-lfs 四件套 |
| `[user]` | `azwpayne` / `paynewu0719@gmail.com` | 个人身份（fork 公开后注意脱敏） |
| `http "https://github.com"` | `socks5://127.0.0.1:7890` | 仅 github.com 走本地 SOCKS5 代理 |
| `https "https://github.com"` | `socks5://127.0.0.1:7890` | 同上，https 协议 |
| `ssh "ssh.github.com"` | `socks5://127.0.0.1:7890` | SSH over HTTPS 端口（443）同样走代理 |
| `push.default` | `current` | push 当前分支 |
| `push.autoSetupRemote` | `true` | 首次 push 自动建立上游追踪 |
| `safe.directory` | `*` | 信任所有目录（容器/挂载盘场景避免 dubious ownership） |

> **注意**：`[push]` 段下的 `rebase = true` 并非标准 git 配置键，会被 git 静默忽略；
> 若希望 `git pull` 一律变基，应改为 `pull.rebase = true` 或 `pull.rebase = false` 显式声明。
> 当前 `dot_gitconfig` 已不再保留注释掉的 `[http]`/`[https]` 全局代理段，仅保留按域名限定的三条代理。

全局忽略规则（`dot_gitignore_global` → `~/.gitignore_global`）：

`*~`、`.DS_Store`（含 `**/.DS_Store`）、IDE 目录（`.idea`/`*.iml`/`.vscode`）、
编辑器交换文件（`*.swp`/`*.swo`/`*.bak`）、编译产物（`*.aux`/`*.log*`/`.tox`/`dist/`/`build/`/`target/`/`bin/`）、
Python 缓存（`__pycache__/`/`*.venv`/`*.cache`/`*.git`）、`node_modules/` 等。

## GitHub CLI — `gh`

当前仓库未直接托管 `private_dot_config/gh/private_config.yml`（该目录不存在），
`gh` 配置由目标机器上 `gh auth login` 生成（`~/.config/gh/hosts.yml` / `config.yml`）：

- 协议 `git_protocol: https` 为默认值；`hosts.yml` 中通常按主机覆盖为 `ssh`。
- 常用别名：`gh co` = `pr checkout`（若在本地配置）。
- `pager` / `browser` 留空跟随环境变量；spinner 动画开启。
- 配合 `private_dot_config/zsh/aliases.zsh` 中的 `gopen`（`gh browse`）在浏览器打开当前仓库。

## mise — `private_dot_config/mise/config.toml`

声明五个工具均为 `latest`：**bun · deno · go · node · pnpm**。

```toml
[tools]
bun = "latest"
deno = "latest"
go = "latest"
node = "latest"
pnpm = "latest"
```

`~/.zshrc` 已 `eval "$(mise activate zsh)"`，常用命令：

```bash
mise ls                  # 查看已安装版本
mise install             # 安装声明的全部工具
mise use -g node@lts     # 固定某工具全局版本（会改写 config.toml，记得提交）
```

## Codex — `dot_codex/private_empty_config.toml`

`~/.codex/empty_config.toml` 的空文件占位，仅用于保证 `~/.codex/` 目录存在且权限正确，
无实际配置内容。

## pi coding agent — `private_dot_pi/private_agent/`

为 [pi](https://github.com/earendil-works/pi-coding-agent) 编码代理准备的受限运行环境，
四个文件各司其职（整体 0600 权限）：

### settings.json — 主题与扩展包

当前已简化为最小可用形态，仅保留主题、思考块显隐与扩展包列表：

```json
{
  "theme": "dark",
  "lastChangelogVersion": "0.84.2",
  "hideThinkingBlock": true,
  "packages": [
    "npm:pi-web-access",
    "npm:pi-subagents",
    "npm:@quintinshaw/pi-dynamic-workflows",
    "npm:@narumitw/pi-btw",
    "npm:@narumitw/pi-goal",
    "npm:pi-landstrip",
    "npm:@gotgenes/pi-permission-system"
  ]
}
```

- `theme: dark`，`hideThinkingBlock: true`。
- **不再包含**旧版的 `defaultProvider` / `defaultModel` / `thinkingLevel` 等字段，
  provider 与模型选择由运行时或上层编排决定。
- 启用 7 个包：`pi-web-access`、`pi-subagents`、`@quintinshaw/pi-dynamic-workflows`、
  `@narumitw/pi-btw`、`@narumitw/pi-goal`、`pi-landstrip`、`@gotgenes/pi-permission-system`。

### sandbox.json — 文件系统与网络沙箱

```json
{
  "enabled": true,
  "shell": { "readAccess": "host" },
  "filesystem": {
    "allowRead": [],
    "denyRead": ["/Users", "/home", "/root", "/etc", "/var", "/tmp", "/private/var", "/private/tmp"],
    "allowWrite": [".", "/dev/null", "/tmp", "~/.npm", "~/.cargo/registry", "~/.cache"],
    "denyWrite": ["**/.env", "**/*.pem", "**/.env.*", "**/*.key", "~/.ssh", ".pi/sandbox.json", "~/.bashrc", "~/.zshrc", "~/.profile", "~/.gitconfig"]
  },
  "network": { "allowNetwork": false, "allowLocalBinding": false }
}
```

- shell 可读宿主文件系统（`readAccess: host`），但显式 deny 读 `/Users`、`/home`、`/root`、`/etc`、`/var`、`/tmp`、`/private/var`、`/private/tmp` 等大范围路径（工作依赖 cwd 白名单放行）；`allowRead` 为空数组。
- 写白名单仅限项目目录（`.`）、`/dev/null`、`/tmp` 及 `~/.npm`、`~/.cargo/registry`、`~/.cache`。
- 写黑名单保护 `**/.env`、`**/.env.*`、`**/*.pem`、`**/*.key`、`~/.ssh`、shell rc 文件（`~/.bashrc`/`~/.zshrc`/`~/.profile`）、`~/.gitconfig` 与本沙箱配置自身（`.pi/sandbox.json`）。
- **网络默认关闭**（`allowNetwork: false`，`allowLocalBinding: false`），需要联网的工具须显式放行。

### landstrip.json — 子代理与任务权限

```json
{
  "maxSubagents": 16,
  "toolFilesystemPolicy": "sandbox",
  "permission": {
    "task": { "*": "deny", "review": "allow" }
  }
}
```

- 子代理上限 16；`toolFilesystemPolicy: sandbox` 复用上节沙箱。
- 任务级权限除 `review` 外一律 `deny`——防止 agent 自行派生执行类子代理。

### extensions/pi-permission-system/config.json — 工具级权限矩阵

> 注释已由旧版 `// project management` 更名为 `// script`，对应 `node -e` / `npm` / `pnpm` / `cargo` 等脚本类命令分组。

| 类别 | 策略 |
| --- | --- |
| `*` | `allow`（全局默认放行） |
| `mcp` | 默认 `ask`；`mcp_status` / `mcp_list` 例外 `allow` |
| `skill` | 默认 `ask` |
| `read` | 默认 `allow`；deny `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`、`~/.gnupg/*`（`*.env.example` 例外放行） |
| `write` / `edit` | 默认 `allow`；deny `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`（注意：`*.env.example` 在 write/edit 段未单独放行） |
| `path` | 默认 `allow`；deny `*.env`、`*.env.*`、`*.pem`、`*.key`、`~/.ssh/*`、`/etc/*`、`/var/*`（`*.env.example` 放行） |
| `external_directory` | 默认 `ask`；`~/.cargo/registry/*`、`~/.npm/*`、`~/.cache/*` 例外 `allow` |
| `bash` | 默认 `ask`；只读命令 `pwd`/`ls *`/`cat *`/`echo *`/`mkdir *`/`touch *`/`cd *`/`find *`/`grep *`/`head *`/`awk *`/`sed *`/`wc *`/`for *`/`ps *`/`sleep *` 例外 `allow`；`sudo *`/`mv *`/`rm *`/`unlink *`/`dd if=* of=*`/`mkfs.*` deny；`git *` 默认 `allow` 但 `git rm *` deny；脚本类 `node -e`/`npm install`/`npm ci`/`pnpm *`/`cargo *` 为 `ask`（归入 `// script` 组） |

这套策略的目标：让 agent 能完成日常编码、只读检索与受控编辑，同时杜绝误删、密钥外泄、未授权推送与敏感路径写入。
`promptMaxRows: 32`，`$schema` 指向 `pi-permission-system` 的 JSON Schema。

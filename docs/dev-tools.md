# 开发工具链：git / gh / mise / codex / pi agent

## Git — `dot_gitconfig` → `~/.gitconfig`

> **注意**：`dot_gitconfig` **会**随 `chezmoi apply` 部署为 `~/.gitconfig`（`chezmoi managed` 实测包含 `.gitconfig`）；早期版本 `.chezmoiignore` 中按源文件名书写的 `dot_gitconfig` / `**/dot_git` 行从不匹配任何目标、未生效，现已删除。下表为其字段快照，值与源文件逐行核对一致。

| 配置项 | 值 | 说明 |
| --- | --- | --- |
| `core.editor` | `'code'` | 提交信息等由 VS Code 编辑 |
| `init.defaultBranch` | `main` | 新仓库默认分支 |
| `core.autocrlf` | `input` | 仅提交时转换为 LF，检出时不转换 |
| `core.excludesfile` | `~/.gitignore_global` | 全局忽略文件（`~` 由 git 原生展开，无用户名硬编码；见下文） |
| `filter.lfs` | `smudge` / `clean` / `process` + `required true` | git-lfs 四件套 |
| `[user]` | `azwpayne` / `paynewu0719@gmail.com` | 个人身份（公开 fork 前注意脱敏） |
| `http "https://github.com"` | `socks5://127.0.0.1:5376` | 唯一按域名限定的代理；`http.<url>` 段对匹配该 URL 的 HTTP/HTTPS 远程均生效（`[https …]` / `[ssh …]` 冗余段已删除） |
| `push.default` | `current` | `push` 默认推送当前分支 |
| `push.autoSetupRemote` | `true` | 首次 `push` 自动建立上游追踪 |
| `safe.directory` | `*` | 信任所有目录（容器/挂载盘场景避免 `dubious ownership`） |

> **代理已精简**：当前 `dot_gitconfig` 仅保留一条按域名限定的代理行；历史遗留的注释化全局代理段及冗余的非标准 `[https …]`、`[ssh "ssh.github.com"]` 段均已删除（非标准键会被 git 静默忽略）。SSH 侧代理由 `private_dot_ssh/config` 的自适应 `ProxyCommand` 负责，探测端口同为 `5376`；如需 `git pull` 一律变基，应使用标准键 `pull.rebase = true`（当前未启用）。

全局忽略规则（`dot_gitignore_global` → `~/.gitignore_global`，概要归类，完整清单以源文件为准）：

- 编辑器临时文件与交换文件：`*~`、`.DS_Store`（无斜杠模式递归匹配任意层级，等价覆盖 `**/.DS_Store`）、`*.swp` / `*.swo` / `*.bak`
- IDE 目录：`.idea` / `*.iml` / `.vscode`
- 编译产物与构建目录：`*.aux` / `*.log*` / `.tox` / `dist/` / `build/` / `target/` / `bin/`
- Python 相关：`__pycache__/`、`*.venv`、`*.cache`
- Node 依赖：`node_modules/`

与 `dot_gitignore_global` 实际 19 条模式逐行一致（历史上的 `*.git` 笔误行与冗余的
`**/.DS_Store` 行已删；现存 1 行说明性注释，不计入模式数）。

## GitHub CLI — `gh`

当前仓库未直接托管 `private_dot_config/gh/private_config.yml`（该目录不存在），
`gh` 配置由目标机执行 `gh auth login` 后生成（`~/.config/gh/hosts.yml` / `config.yml`）：

- 协议 `git_protocol: https` 为默认值；`hosts.yml` 中通常按主机覆盖为 `ssh`。
- 常用别名：`gh co` = `pr checkout`（若在本地配置）。
- `pager` / `browser` 留空，跟随环境变量；`spinner` 动画开启。
- 配合 `private_dot_config/zsh/aliases.zsh` 中的 `gopen`（`gh browse`）在浏览器打开当前仓库。
- 网络可达性与 `dot_gitconfig` / `private_dot_ssh/config` 共用本机 `127.0.0.1:5376` SOCKS5 代理（见 [getting-started.md](getting-started.md)「弱网环境：bootstrap 前先设代理」），已统一为 `5376`，不再区分 `7890`。

## mise — `private_dot_config/mise/config.toml`

声明 5 个工具均为 `latest`：**bun · deno · go · node · pnpm**，与源文件逐行一致。

```toml
[tools]
bun = "latest"
deno = "latest"
go = "latest"
node = "latest"
pnpm = "latest"
```

`dot_zshrc` 已 `eval "$(mise activate zsh)"`，常用命令与实际行为一致：

```bash
mise ls                  # 查看已安装版本
mise install             # 安装 config.toml 声明的全部工具
mise use -g node@lts     # 固定某工具全局版本（会改写 config.toml，记得提交）
mise upgrade             # 升级全部受管工具（被 aliases.zsh 的 update-all 复用）
```

### 包管理器更新：`aliases.zsh` 的 `auto_update` 与 `update-all`

`private_dot_config/zsh/aliases.zsh` 提供两个更新入口，实际更新逻辑已收敛为一处：

| 函数 | 位置 | 覆盖目标 | 核心机制 | 适用场景 |
| --- | --- | --- | --- | --- |
| `auto_update` | `aliases.zsh:32` | 与 `update-all` 相同（6 项） | 薄包装：打印 🚀 横幅，若定义了 `onproxy` 函数则先切代理，随后**直接委托**同文件下方的 `update-all` 执行（调用时解析） | 兼容旧习惯的一键全量入口 |
| `update-all` | `aliases.zsh:178` | 6 项：`brew` / `sdk` / `rustup` / `tldr` / `uv` / `mise` | 基于 `local -A tasks` 关联数组；支持 `update-all brew mise` 参数过滤，未传参则 `targets=(${(k)tasks})` 全量；循环内 `command -v $name` 守卫 + 未知目标报错并提示 `Available: ...`；失败计数 `failed`、耗时统计 `start_time/duration`、`print -P` 彩色输出（蓝标题/绿成功/黄跳过/红失败） | 需灵活选择目标、查看耗时与失败统计 |

要点：

- 旧版 `auto_update` 曾顺序守卫调用五个 `*_update` 辅助函数（`uv_update` / `sdk_update` / `rust_update` / `tldr_update` / `brew_update`），它们已在提交 `0af1f61` 中删除；现 `auto_update` 委托 `update-all`，二者覆盖目标完全一致（均含 `mise`）。
- `update-all` 的 `brew` 任务激进：`brew update -f && brew upgrade -f --greedy-latest -y && brew cu -y -a && brew cleanup --prune=all`（含 `brew cu -y -a`；历史上的 `brew_update` 别名已删除，`brew cu` 现仅存在于 `update-all`）。

> 验证：`zsh -n ~/.config/zsh/aliases.zsh` 可覆盖两函数语法；`zsh -ic 'type update-all auto_update'` 确认已加载。

## Codex — `dot_codex/private_empty_config.toml`

部署目标为 **`~/.codex/config.toml`**（`chezmoi managed` 实测为 `.codex/config.toml`；旧文档所写 `~/.codex/empty_config.toml` 有误）：`empty_` 前缀生成 0 字节空文件、`private_` 前缀对应 `0600` 权限，仅用于保证 `~/.codex/` 目录存在且权限正确，无实际配置内容。

## pi coding agent — `private_dot_pi/private_agent/`

为 [pi](https://github.com/earendil-works/pi-coding-agent) 编码代理准备的受限运行环境（部署到 `~/.pi/agent/`）。
四个文件各司其职：由于 chezmoi 目标名均无 `private_` 前缀，文件应用后为默认权限 `0644`，
仅父目录因 `private_dot_pi/private_agent` 命名为 `0700`。

### settings.json — 主题与扩展包

与 `private_dot_pi/private_agent/settings.json` 实际内容完全一致（已修正旧文档的过时说明）：

```json
{
  "theme": "dark",
  "lastChangelogVersion": "0.84.3",
  "hideThinkingBlock": true,
  "packages": [
    "npm:@gotgenes/pi-permission-system",
    "npm:pi-landstrip",
    "npm:@quintinshaw/pi-dynamic-workflows",
    "npm:@narumitw/pi-goal",
    { "source": "npm:@juicesharp/rpiv-todo", "extensions": ["-index.ts"] },
    { "source": "npm:@asermax/pi-cc-plugins", "extensions": ["-index.ts"] },
    { "source": "npm:@narumitw/pi-btw", "extensions": ["-dist/index.ts"] },
    { "source": "npm:pi-web-access", "extensions": ["-index.ts"] },
    { "source": "npm:pi-lens", "extensions": ["-dist/index.js"] },
    "npm:pi-subagents"
  ],
  "defaultProvider": "cc-switch-zhipu-glm",
  "defaultModel": "glm-5.3-flash",
  "defaultThinkingLevel": "high"
}
```

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `theme` | `dark` | 深色主题 |
| `lastChangelogVersion` | `0.84.3` | 已同步至最新 pi 版本 |
| `hideThinkingBlock` | `true` | 隐藏思考块（界面默认不展示 thinking 内容） |
| `packages` | 10 个条目 | 5 个纯字符串包（`@gotgenes/pi-permission-system`、`pi-landstrip`、`@quintinshaw/pi-dynamic-workflows`、`@narumitw/pi-goal`、`pi-subagents`）+ 5 个带 `extensions` 过滤的对象形式条目（`rpiv-todo`、`pi-cc-plugins`、`pi-btw`、`pi-web-access`、`pi-lens`），顺序同源文件 |
| `defaultProvider` | `cc-switch-zhipu-glm` | 默认 provider |
| `defaultModel` | `glm-5.3-flash` | 默认模型 |
| `defaultThinkingLevel` | `high` | 默认思考强度 |

> 实值以 `private_dot_pi/private_agent/settings.json` 为唯一权威；跨文档冲突时一律以源文件为准。

### sandbox.json — 文件系统与网络沙箱

与 `private_dot_pi/private_agent/sandbox.json` 实际内容完全一致（历史遗留的重复列表项已清理，现无重复）：

```json
{
  "enabled"   : true,
  "shell"     : {"readAccess": "host"},
  "filesystem": {
    "allowRead" : ["**"],
    "denyRead"  : ["/Users", "/home", "/root", "/etc", "/var", "/tmp", "/private/var", "/private/tmp"],
    "allowWrite": [
      ".",                    "/dev/null",            "/tmp",                 "~/.npm",
      "~/.cargo/registry",    "~/.cache",             "~/.gitconfig",         "~/.config/git/config"
    ],
    "denyWrite" : [
      "**/.env",          "**/*.pem",         "**/.env.*",        "~/.ssh",
      "**/*.key",         ".pi/sandbox.json", "~/.bashrc",        "~/.zshrc",
      "~/.profile",       "~/.gitconfig"
    ]
  },
  "network"   : {
    "allowNetwork"       : false,
    "allowLocalBinding"  : false,
    "allowAllUnixSockets": false,
    "allowUnixSockets"   : [],
    "allowedDomains"     : ["*.githubusercontent.com", "*.github.com", "github.com"],
    "deniedDomains"      : []
  },
  "windows"   : {"appContainerMode": "standard", "allowLoopback": false}
}
```

| 维度 | 配置 | 说明 |
| --- | --- | --- |
| `enabled` | `true` | 沙箱总开关开启 |
| `shell.readAccess` | `host` | shell 可读宿主文件系统 |
| `filesystem.allowRead` | `["**"]` | 全域读取放行（1b535e9 放宽，实际约束靠 `denyRead` 与工具级权限矩阵） |
| `filesystem.denyRead` | 8 项 | `/Users`、`/home`、`/root`、`/etc`、`/var`、`/tmp`、`/private/var`、`/private/tmp`（大范围 deny，工作区由 `cwd` 白名单放行） |
| `filesystem.allowWrite` | 8 项 | `.`、`/dev/null`、`/tmp`、`~/.npm`、`~/.cargo/registry`、`~/.cache`、`~/.gitconfig`、`~/.config/git/config` |
| `filesystem.denyWrite` | 10 项 | `**/.env`、`**/*.pem`、`**/.env.*`、`~/.ssh`、`**/*.key`、`.pi/sandbox.json`、`~/.bashrc`、`~/.zshrc`、`~/.profile`、`~/.gitconfig` |
| `network.allowNetwork` | `false` | **网络默认关闭**（禁网策略） |
| `network.allowLocalBinding` | `false` | 禁止本地端口绑定 |
| `network.allowAllUnixSockets` | `false` | 不放行全部 Unix socket |
| `network.allowUnixSockets` | `[]` | Unix socket 白名单为空 |
| `network.allowedDomains` | 3 项 | `*.githubusercontent.com`、`*.github.com`、`github.com`——域名白名单，仅当 `allowNetwork` 启用时作为出站限制生效 |
| `network.deniedDomains` | `[]` | 无额外黑名单 |
| `windows` | `appContainerMode: standard`、`allowLoopback: false` | Windows 平台的沙箱容器模式（macOS 上不生效） |

- **网络默认关闭（禁网策略）**：`allowNetwork: false` + `allowLocalBinding: false` + `allowAllUnixSockets: false`，沙箱内禁止出站网络、本地端口绑定与 Unix socket；`allowedDomains` 3 项域名白名单仅在网络启用时才作为出站限制生效（当前不生效）；`deniedDomains` 为空。
- **重复项已清理**：历史上 `allowWrite` 中 `/dev/null` 重复一次（9 项）、`denyWrite` 中 `**/.env` 与 `**/*.pem` 各重复一次（12 项），去重后为 8 / 10 项、无重复，语义不变（实测：`python3 -c "import json; d=json.load(open('private_dot_pi/private_agent/sandbox.json'))['filesystem']; print(len(d['allowWrite']), len(d['denyWrite']))"` → `8 10`）。
- `~/.gitconfig` 同时出现在 `allowWrite` 与 `denyWrite`（交集未收口，属已知的配置矛盾）。

### landstrip.json — 子代理与任务权限

与 `private_dot_pi/private_agent/landstrip.json` 实际内容一致：

```json
{
  "maxSubagents"        : 5,
  "toolFilesystemPolicy": "sandbox",
  "permission"          : { "task": {"*": "ask", "review": "allow"} }
}
```

- 子代理上限 **5**（更早版本曾为 `16` / `8`）；`toolFilesystemPolicy: sandbox` 复用上节沙箱。
- 任务级权限 `*`: `ask`、`review`: `allow`——派生子代理前需用户确认（`c6408c0` 将 `*` 由 `deny` 放宽为 `ask`）：防止 agent 未经询问自行派生执行类子代理，同时免询问放行只读审查。
- **与 `workflows/settings.json` 的关系**：`landstrip.json` 的 `maxSubagents` 限制**子代理工具可派生的子代理总数上限**；`workflows/settings.json` 的 `progressPanelMaxAgents` 限制**工作流进度面板的并发/展示代理数上限**。二者职责不同、相互独立，当前值分别为 `5` / `8`。详见 [layout.md](layout.md) 与下节。

### workflows/settings.json — 动态工作流设置

位于 `private_dot_pi/workflows/settings.json`（部署到 `~/.pi/workflows/settings.json`），为不含注释的纯 JSON，与实际文件一致：

```json
{
    "defaultConcurrency"    : 10,
    "defaultAgentRetries"   : 2,
    "progressPanelMode"     : "compact",
    "progressPanelMaxAgents": 8,
    "persistAgentSessions"  : false,
    "allowBudgetCaps"       : false
}
```

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `defaultConcurrency` | `10` | 工作流默认并发代理数（`6cc29ce` 由 `5` 提升至 `10`） |
| `defaultAgentRetries` | `2` | 单个代理默认重试次数 |
| `defaultAgentTimeoutMs` | （该键已不存在） | 单代理超时，已从文件中删除 |
| `defaultTokenBudget` | （该键已不存在） | 单代理 token 预算，已从文件中删除 |
| `progressPanelMode` | `compact` | 进度面板紧凑模式 |
| `progressPanelMaxAgents` | `8` | 进度面板最大并发/展示代理数 |
| `persistAgentSessions` | `false` | 不持久化代理会话 |
| `allowBudgetCaps` | `false` | 不启用预算上限 |

`progressPanelMaxAgents: 8` 用于 `pi-dynamic-workflows` 的进度面板。它与上节 `pi-subagents` 的
`maxSubagents: 5` 相互独立：前者限制工作流进度面板的并发/展示代理数上限，
后者限制子代理工具可派生的子代理总数上限。详见 [layout.md](layout.md)。

### workflows/model-tiers.json — 工作流三档模型分层

位于 `private_dot_pi/workflows/model-tiers.json`（部署到 `~/.pi/workflows/model-tiers.json`），与实际文件一致：

```json
{
  "tiers": {
    "small" : "cc-switch-zhipu-glm/glm-4.7",
    "medium": "cc-switch-zhipu-glm/glm-5.3-flash",
    "big"   : "cc-switch-zhipu-glm/glm-5.3:max"
  }
}
```

- 三档 `small` / `medium` / `big` 分别绑定 `glm-4.7`、`glm-5.3-flash`、`glm-5.3:max`——思考预算随档位递增。
- 成本分层意图明显：轻量任务下沉到 glm-4.7 降本，中档用 glm-5.3-flash，重档 glm-5.3:max 拉满思考；主模型 `defaultModel: glm-5.3-flash`（settings.json）。

### extensions/pi-permission-system/config.json — 工具级权限矩阵

> 与源文件逐行核对一致：`bash` 组内脚本类为 `python3 *` / `node *` 两条 `ask`（文件为无注释的纯 JSON）；不存在任何被整段注释的历史遗留条目，其余命令由 `*` : `allow` 默认兜底。

| 类别 | 策略 |
| --- | --- |
| `*` | `allow`（全局默认放行） |
| `mcp` | 全部 `allow`（`*` / `mcp_status` / `exa:*`） |
| `skill` | `allow` |
| `read` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`、`~/.gnupg/*`（`*.env.example` 例外 `allow`） |
| `write` / `edit` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`（注意：`*.env.example` 在 `write` / `edit` 段未单独放行） |
| `path` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`*.pem`、`*.key`、`~/.ssh/*`、`/etc/*`、`/var/*`（`*.env.example` 放行） |
| `external_directory` | 默认 `ask`；`~/.cargo/registry/*`、`~/.npm/*`、`~/.cache/*` 为 `allow` |
| `bash` | 默认 `*` → `allow`；危险命令 `sudo *` / `mv *` / `rm *` / `unlink *` / `dd if=* of=*` / `mkfs.*` 为 `deny`；脚本类 `python3 *` / `node *` 为 `ask`（文件为纯 JSON，无注释分组、无历史注释条目） |

这套策略的目标：让 agent 能完成日常编码、只读检索与受控编辑，同时杜绝误删、密钥外泄与敏感路径写入，并把脚本执行类命令收敛到 `ask`。
`promptMaxRows: 8`，`$schema` 指向 `pi-permission-system` 的 JSON Schema，与源文件一致。

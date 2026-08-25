# 开发工具链：git / gh / mise / codex / pi agent

## Git — `dot_gitconfig` → `~/.gitconfig`

> **注意**：根目录 `.chezmoiignore` 虽含 `dot_gitconfig` / `**/dot_git` 等行，但它们按**源文件名**而非部署目标名书写，实际不生效；
> `chezmoi managed` 实测包含 `.gitconfig`，即 `chezmoi apply` 会将本文件渲染为 `~/.gitconfig`。下表为其字段快照，值与源文件逐行核对一致。

| 配置项 | 值 | 说明 |
| --- | --- | --- |
| `core.editor` | `'code'` | 提交信息等由 VS Code 编辑 |
| `init.defaultBranch` | `main` | 新仓库默认分支 |
| `core.autocrlf` | `input` | 仅提交时转换为 LF，检出时不转换 |
| `core.excludesfile` | `/Users/payne/.gitignore_global` | 全局忽略文件（见下文） |
| `filter.lfs` | `smudge` / `clean` / `process` + `required true` | git-lfs 四件套 |
| `[user]` | `azwpayne` / `paynewu0719@gmail.com` | 个人身份（公开 fork 前注意脱敏） |
| `http "https://github.com"` | `socks5://127.0.0.1:5376` | 仅 `github.com` 走本地 SOCKS5 代理 |
| `https "https://github.com"` | `socks5://127.0.0.1:5376` | 同上，`https` 协议，三处统一为 `5376` |
| `ssh "ssh.github.com"` | `socks5://127.0.0.1:5376` | SSH over HTTPS（`ssh.github.com:443`）同样走 `socks5://127.0.0.1:5376` |
| `push.default` | `current` | `push` 默认推送当前分支 |
| `push.autoSetupRemote` | `true` | 首次 `push` 自动建立上游追踪 |
| `safe.directory` | `*` | 信任所有目录（容器/挂载盘场景避免 `dubious ownership`） |

> **非标准键告警**：`[push] rebase = true` 并非标准 git 配置键，会被 git 静默忽略；
> 如需 `git pull` 一律变基，应改为 `pull.rebase = true`（或显式 `false`）。详见 `dot_gitconfig` 实测与本段告警。
>
> **代理已统一**：当前 `dot_gitconfig` 已清理注释掉的全局 `[http]` / `[https]` 代理段，仅保留按域名限定的三条代理，且三条 `proxy` 均已统一为 `socks5://127.0.0.1:5376`（历史文档中的 `7890` 已失效），与 `private_dot_ssh/config` 的 `ProxyCommand` 探测端口 `5376` 保持一致。

全局忽略规则（`dot_gitignore_global` → `~/.gitignore_global`，概要归类，完整清单以源文件为准）：

- 编辑器临时文件与交换文件：`*~`、`.DS_Store`、`**/.DS_Store`、`*.swp` / `*.swo` / `*.bak`
- IDE 目录：`.idea` / `*.iml` / `.vscode`
- 编译产物与构建目录：`*.aux` / `*.log*` / `.tox` / `dist/` / `build/` / `target/` / `bin/`
- Python 相关：`__pycache__/`、`*.venv`、`*.cache`
- 版本控制：`*.git`（排除嵌套仓库）
- Node 依赖：`node_modules/`

与 `dot_gitignore_global` 实际 21 条模式逐行一致。

## GitHub CLI — `gh`

当前仓库未直接托管 `private_dot_config/gh/private_config.yml`（该目录不存在），
`gh` 配置由目标机执行 `gh auth login` 后生成（`~/.config/gh/hosts.yml` / `config.yml`）：

- 协议 `git_protocol: https` 为默认值；`hosts.yml` 中通常按主机覆盖为 `ssh`。
- 常用别名：`gh co` = `pr checkout`（若在本地配置）。
- `pager` / `browser` 留空，跟随环境变量；`spinner` 动画开启。
- 配合 `private_dot_config/zsh/aliases.zsh` 中的 `gopen`（`gh browse`）在浏览器打开当前仓库。
- 网络可达性与 `dot_gitconfig` / `private_dot_ssh/config` 共用本机 `127.0.0.1:5376` SOCKS5 代理（见 [getting-started.md](getting-started.md)「网络与代理前提」），已统一为 `5376`，不再区分 `7890`。

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

`private_dot_config/zsh/aliases.zsh` 提供两套更新入口，二者互补，差异已精确文档化：

| 函数 | 位置 | 覆盖目标 | 核心机制 | 适用场景 |
| --- | --- | --- | --- | --- |
| `auto_update` | `aliases.zsh:42` | 5 项：`uv` / `sdk` / `rustup` / `tldr` / `brew`（**不含 `mise`**） | 顺序守卫调用各 `*_update`，每步前 `command -v xxx &>/dev/null &&` 守卫，缺失跳过；固定顺序、无参数、无失败计数 | 日常一键全量、兼容旧习惯 |
| `update-all` | `aliases.zsh:196` | 6 项：`brew` / `sdk` / `rustup` / `tldr` / `uv` / `mise` | 基于 `local -A tasks` 关联数组；支持 `update-all brew mise` 参数过滤，未传参则 `targets=(${(k)tasks})` 全量；循环内 `command -v $name` 守卫 + 未知目标报错并提示 `Available: ...`；失败计数 `failed`、耗时统计 `start_time/duration`、`print -P` 彩色输出（蓝标题/绿成功/黄跳过/红失败） | 需灵活选择目标、查看耗时与失败统计、覆盖 `mise` 的新场景 |

关键差异：

- `mise` 仅在 `update-all` 覆盖：`tasks[mise]="mise upgrade"`，而 `auto_update` 尚未覆盖 `mise`，这是两者在工具链覆盖上的核心差异。
- `brew` 任务激进程度不同：
  - `update-all` 的 `brew`：`brew update -f && brew upgrade -f --greedy-latest -y && brew cu -y -a && brew cleanup --prune=all`（含 `brew cu -y -a`）
  - `brew_update` 别名：`brew update && brew upgrade --greedy-latest && brew cleanup --prune=all`（已移除 `brew cu` 与 `-f`，更保守；差异已在仓库中显式注释）

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
    "npm:pi-web-access",
    "npm:pi-subagents",
    "npm:@quintinshaw/pi-dynamic-workflows",
    "npm:@narumitw/pi-btw",
    "npm:@narumitw/pi-goal",
    "npm:pi-landstrip",
    "npm:@gotgenes/pi-permission-system"
  ],
  "defaultProvider": "zai-coding-cn",
  "defaultModel": "glm-5.2",
  "defaultThinkingLevel": "xhigh"
}
```

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `theme` | `dark` | 深色主题 |
| `lastChangelogVersion` | `0.84.3` | 已同步至最新 pi 版本（原文档 `0.84.2` 已过时） |
| `hideThinkingBlock` | `true` | 隐藏思考块（界面默认不展示 thinking 内容） |
| `packages` | 7 个 `npm:` 包 | `pi-web-access`、`pi-subagents`、`@quintinshaw/pi-dynamic-workflows`、`@narumitw/pi-btw`、`@narumitw/pi-goal`、`pi-landstrip`、`@gotgenes/pi-permission-system` |
| `defaultProvider` | `zai-coding-cn` | 默认 provider |
| `defaultModel` | `glm-5.2` | 默认模型 |
| `defaultThinkingLevel` | `xhigh` | 默认思考强度（原文档 `high` 已更新为 `xhigh`） |

> **修正说明**：本节此前长期失实——曾把 `hideThinkingBlock` 写成 `false`、`defaultProvider` 写成 `opencode`、`defaultModel` 写成 `muse-spark-1.2-contributor-free`，并自称"已更正、与 layout/README 快照一致"，均为错误。实值以 `private_dot_pi/private_agent/settings.json` 为唯一权威：`hideThinkingBlock: true`、`defaultProvider: zai-coding-cn`、`defaultModel: glm-5.2`、`defaultThinkingLevel: xhigh`。本节 JSON 快照与表格已按实值重写；跨文档冲突时一律以源文件为准。

### sandbox.json — 文件系统与网络沙箱

与 `private_dot_pi/private_agent/sandbox.json` 实际内容完全一致（含重复项原样保留）：

```json
{
  "enabled": true,
  "shell": { "readAccess": "host" },
  "filesystem": {
    "allowRead": [],
    "denyRead": ["/Users", "/home", "/root", "/etc", "/var", "/tmp", "/private/var", "/private/tmp"],
    "allowWrite": [".", "/dev/null", "/tmp", "~/.npm", "~/.cargo/registry", "~/.cache"],
    "denyWrite": [
      "**/.env",
      "**/*.pem",
      "**/.env",
      "**/.env.*",
      "~/.ssh",
      "**/*.pem",
      "**/*.key",
      ".pi/sandbox.json",
      "~/.bashrc",
      "~/.zshrc",
      "~/.profile",
      "~/.gitconfig"
    ]
  },
  "network": {
    "allowNetwork": false,
    "allowLocalBinding": false,
    "allowedDomains": ["*.githubusercontent.com", "*.github.com", "github.com"],
    "deniedDomains": []
  }
}
```

| 维度 | 配置 | 说明 |
| --- | --- | --- |
| `enabled` | `true` | 沙箱总开关开启 |
| `shell.readAccess` | `host` | shell 可读宿主文件系统 |
| `filesystem.allowRead` | `[]` | 无显式读白名单（依赖 `cwd` 与默认放行） |
| `filesystem.denyRead` | 8 项 | `/Users`、`/home`、`/root`、`/etc`、`/var`、`/tmp`、`/private/var`、`/private/tmp`（大范围 deny，工作区由 `cwd` 白名单放行） |
| `filesystem.allowWrite` | 6 项 | `.`、`/dev/null`、`/tmp`、`~/.npm`、`~/.cargo/registry`、`~/.cache` |
| `filesystem.denyWrite` | 12 项（含重复） | `**/.env`、`**/*.pem`、`**/.env.*`、`**/*.key`、`~/.ssh`、`.pi/sandbox.json`、`~/.bashrc`、`~/.zshrc`、`~/.profile`、`~/.gitconfig`（其中 `**/.env` 与 `**/*.pem` 各重复一次，功能不受影响，文档已标注待清理） |
| `network.allowNetwork` | `false` | **网络默认关闭**（禁网策略；旧文档误写 `true` / "网络已开启"已按实值更正） |
| `network.allowLocalBinding` | `false` | 禁止本地端口绑定 |
| `network.allowedDomains` | 3 项 | `*.githubusercontent.com`、`*.github.com`、`github.com`——域名白名单，仅当 `allowNetwork` 启用时作为出站限制生效 |
| `network.deniedDomains` | `[]` | 无额外黑名单 |

- **网络默认关闭（禁网策略）**：`allowNetwork: false` + `allowLocalBinding: false`，沙箱内禁止出站网络与本地端口绑定；`allowedDomains` 3 项域名白名单仅在网络启用时才作为出站限制生效（当前不生效）；`deniedDomains` 为空。
- 快照中 `denyWrite` 的 12 项含重复已与源文件逐字一致（`python -c "import json; print(len(json.load(open('private_dot_pi/private_agent/sandbox.json'))['filesystem']['denyWrite'])"` → `12`）。

### landstrip.json — 子代理与任务权限

与 `private_dot_pi/private_agent/landstrip.json` 实际内容一致：

```json
{
  "maxSubagents": 8,
  "toolFilesystemPolicy": "sandbox",
  "permission": {
    "task": { "*": "deny", "review": "allow" }
  }
}
```

- 子代理上限 **8**（原文档 `16` 已更正为 `8`）；`toolFilesystemPolicy: sandbox` 复用上节沙箱。
- 任务级权限除 `review` 外一律 `deny`——防止 agent 自行派生执行类子代理。
- **与 `workflows/settings.json` 的关系**：`landstrip.json` 的 `maxSubagents` 限制**子代理工具可派生的子代理总数上限**；`workflows/settings.json` 的 `progressPanelMaxAgents` 限制**工作流进度面板的并发/展示代理数上限**。二者职责不同、相互独立，当前实际值均为 `8`，数值一致仅为巧合，不代表联动。详见 [layout.md](layout.md) 与下节。

### workflows/settings.json — 动态工作流设置

位于 `private_dot_pi/workflows/settings.json`（部署到 `~/.pi/workflows/settings.json`），为带注释的 JSON（JSONC），与实际文件一致：

```jsonc
{
    "defaultConcurrency"    : 5,
    "defaultAgentRetries"   : 2,
    // "defaultAgentTimeoutMs" : 600000,
    // "defaultTokenBudget"    : 50000,
    "progressPanelMode"     : "compact",
    "progressPanelMaxAgents": 8,
    "persistAgentSessions"  : false,
    "allowBudgetCaps"       : false
}
```

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `defaultConcurrency` | `5` | 工作流默认并发代理数 |
| `defaultAgentRetries` | `2` | 单个代理默认重试次数 |
| `defaultAgentTimeoutMs` | （已注释，值 `600000`） | 单代理超时，当前未启用 |
| `defaultTokenBudget` | （已注释，值 `50000`） | 单代理 token 预算，当前未启用 |
| `progressPanelMode` | `compact` | 进度面板紧凑模式 |
| `progressPanelMaxAgents` | `8` | 进度面板最大并发/展示代理数 |
| `persistAgentSessions` | `false` | 不持久化代理会话 |
| `allowBudgetCaps` | `false` | 不启用预算上限 |

`progressPanelMaxAgents: 8` 用于 `pi-dynamic-workflows` 的进度面板。它与上节 `pi-subagents` 的
`maxSubagents: 8` 相互独立：前者限制工作流进度面板的并发/展示代理数上限，
后者限制子代理工具可派生的子代理总数上限。详见 [layout.md](layout.md)。

### workflows/model-tiers.json — 工作流三档模型分层

位于 `private_dot_pi/workflows/model-tiers.json`（部署到 `~/.pi/workflows/model-tiers.json`），与实际文件一致：

```json
{
  "tiers": {
    "small" : "zai-coding-cn/glm-5-turbo:minimal",
    "medium": "zai-coding-cn/glm-5.1:medium",
    "big"   : "zai-coding-cn/glm-5.3:max"
  }
}
```

- 三档 `small` / `medium` / `big` 分别绑定 `glm-5-turbo:minimal`、`glm-5.1:medium`、`glm-5.3:max`——模型代际与思考预算随档位递增。
- 三档模型（5-turbo / 5.1 / 5.3）与主模型 `defaultModel: glm-5.2` 分属不同代际，成本分层意图明显：轻量任务下沉到 turbo 降本，重度任务上浮到 5.3 拉满，主模型 5.2 居中兜底。

### extensions/pi-permission-system/config.json — 工具级权限矩阵

> 与源文件逐行核对一致：`// script` 分组实际为 `python* *` / `node *` / `pnpm *` / `cargo *` 四条 `ask`（并无 `npm` 条目）；早期版本放行的只读命令（`chezmoi *` / `xargs *` / `which *` / `pwd` / `ls *` 等 20 条）与 `git *` allow、`git rm *` / `git config *` deny 等条目现均已整段注释、**当前不生效**（由 `bash` 的 `*` : `allow` 默认兜底）。

| 类别 | 策略 |
| --- | --- |
| `*` | `allow`（全局默认放行） |
| `mcp` | 全部 `allow`（`*` / `mcp_status` / `mcp_list`） |
| `skill` | `allow` |
| `read` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`、`~/.gnupg/*`（`*.env.example` 例外 `allow`） |
| `write` / `edit` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`（注意：`*.env.example` 在 `write` / `edit` 段未单独放行） |
| `path` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`*.pem`、`*.key`、`~/.ssh/*`、`/etc/*`、`/var/*`（`*.env.example` 放行） |
| `external_directory` | 全部 `allow`（`*` 及 `~/.cargo/registry/*`、`~/.npm/*`、`~/.cache/*`） |
| `bash` | 默认 `*` → `allow`；危险命令 `sudo *` / `mv *` / `rm *` / `unlink *` / `dd if=* of=*` / `mkfs.*` 为 `deny`；脚本类（`// script` 组）`python* *` / `node *` / `pnpm *` / `cargo *` 为 `ask`；另有只读命令放行与 `git *` allow、`git rm *` / `git config *` deny 等条目已整段注释、当前不生效 |

这套策略的目标：让 agent 能完成日常编码、只读检索与受控编辑，同时杜绝误删、密钥外泄与敏感路径写入，并把脚本执行类命令收敛到 `ask`。
`promptMaxRows: 8`，`$schema` 指向 `pi-permission-system` 的 JSON Schema，与源文件一致。


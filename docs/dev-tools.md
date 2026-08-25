# 开发工具链：git / gh / mise / codex / pi agent

## Git — `dot_gitconfig` → `~/.gitconfig`

> **注意**：`dot_gitconfig` 已被根目录 `.chezmoiignore` 显式排除（`dot_gitconfig` / `**/dot_git`），`chezmoi apply` 不会将其渲染为 `~/.gitconfig`；
> 下表仅作为本机手工维护的 `~/.gitconfig` 参考快照，值与源文件逐行核对一致。

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

- 编辑器临时文件与交换文件：`*~`、`.DS_Store`、`*.swp` / `*.swo` / `*.bak`
- IDE 目录：`.idea` / `*.iml` / `.vscode`
- 编译产物与构建目录：`*.aux` / `*.log*` / `.tox` / `dist/` / `build/` / `target/` / `bin/`
- Python 相关：`__pycache__/`、`*.venv`、`*.cache`
- 版本控制：`*.git`（排除嵌套仓库）
- Node 依赖：`node_modules/`

与 `dot_gitignore_global` 实际 15 类规则逐行一致。

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

`~/.codex/empty_config.toml` 为空文件占位，仅用于保证 `~/.codex/` 目录存在且权限正确（`private_` 前缀对应 `0600`），无实际配置内容。

## pi coding agent — `private_dot_pi/private_agent/`

为 [pi](https://github.com/earendil-works/pi-coding-agent) 编码代理准备的受限运行环境。
四个文件各司其职：由于 chezmoi 目标名均无 `private_` 前缀，文件应用后为默认权限 `0644`，
仅父目录因 `private_dot_pi/private_agent` 命名为 `0700`。

### settings.json — 主题与扩展包

与 `private_dot_pi/private_agent/settings.json` 实际内容完全一致（已修正旧文档的过时说明）：

```json
{
  "theme": "dark",
  "lastChangelogVersion": "0.84.3",
  "hideThinkingBlock": false,
  "packages": [
    "npm:pi-web-access",
    "npm:pi-subagents",
    "npm:@quintinshaw/pi-dynamic-workflows",
    "npm:@narumitw/pi-btw",
    "npm:@narumitw/pi-goal",
    "npm:pi-landstrip",
    "npm:@gotgenes/pi-permission-system"
  ],
  "defaultProvider": "opencode",
  "defaultModel": "muse-spark-1.2-contributor-free",
  "defaultThinkingLevel": "xhigh"
}
```

| 字段 | 值 | 说明 |
| --- | --- | --- |
| `theme` | `dark` | 深色主题 |
| `lastChangelogVersion` | `0.84.3` | 已同步至最新 pi 版本（原文档 `0.84.2` 已过时） |
| `hideThinkingBlock` | `false` | 展示思考块（原文档 `true` 已更正；`false` 为当前实际值） |
| `packages` | 7 个 `npm:` 包 | `pi-web-access`、`pi-subagents`、`@quintinshaw/pi-dynamic-workflows`、`@narumitw/pi-btw`、`@narumitw/pi-goal`、`pi-landstrip`、`@gotgenes/pi-permission-system` |
| `defaultProvider` | `opencode` | 默认 provider（旧文档误称“不再包含 provider/model”已更正） |
| `defaultModel` | `muse-spark-1.2-contributor-free` | 默认模型（原文档 `x-preview-f-free` 已更新） |
| `defaultThinkingLevel` | `xhigh` | 默认思考强度（原文档 `high` 已更新为 `xhigh`） |

> **修正说明**：旧版文档称“不再包含旧版的 `defaultProvider` / `defaultModel` / `thinkingLevel` 等字段”，与实际不符；当前 `settings.json` 完整包含上述三字段，且值为 `opencode` / `muse-spark-1.2-contributor-free` / `xhigh`，已在上表与 JSON 快照中同步，与 [layout.md](layout.md) / README 快照一致。

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
    "allowNetwork": true,
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
| `network.allowNetwork` | `true` | **网络已开启**（原文档 `false` / “网络默认关闭”已更正） |
| `network.allowLocalBinding` | `false` | 禁止本地端口绑定 |
| `network.allowedDomains` | 3 项 | `*.githubusercontent.com`、`*.github.com`、`github.com`（原文档 `api.github.com` / `www.google.com` / `goproxy.cn` 四域已更新，仅白名单域名可出站） |
| `network.deniedDomains` | `[]` | 无额外黑名单 |

- **网络已开启，仅白名单域名可出站**（`allowNetwork: true` + `allowedDomains` 白名单），非旧文档所述“网络默认关闭”；`deniedDomains` 为空。
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

位于 `private_dot_pi/workflows/settings.json`（部署到 `~/.pi/workflows/settings.json`），与实际文件一致：

```json
{ "progressPanelMaxAgents": 8 }
```

用于 `pi-dynamic-workflows` 的进度面板最大并发代理数（`8`）。它与上节 `pi-subagents` 的
`maxSubagents: 8` 相互独立：前者限制工作流进度面板的并发/展示代理数上限，
后者限制子代理工具可派生的子代理总数上限。详见 [layout.md](layout.md)。

### extensions/pi-permission-system/config.json — 工具级权限矩阵

> 注释已由旧版 `// project management` 更名为 `// script`，对应 `node -e` / `npm` / `pnpm` / `cargo` 等脚本类命令分组。与源文件逐行核对一致（含 `xargs` / `which` / `chezmoi` 放行）。

| 类别 | 策略 |
| --- | --- |
| `*` | `allow`（全局默认放行） |
| `mcp` | 默认 `ask`；`mcp_status` / `mcp_list` 例外 `allow` |
| `skill` | 默认 `ask` |
| `read` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`、`~/.gnupg/*`（`*.env.example` 例外 `allow`） |
| `write` / `edit` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`~/.ssh/*`、`~/.aws/*`（注意：`*.env.example` 在 `write` / `edit` 段未单独放行） |
| `path` | 默认 `allow`；`deny` → `*.env`、`*.env.*`、`*.pem`、`*.key`、`~/.ssh/*`、`/etc/*`、`/var/*`（`*.env.example` 放行） |
| `external_directory` | 默认 `ask`；`~/.cargo/registry/*`、`~/.npm/*`、`~/.cache/*` 例外 `allow` |
| `bash` | 默认 `ask`；只读命令 `chezmoi *` / `xargs *` / `which *` / `pwd` / `ls *` / `cat *` / `echo *` / `mkdir *` / `touch *` / `cd *` / `find *` / `grep *` / `head *` / `tail *` / `lsof *` / `awk *` / `sed *` / `wc *` / `for *` / `ps *` / `sleep *` 例外 `allow`；`sudo *` / `mv *` / `rm *` / `unlink *` / `dd if=* of=*` / `mkfs.*` 为 `deny`；`git *` 默认 `allow` 但 `git rm *` 与 `git config *` 均 `deny`（防止 agent 篡改 git 配置）；脚本类 `node -e` / `npm install` / `npm ci` / `pnpm *` / `cargo *` 为 `ask`（归入 `// script` 组） |

这套策略的目标：让 agent 能完成日常编码、只读检索与受控编辑，同时杜绝误删、密钥外泄、未授权推送与敏感路径写入。
`promptMaxRows: 32`，`$schema` 指向 `pi-permission-system` 的 JSON Schema，与源文件一致。


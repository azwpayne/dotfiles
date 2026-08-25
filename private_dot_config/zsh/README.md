# zsh 配置仓库

个人 zsh 配置模块集合。目标环境：**macOS (Apple Silicon) + Homebrew (`/opt/homebrew`) + zsh 5.9**。

本仓库只包含按模块拆分的配置文件；入口加载器是仓库外的 `~/.zshrc`。

## 模块总览

| 文件 | 职责 | 主要内容 |
| --- | --- | --- |
| `aliases.zsh` | 通用别名与函数 | 目录跳转、系统信息、包管理更新、K8s 别名、编辑器/AI 助手别名、`ruff_auto`/`auto_update`/`y` 等函数 |
| `fzf.zsh` | fzf 与 fzf-tab 配置 | 前缀探测与缓存、全局选项（Ctrl-R / Ctrl-T / Alt-C）、交互式函数 `frg` `fkill` `find_large_files` `ftm` `flf` `flkill` `flnet` `fluser` |
| `sdk.zsh` | SDK 环境与补全 | pnpm 补全、SDKMAN（可选）、Android NDK、Go/Rust 环境、Docker/Kubectl 补全、kubecolor 包装 |

### 加载顺序契约（重要）

`~/.zshrc` 按 **compinit（Zim 框架）→ aliases.zsh → fzf.zsh → sdk.zsh** 的顺序 source 本仓库文件。

> ⚠️ **顺序即语义**：同名定义后加载者生效。典型例子是短别名 `k`：
> `sdk.zsh` 在 kubectl 存在时定义 `k='kubectl'`（有 `command -v` 守卫），因此
> `aliases.zsh` 不再定义 `k`（历史上曾定义为 `kill`，已删除以免误导）。
> 重排模块顺序会静默改变行为。

## 关键设计约定

### 编辑器契约

`aliases.zsh` 导出 `EDITOR` / `VISUAL`（环境变量，不是 alias），`fzf.zsh` 的 Ctrl+O
绑定在 source 时展开 `$EDITOR`。因此：

- `aliases.zsh` 必须先于 `fzf.zsh` 加载；
- 不要把 `export EDITOR=...` 改回 `alias EDITOR=...`（alias 不会被子进程读到）。

### fzf 前缀缓存

首次启动探测 fzf 安装前缀（Apple Silicon Homebrew → Intel Homebrew → `~/.fzf` → `/usr`），
结果写入 `~/.fzf_prefix_cache`（已被 `.gitignore` 忽略）。缓存仅在
`$FZF_PREFIX/bin/fzf` 可执行时被信任，否则自动删除并重新探测——换机器/卸载重装无需手工清理。

### 内联注释的兼容性

`FZF_DEFAULT_OPTS` 等多行值中的行内 `#` 注释已在本机 fzf **0.74.3** 实测可正常解析；
如升级后出现解析异常，优先检查第 3 节的全局选项。

## 函数速查

| 函数 | 所在文件 | 用途 |
| --- | --- | --- |
| `auto_update` | aliases.zsh | 全量更新各包管理器（逐个守卫，未安装即跳过） |
| `ruff_auto [dir]` | aliases.zsh | ruff 自动修复 lint 并格式化（默认当前目录） |
| `y [args]` | aliases.zsh | yazi 包装：退出后 cd 到最后浏览的目录 |
| `jdx [args]` / `scr [args]` | aliases.zsh | 后台启动 jadx-gui / scrcpy |
| `frg [pattern]` | fzf.zsh | rg+fzf 搜代码内容，回车在 nvim 打开对应行 |
| `fkill [signal]` | fzf.zsh | fzf 选进程并杀掉（默认 -9） |
| `find_large_files [size]` | fzf.zsh | 列出超过指定大小的文件（默认 100M） |
| `ftm [session]` | fzf.zsh | fzf 选择/创建 tmux 会话 |
| `flf` / `flkill` / `flnet` / `fluser [user]` | fzf.zsh | lsof+fzf 浏览打开文件/杀进程/看连接/按用户过滤 |

## 依赖清单

**启动必需**（缺失会在启动时报错或功能缺失）：

- `fzf`（有 `command -v` 守卫；缺失则失去 Ctrl-R/Ctrl-T/Alt-C 按键绑定，且 `frg`/`fkill`/`ftm`/`fl*` 等 fzf 函数不可用）
- `fzf-tab` 插件（Homebrew formula；有 `[[ -r ]]` 守卫）
- zsh 补全系统初始化（compinit，由 `~/.zshrc` 的 Zim 框架在最前面完成）

**有守卫的可选组件**（未安装时静默跳过）：`pnpm`、SDKMAN(`sdk`)、`docker`、`kubectl`+`kubecolor`、`~/.cargo/env`、`onproxy` 函数（仓库外定义，若存在则 `auto_update` 前自动切代理）

**运行时工具**（对应别名/函数调用时才需要）：
`fd`（缺省回退 `rg`）、`bat`、`lsd`、`nvim`、`code`、`htop`、`fastfetch`、`tmux`、
`yazi`、`gh`、`lazygit`、`claude`、`opencode`、`ruff`、`uv`、`rustup`、`tldr`、
`nproc`（coreutils）、`jadx-gui`、`scrcpy`。
另：`java` 仅在 SDKMAN 存在时经 `sdk_update` 间接使用，本仓库无直接引用。

已移除的死引用（工具未安装/路径不存在，可从 git 历史 `baseline` 标签找回）：
conda、wezterm 工作区别名、`pkid`/`jeb`、`brew cu` 段。

## 注意事项

1. **破坏性命令**：`uv_resync` 会先删除当前项目的 `.venv` 和 `uv.lock` 再重建，仅在项目根目录使用。
2. **~/.zshrc 在仓库外且未被跟踪**：其中还会 `eval "$(fzf --zsh)"` 一次（与本仓库重复初始化，
   冗余但无害）；其注释称 sdk.zsh「可选/需取消注释」与实际的无条件 source 不符，以实际代码为准。
3. **强绑定的个人路径**：`GOPATH=~/WorkSpaces/project/go`、`GOPROXY=goproxy.cn`、
   清华 pip 镜像、`ANDROID_NDK_HOME=/opt/homebrew/share/android-ndk`（目录存在才导出）。
4. **被别名替换的原生命令**：`cat→bat`、`ls→lsd`、`top→htop`、`rm/cp/mv→-i`。
   脚本中需要原生行为时请用 `command cat` 等形式。

## 修改与验收流程

1. 改完后跑语法检查：`zsh -n aliases.zsh fzf.zsh sdk.zsh`
2. 干净启动验证无报错：`zsh -ic 'exit'`
3. 抽查关键定义：`zsh -ic 'type k df du; echo $EDITOR'`
4. 提交：小步提交，说明动机；重大重构保留 `baseline` 标签以便回退。

# zsh 配置仓库

个人 zsh 配置模块集合。目标环境：**macOS (Apple Silicon) + Homebrew (`/opt/homebrew`) + zsh 5.9**。

本仓库包含按模块拆分的配置文件；入口加载器是仓库根的 `dot_zshrc`（部署为 `~/.zshrc`）。

## 模块总览

| 文件 | 职责 | 主要内容 |
| --- | --- | --- |
| `aliases.zsh` | 通用别名与函数 | 目录跳转（dl/dt/doc/wp/ws）、系统信息（ff/fastfetch、时间戳）、进程资源（htop/df/du）、基础命令增强（lsd/bat/rm -i）、包管理更新（`auto_update`/`update-all`；`auto_update` 为薄包装——可选 `onproxy` 切代理后直接委托 `update-all`，覆盖目标一致；`update-all` 为关联数组+参数过滤、失败计数与耗时统计，支持 `brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise` 6 目标）、K8s 别名（含 `kk`=kubectl krew）、编辑器/AI 助手别名、`ruff_auto`/`y`/`jdx`/`scr` 等函数 |
| `fzf.zsh` | fzf 与 fzf-tab 配置 | 前缀探测与缓存、全局选项（FZF_DEFAULT_OPTS / CTRL_R/T/C_OPTS）、交互式函数 `frg` `fkill` `find_large_files` `ftm` `flf` `flkill` `flnet` `fluser`、fzf-tab zstyle |
| `sdk.zsh` | SDK 环境与补全 | pnpm 补全、SDKMAN（惰性加载）、Android NDK、Go/Rust 环境、Docker/Kubectl 补全缓存、kubecolor 包装与短别名 `k`、krew bin 目录守卫注入 |

### 加载顺序契约（重要）

`~/.zshrc` 按 **compinit（Zim 框架）→ aliases.zsh → fzf.zsh → sdk.zsh** 的顺序 source 本仓库文件：

```zsh
source ${ZIM_HOME}/init.zsh          # compinit 在此完成
for file in ~/.config/zsh/aliases.zsh ~/.config/zsh/fzf.zsh; do source "$file"; done
source ~/.config/zsh/sdk.zsh         # 无条件加载（如需禁用请注释 source 行）
```

> ⚠️ **顺序即语义**：同名定义后加载者生效。典型例子是短别名 `k`：
> `sdk.zsh` 在 kubectl 存在时定义 `k='kubectl'`（有 `command -v kubectl` 守卫 + `compdef k=kubectl`），因此
> `aliases.zsh` 不再定义 `k`（历史上曾定义为 `kill`，已删除以免误导）。
> 重排模块顺序会静默改变行为。`sdk.zsh` 必须在 compinit 之后加载（内含 `compdef` 调用）。

## 关键设计约定

### 编辑器契约

`aliases.zsh` 统一导出环境变量（非 alias）：

```zsh
export EDITOR='nvim'
export VISUAL='nvim'
```

`fzf.zsh` 的 `FZF_DEFAULT_OPTS` 中 `ctrl-o:execute($EDITOR {} &> /dev/tty)` 在 source 时展开 `$EDITOR`。因此：

- `aliases.zsh` **必须**先于 `fzf.zsh` 加载（MUST before）；
- 不要把 `export EDITOR=...` 改回 `alias EDITOR=...`（alias 不会被子进程/预览绑定读到）；
- `dot_zshrc` 顶部另有被注释的 `[[ -n $SSH_CONNECTION ]] && export EDITOR='vi' || export EDITOR='nvim'`，当前未生效，以 `aliases.zsh` 为准。

### 前缀缓存

首次启动探测 fzf 安装前缀（Apple Silicon Homebrew → Intel Homebrew → `~/.fzf` → `/usr`），
结果写入 `~/.fzf_prefix_cache`（不入仓库，无 git 规则覆盖此路径）。缓存仅在
`$FZF_PREFIX/bin/fzf` 可执行时被信任，否则自动删除并重新探测——换机器/卸载重装无需手工清理。
探测顺序与 `fzf.zsh` 一致：`/opt/homebrew/opt/fzf` → `/usr/local/opt/fzf` → `~/.fzf` → `/usr`，
缓存文件位于 `$HOME` 下（`~/.fzf_prefix_cache`），不入仓库。

### 内联注释的兼容性

`FZF_DEFAULT_OPTS` 等多行值中的行内 `#` 注释已在本机 fzf **0.74.3** 实测可正常解析；
如升级后出现解析异常，优先检查第 3 节的全局选项。

## 函数速查

| 函数 | 所在文件 | 用途 | 关键实现 |
| --- | --- | --- | --- |
| `auto_update` | aliases.zsh | 一键全量更新入口：若存在 `onproxy` 函数则先切代理，随后直接委托同文件的 `update-all` 执行（无参全量） | 打印 🚀 横幅 → `onproxy`（可选）→ `update-all`；覆盖目标与行为与 `update-all` 完全一致 |
| `update-all [targets...]` | aliases.zsh | 声明式批量更新（默认全部，支持参数过滤如 `update-all brew uv`） | `local -A tasks=(brew … sdk … rustup … tldr … uv … mise …)` 6 项；`targets=(${(k)tasks})` 全量或过滤；`command -v $name` 守卫（未安装黄色 `⚠️ not found` 跳过）；`eval "${tasks[$name]}" 2>! 临时错误文件 \|\| rc=$?`，失败收集 stderr 摘要并累计 failed/attempted；`print -P %F{blue/green/red/yellow}` 彩色输出；`start_time/duration` 统计耗时 `${mins}m${secs}s`；未知参数提示 `Available: …` 并返回 1 |
| `ruff_auto [dir]` | aliases.zsh | ruff 自动修复 lint 并格式化（默认当前目录） | `ruff check --fix --exit-zero && ruff format` |
| `y [args]` | aliases.zsh | yazi 包装：退出后 cd 到最后浏览的目录 | `yazi --cwd-file` + `mktemp` |
| `jdx [args]` / `scr [args]` | aliases.zsh | 后台启动 jadx-gui / scrcpy | `nohup ... &` |
| `frg [pattern]` | fzf.zsh | rg+fzf 搜代码内容，回车在 nvim 打开对应行 | `rg --line-number \| fzf --delimiter : --preview bat --highlight-line` |
| `fkill [signal]` | fzf.zsh | fzf 选进程并杀掉（默认 -9） | `ps -ef \| fzf -m \| awk '{print $2}' \| xargs kill` |
| `find_large_files [size]` | fzf.zsh | 列出超过指定大小的文件（默认 100M） | `fd -t f -S "+$size" -X du -h \| sort -k1hr` |
| `ftm [session]` | fzf.zsh | fzf 选择/创建 tmux 会话 | `tmux list-sessions \| fzf` + `switch-client`/`attach-session` |
| `flf` | fzf.zsh | lsof+fzf 浏览打开文件（带 `LSOF_PREVIEW` 预览） | `lsof \| fzf --preview` |
| `flkill` | fzf.zsh | lsof+fzf 选进程杀掉（提取 PID 后 `kill -9`） | `lsof \| fzf \| awk '{print $2}'` |
| `flnet` | fzf.zsh | 仅显示 TCP/UDP 网络连接 | `lsof -i \| fzf` |
| `fluser [user]` | fzf.zsh | 按用户过滤打开文件（默认 `$USER`） | `lsof -u "$user" \| fzf` |

> `auto_update` 为薄包装（横幅 + 可选 `onproxy` 后直接委托 `update-all`），`update-all` 为关联数组驱动（声明式、可过滤、可统计），二者分工对比见 `docs/shell.md`；日常推荐 `update-all`。

破坏性命令不在此表：`uv_resync`（`rm -rf .venv uv.lock && uv sync`）见注意事项。

## 依赖清单

### 环境变量

| 变量 | 定义位置 | 说明 |
| --- | --- | --- |
| `LANG` | `dot_zshrc:6` | `export LANG=en_US.UTF-8` 已生效，统一固定为 `en_US.UTF-8`，与 Ghostty `LANG=zh_CN.UTF-8` 互补（终端侧中文、shell 侧英文，避免远端/脚本 locale 回退） |
| `EDITOR` / `VISUAL` | `aliases.zsh` | 均为 `nvim`，环境变量（非 alias），供 git/crontab/fzf Ctrl-O 等读取 |
| `GOPROXY` / `GOPATH` / `GOBIN` | `sdk.zsh` | `GOPROXY=https://goproxy.cn,direct`、`GOPATH=~/WorkSpaces/project/go`、`GOBIN=$GOPATH/bin`（`GOBIN` 存在时才加入 PATH） |
| `ANDROID_NDK_HOME` | `sdk.zsh` | `/opt/homebrew/share/android-ndk`（目录存在时才导出） |
| `FZF_PREFIX` / `FZF_PREFIX_CACHE` | `fzf.zsh` | 前缀探测结果与缓存文件 `~/.fzf_prefix_cache` |
| `PATH` | `dot_zshrc` + `fzf.zsh` + `sdk.zsh` | `dot_zshrc` 先追加 `~/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:~/.local/bin`，再在 `brew shellenv` 之后前缀插入 `~/.cargo/bin` 与 `${HOMEBREW_PREFIX:-/opt/homebrew}/opt/rustup/bin`（仅当目录存在且 PATH 未包含时，静态路径、重复 source 幂等）；`fzf.zsh` 追加 `$FZF_PREFIX/bin`；`sdk.zsh` 条件追加 `$GOBIN` 与 `${KREW_ROOT:-$HOME/.krew}/bin`（同样目录存在 + 去重双守卫） |

### 启动必需（缺失会导致功能缺失）

- `fzf`（有 `command -v` 守卫；缺失则失去 Ctrl-R/Ctrl-T/Alt-C 按键绑定，且 `frg`/`fkill`/`ftm`/`fl*` 等函数不可用）
- `fzf-tab` 插件（由 `dot_zimrc` 的 `zmodule Aloxaf/fzf-tab` 经 zimfw 加载，不再由 `fzf.zsh` source；缺失则补全菜单失去 fzf 化，`fzf.zsh` 中的 zstyle 配置不生效）
- zsh 补全系统初始化（compinit，由 `~/.zshrc` 的 Zim 框架在最前面完成；`sdk.zsh` 的 `compdef` 依赖它）

### 有守卫的可选组件（未安装时静默跳过）

`pnpm`（tabtab 补全，compdef 守卫）、SDKMAN（**惰性加载**：首次调用 `sdk` 时才 source `sdkman-init.sh`，未装不定义任何内容）、`docker`/`kubectl`+`kubecolor`（补全缓存于 `~/.cache/zsh/` 并 zcompile，二进制更新时自动重建；`k` 别名带 kubectl 守卫）、krew（`${KREW_ROOT:-$HOME/.krew}/bin` 仅在目录存在且 PATH 未包含时注入）、`~/.cargo/env`（rustup，sdk.zsh 无守卫 source 但缺失时静默）、`onproxy` 函数（仓库外定义，若存在则 `auto_update` 前自动切代理）。`update-all` 对 6 目标 `brew`/`sdk`/`rustup`/`tldr`/`uv`/`mise` 逐项 `command -v` 守卫，未安装时黄色 `⚠️ not found` 提示跳过；目标失败打印红色 `✗ failed` 与 stderr 摘要并使函数返回非零；未知目标红色 `❌ Unknown target` 并列出 `Available: …`。

### 运行时工具（对应别名/函数调用时才需要）

`fd`（主力，缺省回退 `rg`）、`bat`、`lsd`、`nvim`、`code`、`htop`、`fastfetch`、`tmux`、
`yazi`、`gh`、`lazygit`、`claude`、`opencode`、`ruff`、`uv`、`rustup`、`tldr`、`mise`、
`nproc`（coreutils）、`jadx-gui`、`scrcpy`。
另：`java` 仅在 SDKMAN 存在时经 `update-all` 的 `sdk` 任务（`sdk upgrade` 等）间接使用，本仓库无直接引用。

已移除的死引用（工具未安装/路径不存在，可从更早的独立 `zsh-config` 仓库历史找回；本仓库从未有过 `baseline` 标签，勿凭空创建）：
conda、wezterm 工作区别名、`pkid`/`jeb`、`chown/chmod/chgrp --preserve-root`、旧版 `auto_update` 依赖的五个 `*_update` 辅助函数（`brew cu` 并未移除，现位于 `update-all` 的 brew 任务内）。

## 注意事项

1. **破坏性命令**：`uv_resync` 会先删除 `~/.venv` 与 `~/uv.lock` 再执行 `uv sync`（注意目标是家目录下的路径而非当前项目），使用前请确认。
2. **`~/.zshrc`（即仓库内 `dot_zshrc`）已收敛单一初始化点**：fzf 键位/补全仅在 `fzf.zsh` 内初始化一次（带 `command -v fzf` 守卫），`~/.zshrc` 不再重复 eval；其 sdk.zsh 加载为无条件 `source`，注释与代码已保持一致。
3. **强绑定的个人路径**：`GOPATH=~/WorkSpaces/project/go`、`GOPROXY=goproxy.cn`、清华 pip 镜像（`pip_tsinghua_mirror` 别名）、`ANDROID_NDK_HOME=/opt/homebrew/share/android-ndk`（目录存在才导出）。
4. **被别名替换的原生命令**：`cat→bat`、`ls→lsd`、`top→htop`、`rm/cp/mv→-i`。脚本中需要原生行为时请用 `command cat` 等形式。

## 修改与验收流程

1. 改完后跑语法检查：`zsh -n aliases.zsh fzf.zsh sdk.zsh`
2. 干净启动验证无报错：`zsh -ic 'exit'`
3. 抽查关键定义：`zsh -ic 'type k df du; echo $EDITOR; echo $LANG'`
4. 提交：小步提交，说明动机；重大重构前先打 tag 以便回退（本仓库历史上并无 `baseline` 标签，不要创建同名标签造成混淆）。

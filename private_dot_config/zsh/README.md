# zsh 配置仓库

个人 zsh 配置模块集合。目标环境：**macOS (Apple Silicon) + Homebrew (`/opt/homebrew`) + zsh 5.9**。

本仓库只包含按模块拆分的配置文件；入口加载器是仓库外的 `~/.zshrc`（即 `dot_zshrc`）。

## 模块总览

| 文件 | 职责 | 主要内容 |
| --- | --- | --- |
| `aliases.zsh` | 通用别名与函数 | 目录跳转（dl/dt/doc/wp）、系统信息（ff/fastfetch、时间戳）、进程资源（htop/df/du）、基础命令增强（lsd/bat/rm -i）、包管理更新（brew_update/sdk_update/.../auto_update）、K8s 别名、编辑器/AI 助手别名、`ruff_auto`/`y`/`jdx`/`scr` 等函数 |
| `fzf.zsh` | fzf 与 fzf-tab 配置 | 前缀探测与缓存、全局选项（FZF_DEFAULT_OPTS / CTRL_R/T/C_OPTS）、交互式函数 `frg` `fkill` `find_large_files` `ftm` `flf` `flkill` `flnet` `fluser`、fzf-tab zstyle |
| `sdk.zsh` | SDK 环境与补全 | pnpm 补全、SDKMAN（可选）、Android NDK、Go/Rust 环境、Docker/Kubectl 补全、kubecolor 包装与短别名 `k` |

### 加载顺序契约（重要）

`~/.zshrc` 按 **compinit（Zim 框架）→ aliases.zsh → fzf.zsh → sdk.zsh** 的顺序 source 本仓库文件：

```
source ${ZIM_HOME}/init.zsh          # compinit 在此完成
for file in ~/.config/zsh/aliases.zsh ~/.config/zsh/fzf.zsh; do source "$file"; done
source ~/.config/zsh/sdk.zsh         # 无条件加载（注释称"可选"与实际不符，以代码为准）
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

- `aliases.zsh` 必须先于 `fzf.zsh` 加载；
- 不要把 `export EDITOR=...` 改回 `alias EDITOR=...`（alias 不会被子进程/预览绑定读到）；
- `dot_zshrc` 顶部另有被注释的 `[[ -n $SSH_CONNECTION ]] && export EDITOR='vi' || export EDITOR='nvim'`，当前未生效，以 `aliases.zsh` 为准。

### 前缀缓存

首次启动探测 fzf 安装前缀（Apple Silicon Homebrew → Intel Homebrew → `~/.fzf` → `/usr`），
结果写入 `~/.fzf_prefix_cache`（已被 `.gitignore` 忽略）。缓存仅在
`$FZF_PREFIX/bin/fzf` 可执行时被信任，否则自动删除并重新探测——换机器/卸载重装无需手工清理。

### 内联注释的兼容性

`FZF_DEFAULT_OPTS` 等多行值中的行内 `#` 注释已在本机 fzf **0.74.3** 实测可正常解析；
如升级后出现解析异常，优先检查第 3 节的全局选项。

## 函数速查

| 函数 | 所在文件 | 用途 | 关键实现 |
| --- | --- | --- | --- |
| `auto_update` | aliases.zsh | 全量更新各包管理器（逐个 `command -v` 守卫，未安装即跳过；若存在 `onproxy` 函数则先切代理） | `uv_update` / `sdk_update` / `rust_update` / `tldr_update` / `brew_update` |
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

破坏性命令不在此表：`uv_resync`（`rm -rf .venv uv.lock && uv sync`）见注意事项。

## 依赖清单

### 环境变量

| 变量 | 定义位置 | 说明 |
| --- | --- | --- |
| `LANG` | `dot_zshrc` | 当前为 `# export LANG=en_US.UTF-8` 注释状态，未生效；取消注释即固定为 `en_US.UTF-8` |
| `EDITOR` / `VISUAL` | `aliases.zsh` | 均为 `nvim`，环境变量（非 alias），供 git/crontab/fzf Ctrl-O 等读取 |
| `GOPROXY` / `GOPATH` / `GOBIN` | `sdk.zsh` | `GOPROXY=https://goproxy.cn,direct`、`GOPATH=~/WorkSpaces/project/go`、`GOBIN=$GOPATH/bin`（`GOBIN` 存在时才加入 PATH） |
| `ANDROID_NDK_HOME` | `sdk.zsh` | `/opt/homebrew/share/android-ndk`（目录存在时才导出） |
| `FZF_PREFIX` / `FZF_PREFIX_CACHE` | `fzf.zsh` | 前缀探测结果与缓存文件 `~/.fzf_prefix_cache` |
| `PATH` | `dot_zshrc` + `fzf.zsh` + `sdk.zsh` | `dot_zshrc` 先追加 `~/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:~/.local/bin`，再在 `brew shellenv` 后前缀插入 `$(brew --prefix rustup)/bin:$HOME/.cargo/bin`；`fzf.zsh` 追加 `$FZF_PREFIX/bin`；`sdk.zsh` 条件追加 `$GOBIN` |

### 启动必需（缺失会导致功能缺失）

- `fzf`（有 `command -v` 守卫；缺失则失去 Ctrl-R/Ctrl-T/Alt-C 按键绑定，且 `frg`/`fkill`/`ftm`/`fl*` 等函数不可用）
- `fzf-tab` 插件（Homebrew formula；有 `[[ -r ]]` 守卫，路径 `/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh`）
- zsh 补全系统初始化（compinit，由 `~/.zshrc` 的 Zim 框架在最前面完成；`sdk.zsh` 的 `compdef` 依赖它）

### 有守卫的可选组件（未安装时静默跳过）

`pnpm`（tabtab 补全）、SDKMAN（`~/.sdkman/bin/sdkman-init.sh`）、`docker`（`docker completion zsh`）、`kubectl`+`kubecolor`（补全 + 函数包装 + `k` 别名）、`~/.cargo/env`（rustup）、`onproxy` 函数（仓库外定义，若存在则 `auto_update` 前自动切代理）

### 运行时工具（对应别名/函数调用时才需要）

`fd`（缺省回退 `rg`）、`bat`、`lsd`、`nvim`、`code`、`htop`、`fastfetch`、`tmux`、
`yazi`、`gh`、`lazygit`、`claude`、`opencode`、`ruff`、`uv`、`rustup`、`tldr`、
`nproc`（coreutils）、`jadx-gui`、`scrcpy`。
另：`java` 仅在 SDKMAN 存在时经 `sdk_update` 间接使用，本仓库无直接引用。

已移除的死引用（工具未安装/路径不存在，可从 git 历史 `baseline` 标签找回）：
conda、wezterm 工作区别名、`pkid`/`jeb`、`brew cu` 段、`chown/chmod/chgrp --preserve-root`。

## 注意事项

1. **破坏性命令**：`uv_resync` 会先删除当前项目的 `.venv` 和 `uv.lock` 再重建，仅在项目根目录使用。
2. **`~/.zshrc` 在仓库外且未被跟踪**：其中还会 `eval "$(fzf --zsh)"` 一次（与本仓库 `fzf.zsh` 重复初始化，冗余但无害）；其注释称 sdk.zsh「可选/需取消注释」与实际的无条件 `source ~/.config/zsh/sdk.zsh` 不符，以实际代码为准。
3. **强绑定的个人路径**：`GOPATH=~/WorkSpaces/project/go`、`GOPROXY=goproxy.cn`、清华 pip 镜像（`pip_tsinghua_mirror` 别名）、`ANDROID_NDK_HOME=/opt/homebrew/share/android-ndk`（目录存在才导出）。
4. **被别名替换的原生命令**：`cat→bat`、`ls→lsd`、`top→htop`、`rm/cp/mv→-i`。脚本中需要原生行为时请用 `command cat` 等形式。

## 修改与验收流程

1. 改完后跑语法检查：`zsh -n aliases.zsh fzf.zsh sdk.zsh`
2. 干净启动验证无报错：`zsh -ic 'exit'`
3. 抽查关键定义：`zsh -ic 'type k df du; echo $EDITOR; echo $LANG'`
4. 提交：小步提交，说明动机；重大重构保留 `baseline` 标签以便回退。

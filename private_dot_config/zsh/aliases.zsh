# =============================================================================
# aliases.zsh —— 通用别名与函数
# =============================================================================
# Description : 个人 zsh 别名/函数集合（系统应用、包管理更新、目录跳转、
#               Kubernetes、编辑器、AI 助手、开发构建等）
# Usage       : 由 ~/.zshrc source 加载；加载顺序必须为
#               aliases.zsh -> fzf.zsh -> sdk.zsh（后加载者覆盖同名定义）
# Depends     : lsd/bat/htop/fastfetch/yazi/nvim 等，完整清单见 README.md
# Last Updated: 2026-08-27（auto_update 改为委托 update-all，修复对已删除的
#               uv_update 等五个 *_update 辅助函数的调用）
# Author      : Payne
# =============================================================================

# =============================================================================
# 系统与应用
# =============================================================================
alias finder='open .'                            # Finder 打开当前目录
alias iterm_ghostty='open -a ghostty "$PWD"'     # Ghostty 打开当前目录（单引号保证运行时取 $PWD）
alias iterm='open -a iTerm "$PWD"'               # iTerm 打开当前目录

alias zshconfig='code ~/.zshrc'                  # 编辑 ~/.zshrc
alias zshsource='source ~/.zshrc'                # 重新加载配置

# =============================================================================
# 包管理器更新
# =============================================================================

# 一键全量更新（每步按工具是否可用守卫，缺哪个跳哪个）
# 注：实际更新逻辑统一委托给本文件下方的 update-all。原先此处直接调用的
# uv_update / sdk_update / rust_update / tldr_update / brew_update 五个辅助
# 函数已在 0af1f61 中删除，继续调用只会报 command not found 并误报成功。
auto_update() {
    echo "🚀 开始更新 ..."
    # 若定义了 onproxy 函数则先切换代理（可选依赖）
    (( $+functions[onproxy] )) && onproxy

    update-all
}

# 注：conda 已卸载（sdk.zsh 中对应的 conda init 也已停用），不再纳入更新流程。

# =============================================================================
# Unix 命令增强
# =============================================================================

# ~~~ 目录跳转 ~~~
alias dl='cd ${HOME}/Downloads'
alias dt='cd ${HOME}/Desktop'
alias doc='cd ${HOME}/Documents'
alias wp='cd ${HOME}/WorkSpaces'
alias ws='cd ${HOME}/WisdomSpaces'

# ~~~ 系统信息 ~~~
alias ff='fastfetch'
alias nowdatetime='date "+%Y%m%d_%H%M%S"'
alias timestamp_seconds='date +%s%N | cut -c 1-10'
alias timestamp_millisecond='date +%s%N | cut -c 1-13'
alias timestamp_microsecond='date +%s%N | cut -c 1-16'

# ~~~ 进程与资源 ~~~
alias top='htop'                                 # htop 替代 top
alias df='df -h'                                 # 人类可读的磁盘占用
alias du='du -h -d 2'                            # 目录占用统计（两层深）
alias ping='ping -c 5'                           # 默认只发 5 个探测包
alias pws='ps -p $$'                             # 查看当前 shell 进程

# ~~~ 终端复用 ~~~
alias tmux='tmux -2'                             # 强制 256 色

# ~~~ 基础命令 ~~~
# 注：原 chown/chmod/chgrp --preserve-root 别名已移除——GNU 专属标志在 macOS BSD
# 工具链上必然报 illegal option（历史版本即已损坏），需要时从 git 历史找回。
alias wget='wget -c'                             # 断点续传
alias rm='rm -i'                                 # 删除前逐个确认
alias cp='cp -i'                                 # 覆盖前确认
alias mv='mv -i'                                 # 移动覆盖前确认
alias mkdir='mkdir -p -v'                        # 自动创建父目录并显示过程

# ~~~ 列表与导航 (lsd) ~~~
alias l='lsd --group-directories-first'          # 目录排在前面
alias ls='l'                                     # ls -> lsd
alias tree='lsd --tree --depth 3'                # 树状显示 3 层
alias cat='bat --paging=never'                   # bat 替代 cat（脚本中需要原生行为时用 command cat）

# =============================================================================
# Kubernetes (kubectl)
# 注意：短别名 k 定义在 sdk.zsh（k -> kubectl，含 kubecolor 包装），此处不再重复定义。
# =============================================================================
alias kk='kubectl krew'
alias kg='kubectl get'
alias kl='kubectl logs'
alias kd='kubectl describe'
alias kdel='kubectl delete'
alias ka='kubectl apply -f'

alias kgp='kubectl get pods -o wide'
alias kgn='kubectl get nodes -o wide'
alias kgs='kubectl get svc -o wide'
alias kgd='kubectl get deployment -o wide'

alias ksys='kubectl -n kube-system'

alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'


# =============================================================================
# 编辑器 (Neovim)
# =============================================================================
export EDITOR='nvim'                             # $EDITOR：git/crontab/fzf 等程序读取（必须是环境变量而非 alias）
export VISUAL='nvim'                             # $VISUAL：部分 GUI 程序优先读取

alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'
alias nvi='nvim'

# =============================================================================
# AI 助手 (Agent-Native)
# =============================================================================
alias cla='claude'
alias cla-unsafe='claude --dangerously-skip-permissions'
alias clp='opencode'
alias clp_cfg='code ${HOME}/.config/opencode'
alias cla_cfg='code ${HOME}/.claude'

# =============================================================================
# 开发与构建
# =============================================================================

# ~~~ 编译构建 ~~~
alias makes='make -j $(( $(nproc) / 2 ))'        # 用一半核数并行编译（nproc 来自 coreutils）
alias xargsp='xargs -P $(( $(nproc) / 2 ))'      # xargs 半核并行执行

# ~~~ Git 相关 ~~~
alias gopen='gh browse'                          # 浏览器打开当前仓库
alias lg='lazygit'

# ~~~ Python 工具 ~~~
ruff_auto() {
    # 自动修复 lint 并格式化；可传目标目录参数，默认当前目录
    local d="${1:-.}"
    ruff check --fix --exit-zero "$d" && ruff format "$d"
}

# 使用清华镜像安装 pip 包
alias pip_tsinghua_mirror='python3 -m pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple'
# ⚠️ 破坏性操作：删除 .venv 与 uv.lock 后重建并同步
alias uv_resync='rm -rf ${HOME}/.venv ${HOME}/uv.lock && uv sync'

# =============================================================================
# WezTerm 工作区（已移除）
# =============================================================================
# wezterm 未安装，原六个 *Space 工作区别名已删除；
# 需要时从 git 历史找回。

# =============================================================================
# Android 逆向工程
# =============================================================================
jdx() { nohup jadx-gui "$@" > /dev/null 2>&1 & } # 后台启动 jadx-gui 反编译工具
scr() { nohup scrcpy "$@" > /dev/null 2>&1 & }   # 后台启动 scrcpy 投屏
# 注：原 pkid / jeb 别名已移除——其指向的 jar 包与 JEB 目录已不存在，
# 需要时从 git 历史找回。

# =============================================================================
# 文件管理器 (yazi)
# =============================================================================

# yazi 包装：退出时自动 cd 到最后浏览的目录
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

function update-all() {
    local -A tasks=(
        brew  "brew update -f && brew upgrade -f --greedy-latest -y && brew cu -y -a && brew cleanup --prune=all"
        sdk   "sdk upgrade && sdk selfupdate && sdk flush"
        rustup  "rustup update && rustup upgrade"
        tldr  "tldr --update"
        uv    "uv tool upgrade --all"
        mise  "mise upgrade"
    )

    local -a targets
    if (( $# > 0 )); then
        targets=("$@")
    else
        targets=(${(k)tasks})
    fi

    local failed=0
    local attempted=0          # 实际执行的目标数（not found 跳过的不计）
    local skipped=0
    local -a failed_names skipped_names
    local start_time=$(date +%s)

    for name in $targets; do
        if [[ -z "${tasks[$name]}" ]]; then
            print -P "%F{red}❌ Unknown target: $name%f"
            print -P "Available: ${(kj:, :)tasks}"
            return 1
        fi

        print -P "%F{blue}═══ Updating $name ═══%f"

        if command -v $name >/dev/null 2>&1; then
            (( attempted++ ))
            # stderr 重定向到临时文件供失败时提取错误摘要（stdout 正常实时输出）；
            # 模板结尾 XXXXXX 才能在 macOS/BSD mktemp 下被替换成随机串；
            # 2>! 强制覆盖——Zim environment 模块 setopt NO_CLOBBER，普通 2> 会对
            # mktemp 已创建的文件报 "file exists" 而误判目标失败
            local errfile="$(mktemp "${TMPDIR:-/tmp}/update-all.${name}.XXXXXX")"
            local rc=0
            eval "${tasks[$name]}" 2>! "$errfile" || rc=$?
            if (( rc == 0 )); then
                # 成功路径保持绿色 ✓；stderr 中残留的非空内容（如警告）不丢弃
                [[ -s "$errfile" ]] && command cat "$errfile" >&2
                print -P "%F{green}✓ $name done%f"
            else
                (( failed++ ))
                failed_names+=($name)
                print -P "%F{red}✗ $name failed (exit=${rc})%f"
                if [[ -s "$errfile" ]]; then
                    print -P "%F{red}── $name 错误摘要（stderr 末 5 行）──%f"
                    command tail -n 5 "$errfile" | command sed 's/^/  /'
                fi
            fi
            command rm -f -- "$errfile"
        else
            (( skipped++ ))
            skipped_names+=($name)
            print -P "%F{yellow}⚠️  $name not found, skipped%f"
        fi
        echo ""
    done

    local duration=$(( $(date +%s) - start_time ))
    local mins=$(( duration / 60 ))
    local secs=$(( duration % 60 ))

    if (( skipped > 0 )); then
        print -P "%F{yellow}ℹ️  skipped ${skipped} not-installed target(s): ${(j:, :)skipped_names}%f"
    fi
    if (( attempted == 0 )); then
        print -P "%F{yellow}⚠️  no runnable targets in ${mins}m${secs}s%f"
        return 0
    fi
    if (( failed == 0 )); then
        print -P "%B%F{green}✨ All ${attempted} target(s) updated in ${mins}m${secs}s%f%b"
    else
        # 失败即红：N/M 汇总 + 失败目标清单，并返回非零退出码
        print -P "%B%F{red}✗ ${failed}/${attempted} target(s) failed in ${mins}m${secs}s: ${(j:, :)failed_names}%f%b"
        return 1
    fi
}

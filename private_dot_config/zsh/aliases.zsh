# =============================================================================
# aliases.zsh —— 通用别名与函数
# =============================================================================
# Description : 个人 zsh 别名/函数集合（系统应用、包管理更新、目录跳转、
#               Kubernetes、编辑器、AI 助手、开发构建等）
# Usage       : 由 ~/.zshrc source 加载；加载顺序必须为
#               aliases.zsh -> fzf.zsh -> sdk.zsh（后加载者覆盖同名定义）
# Depends     : lsd/bat/htop/fastfetch/yazi/nvim 等，完整清单见 README.md
# Last Updated: 2026-08-25
# Author      : Payne
# =============================================================================

# =============================================================================
# 系统与应用
# =============================================================================

# ~~~ macOS 桌面 ~~~
alias finder='open .'                            # Finder 打开当前目录
alias iterm_ghostty='open -a ghostty "$PWD"'     # Ghostty 打开当前目录（单引号保证运行时取 $PWD）
alias iterm='open -a iTerm "$PWD"'               # iTerm 打开当前目录

# ~~~ Zsh 配置 ~~~
alias zshconfig='code ~/.zshrc'                  # 编辑 ~/.zshrc
alias zshsource='source ~/.zshrc'                # 重新加载配置

# =============================================================================
# 包管理器更新
# =============================================================================

alias brew_update='brew update && brew upgrade --greedy-latest && brew cleanup --prune=all'
                                                 # 更新全部公式与 cask 并清理
# 注：相对旧版移除了 brew cu 段（tap 不受信任导致整链失败）与 -f 强制标志；
# --greedy-latest 已覆盖 auto-update 型 cask 的升级。
alias sdk_update='sdk upgrade && sdk selfupdate && sdk flush'
                                                 # SDKMAN 更新（未安装时由 auto_update 守卫跳过）
alias rust_update='rustup update && rustup upgrade'
                                                 # Rust 工具链与 rustup 自身
alias tldr_update='tldr --update'                # tldr 手册页
alias uv_update='uv tool upgrade --all'          # uv 安装的全部工具

# 一键全量更新（每步按工具是否可用守卫，缺哪个跳哪个）
auto_update() {
    echo "🚀 开始更新 ..."
    # 若定义了 onproxy 函数则先切换代理（可选依赖）
    (( $+functions[onproxy] )) && onproxy

    command -v uv     &>/dev/null && uv_update
    command -v sdk    &>/dev/null && sdk_update
    command -v rustup &>/dev/null && rust_update
    command -v tldr   &>/dev/null && tldr_update
    command -v brew   &>/dev/null && brew_update

    echo ""
    echo "✅ 所有更新完成！"
}

# 注：conda 已卸载（sdk.zsh 中对应的 conda init 也已停用），不再纳入更新流程。

# =============================================================================
# Unix 命令增强
# =============================================================================

# ~~~ 目录跳转 ~~~
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias doc='cd ~/Documents'
alias wp='cd ~/workspace'

# ~~~ 系统信息 ~~~
alias ff='fastfetch'
alias h='history'
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
# 工具链上必然报 illegal option（baseline 时即已损坏），需要时从 git 历史找回。
alias wget='wget -c'                             # 断点续传
alias rm='rm -i'                                 # 删除前逐个确认
alias cp='cp -i'                                 # 覆盖前确认
alias mv='mv -i'                                 # 移动覆盖前确认
alias mkdir='mkdir -p -v'                        # 自动创建父目录并显示过程

# ~~~ 列表与导航 (lsd) ~~~
alias l='lsd --group-directories-first'          # 目录排在前面
alias ls='l'                                     # ls -> lsd
alias tree='lsd --tree --depth 3'                # 树状显示 3 层

# ~~~ 文件查看 ~~~
alias cat='bat --paging=never'                   # bat 替代 cat（脚本中需要原生行为时用 command cat）

# =============================================================================
# Kubernetes (kubectl)
# 注意：短别名 k 定义在 sdk.zsh（k -> kubectl，含 kubecolor 包装），此处不再重复定义。
# =============================================================================
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
alias krew='kubectl krew'

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
alias cla='claude --dangerously-skip-permissions'
alias clp='opencode'
alias clp_cfg='code ~/.config/opencode'
alias cla_cfg='code ~/.claude'

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

alias pip_tsinghua_mirror='python3 -m pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple'
                                                 # 使用清华镜像安装 pip 包
alias uv_resync='rm -rf .venv uv.lock && uv sync'
                                                 # ⚠️ 破坏性操作：删除 .venv 与 uv.lock 后重建并同步

# =============================================================================
# WezTerm 工作区（已移除）
# =============================================================================
# wezterm 未安装，原六个 *Space 工作区别名已删除；
# 需要时用 `git show baseline:aliases.zsh` 找回。

# =============================================================================
# Android 逆向工程
# =============================================================================
jdx() { nohup jadx-gui "$@" > /dev/null 2>&1 & } # 后台启动 jadx-gui 反编译工具
scr() { nohup scrcpy "$@" > /dev/null 2>&1 & }   # 后台启动 scrcpy 投屏
# 注：原 pkid / jeb 别名已移除——其指向的 jar 包与 JEB 目录已不存在，
# 需要时用 `git show baseline:aliases.zsh` 找回。

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
    local start_time=$(date +%s)

    for name in $targets; do
        if [[ -z "${tasks[$name]}" ]]; then
            print -P "%F{red}❌ Unknown target: $name%f"
            print -P "Available: ${(j:, :)tasks}"
            return 1
        fi

        print -P "%F{blue}═══ Updating $name ═══%f"

        if command -v $name >/dev/null 2>&1; then
            eval "${tasks[$name]}" || ((failed++))
        else
            print -P "%F{yellow}⚠️  $name not found%f"
        fi

        print -P "%F{green}✓ $name done%f"
        echo ""
    done

    local duration=$(( $(date +%s) - start_time ))
    local mins=$(( duration / 60 ))
    local secs=$(( duration % 60 ))

    if (( failed == 0 )); then
        print -P "%B%F{green}✨ All updates completed in ${mins}m${secs}s%f%b"
    else
        print -P "%B%F{red}⚠️  $failed update(s) failed in ${mins}m${secs}s%f%b"
        return 1
    fi
}
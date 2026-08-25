# =============================================================================
# sdk.zsh —— 多语言 SDK 环境与补全配置
# =============================================================================
# Description : pnpm 补全、SDKMAN（可选）、Android NDK、Python(uv/pip)、
#               Go、Rust(rustup)、Docker/Kubectl 补全与 kubecolor 包装
# Usage       : 由 ~/.zshrc source 加载；必须在 compinit 之后、aliases.zsh 之后加载
#               （本文件定义的 k -> kubectl 会覆盖同名定义，顺序即语义）
# Last Updated: 2026-08-25
# Author      : Payne
# =============================================================================

########## pnpm ##########
# pnpm 补全（tabtab 模板）：函数名必须为 _pnpm_completion，且 compdef 注册到 pnpm
if command -v pnpm &>/dev/null; then
    _pnpm_completion () {
        local reply
        local si=$IFS
        IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" SHELL=zsh pnpm completion-server -- "${words[@]}"))
        IFS=$si
        if [ "$reply" = "__tabtab_complete_files__" ]; then
            _files
        else
            _describe 'values' reply
        fi
    }
    compdef _pnpm_completion pnpm
fi

########## Java / SDKMAN ##########
# SDKMAN 已安装时才初始化（未安装则静默跳过）
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

########## Android ##########
# NDK 由 Homebrew cask 安装；目录存在时才导出，避免悬空变量
[[ -d "/opt/homebrew/share/android-ndk" ]] && export ANDROID_NDK_HOME="/opt/homebrew/share/android-ndk"
# export PATH="$PATH:$ANDROID_NDK_HOME"

########## Python ##########
# Python 环境由 uv 管理；conda 已卸载，相关 init 已移除（见 git 历史 baseline）
# 如需切换 PyPI 镜像可启用：
# export UV_DEFAULT_INDEX="https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple"

########## Golang ##########
export GOPROXY='https://goproxy.cn,direct'           # 国内模块代理
export GOPATH="${HOME}/WorkSpaces/project/go"        # 个人 Go 工作区
export GOBIN="${GOPATH}/bin"
# 仅当 GOBIN 实际存在时加入 PATH，避免塞入死路径
[[ -d "$GOBIN" ]] && export PATH="$PATH:${GOBIN}"

########## Rust ##########
# rustup 环境（brew 安装的 rustup 无此文件时静默跳过）
source "$HOME/.cargo/env" 2>/dev/null

########## Container ##########
# Docker 补全（未安装 docker CLI 时跳过，避免启动报错）
if (( $+commands[docker] )); then
    source <(docker completion zsh)
fi

# ==================== kubectl / kubecolor ====================
# 1. kubectl 存在时加载其补全
if command -v kubectl &> /dev/null; then
    source <(kubectl completion zsh)
fi

# 2. 主命令：优先使用 kubecolor 彩色输出，否则保留原生 kubectl
if command -v kubecolor &> /dev/null; then
    # 用函数替代别名，更灵活（可以处理参数）
    kubectl() { kubecolor "$@"; }
    # 让 kubecolor 继承 kubectl 的补全
    compdef kubecolor=kubectl
fi

# 3. 短别名 k -> kubectl（仅在 kubectl 可用时定义；补全一并关联。
#    注意：本别名会覆盖 aliases.zsh 中可能存在的同名定义——这是有意设计）
if command -v kubectl &> /dev/null; then
    alias k='kubectl'
    compdef k=kubectl
fi

########## 其他 ##########
# libpq/pgcli 相关路径配置已移除（未使用）；需要时用 `git show baseline:sdk.zsh` 找回。

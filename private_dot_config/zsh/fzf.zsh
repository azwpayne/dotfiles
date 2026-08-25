# =============================================================================
# fzf.zsh —— fzf / fzf-tab 配置与交互式函数
# =============================================================================
# Description : fzf 路径探测与缓存、全局默认选项、Ctrl-R/Ctrl-T/Alt-C 定制、
#               以及 frg/fkill/ftm/fl* 等交互式函数
# Usage       : 由 ~/.zshrc source 加载；必须在 aliases.zsh 之后（依赖其导出的 $EDITOR）
# Depends     : 必需 fzf、fzf-tab；主力 fd（缺失时回退 rg）；预览用 bat/lsd
# Last Updated: 2026-08-25
# Author      : Payne
# =============================================================================

# -----------------------------------------------------------------------------
# 1. fzf 可执行文件前缀探测（带磁盘缓存，避免每次启动重复探测）
# -----------------------------------------------------------------------------
FZF_PREFIX_CACHE="${ZDOTDIR:-${HOME}}/.fzf_prefix_cache"

if [[ -f "$FZF_PREFIX_CACHE" ]]; then
    FZF_PREFIX=$(cat "$FZF_PREFIX_CACHE")
    # 仅当缓存指向的前缀仍可用时才信任它，否则删掉缓存走重新探测（自愈）
    if [[ ! -x "$FZF_PREFIX/bin/fzf" ]]; then
        rm -f "$FZF_PREFIX_CACHE"
        unset FZF_PREFIX
    fi
fi

if [[ -z "${FZF_PREFIX:-}" ]]; then
    if [[ -d "/opt/homebrew/opt/fzf/bin" ]]; then
        FZF_PREFIX="/opt/homebrew/opt/fzf"      # macOS ARM (Apple Silicon)
    elif [[ -d "/usr/local/opt/fzf/bin" ]]; then
        FZF_PREFIX="/usr/local/opt/fzf"         # macOS Intel
    elif [[ -d "$HOME/.fzf/bin" ]]; then
        FZF_PREFIX="$HOME/.fzf"                 # 手动安装路径（git 安装方式）
    elif [[ -x "/usr/bin/fzf" ]]; then
        FZF_PREFIX="/usr"                       # Linux 发行版仓库安装（注意是可执行文件，用 -x 测试）
    fi
    # 探测成功则写缓存，供后续启动复用
    if [[ -n "${FZF_PREFIX:-}" ]]; then
        echo "$FZF_PREFIX" > "$FZF_PREFIX_CACHE"
    fi
fi

if [[ -n "${FZF_PREFIX:-}" && ! "$PATH" == *"$FZF_PREFIX/bin"* ]]; then
    export PATH="${PATH:+$PATH:}$FZF_PREFIX/bin"
fi

# 加载 fzf 的按键绑定与补全脚本（fzf 不存在时静默跳过，避免启动报错）
command -v fzf >/dev/null 2>&1 && eval "$(fzf --zsh)"

# -----------------------------------------------------------------------------
# 2. 文件/目录列表命令（fd 为主，rg 兜底）
# -----------------------------------------------------------------------------
exclude_list='{.git,node_modules,.idea,.venv,.cache,dist,build,.pyc,.DS_Store,.gitignore,.gitmodules,.gitkeep,.gitlab,.gitlab-ci.yaml,\*.zip,\*.apk,\*.so,.keep}'

export FZF_DEFAULT_COMMAND="fd --max-depth=5 --type f --hidden --follow --exclude=${exclude_list}"
export FZF_ALT_C_COMMAND="fd --max-depth=5 --type d --follow --exclude=${exclude_list}"

# 备选：如果未安装 fd，回退到 rg（但效果稍差）
if ! command -v fd &> /dev/null; then
    export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git' --glob '!node_modules' --glob '!.venv'"
    export FZF_ALT_C_COMMAND="rg --files --null | xargs -0 dirname | sort -u"
fi

# Ctrl+T 与默认命令保持一致（必须放在 fd 回退判断之后，确保回退值也能生效）
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"

# -----------------------------------------------------------------------------
# 3. 全局默认选项（交互体验优化）
# 注：行内 # 注释与十六进制色值已在本机 fzf 0.74.3 实测可正常解析；
#     升级/更换 fzf 时如遇解析异常请优先检查此处。
# -----------------------------------------------------------------------------
export FZF_DEFAULT_OPTS="
  --height=80%                                                # 更高视野, 40% 太小
  --layout=reverse                                            # 搜索框在顶部（更自然）
  --border=rounded                                            # 圆角边框（现代感）
  --cycle                                                     # 循环滚动
  --info=inline-right                                         # 计数器放右侧，不占用左侧空间
  --multi                                                     # 支持多选(Tab 切换选中,Enter 确认）
  --ansi                                                      # 支持颜色编码
  --preview-window=right:50%:wrap                             # 预览窗口默认右侧,50%宽度，自动换行
  --bind='ctrl-/:change-preview-window(down|hidden|)'         # Ctrl+/ 切换预览位置/隐藏
  --bind='ctrl-o:execute($EDITOR {} &> /dev/tty)'             # Ctrl+O 用编辑器打开（$EDITOR 由 aliases.zsh 导出）
  --bind='ctrl-e:execute(code {} &> /dev/tty)'                # Ctrl+E 用 VS Code 打开
  --bind='ctrl-y:execute-silent(echo {} | pbcopy)+abort'      # Ctrl+Y 复制路径
  --bind='ctrl-p:toggle-preview'                              # Ctrl+P 切换预览
  --bind='ctrl-a:select-all'                                  # Ctrl+A 全选
  --bind='ctrl-d:deselect-all'                                # Ctrl+D 取消全选
  --bind='ctrl-r:toggle-sort'                                 # Ctrl+R 切换排序
  --color='fg:#bbccdd,fg+:#ddeeff,bg:#334455,preview-bg:#223344,border:#778899'
"
# 说明：--multi 模式下保留 fzf 默认的 Tab=toggle+down / Shift-Tab=toggle+up，
# 不要重新绑定为纯移动，否则会丢失多选能力。

# 历史记录搜索(Ctrl+R)优化
# 不用 --exact：历史记录需要模糊匹配（比如记得 "docker build" 但不记得完整命令）
# --scheme=history（fzf 0.35+）针对历史记录优化排序算法
export FZF_CTRL_R_OPTS="
  --sort                                                      # 按相关性排序
  --scheme=history                                            # 历史记录专用匹配算法
  --prompt='history>'
"

# 文件选择（Ctrl+T）优化
export FZF_CTRL_T_OPTS="
  --preview='if [ -d {} ]; then lsd --tree --depth 5 --color=always --icon=always {} | head -50; else bat --color=always --style=header,grid --line-range :100 {}; fi'
  --prompt='files>'
  --multi
"

# 目录跳转（Alt+C）优化
export FZF_ALT_C_OPTS="
  --preview 'lsd --tree --depth 5 --color=always --icon=always {} | head -50'
  --prompt='dir>'
"

# -----------------------------------------------------------------------------
# 4. 交互式函数
# -----------------------------------------------------------------------------

# 通过 fzf 交互式搜索文件内容并跳转到对应行（回车在 nvim 中打开并定位到该行）
frg() {
  rg --line-number --color=always --smart-case "$@" | fzf --ansi \
      --delimiter : \
      --preview "bat --style=full --color=always '{1}' --highlight-line={2}" \
      --bind "enter:execute(nvim '{1}' +{2})+abort" \
      --exit-0
}

# 通过 fzf 交互式选择并杀死进程（可选信号，默认 -9）
fkill() {
    local pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

    if [ "x$pid" != "x" ]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

# 寻找大文件，默认 100M 以上，也可以指定大小参数
# Usage: find_large_files 500M
find_large_files() {
    local size=${1:-100M}
    fd -t f -S "+$size" -X du -h {} | sort -k1hr
}

# tm - 快速创建/切换 tmux 会话（@bag-man）
# `ftm`         通过 fzf 选择已有会话并附加
# `ftm irc`     附加到 irc 会话（不存在则先创建）
ftm() {
  local change
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ -n "${1:-}" ]; then
      tmux "$change" -t "$1" 2>/dev/null || { tmux new-session -d -s "$1" && tmux "$change" -t "$1"; }
      return
  fi
  local session
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf +m --height 60% --exit-0) && tmux "$change" -t "$session" || echo "No sessions found."
}

# lsof 预览片段：显示选中行 PID 对应的进程详情（供下方 fl* 系列函数复用）
LSOF_PREVIEW='pid=$(echo {} | awk "{print \$2}"); [ -n "$pid" ] && ps -fp "$pid" 2>/dev/null || echo "No PID"'

# 交互式查看进程打开的文件（带预览）
# 使用：flf —— 模糊搜索过滤，回车仅高亮选中，Ctrl-C 退出。
flf() {
  lsof 2>/dev/null | fzf --preview "$LSOF_PREVIEW" \
      --preview-window=right:50% --header 'Enter: select, Ctrl-C: exit'
}

# 交互式杀死进程（安全确认版）
# 使用：flkill —— 选择一个打开文件的进程，提取 PID 并执行 kill -9。
flkill() {
  local pid
  pid=$(lsof 2>/dev/null | fzf --preview "$LSOF_PREVIEW" \
        --preview-window=right:50% --header 'Select a process to kill' | awk '{print $2}')

  if [ -n "$pid" ]; then
    echo "Killing process $pid ..."
    kill -9 "$pid" && echo "Killed." || echo "Failed to kill $pid"
  else
    echo "No process selected."
  fi
}

# 快速查看网络连接
# 使用：flnet —— 仅显示 TCP/UDP 连接，并预览进程信息。
flnet() {
  lsof -i 2>/dev/null | fzf --preview "$LSOF_PREVIEW" \
      --preview-window=right:50% --header 'Network connections (lsof -i)'
}

# 查看特定用户的打开文件
# 使用：fluser [username]
fluser() {
  local user=${1:-$USER}
  lsof -u "$user" 2>/dev/null | fzf --preview "$LSOF_PREVIEW" \
      --preview-window=right:50% --header "Open files for user: $user"
}

# -----------------------------------------------------------------------------
# 5. fzf-tab 插件（补全菜单模糊化）
# -----------------------------------------------------------------------------
# 仅在插件实际存在时加载（Homebrew 前缀可能因机器架构而异）
[[ -r "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" ]] && \
  source "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with lsd when completing cd（与全仓 lsd 工具链保持一致）
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always --icon=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

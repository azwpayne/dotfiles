alias k="kubecolor"
alias kk="k krew"
alias finder="open ."

# ~~~ 笔记与文档 ~~~
# alias notes="open ~/Documents/notes"
# alias docs="open ~/Documents/docs"

# ~~~ 快速访问 ~~~
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias doc="cd ~/Documents"
alias wp="cd ~/WorkSpaces"
alias wi="cd ~/WisdomSpaces"

# ~~~ 剪贴板 ~~~
alias cbcopy="pbcopy"
alias cbpaste="pbpaste"

# --- 智能 cd (自动 ls) ---
function cdd --wraps='builtin cd' --description 'cd with automatic listing'
    cd $argv
    ls -la --group-directories-first 2>/dev/null
end

# --- 智能 mkdir (自动 cd) ---
function mkcd --description 'Create directory and cd into it'
    mkdir -p $argv[1] && cd $argv[1]
end

# --- 查找大文件 ---
function find-large --description 'Find large files in current directory'
    # set -l size_limit ${1:-100M}
    set -l count 100
    if test (count $argv) -gt 0
        set count $argv[1]
    end
    find . -type f -size +$size_limit -exec ls -lh {} \; | awk '{ print $9 ": " $5 }'
end

# --- 磁盘使用分析 ---
function dus --description 'Disk usage summary (sorted)'
    du -sh */ 2>/dev/null | sort -hr
end

# --- 进程监控 ---
function psgrep --description 'Search processes'
    ps aux | grep -v grep | grep $argv[1]
end

# --- 端口占用查询 ---
function port --description 'Check what is using a port'
    lsof -i :$argv[1] 2>/dev/null
end

# --- 快速 HTTP 服务器 ---
function serve --description 'Start a simple HTTP server'
    # set -l port ${1:-8000}
    set -l count 8000
    if test (count $argv) -gt 0
        set count $argv[1]
    end
    echo (set_color green)"🚀 Server running at http://localhost:$port"(set_color normal)
    python3 -m http.server $port
end

# --- JSON 格式化 ---
# function json_format --description 'Format JSON'
#     if test (count $argv) -eq 0
#         cat /dev/stdin | python3 -m json.tool
#     else
#         cat $argv[1] | python3 -m json.tool
#     end
# end

# function json_compress --description 'Minify JSON'
#     if test (count $argv) -eq 0
#         cat /dev/stdin | python3 -c 'import sys, json; print(json.dumps(json.load(sys.stdin), separators=(",", ":")))'
#     else
#         cat $argv[1] | python3 -c 'import sys, json; print(json.dumps(json.load(sys.stdin), separators=(",", ":")))'
#     end
# end

# function json_validate --description 'Validate JSON'
#     if test (count $argv) -eq 0
#         cat /dev/stdin | python3 -m json.tool >/dev/null
#     else
#         cat $argv[1] | python3 -m json.tool >/dev/null
#     end
#     and echo (set_color green)"✅ Valid JSON"(set_color normal) || echo (set_color red)"❌ Invalid JSON"(set_color normal)
# end

# --- 颜色测试 ---
function colortest --description 'Display 256 color palette'
    for i in (seq 0 255)
        printf "\x1b[38;5;%dmcolor %3d\x1b[0m " $i $i
        if test (math $i % 6) -eq 5
            echo
        end
    end
    echo
end

# --- 网络诊断 ---
function netcheck --description 'Quick network diagnostics'
    echo (set_color cyan)"🌐 External IP:"(set_color normal)
    curl -s icanhazip.com

    echo (set_color cyan)"📡 DNS Test:"(set_color normal)
    dig google.com +short | head -1

    echo (set_color cyan)"⚡ Speed Test (Download):"(set_color normal)
    curl -s https://raw.githubusercontent.com/sivelabs/speedtest-cli/master/speedtest.py | python3 - --simple 2>/dev/null | head -1
end

# --- 文件类型统计 ---
function filestats --description 'Show file type statistics in current directory'
    find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20
end

# --- 最近修改的文件 ---
function recent --description 'Show recently modified files'
    # set -l count ${1:-10}
    set -l count 10
    if test (count $argv) -gt 0
        set count $argv[1]
    end
    ls -lt | head -n (math $count + 1)
end

# --- 目录大小可视化 ---
function tree-size --description 'Visualize directory sizes'
    du -h --max-depth=1 | sort -hr | head -20
end

function onproxy --description "启用终端代理, 默认使用clash的本地代理设置(127.0.0.1:7890)"
    set -l proxy_host "127.0.0.1"
    set -l proxy_port 5376
    set -l proxy_url "http://$proxy_host:$proxy_port"
    set -l socks_url "socks5://$proxy_host:$proxy_port"

    set -gx all_proxy "$socks_url"
    set -gx http_proxy "$proxy_url"
    set -gx https_proxy "$proxy_url"
    set -gx ALL_PROXY "$socks_url"
    set -gx HTTP_PROXY "$proxy_url"
    set -gx HTTPS_PROXY "$proxy_url"

    echo -e "🚀 终端代理已开启："
    echo -e "   HTTP/HTTPS: $proxy_url"
    echo -e "   SOCKS5: $socks_url"
end

function ofproxy --description "关闭终端代理"
    set -e all_proxy
    set -e http_proxy
    set -e https_proxy
    set -e ALL_PROXY
    set -e HTTP_PROXY
    set -e HTTPS_PROXY

    echo -e "⛵️ 终端代理已关闭。"
end

function update-all --description "一键更新所有开发环境"
    # 定义更新任务（名称 → 命令）
    onproxy
    set -l tasks brew rust tldr uv mise pi

    # 如果没有参数，更新全部；否则只更新指定的
    set -l targets
    if test (count $argv) -eq 0
        set targets $tasks
    else
        set targets $argv
    end

    set -l failed 0
    set -l start_time (date +%s)

    for name in $targets
        echo (set_color --bold blue)"═══ Updating $name ═══"(set_color normal)

        switch $name
            case brew
                if command -q brew
                    brew update -f && brew upgrade -f --greedy-latest -y && brew cu -y -a && brew cleanup --prune=all
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  brew not found"(set_color normal)
                end

            case sdk
                sdk upgrade && sdk selfupdate && sdk flush
                or set failed (math $failed + 1)

            case rust
                if command -q rustup
                    rustup update && rustup upgrade
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  rustup not found"(set_color normal)
                end

            case tldr
                if command -q tldr
                    tldr --update
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  tldr not found"(set_color normal)
                end

            case uv
                if command -q uv
                    uv tool upgrade --all
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  uv not found"(set_color normal)
                end

            case mise
                if command -q mise
                    mise upgrade
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  mise not found"(set_color normal)
                end
            case pi
                if command -q pi
                    pi update --all
                    or set failed (math $failed + 1)
                else
                    echo (set_color yellow)"⚠️  pi not found"(set_color normal)
                end

            case '*'
                echo (set_color red)"❌ Unknown target: $name"(set_color normal)
                echo "Available: brew, conda, sdk, rust, tldr, uv"
                return 1
        end

        if test $status -eq 0
            echo (set_color green)"✓ $name updated successfully"(set_color normal)
        else
            echo (set_color red)"✗ $name update failed"(set_color normal)
        end
        echo ""
    end

    set -l duration (math (date +%s) - $start_time)
    set -l mins (math $duration / 60)
    set -l secs (math $duration % 60)

    if test $failed -eq 0
        echo (set_color --bold green)"✨ All updates completed in {$mins}m{$secs}s"(set_color normal)
    else
        echo (set_color --bold red)"⚠️  $failed update(s) failed, completed in {$mins}m{$secs}s"(set_color normal)
        return 1
    end
end

# ~~~ 颜色测试 ~~~
function testcolors
    for i in (seq 0 255)
        printf "\x1b[38;5;%dmcolor %3d\x1b[0m " $i $i
        if test (math $i % 6) -eq 5
            echo
        end
    end
    echo
end

# ~~~ 倒计时器 ~~~
function timer --description "简单倒计时"
    set -l seconds $argv[1]
    if test -z "$seconds"
        echo "Usage: timer <seconds>"
        return 1
    end
    while test $seconds -gt 0
        printf "\r%02d:%02d:%02d" (math $seconds / 3600) (math ($seconds % 3600) / 60) (math $seconds % 60)
        sleep 1
        set seconds (math $seconds - 1)
    end
    echo -e "\n⏰ Time's up!"
    echo -a "\007"
end

# ~~~ 决策助手 ~~~
function decide --description "从多个选项中随机选择一个"
    if test (count $argv) -lt 2
        echo "Usage: decide <option1> <option2> ..."
        return 1
    end
    set -l idx (random (count $argv))
    echo "🎲 决定：$argv[$idx]"
end

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    command yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# ~~~ 编译构建 ~~~
# alias makes='make -j (math (nproc) / 2) $argv'
# alias xargsp='xargs -P (math (nproc) / 2) $argv'
#
function __half_cpu_count --description "Return half the available CPU count, minimum 1"
    set -l cpu_count 1

    if command -q nproc
        set cpu_count (nproc)
    else if command -q sysctl
        set cpu_count (sysctl -n hw.ncpu 2>/dev/null)
    end

    if not string match -qr '^[0-9]+$' -- $cpu_count
        set cpu_count 1
    end

    set -l half_count (math "max(1, floor($cpu_count / 2))")
    echo $half_count
end

function makes --description "Run make using half the available CPUs"
    make -j (__half_cpu_count) $argv
end

function xargsp --description "Run xargs using half the available CPUs"
    xargs -P (__half_cpu_count) $argv
end
# =============================================================================
# 系统与环境配置
# =============================================================================

# ~~~ macOS 系统 ~~~
alias finder="open ."
alias iterm_ghostty="open -a ghostty $(PWD)"
alias iterm="open -a iTerm $(PWD)"

# ~~~ Zsh 配置 ~~~
alias zshconfig="code ~/.zshrc"
alias zshsource="source ~/.zshrc"
alias fishconfig="code ~/.config/fish"
alias fishsource="exec fish"

# =============================================================================
# Unix 命令增强
# =============================================================================
alias ff="fastfetch"
alias nowdatetime='date "+%Y%m%d_%H%M%S"'
alias timestamp_seconds='date +%s%N | cut -c 1-10'
alias timestamp_millisecond='date +%s%N | cut -c 1-13'
alias timestamp_microsecond='date +%s%N | cut -c 1-16'

# ~~~ 进程与资源 ~~~
# alias k='kill'
alias top='htop'
alias df='df -kTh'
alias du='du -kh'
alias ping='ping -c 5'

alias pws="ps -p $fish_pid"

# ~~~ 终端复用 ~~~
alias tmux="tmux -2"

# ~~~ 列表与导航 ~~~
alias l="lsd --group-directories-first"
alias ls="l"
alias lt="ls --tree"
alias tree="ls --tree --depth 3"

# ~~~ 文件操作 ~~~
alias cat='bat --paging=never'
# alias rm='rm -i'
alias cp='cp -ir'
alias mv='mv -i'
alias mkdir='mkdir -p -v'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# =============================================================================
# Wezterm 工作区
# =============================================================================
# alias devSpace='wezterm start --class "DevWorkspace" -- tmux new-session -A -s dev /bin/zsh'
# alias secSpace='wezterm start --class "DevWorkspace" -- tmux new-session -A -s sec /opt/homebrew/bin/fish'
# alias tstSpace='wezterm start --class "DevWorkspace" -- tmux new-session -A -s tst /opt/homebrew/bin/fish'
# alias opsSpace='wezterm start --class "OpsWorkspace" -- tmux new-session -A -s ops /opt/homebrew/bin/nu'
# alias revSpace='wezterm start --class "RevWorkspace" -- tmux new-session -A -s rev /opt/homebrew/bin/fish'
# alias tmpSpace='wezterm start --class "TmpWorkspace" -- tmux new-session -A -s tmp /opt/homebrew/bin/fish'

function bak --description "备份文件，添加时间戳后缀"
    if test (count $argv) -eq 0
        echo "Usage: bak <file1> <file2> ..."
        return 1
    end

    set date_stamp (date +%Y%m%d_%H%M%S)
    for file in $argv
        if test -e $file
            cp -f $file $file.$date_stamp.bak
            echo "Backed up: $file -> $file.$date_stamp.bak"
        else
            echo (set_color red)"Error: $file does not exist"(set_color normal)
        end
    end
end

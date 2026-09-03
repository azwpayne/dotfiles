# =============================================================================
# 01_rev.fish — 逆向工程工具 (Fish)
# =============================================================================
# Description : Android 逆向与投屏工具封装（jadx-gui、scrcpy、JEB）。
#               后台启动、失败回退与路径守卫；与 zsh 的 jdx/scr 对齐
#               但适配 Fish 的 `type -q` / `test -e` 守卫与 disown 语义。
# Usage       : 由 Fish 自动 source；函数在交互时调用，缺装时黄字提示
#               不阻断启动。JEB 路径为机器本地约定，缺失时提示不报错。
# Guards      : jadx-gui/scrcpy/JEB 均带存在性守卫；jobs disown 避免挂起
# Last Updated: 2026-09-04 — 补全文件头、Guard 说明、JEB 路径注释收敛
# Author      : Payne
# =============================================================================
# about android reverse engineering
alias pkid='java -jar ~/Applications/ApkScan-PKID.jar'

function jdx --description '后台启动 jadx-gui 反编译 (fish 包装)'
    if not type -q jadx-gui
        echo (set_color red)"❌ jadx-gui not found — brew install jadx"(set_color normal)
        return 1
    end
    jadx-gui $argv >/dev/null 2>&1 &
    disown (jobs -lp | tail -1) 2>/dev/null
end

function scrcpyd --description '后台启动 scrcpy 投屏 (fish 包装)'
    if not type -q scrcpy
        echo (set_color red)"❌ scrcpy not found — brew install scrcpy"(set_color normal)
        return 1
    end
    scrcpy $argv >/dev/null 2>&1 &
    disown (jobs -lp | tail -1) 2>/dev/null
end

function jeb
    set -l jeb_path "$HOME/Documents/crack/JEB-5.28.0.202504061650_by_CXV"
    if not test -e "$jeb_path"
        echo (set_color red)"❌ JEB path not found: $jeb_path"(set_color normal)
        return 1
    end

    pushd $jeb_path >/dev/null
    and begin
        sh jeb_macos.sh $argv >/dev/null 2>&1 &
        disown (jobs -lp | tail -1)
        popd >/dev/null
    end

end

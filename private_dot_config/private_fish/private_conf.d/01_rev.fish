# =============================================================================
# 逆向工程
# =============================================================================
# about android reverse engineering
alias pkid='java -jar ~/Applications/ApkScan-PKID.jar'

function jdx
    if not command -q jadx-gui
        echo (set_color red)"❌ jadx-gui not found"(set_color normal)
        return 1
    end
    jadx-gui $argv >/dev/null 2>&1 &
    disown (jobs -lp | tail -1)
end

function scrcpyd
    if not command -q scrcpy
        echo (set_color red)"❌ scrcpy not found"(set_color normal)
        return 1
    end
    scrcpy $argv >/dev/null 2>&1 &
    disown (jobs -lp | tail -1)
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

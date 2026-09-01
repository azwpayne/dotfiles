# =============================================================================
# 开发与构建
# =============================================================================

# ~~~ github-cli 相关 ~~~
alias gopen='gh browse'
alias lg='lazygit'

# ~~~ Node.js 工具 ~~~
# alias ni="npm install"
# alias nid="npm install --save-dev"
# alias nig="npm install -g"
# alias ns="npm start"
# alias nt="npm test"
# alias nr="npm run"
# alias npxl="npx --no-install"

# alias yi="yarn install"
# alias ya="yarn add"
# alias yad="yarn add --dev"
# alias yr="yarn remove"
# alias ys="yarn start"
# alias yt="yarn test"

alias pnpi="pnpm install"
alias pnpa="pnpm add"
alias pnpad="pnpm add -D"
alias pnps="pnpm start"
alias pnpt="pnpm test"

# ~~~ Go 工具 ~~~
alias gob="go build"
alias gor="go run"
alias got="go test"
alias gom="go mod"
alias gomt="go mod tidy"
alias goi="go install"

# ~~~ Rust 工具 ~~~
alias cb="cargo build"
alias cr="cargo run"
alias ct="cargo test"
alias cc="cargo check"
alias ccl="cargo clean"
alias cu="cargo update"

# ~~~ Java/Maven ~~~
alias mvnc="mvn clean"
alias mvni="mvn install"
alias mvnp="mvn package"
alias mvnt="mvn test"
alias mvnci="mvn clean install"

# ~~~ Python 工具 ~~~
alias pipi="pip install"
alias pipid="pip install -e ."
alias pipr="pip uninstall"
alias pipl="pip list"
alias pipu="pip install --upgrade pip"
alias ruff_auto='ruff check --fix --exit-zero . && ruff format .'
alias pip_tsinghua_mirror='python3 -m pip install -i https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple'
# alias uv_resync='rm -rf .venv uv.lock && bass uv pip sync --allow-empty-requirements <(cat /dev/null) && uv sync --upgrade'
# alias uvsync='rm -rf .venv uv.lock && bass uv pip sync --allow-empty-requirements /dev/null && uv sync --upgrade'

function uv_resync
    rm -rf .venv uv.lock
    uv venv  # 显式创建虚拟环境
#     uv pip sync --requirement /dev/null  # 清空依赖（可选）
    uv sync --upgrade
end


# alias pyserver="python -m http.server 8000"
# alias pyv="python -m venv"

# ~~~ 数据库工具 ~~~
alias mongo-local="mongosh mongodb://localhost:27017"
alias redis-cli="redis-cli -h localhost"
alias mysql-local="mysql -u root -p"
alias pg-local="psql -U postgres"


# =============================================================================
# AI 助手
# Agent-Native
# =============================================================================
# alias cla="claude --effort=max"
alias cla="claude"
alias cla-unsafe="claude --dangerously-skip-permissions"
# alias cla="claude --permission-mode auto --effort=max"
# alias cla-unsafe="claude --permission-mode auto --effort=max"

alias clp="opencode"
alias clpconfig="code ~/.config/opencode"
alias claconfig="code ~/.claude"



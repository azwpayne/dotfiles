# 维护指南

## 日常修改流程

本仓库是 chezmoi 的源目录——**永远编辑源文件，不要直接改 `$HOME` 下的目标文件**
（否则下次 `apply` 会被覆盖，产生漂移）。

```bash
# 1. 编辑源文件（chezmoi edit 会直接打开源目录中的对应文件）
chezmoi edit ~/.zshrc
# 或直接：$EDITOR ~/.local/share/chezmoi/dot_zshrc
# 其他示例：chezmoi edit ~/.config/nvim/lua/config/options.lua

# 2. 预览将要发生的变更（apply 前必看）
chezmoi diff

# 3. 应用到 $HOME
chezmoi apply

# 4. 验证（见下方验收清单），通过后提交
git -C ~/.local/share/chezmoi add -A && git -C ~/.local/share/chezmoi commit -m "..."
```

> 小贴士：`chezmoi edit` 等价于用 `$EDITOR` 打开 `~/.local/share/chezmoi/` 下的对应 `dot_`/`private_` 源文件；
> 直接编辑源文件亦可，效果相同。

## 常用命令

| 命令 | 用途 |
| --- | --- |
| `chezmoi managed` | 列出所有被管理的目标文件 |
| `chezmoi diff` | 源与目标的差异预览（apply 前必看） |
| `chezmoi apply --dry-run` | 试运行，不实际写入 |
| `chezmoi add <file>` | 把已有文件纳入管理（自动加 `dot_`/`private_` 前缀） |
| `chezmoi add --encrypt` / `--template` | 需要时再启用加密/模板 |
| `chezmoi forget <file>` | 停止管理（源文件一并删除） |
| `chezmoi doctor` | 环境体检 |
| `chezmoi status` | 简要漂移概览 |
| `zimfw update` | 更新 Zim 插件（zsh，见下方说明） |
| `zimfw upgrade` | 升级 zimfw 自身（zsh） |
| `zimfw init` | 重建 `${ZIM_HOME}/init.zsh`（改动 `~/.zimrc` 后需要） |

## 验收清单

改动不同组件后至少跑过对应检查（覆盖 zsh / zim / starship / ghostty / alacritty / nvim / fish / mise / git / chezmoi）：

```bash
# zsh 模块（语法 + 干净启动 + 关键定义）
zsh -n ~/.config/zsh/{aliases,fzf,sdk}.zsh
zsh -n ~/.zshrc
zsh -ic 'exit'                          # 干净启动无报错
zsh -ic 'type ls df du; echo $EDITOR'   # 关键别名/变量
# 注意：短别名 k 定义在 sdk.zsh 且仅当 kubectl 可用时才存在，无 kubectl 的机器上属预期缺失

# Zim 插件管理器（改动 ~/.zimrc 后；重启 shell 时 dot_zshrc 会按 -nt 时间戳自动重建 init.zsh）
zsh -ic 'zimfw info'                    # 查看 zimfw 版本
zsh -ic 'zimfw update'                  # 更新插件
zsh -ic 'zimfw init'                    # 手动重建 init.zsh

# starship 渲染
starship prompt
starship explain  # 可选：查看各模块判定

# ghostty 配置解析（会打印生效值）
ghostty +show-config
# 或：ghostty +show-config | head -n 50

# neovim 无报错启动
nvim --headless +qa
nvim --headless -c "lua require('config.lazy')" -c "qa"  # 可选：校验 lazy spec

# git 配置合法（未知键不会报错，但可确认解析）
git config --list --show-origin | head
git config --get core.editor
git config --get safe.directory

# fish 配置语法检查
fish -n ~/.config/fish/config.fish

# mise 环境体检
mise doctor

# alacritty 配置解析（或直接启动 alacritty 验证）
alacritty --print-config | head

# chezmoi 全局状态
chezmoi doctor && chezmoi diff
```

提交约定：小步提交、说明动机；涉及行为变化的改动在 commit body 里写明验证命令与结果。

## 常见问题（FAQ）

### fzf 找不到 / 快捷键失效

fzf 安装前缀缓存放在 `$ZDOTDIR/.fzf_prefix_cache`（未设置 `ZDOTDIR` 时即
`~/.fzf_prefix_cache`）。升级/卸载/换机器后若失效，模块会自愈删除并重新探测；
也可手动删除该缓存文件强制重建。
详见 `private_dot_config/zsh/fzf.zsh` 的探测逻辑。

### 换了代理端口/地址

`dot_gitconfig` 中三处引用 `socks5://127.0.0.1:7890`
（`http "https://github.com"`、`https "https://github.com"`、`ssh "ssh.github.com"`），全局替换即可。
当前已无注释掉的 `[http]`/`[https]` 全局代理段，无需再清理旧注释。

### Go / Python 路径强绑定个人环境

- `GOPATH=~/WorkSpaces/project/go`、`GOPROXY=goproxy.cn`（`private_dot_config/zsh/sdk.zsh`）
- pip 清华镜像别名（`private_dot_config/zsh/aliases.zsh`）、uv 镜像开关注释（`sdk.zsh`）

新机器路径不一致时按需调整源文件后 `chezmoi diff` → `apply`。

### `$HOME` 与仓库出现漂移（diff 有输出）

说明目标文件在应用后被直接改过（例如工具自动写回配置）。两种处理：

1. 这些改动是想要的 → 把内容合并回源文件再提交；
2. 是临时产物 → 直接 `chezmoi apply` 覆盖回去。

**不要**让漂移长期存在，否则无法分清哪边是权威版本。
可用 `chezmoi status` 快速查看漂移文件列表。

### .chezmoiignore 生效范围

`.chezmoiignore`（仓库根）控制 `chezmoi add`/`apply` 时忽略的源文件模式，当前包括：

- 本地覆盖与备份：`*.local`、`*.local.*`、`*.bak`、`README.md`、`LICENSE`、`docs/`、`docs/**`、`**/REAMDME.md`（含拼写保留）、`dot_gitconfig`、`**/dot_DS_Store`、`**/dot_git`
- 敏感信息：`*token*`、`*secret*`、`*credential*`、`*client_secret*`
- 构建产物：`node_modules/`、`.pnpm-store/`

注意：`docs/` 被忽略意味着文档改动仅在仓库内维护，不会 `apply` 到 `$HOME`。

### 关于历史上的 `baseline` 标签

部分旧注释提到用 `git show baseline:...` 找回已删除的配置（conda、wezterm 别名等）。
本仓库自 `init` 提交起从未打过 `baseline` 标签（`git tag` 为空），旧内容来自更早的独立
zsh-config 仓库；如确需找回请去旧仓库翻历史。不要在本仓库中创建同名标签造成混淆。

### 新增文件的命名提醒

`chezmoi add` 会自动推断前缀；手工放文件进源目录时要记得：
隐藏文件加 `dot_`、要收紧权限的加 `private_`、符号链接用 `symlink_`（内容写目标路径）、
可执行文件加 `executable_`。详见 [layout.md](layout.md)。
模板文件追加 `.tmpl` 后缀。

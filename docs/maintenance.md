# 维护指南

## 日常修改流程

本仓库是 chezmoi 的源目录——**永远编辑源文件，不要直接改 `$HOME` 下的目标文件**
（否则下次 apply 会被覆盖，产生漂移）。

```bash
# 1. 编辑源文件（chezmoi edit 会直接打开源目录中的对应文件）
chezmoi edit ~/.zshrc
# 或直接：$EDITOR ~/.local/share/chezmoi/dot_zshrc

# 2. 预览将要发生的变更
chezmoi diff

# 3. 应用到 $HOME
chezmoi apply

# 4. 验证（见下方验收清单），通过后提交
git -C ~/.local/share/chezmoi add -A && git -C ~/.local/share/chezmoi commit -m "..."
```

## 常用命令

| 命令 | 用途 |
| --- | --- |
| `chezmoi managed` | 列出所有被管理的目标文件 |
| `chezmoi diff` | 源与目标的差异预览（apply 前必看） |
| `chezmoi apply --dry-run` | 试运行 |
| `chezmoi add <file>` | 把已有文件纳入管理（自动加 `dot_`/`private_` 前缀） |
| `chezmoi add --encrypt` / `--template` | 需要时再启用加密/模板 |
| `chezmoi forget <file>` | 停止管理（源文件一并删除） |
| `chezmoi doctor` | 环境体检 |

## 验收清单

改动不同组件后至少跑过对应检查：

```bash
# zsh 模块（语法 + 干净启动 + 关键定义）
zsh -n ~/.config/zsh/{aliases,fzf,sdk}.zsh
zsh -ic 'exit'
zsh -ic 'type k df du; echo $EDITOR'

# starship 渲染
starship prompt

# ghostty 配置解析（会打印生效值）
ghostty +show-config

# neovim 无报错启动
nvim --headless +qa

# git 配置合法（未知键不会报错，但可以确认解析）
git config --list --show-origin | head

# chezmoi 全局状态
chezmoi doctor && chezmoi diff
```

提交约定：小步提交、说明动机；涉及行为变化的改动在 commit body 里写明验证命令。

## 常见问题（FAQ）

### fzf 找不到 / 快捷键失效

fzf 安装前缀缓存写在 `~/.fzf_prefix_cache`。升级/卸载/换机器后若失效，
模块会自愈删除并重新探测；也可手动 `rm ~/.fzf_prefix_cache` 强制重建。

### 换了代理端口/地址

`dot_gitconfig` 中三处引用 `socks5://127.0.0.1:7890`
（http、https、ssh.github.com），全局替换即可。

### Go / Python 路径强绑定个人环境

- `GOPATH=~/WorkSpaces/project/go`、`GOPROXY=goproxy.cn`（sdk.zsh）
- pip 清华镜像别名（aliases.zsh）、uv 镜像开关注释（sdk.zsh）

新机器路径不一致时按需调整。

### `$HOME` 与仓库出现漂移（diff 有输出）

说明目标文件在应用后被直接改过（例如工具自动写回配置）。两种处理：

1. 这些改动是想要的 → 把内容合并回源文件再提交；
2. 是临时产物 → 直接 `chezmoi apply` 覆盖回去。

**不要**让漂移长期存在，否则无法分清哪边是权威版本。

### 关于历史上的 `baseline` 标签

部分旧注释提到用 `git show baseline:...` 找回已删除的配置（conda、wezterm 别名等）。
本仓库历史只有一条 `init` 提交，**该标签不存在**，旧内容来自更早的独立 zsh-config
仓库；如确需找回请去旧仓库翻历史。

### 新增文件的命名提醒

`chezmoi add` 会自动推断前缀；手工放文件进源目录时要记得：
隐藏文件加 `dot_`、要收紧权限的加 `private_`、符号链接用 `symlink_`（内容写目标路径）。
详见 [layout.md](layout.md)。

# Dotfiles Audit Report — Prioritized Findings & Remediation Plan

**Scope**: chezmoi source repo `~/.local/share/chezmoi` @ commit `8c7107e` (working tree clean)
**Method**: 4 parallel audits (file-structure, config-consistency, doc-separation, annotation-quality) → cross-validation against repo → this report
**Verdict**: Audits highly concordant; nearly all findings confirmed. One critical temporal correction: the regressions previously flagged as *uncommitted worktree state* were **committed** in `8c7107e`. Remediation is therefore **restoration + doc re-sync in new commits**, not "commit or revert" of a dirty tree.

---

## 1 · P0 — Fix before next sync/apply

### P0-1 · Gitconfig regression was committed, docs now false *(was D — High)*
- **Fact**: `[https "https://github.com"]` was **absent at HEAD~1** (docs were true). `8c7107e` reintroduced it, deleted the precise NOTE + rollback command, and dropped the trailing newline. `docs/dev-tools.md:15,20` ("冗余段已删除 / 仅保留一条代理行") now contradict the committed file.
- **Why P0**: non-standard keys are silently ignored by git — a latent trap in the most safety-relevant file (proxy config), plus doc/file divergence.
- **Fix (pick one policy)**:
  - **A (recommended — restores HEAD~1 truth)**: remove the `[https]` block; restore the NOTE + rollback command + trailing newline in `dot_gitconfig`.
  - **B**: keep the block deliberately and re-sync `dev-tools.md:15,20` to state it exists and is inert.
- **Verify**: `git diff HEAD~1 HEAD -- dot_gitconfig` → re-apply chosen state → doc grep `https` matches file.

### P0-2 · sandbox.json doc describes the *opposite* security posture *(was C — High)*
- **Fact**: actual `filesystem.allowRead` is a **narrow 5-entry allowlist**; docs claim `["**", …]` 全域读取放行 at `dev-tools.md:144,172`. Doc table also stale: denyRead says 8 items incl `/tmp` (actual 7, no `/tmp`); denyWrite says 10 (actual 12 — missing `**/.git`, `~/.pi/agent/sandbox.json`). The `dev-tools.md:5` receipt "逐行核对一致" is false for this file.
- **Why P0**: a reader trusting the doc could widen or tighten the sandbox incorrectly, in either direction.
- **Fix**: regenerate the table from the actual file; correct both prose claims; fix or qualify the line-5 receipt; consider stamping tables "verified @ `<commit>`".
- **Verify**: diff doc table vs `private_dot_config`/`~/.pi/agent/sandbox.json` line-by-line; zero mismatches.

### P0-3 · Codex doc drift at 6 spots *(was A — High, confirmed by all 4 audits)*
- **Fact**: `dot_codex/private_config.toml` is a real 210 B cc-switch config (`base_url 127.0.0.1:15721/v1`); **zero** chezmoi empty-placeholder files exist in the repo. Stale: `README.md:76,128` · `docs/layout.md:13,67` · `docs/dev-tools.md:82,84`. **Not fixed by `8c7107e`.**
- **Why P0**: setup instructions reference files that don't exist; a fresh-machine apply produces a config whose documented provenance is wrong (0600 "empty placeholder" vs live proxy config).
- **Fix**: rewrite all six refs to the actual filename, size, and cc-switch purpose.
- **Verify**: a repo-wide grep for empty-placeholder references in `README.md` and `docs/` returns 0 hits.

---

## 2 · P1 — Fix this cycle

### P1-1 · Pi settings.json machine rewrite was committed *(was E — Med)*
- packages list (**10 entries**) erased, aligned-colon formatting stripped, `lastChangelogVersion` 0.84.4→0.84.3 (undoes `513bdb1`'s deliberate "latest"), trailing newline lost. `landstrip.json` also lost its newline + formatting churn.
- **Fix**: restore packages list + annotations; decide `lastChangelogVersion` policy (0.84.3 *matches* installed pi and the doc snapshot — either re-set to "latest" intentionally or pin docs to 0.84.3); add final newlines.

### P1-2 · Docs describe a key that no longer exists — new drift *(emergent N2)*
- `dev-tools.md:97–126` documents `packages` (10-entry table, "顺序同源文件") in a settings.json snapshot; the key is **gone from source** as of `8c7107e`.
- **Fix**: after P1-1, re-sync the snapshot; if the key is intentionally removed, delete the section instead.

### P1-3 · `yoloMode: true` undocumented, contradicts deny-matrix *(was I — Med)*
- In `pi-permission-system/config.json`; moots the `python3*`/`node*` ask rules.
- **Fix**: either set `false` or document it as an explicit opt-out next to the permission matrix, with rationale and blast radius.

### P1-4 · fzf binding stale at 6 spots *(was H — Med)*
- `dot_zshrc:122` (Ctrl-O), `docs/shell.md:27,133`, `zsh/README.md:41,89`, `docs/getting-started.md:145`. Binding commented out since `99e619b` (`fzf.zsh:83` comment is honest).
- **Fix**: pick one — re-enable the binding, or correct all refs to the actual current binding; grep `Ctrl-O|Ctrl-E` → consistent.

### P1-5 · `.claude` entirely undocumented *(was B — Med)*
- Zero mentions in README/docs; `settings.json` statusLine hardcodes `/Users/payne/.local/share/mise/...`; `PROXY_MANAGED` placeholder unexplained.
- **Fix**: add a README/docs section; annotate settings.json; replace the absolute path with a portable form (`$HOME`/chezmoi template).

### P1-6 · 21 Fisher files are machine-local and invisible to apply *(was F — Med)*
- `private_functions`: 15 ignored (of 16); `private_completions`: 6 ignored (of 9); `git check-ignore` confirmed. Fresh-machine drift guaranteed.
- **Fix**: choose policy — (a) track them (adjust `.chezmoiignore`), or (b) keep local + document the post-apply `fisher install` bootstrap step in getting-started, ideally automated via a chezmoi hook/script.

---

## 3 · P2 — Batch cleanup (low)

| ID | Finding | Fix |
|---|---|---|
| G1 | fish_plugins = **14**, docs say "15" at 4 spots: `README.md:15`, `getting-started.md:132`, `layout.md:79`, `shell.md:192` | Correct the 4 refs |
| G2 | managed = **82**; docs say 55 (`README.md:107`), 55→80/81 (`layout.md:141`, `maintenance.md:175`) | Update, or phrase as "82 @ `<commit>`" / drop volatile counts |
| G3 | `chezmoi diff` = 144 lines (exactly the unapplied `8c7107e` changes) | Resolved by running `chezmoi apply` after P0/P1 land |
| J1 | `00_env.fish:1` stray `complete kubecolor --wraps kubectl` | Move to a completions file or delete |
| J2 | ssh `ProxyCommand` undocumented in-file; `[safe] directory=*` unannotated | Add brief annotations (ports are already consistent: 5376/15721) |
| J3 | Missing trailing newlines: `dot_gitconfig`, `landstrip.json`, pi `settings.json` | Folded into P0-1 / P1-1 |

---

## 4 · Remediation roadmap (3 commits + apply)

1. **Commit 1 — "restore regressions"**: `dot_gitconfig` (drop `[https]` per P0-1-A, restore NOTE + newline) · pi `settings.json` (packages, lastChangelogVersion, newline) · `landstrip.json` newline.
2. **Commit 2 — "re-sync docs"**: codex 6 spots (P0-3) · sandbox table + receipt (P0-2) · gitconfig `dev-tools.md:15,20` · packages `:97–126` (P1-2).
3. **Commit 3 — "doc completeness"**: `.claude` section (P1-5) · yoloMode decision (P1-3) · fzf refs (P1-4) · counts 14/82 (G1, G2) · fisher bootstrap note (P1-6) · J1/J2 annotations.
4. **Apply**: `chezmoi apply` → `chezmoi diff` empty; `chezmoi managed | wc -l` = 82.
5. **Guard**: add a pre-apply/CI check — a repo-wide grep for empty-placeholder references in `README.md` and `docs/` returns 0 hits; doc-vs-file parity spot-checks for gitconfig/sandbox tables; trailing-newline lint.

## 5 · Confirmed healthy (no action)

Ports **5376** (gitconfig/ssh/pi httpProxy) and **15721** (codex/claude `ANTHROPIC_BASE_URL`) unified across all files · LANG/EDITOR/font/theme consistent · `.chezmoiignore` physical exclusion works (managed list lacks docs/READMEs) · managed=82 agreed by two independent audits · `nvim.log` is documented (`layout.md:116`) — cosmetic only.

## 6 · Trimmed false positives (for the record)

- "fish side lacks zsh header convention" — style opinion, not a defect.
- "6+ doc locations" for the 15-plugin claim — only 4 exist.
- "yoloMode moots landstrip `*: ask`" — that ask lives in `landstrip.json`, a separate mechanism; only `python3*`/`node*` asks are mooted.
- "stray nvim.log" — documented at `layout.md:116`; cosmetic.
- "gitconfig has no header" — resolved by `8c7107e`; header *accuracy* is the remaining issue (P0-1).
- `lastChangelogVersion` "0.84.3" as a standalone regression — matches installed pi and the doc snapshot; only violates `513bdb1`'s "latest" intent (handled in P1-1).

---
name: git-branch-create
description: git ブランチを安全に作成するときに使う標準手順。命名ルールを強制し、作成元を branch.<name>.base に記録する。ブランチ作成・ブランチを切る・issue に紐づくブランチを作りたいときに使う。
---

git ブランチ作成の標準手順。`git checkout -b` / `git switch -c` / `git branch <name>` を直接実行する代わりに、必ずこのスキルを通して作成する。

## 必須の使い方

ブランチ作成はすべて `${CLAUDE_PLUGIN_ROOT}/scripts/create-branch.sh` 経由で行う。

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/create-branch.sh" <new-branch> [base-ref]
```

- `<new-branch>`: 新しく作るブランチ名
- `[base-ref]`: 省略時は現在の HEAD が使われる。必要に応じて `origin/main` などを明示してよい

## 命名ルール

スクリプトでも検証されるが、スキル側でも理由を添えて命名しておくこと。

- **`/` は禁止** (worktree 運用やツールとの相性のため)
- **`issue` に紐づく作業なら `issue<number>-<slug>` 形式で付ける**
  - 例: `issue1234-fix-login-timeout`
  - Issue があるのに prefix を省略しない
- **担当者の名前 (ユーザー名・owner 名) を入れない**
  - 例: `thinca-fix-login-timeout` のような prefix は禁止
  - 作業スコープが個人に紐づくものでも、ブランチ名から個人名は排除する
- **長さ**: 全体で 50 文字以内を目安にする
- slug は小文字英数字と `-` のみ。空白や `_` は `-` に置換する

既存ブランチを base にしたい場合は第 2 引数で渡す。HEAD が既に base になっているなら省略してよい。

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/create-branch.sh" issue1234-fix-login-timeout
"${CLAUDE_PLUGIN_ROOT}/scripts/create-branch.sh" refactor-cleanup origin/main
```

## 作成後の確認

スクリプトは自動で以下を実行する:

1. 命名ルールのバリデーション (`/`・ユーザー名の混入チェック)
2. `git switch -c <new> <base>` でブランチ作成
3. `git config branch.<new>.base <base>` で base 記録

正常終了すれば `<new> (base: <base>)` と出力される。失敗時はエラーメッセージに従う。

ユーザーから「ブランチを切って」「ブランチを作って」と言われたら、他の git コマンドを挟まず、このスキルの手順に従う。

---
name: tidy-branch
description: 作業中のブランチの紆余曲折した変更履歴を、道筋の通った意味のある単位のコミット列に再整理する。ブランチのコミットを整理したいとき、履歴をきれいにしたいとき、「ブランチを整理して」「コミットを分割し直して」と言われたときに使う。
---

作業ブランチの変更全体を意味のある単位のコミット列に再構成する。紆余曲折(試行錯誤の跡、行き止まりの実装、fixup の積み重ね)を履歴から消し、最初からその道筋で書いたかのようなコミット列を作る。

引数: `[base]`(base ブランチの上書き)、`--verify-each`(全中間コミットでフルテスト)

## 不変条件

整理後のブランチ最終ツリーは元と完全一致していなければならない。唯一の例外はユーザーが個別に承認した残骸の削除。この検証(手順 5)を通らない結果を差し替えてはならない。

## 手順

### 1. 前提確認

- リポジトリ直下で現在のブランチを確認する。detached HEAD なら中断。
- base を特定する:
  1. `git base-branch` を実行(ユーザーの個人 alias。`branch.<name>.base` config を返す)。成功したらその値を使う。
  2. 失敗したら upstream またはデフォルトブランチ(`git symbolic-ref refs/remotes/origin/HEAD` など)との `git merge-base` で自動検出。
  3. 引数で base が指定されていればそれを最優先。
- 整理対象範囲 `<merge-base>..HEAD` のコミット一覧を確認する。以下があればプランで警告する:
  - 自分以外の author のコミット(範囲誤認の可能性が高い。base の見直しを促す)
  - merge コミット(積み直しで線形化されることを明記する)
- 未コミットの変更(staged / unstaged / untracked)があれば、ユーザーに選ばせる:
  - **含める**: `git add -A && git commit` で WIP コミットを作り、整理の原材料に加える
  - **除外**: そのまま置いておく(作業は別 worktree で行うので影響しない)
  - **中断**

### 2. 分析

- `git diff <base>...HEAD` の全体を読み、変更の意味的なまとまりを把握する。
- 既存コミットのメッセージと diff を読み、意図の手がかり(何を試し、何を戻したか)と author date を記録する。
- base 側の既存履歴(直近 30〜50 コミット程度)からプロジェクトのコミットスタイルを推定する: 粒度、メッセージ規約(conventional commits 等)、言語、テストの同梱有無。commitlint 等の設定ファイルも確認する。読み取れない場合のフォールバック指針:
  - 「準備(リファクタ・下地)→ 本体(機能変更)→ 仕上げ」の物語型の順序
  - 機械的な変更(rename、フォーマット)と意味のある変更は別コミット
  - 実装とそれを検証するテストは同一コミット
  - 各コミットは「なぜ」が一文で言える単位
  - メッセージは簡潔な英語
- 残骸候補を検出する: 消し忘れのデバッグ出力、コメントアウトされた試行の跡、どこからも使われなくなったコード。
- 安価な静的チェックコマンド(ビルド / 型チェック / lint)がプロジェクトから判明するか調べる。

### 3. プラン提示・承認

以下を提示して承認を得る。承認前に構築を始めない:

- base と整理対象範囲(コミット数)、手順 1 の警告事項
- 新しいコミット列のプラン: 各コミットの目的、含まれる変更の概要(ファイル/内容)、メッセージ案
- 残骸候補の一覧(それぞれ削除するか残すかを個別に確認)
- 実行方式: 既存コミットの reorder / squash / drop だけで実現できるなら **rebase 方式**、コミット境界の引き直し(split や組み替え)が必要なら **積み直し方式**

### 4. 構築

ユーザーの working tree に触れないため、必ず一時 worktree で作業する:

```sh
git worktree add .worktree/tidy-<branch> -b tidy/<branch> HEAD
```

- **rebase 方式**: 一時 worktree 内で `GIT_SEQUENCE_EDITOR` に todo を書き換えるスクリプトを渡して `git rebase -i <base>` を非対話実行する。author date は自然に保存される。
- **積み直し方式**: `git reset --soft <merge-base>` してから、プランの単位ごとに部分ステージング(`git add <file>` / `git apply --cached` によるハンク単位の適用)でコミットを積む。author date を近似保存する: 新コミットが元コミットとほぼ 1:1 なら `GIT_AUTHOR_DATE` にその author date を、複数の統合なら構成要素の最新の author date を設定する。
- 承認済みの残骸はどのコミットにも含めない。
- 静的チェックコマンドが判明していれば各コミット直後に実行し、失敗したら分割を修正する。`--verify-each` 指定時はフルテストも各コミットで実行する。

### 5. 検証

- `git diff <元ブランチ> tidy/<branch>` が空であること。残骸削除を承認した場合は、diff が承認済みの削除分と正確に一致すること。ここが一致しない限り先に進まない。
- コミット数・各コミットの stat がプランと整合していること。

### 6. 差し替え

検証が通ったら確認なしで差し替える(backup ref から `git reset --keep` 一発で戻せるため):

```sh
git update-ref refs/backups/tidy/<branch> <元の先端>
# ユーザーの worktree(元ブランチを checkout している側)で:
git reset --keep tidy/<branch>
git worktree remove .worktree/tidy-<branch>
git branch -D tidy/<branch>
```

- `git reset --keep` が未コミット変更との衝突で失敗したら、stash してから再実行するようユーザーに案内する。
- 差し替え後の報告に含める: 新履歴の `git log --oneline --stat`、検証結果、undo 方法(`git reset --keep refs/backups/tidy/<branch>`)。
- リモートに push 済みのブランチなら `git push --force-with-lease` を案内する(push はしない)。

## 失敗時

構築中に何が起きても元ブランチは無傷。中断する場合は一時 worktree とブランチを削除して報告する:

```sh
git worktree remove --force .worktree/tidy-<branch>
git branch -D tidy/<branch>
```

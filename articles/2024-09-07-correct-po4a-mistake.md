---
title: "Gitで過去の失敗を参考にしつつ新しいブランチで作業する方法"
emoji: "👻"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [git,po4a]
published: true
---
# 要約

Gitで、ブランチに行った作業を一からやり直したいときに、自分が作業した内容を見ながらより良い結果を作るための手順を示す。

# はじめに

このドキュメントを書くにあたっての背景情報としては、[denoland/docs: Deno documentation, examples and API Reference. Powered by Lume.](https://github.com/denoland/docs)のドキュメントを[po4a - ようこそ](https://po4a.org/index.php.ja)を使い、ドキュメントの更新があっても困らない仕組みを構築するために、試行錯誤の作業が必要で何回かやり直すであろう作業手順を残しておく。

po4aやdocs.deno.comに関するアウトプットは別途行う予定です。

## この文章を書いた動機

Gitでやり直しの作業手順の公開はいくつか検索に引っかかるが、過去は振り返らない手順が多いので、自分の成果を参照しながら、新しくやり直す方法を自分のために書いておく。Gitは人によってワークフローが異なるので、他の方法で過去の自分の作業を見ながら、新しくやり直す他の方法を読んでみたいので、別解の提示は歓迎します。

## この文章はだれ向けか

この文書の対象者は、Gitを利用し過去の自分の失敗を乗り越えて、新しく作業を開始したい人です。

## この文書の読み方

細かくは説明しないので、必要に応じて「参考にしたドキュメントたち」の部分で理解を深めてください。

# 本文

## コアのアイディア

コアのアイディアは、現在のローカルブランチを破棄するのではなく、名前を変えて`git worktree`で参照し新しいブランチをmainやdevelopから派生させて、別ディレクトリで前の内容を確認しながら新しく作業する。

というもの。

## 作業手順

下記の順番で作業をする。

- (存在してたら)リモートのブランチを消す
- 既存のブランチの名前を変える
- git worktreeの設定
- 新しく、作業ブランチを作る
- 実際に作業する
- 後始末

### リモートブランチの削除

- `git push --delete orign ブランチ名`

```sh
git push --delete origin po4a 
Enter passphrase for key '/home/yabuki/.ssh/id_ed25519': 
To github.com:yabuki/deno-docs.git
 - [deleted]         po4a
```

### ブランチ名の変更

- `git branch -m existing_branch new_branch`

1. `git switch main` # 影響を受けないmainブランチへ移動
2. `git branch -m po4a po4a-old`# ブランチ名変更
3. `git branch -a` # 変更の確認

### `git worktree` の設定

- `git worktree list` # 現状の確認
- リポジトリのtop levelへ移動する
```
$ cd `git rev-parse --show-toplevel`
$ git branch -a
* main
  po4a-old
$ git worktree add ../old-po4a po4a-old
Preparing worktree (checking out 'po4a-old')
HEAD is now at 89687af Delete *-ja.md # 最後のコミットメッセージが出てる
ls ../old-po4a/ # 失敗したブランチの内容を確認する
lv ../old-po4a/po4a.cfg # 失敗したブランチの内容を確認する

### 新しく作業ブランチを作る

### 実際に作業する

この部分は、人によります。

私の話は、po4aの記事で書きます。

### 後始末

- 作業ツリーを削除する rmコマンド
- `git worktree list`で現状を確認
- `git worktree prune --dry-run` で削除対象を確認
- `git worktree prune` または `--verbose`オプション付きで実際に削除する
- git worktree list 削除を確認する。

# 参考にしたドキュメントたち

- `git branch`
    - `man 1 git-branch`
    - [Git - git-branch Documentation](https://git-scm.com/docs/git-branch)
    - [『【改訂新版】Gitポケットリファレンス』のレビュー 岡本隆史 (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4774185930)
        - p147

- `git worktree`
    - `man 1 git-worktree`
    - [Git - git-worktree Documentation](https://git.github.io/git-scm.com/docs/git-worktree)
    - [『【改訂新版】Gitポケットリファレンス』のレビュー 岡本隆史 (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4774185930)
        - P160からP164

# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-09-07|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
    <!-- 読み手に何の情報を伝えるのか -->
    <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

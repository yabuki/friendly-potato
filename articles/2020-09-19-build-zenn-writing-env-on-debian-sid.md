---
title: "Debian GNU /Linux SidでZenn.devの記事を書く環境をつくる"
emoji: "🎆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian, nvm]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-09-19|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照せよ。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

slugに時系列の概念を入れておきたかったので、公開日を埋めるようにしました。そのため、いただいたハートが消えています。初期の試行錯誤ということでお許しください。＞ハートをつけていただいた人

## はじめに

Zenn.devという技術系の記事を書く場所ができたようだ。

githubと連携して記事をgithubに残すことができるので記事のコントロールが書き手がコントロールしやすいのが気に入ったのと、gh pagesでも公開可能であるのでZenn側とで意見の相違がでて記事が公開されなくても自分のgh pagesにはおいておける。なんなら、記事は自分でコントロールしているので別の場所にも移すことができる。

ロックイン指向のサービスがちらほら人気を得ているが、自分で自分の記事をコントロールしたい私でも書いてみようかと思わせるサービスだったので、まずは本記事を書く。

## install環境

### Hardware

* Thinkpad X200 C2D Memory 8G

### OS

* Debian GNU/Linux Sid

### 上記以外で使っているソフトウェア

* [nvm-sh/nvm: Node Version Manager - POSIX-compliant bash script to manage multiple active node.js versions](https://github.com/nvm-sh/nvm)

### ここで出てくるWebサービス

* Zenn
* GitHub

## 前提条件

1. GitHubにアカウントがあって使い方がわかっている前提です。ここを読む人にこの前提は妥当だとおもっています。
1. Zenn.devにアカウントを作っていること。これは、2020-09-19現在Google Accountしか作れないようなので、さまざまな理由でブロック要因になるかと思いますが、そこも前提条件とさせてください。
1. Debian GNU/Linux Sidこれは、Debianの開発版を使っていますが、本記事の範囲であれば、Linuxでやってるね。ぐらいの話です。
1. nvmは、[nvm-sh/nvm: Node Version Manager - POSIX-compliant bash script to manage multiple active node.js versions](https://github.com/nvm-sh/nvm)で、userのホームディレクトリで複数のバージョンのnodejsを管理できるので、わたしは必要に迫られて使っていますが、他の人は別の方法でnodejsをインストールしているでしょう。

## Install

### nvm.shのインストール

[nvm-sh/nvm: Node Version Manager - POSIX-compliant bash script to manage multiple active node.js versions](https://github.com/nvm-sh/nvm)の中身をよく読んでインストールしてください。

使うnodejsは、

```bash
nvm install --lts
```

で、2020-09-19現在のltsであるlts/eribuimを使っています。

```bash
nvm ls
->     v12.18.4
         system
default -> lts/* (-> v12.18.4)
node -> stable (-> v12.18.4) (default)
stable -> 12.18 (-> v12.18.4) (default)
iojs -> N/A (default)
unstable -> N/A (default)
lts/* -> lts/erbium (-> v12.18.4)
lts/argon -> v4.9.1 (-> N/A)
lts/boron -> v6.17.1 (-> N/A)
lts/carbon -> v8.17.0 (-> N/A)
lts/dubnium -> v10.22.1 (-> N/A)
lts/erbium -> v12.18.4
```

### githubのrepoを作る

いまのgithubのrepoを作る時には、名前の提案をしてくれるんですね。提案名の **friendly-potato** があまりにツボだったので、思わずその名前で連携してしまいました。

あと、gh-pagesも有効にして、themeも決めておきました。これをどうするかはまだ試していないので設定だけしておきます。

### zenn と連携する

* [GitHubリポジトリでZennのコンテンツを管理する | Zenn](https://zenn.dev/zenn/articles/connect-to-github)

この記事をよんでやります。この段階では、gh-pagesブランチしかなかったので、そこと連携します。

### git clone する

私は、~/scm/git/のしたにgit repoをおいているので、そこで

```
git clone git@github.com:yabuki/friendly-potato.git
```

とします。作成されているブランチは、gh-pagesブランチだけだったので、ステージング環境を作るべく、下記のようなブランチ構成にしています。暫定ですけど。

```
* docs
  gh-pages
  remotes/origin/HEAD -> origin/gh-pages
  remotes/origin/gh-pages
```

### Zenn CLI のインストール

グローバルにインストールするのではなく、このrepoだけにインストールしたいので、

[Zenn CLIをインストールする | Zenn](https://zenn.dev/zenn/articles/install-zenn-cli)

の中身を確認して、そのままのインストラクションで、docsブランチにZenn CLIをインストールします。

```

npm init --yes # プロジェクトをデフォルト設定で初期化
Wrote to /home/yabuki/scm/git/friendly-potato/package.json:

{
  "name": "friendly-potato",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/yabuki/friendly-potato.git"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "bugs": {
    "url": "https://github.com/yabuki/friendly-potato/issues"
  },
  "homepage": "https://github.com/yabuki/friendly-potato#readme"
}
```

install log

```bash
npm install zenn-cli
npm WARN deprecated chokidar@2.1.8: Chokidar 2 will break on node v14+. Upgrade to chokidar 3 with 15x less dependencies.
npm WARN deprecated mkdirp@0.5.3: Legacy versions of mkdirp are no longer supported. Please update to mkdirp 1.x. (Note that the API surface has changed to use Promises in 1.x.)
npm WARN deprecated fsevents@1.2.13: fsevents 1 will break on node v14+ and could be using insecure binaries. Upgrade to fsevents 2.
npm WARN deprecated resolve-url@0.2.1: https://github.com/lydell/resolve-url#deprecated
npm WARN deprecated urix@0.1.0: Please see https://github.com/lydell/urix#deprecated

> @ampproject/toolbox-optimizer@2.6.0 postinstall /home/yabuki/scm/git/friendly-potato/node_modules/@ampproject/toolbox-optimizer
> node lib/warmup.js

AMP OPTIMIZER Downloaded latest AMP runtime data.
npm notice created a lockfile as package-lock.json. You should commit this file.
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@~2.1.2 (node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@2.1.3: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@^1.2.7 (node_modules/next/node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.2.13: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})
npm WARN notsup Unsupported engine for watchpack-chokidar2@2.0.0: wanted: {"node":"<8.10.0"} (current: {"node":"12.18.4","npm":"6.14.6"})
npm WARN notsup Not compatible with your version of node/npm: watchpack-chokidar2@2.0.0
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@^1.2.7 (node_modules/watchpack-chokidar2/node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.2.13: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})
npm WARN friendly-potato@1.0.0 No description

+ zenn-cli@0.1.26
added 900 packages from 393 contributors and audited 903 packages in 107.328s

40 packages are looking for funding
  run `npm fund` for details

found 5 low severity vulnerabilities
  run `npm audit fix` to fix them, or `npm audit` for details
```

```
npx zenn init

  🎉Done!
  早速コンテンツを作成しましょう

  👇新しい記事を作成する
  $ zenn new:article

  👇新しい本を作成する
  $ zenn new:book

  👇表示をプレビューする
  $ zenn preview
  
 yabuki   docs … 6  ~  scm  git  friendly-potato  zenn new:article
bash: zenn: コマンドが見つかりません
```

ってことで、fullpath指定で、

```
$ ls
README.md  _config.yml  articles  books  index.md  node_modules  package-lock.json  package.json
$ node_modules/zenn-cli/bin/zenn.js new:article
📄02430e87dd27b8bc82c4.md created.
$ node_modules/zenn-cli/bin/zenn.js preview
👀Preview on http://localhost:8000
```

こんな感じで記事を作って、あとは好きなエディタで記事を使って記事を書く。

### zenn CLIをlatestにアップグレード

下記のようなエラーが出たものの無事に書き込んだら自動リロードしてくれるバージョンに変わった模様だ。

```
npm install zenn-cli@latest
npm WARN deprecated chokidar@2.1.8: Chokidar 2 will break on node v14+. Upgrade to chokidar 3 with 15x less dependencies.
npm WARN deprecated mkdirp@0.5.3: Legacy versions of mkdirp are no longer supported. Please update to mkdirp 1.x. (Note that the API surface has changed to use Promises in 1.x.)
npm WARN deprecated fsevents@1.2.13: fsevents 1 will break on node v14+ and could be using insecure binaries. Upgrade to fsevents 2.
npm WARN deprecated resolve-url@0.2.1: https://github.com/lydell/resolve-url#deprecated
npm WARN deprecated urix@0.1.0: Please see https://github.com/lydell/urix#deprecated
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@~2.1.2 (node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@2.1.3: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@^1.2.7 (node_modules/next/node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.2.13: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})
npm WARN notsup Unsupported engine for watchpack-chokidar2@2.0.0: wanted: {"node":"<8.10.0"} (current: {"node":"12.18.4","npm":"6.14.6"})
npm WARN notsup Not compatible with your version of node/npm: watchpack-chokidar2@2.0.0
npm WARN optional SKIPPING OPTIONAL DEPENDENCY: fsevents@^1.2.7 (node_modules/watchpack-chokidar2/node_modules/chokidar/node_modules/fsevents):
npm WARN notsup SKIPPING OPTIONAL DEPENDENCY: Unsupported platform for fsevents@1.2.13: wanted {"os":"darwin","arch":"any"} (current: {"os":"linux","arch":"x64"})

+ zenn-cli@0.1.29
added 5 packages from 3 contributors, removed 3 packages, updated 2 packages, moved 1 package and audited 905 packages in 31.792s
found 5 low severity vulnerabilities
  run `npm audit fix` to fix them, or `npm audit` for details
```

## 記事を書き終わってから

### 記事の見直し

* slugの文字列を意味あるモノに変更する
  * Zenn Editorの警告に従うこと

* Zenn Editorの警告を直す
  * slugの文字列は、0-9とハイフン、英文字の小文字50文字までとZenn Editorに怒られた記憶がある。

* 文章の手直し

  * そのうち、Redpenを自動的にかけるとかの文章チェックをかけたいね。

### 公開

公開するために、gh-pagesブランチに、docsブランチをマージする。

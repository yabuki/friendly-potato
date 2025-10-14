---
title: "Denoではじめるnode_modules/がないtextlintを使うzenn.dev執筆環境 2025/10版"
emoji: "👋"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [deno, textlint, zennfes2025free]
published: true
---
## 要約

Denoが`node_modules/`ディレクトリなしに、これまでのnodeやnpmパッケージを動かしているのはすごい。
私が、`deno task`の仕様を知らないで困っていたのを解決した話です。

## はじめに

:::message

執筆時の環境は下記です。

```
$ deno --version
deno 2.5.4 (stable, release, x86_64-unknown-linux-gnu)
v8 14.0.365.5-rusty
typescript 5.9.2
```

```
$ deno run -A npm:textlint --version
v14.2.0
```

:::

参考文献1の記事を読んで、deps.tsを使っていた。しかし今では`deno add`で、npmパッケージをインストールする方法がofficalからアナウンスされています。
その時`deno outdated`(参考文献3)や`deno update`(参考文献4および5)を使えとドキュメントにあります。

こうすることで必要なnpmパッケージが`deno.json`or`deno.jsonc`に登録されます。
npmパッケージが記録されているので`git clone`して`deno run`実行時に必要なパッケージをネット経由でとってローカルキャッシュに保存し、`node_modules`を生成せずにnodeとnpmパッケージを動かします。

参考文献2の記事にはtextlintを`node_modules`なしに動かす方法を書いているが、`deno run`が`node_mocules`なしにtextlintを動かしているの考慮すべき点が多いことに気がつく。
とりわけtextlintからimportできないと、プラグインが動かないのをどうやって回避しているのか、Denoのnpm互換性について、理解をしていないが大変そうなのは理解できた。

### この記事を書いた動機は？

denoも2.5系になり現状で執筆環境を新しく記事にしておく必要を感じた。

### この記事はどんな人向けてすか？

自分を含めた、denoで `node_modules/` なしにtextlintを動かしたい人向けです。

### この記事の読み方

ざっと一通り眺めてください。

## 本文

サンプルのrepoは [yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)です。

```jsonc:deno.jsonc
{
  "node-modules-dir": "none",
  "tasks": {
    "zenn": "deno run -A npm:zenn-cli",
    "zenn:preview": "deno task zenn preview --port 3005",
    "zenn:create:article": "deno task zenn new:article",
    "zenn:create:book": "deno task zenn new:book",
    "lint": "deno run -R -W --allow-env --allow-sys npm:textlint",
    "lint:fix": "deno task lint --fix",
    "lint:dry": "deno task lint --dry-run",
    "markdownlint": "deno run -R -W --allow-env --allow-sys npm:markdownlint-cli2",
    "markdownlint:fix": "deno task markdownlint --fix '**/*.md'"
  },
  "fmt": {
    "useTabs": false,
    "indentWidth": 2,
    "semiColons": true,
    "singleQuote": false,
    "proseWrap": "preserve",
    "include": ["/articles", "/books"]
  },
  "imports": {
    "@proofdict/textlint-rule-proofdict": "npm:@proofdict/textlint-rule-proofdict@^3.1.2",
    "markdownlint-cli2": "npm:markdownlint-cli2@^0.18.1",
    "textlint": "npm:textlint@^15.2.3",
    "textlint-filter-rule-comments": "npm:textlint-filter-rule-comments@^1.2.2",
    "textlint-rule-no-dropping-the-ra": "npm:textlint-rule-no-dropping-the-ra@^3.0.0",
    "textlint-rule-preset-ja-spacing": "npm:textlint-rule-preset-ja-spacing@^2.4.3",
    "textlint-rule-preset-ja-technical-writing": "npm:textlint-rule-preset-ja-technical-writing@^12.0.2",
    "textlint-rule-preset-jtf-style": "npm:textlint-rule-preset-jtf-style@^3.0.3",
    "textlint-rule-prh": "npm:textlint-rule-prh@^6.1.0",
    "zenn-cli": "npm:zenn-cli@^0.2.3"
  }
}
```

これをコピペしたdeno.jsoncを作るなどして環境設定します。

### 1.記事生成

articles/の下にmdファイルを作って、記事を書いていきます。雛形には`deno task zenn:create:article`の実行結果などが役立つでしょう。

私はwrapperで下記のようなスクリプトを利用しています。
```bash:new-article.sh
#!/bin/bash -x

echo $1
arg1="$1"
charcnt=${#arg1}
echo $charcnt
# 2020-09-24- 11characters
# 50-11=39
if [ $charcnt -lt 39 ]; then
    echo "doit"
    #npx zenn new:article --slug `date +%Y-%m-%d`-$1
    deno task zenn new:article --slug `date +%Y-%m-%d`-$1
else
    echo "Too long slug. Be more shorten"
fi
```

### 2.textlintを実行する

.textlintrcやdeno.jsoncの存在するディレクトリから、articles/配下のmdファイルを呼び出します。
```
deno task lint articles/2025-10-13-deno-with-zenn-cli-and-textlint.md
```
のようにします。~~articlesにcdすると`deno task lint`は現状うまくうごきません。deno runで直接 `--config`オプションなどを指定すると動きますがおすすめはひとつ上のディレクトリから操作することです。~~


:::message

2025-10-14 kt3kさんに教えていただいた内容を反映した。

articlesディレクトリにcdした場合であっても、`deno task`は**deno.json/deno.jsoncが存在するディレクトリをカレントとして実行します。**

そのため、articles/以下にいても、プログラムから見えるように引数を与える必要があります。

```
deno task lint articles/2020-09-19-build-zenn-writing-env-on-debian-sid.md
```

`deno task`に`--cwd`オプションを与える方法もあります。

```
deno task --cwd . lint 2020-09-19-build-zenn-writing-env-on-debian-sid.md
```

articles/にcdすると動かないと思っていたのは、私が`deno task`の仕様を把握してなかったために誤解でした。

:::

### 3.textlintが指摘してきた内容を修正する

お好きなエディタなどで、文章を修正して2と3を繰り返します。

### deno task での引数について

`deno task lint`がカレントディレクトリを変更すると意図に反する問題を発見しました。
引数がうまく処理できないように見えたのでslack deno-jaで質問させていだだきました。
議論を深めるなかで、そんな単純な問題ではなくtextlintのプラグインの仕組みとdenoの`node_modules`がなくてもキャッシュで動くという仕組みに関連する。
と教えていただきました。

`deno test`では `--` で引数をinvokeしたプログラムに渡すオプションがあるが `deno task`では、`npm:textlint`のように指定した前か後かで、どれにargumentを渡すのかを指示していると明解に教えていただきました。

が、私が困っていた問題は上記でも書いていますが、`deno task`は実行時に、deno.json/deno.jsoncのあるディレクトリで実行される。という仕様をわかっていなかったため間違った方向に進んでいました。

### 今回の調査で`deno task`に関する私の学び

- `deno test` には、良くあるパターンの `--` でinvokeしたプログラムへの引数を書くという書式がある。
    - しかし、`deno task` だと`--`をいちいち書くのは面倒なので、下記のようにする。
        - `deno.json` or `deno.jsonc`のtaskセクションで`deno task`を定義するが、`deno`や `deno run`へのオプションはそれぞれ渡される。
        - `deno run`が `npm:なんちゃら`を呼び出すときのオプションは、`npm:なんちゃら`のあとに書けば良い。
            - `deno run npm:textlint --help` の`--help`オプションが例となる。
        - `deno task`がtaskを呼び出すと、`deno.json`または`deno.jsonc`があるディレクトリをカレントとして実行する。
            - 呼び出す側で上記を意識して、与えるPathを修正する。
            - または`deno task`に`--cwd`オプション与える方法もある。

## 参考文献

1. [Denoでtextlintを使ってZennリポジトリを運用する](https://zenn.dev/estra/articles/deno-textlint-zenn)
2. [textlintをDenoで動かした](https://zenn.dev/kn1cht/articles/deno-textlint)
3. [deno outdated](https://docs.deno.com/runtime/reference/cli/outdated/)
4. [deno update](https://docs.deno.com/runtime/reference/cli/update/)
5. [Deno 2.4: deno bundle is back | Deno](https://deno.com/blog/v2.4#easier-dependency-management-with-deno-update)
    - Deno 2.4での公式blogによる`deno update`の紹介記事

## 謝辞

slackのdeno-jaにて、質問にお答えしていただいたkt3kさんに御礼申し上げます。

## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-10-13|
|  記事を公開した日  |2025-10-13|
|  記事を変更した日  |2025-10-14|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、
[GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)
を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。
受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->
<!-- 画像はrepoのtopにあるimagesに入れよ -->

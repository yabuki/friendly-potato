# Zenn Contents

- [How to use](https://zenn.dev/zenn/articles/zenn-cli-guide)

## markdownlintのドキュメント

- [DavidAnson/markdownlint: A Node.js style checker and lint tool for Markdown/CommonMark files.](https://github.com/DavidAnson/markdownlint)
  - 対処方法については上記を確認すること。

## prh

- 本家
  -[textlint-rule/textlint-rule-prh: textlint rule for prh.](https://github.com/textlint-rule/textlint-rule-prh)

- 参考にした記事
  - [prh/rules: A collection of prh rules](https://github.com/prh/rules)
  - [textlint + prhで表記ゆれを検出する | Web Scratch](https://efcl.info/2015/09/14/textlint-rule-prh/)
  - [textlint + prhで文章を校正する方法 #textlint - Qiita](https://qiita.com/munieru_jp/items/83c2c44fcadb177d2806)
  -

## 2025-10-14

昨日の指示は、私が`deno task`の仕様を理解していないので起きた。`deno task`は実行時カレントをdeno.json/deno.jsoncのある場所にする。
カレントディレクトリをrepository rootから`articles/`に移動しても`deno task`のカレントディレクトリは変わらない。

下記のような解決方法がある。

```
deno task lint articles/2020-09-19-build-zenn-writing-env-on-debian-sid.md
```

また `--cwd`オプションを使う方法もある。

```
deno task --cwd . lint 2020-09-19-build-zenn-writing-env-on-debian-sid.md
```

## 2025-10-13

deno task lintを実行するときには、リポジトリトップから実行すること。

denoは`node_modules`がなくてもnodeやnpmパッケージを実行できる。しかし互換性は現在100%ではない。
カレントディレクトリを変えてのtextlintの実行は、deno runならいけるがtaskのなかだとまだ問題がある。
(2025-10-14この問題にであっていた訳ではなかった)

textlintはnpmパッケージで分割されている。それぞれのnpmパッケージをimportできる必要がある。
それが`node_modules`をもってないdenoだと、まだ難しいようだ。
(2025-10-14この問題にであっていた訳ではなかった)

## 2025-06-05

箇条書きで、ですますで指摘される場合は体言止めをしてみるのも良い。

## 2024-10-24

markdownlintのlint内容で、zenn.devのキャプションが指摘されるのを抑制するのに
コメントで、markdownlint-next-lineを指定する方法を覚えた。

あと、linkで怒られることがあるのは、lower caseで統一されてないから。
aタグのidをzenn.devで使えるといいのだが。

もしくはローカルのリンクの警告は、markdownlintを黙らせる方向になるのかも知れない。

## 2024-10-01

deno upgrade rcでdeno 2.0.0-rc.8にバージョンを上げる。

deno.jsoncに "node-modules-dir": "none"とする。
`deno cache -r deps.ts`を実行する。

または、下記のようにする。
```
deno install -r --entrypont deps.ts (2.0からはこっちがおすすめらしい)
deno install -r -e deps.tsも等価
```

単にdeno installするとnode-modules/やpackage.json, package-lock.jsonができる。

## 2024-08-30

- [Denoでtextlintを使ってZennリポジトリを運用する](https://zenn.dev/estra/articles/deno-textlint-zenn)
  - この記事で再設定した。

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

昨日の指示は、私が`deno task`の仕様を理解していないので起きた。`deno task`は実行時カレントを deno.json/deno.jsoncのある場所にする。
そのため article/にいても
```
deno task lint articles/2020-09-19-build-zenn-writing-env-on-debian-sid.md
```
や `--cwd`オプションを使う方法があります。
```
deno task --cwd . lint 2020-09-19-build-zenn-writing-env-on-debian-sid.md
```

## 2025-10-13

deno task lint を実行するときには、リポジトリトップから実行すること。
    - denoは`node_modules`がなくてもnodeやnpmパッケージを実行できるが互換性が100%ではないのでカレントディレクトリを変えてのtextlintの実行は、deno runならいけるがtaskのなかだとまだ問題がある。
    - textlintはnpmパッケージで分割されており、それぞれがimportできる必要がある。それが`node_modules`をもってないdenoだと、まだ難しいようだ。

## 2025-06-05

箇条書きで、ですますで指摘される場合は体言止めをしてみるのも良い。

## 2024-10-24

markdownlintのlint内容で、zenn.devのキャプションが指摘されるのを抑制するのに
コメントで、markdownlint-next-lineを指定する方法を覚えた。

あと、linkで怒られることがあるのは、lower caseで統一されてないから。
a タグのidをzenn.devで使えるといいのだが。

もしくはローカルのリンクの警告は、markdownlintを黙らせる方向になるのかも知れない。

## 2024-10-01

deno upgrade rc でdeno 2.0.0-rc.8にバージョンを上げる。
deno.jsoncに "node-modules-dir": "none"
deno cache -r deps.ts
または、
deno install -r --entrypont deps.ts (2.0からはこっちがおすすめらしい)
deno install -r -e deps.ts も等価

単に deno install すると node-modules/やpackage.json, package-lock.jsonができて
しまう。

## 2024-08-30

- [Denoでtextlintを使ってZennリポジトリを運用する](https://zenn.dev/estra/articles/deno-textlint-zenn)
  - この記事で再設定した。

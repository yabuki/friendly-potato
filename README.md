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

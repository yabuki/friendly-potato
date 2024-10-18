# Zenn Contents

[✍️ How to use](https://zenn.dev/zenn/articles/zenn-cli-guide)

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

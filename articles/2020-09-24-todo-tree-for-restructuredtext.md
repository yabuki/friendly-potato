---
title: "Visual Stdio CodeでRestructured Textを書いているときに、TODO Treeを使いたい"
emoji: "👋"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Sphinx", "VisualStudioCode", "VSCodium"]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-09-24|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

## はじめに

Visual Studio Code (以下、vscode)や、その派生である VSCodium[^VSCodium] を使って、Sphinx[^Sphinx] のドキュメント RestructuredText[^RestructuredText]を扱っている人向けの記事です。

TagのRestructuredtextは、タグが切れるので抜きました。

## TODO Tree とはなにか

プログラムや文書う作っている時に、

* TODO
* FIXME

などをコメントに埋めて込んで、コードや文書の手が回っていないがやらないといけないことについて、チケットなどにする前の段階を、対象のソースコードや設計文書に埋め込んで、作業を進めていくスタイルの人にはとても便利な拡張です。

* [Todo Tree - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree)

ファイル毎に、それらのマークアップを視覚化します。リンク先を見たらよりわかりやすいです。

## 問題点

2つあります。

1. 自分の使っているタグがないことがある
1. 残念なことに、Todo Treeのデフォルト状態では、restructured textのコメント形式には、対応していないので、文中に書き込まない限り、Todo Treeは検知しません。

なので、

## Todo Treeをrestructued textに対応させる

### Tagの追加

ユーザー設定->設定　で設定画面をだして、拡張機能から、Todo Treeaを選択して、下記のような画面を出します。

![Todo Tree settings](<https://yabuki.github.io/friendly-potato/articles/images/2020-09-24_18-26.png> =600x)

ここに書いてあるタグでたりないなら、チームで、共有するならワークスペース経由で、個人ならそのまま設定に書きます。

例えば、人によっては *NOTE* Tag が足りてないと思う人もいるでしょう。ただし、sphinxの記法で 注釈を表す

```
.. note::
```

記法があるので、注意深くUpper Lowerを管理できる人でないなら、Restructured textというか、sphinx
の時には気をつけた方がいいでしょう。

Restructured textのコメントになる条件は、みなさん一度はハマるので、確認したほうがいいとおもいますが、
簡単に言うと　.. (dot)2つでコメントです。

restructued textもpythonと同じく、**インデント**が重要なのです。

### コメントにしてもTagを認識させる

> Regex: Regex
> Regular expression for matching TODOs. Note: $TAGS will be replaced by the tag list.

上記のセクションもとは、下記でしたが、

```
((//|#|<!--|;|/\*|^)\s*($TAGS)|^\s*- \[ \])
```

.. も見てくれるように\\.\\.を追加したのが下記になります。--と;の間に正規表現を追加しています。

Escapeせずに書いてて、dotが正規表現だったことを思い出して、この記事を書いてよかった。

あと、ユーザ設定とワークスペース設定だと、ワークスペース設定の方が強いのでそこも注意する。

```
((//|#|<!--|\.\.|;|/\*|^)\s*($TAGS)|^\s*- \[ \])
```

[^VSCodium]: [VSCodium/vscodium: binary releases of VS Code without MS branding/telemetry/licensing](https://github.com/VSCodium/vscodium)
[^Sphinx]: [概要 — Sphinx 4.0.0+/e2079865c ドキュメント](https://www.sphinx-doc.org/ja/master/index.html)
[^RestructuredText]: [reStructuredText - Wikipedia](https://ja.wikipedia.org/wiki/ReStructuredText)

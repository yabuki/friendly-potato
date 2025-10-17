---
title: "私的Linux上におけるScreenshotを取るプログラムの変遷"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian, Screenshot]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-09-24|
|記事を変更した日|2025-10-15|

上記は本記事の鮮度を判断する一助のために書き手が載せたものです。
詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

## はじめに

「百聞は一見に如かず」とのことわざがある。コンピュータを使って、他人とコミュニケーションをとる時にぜんぶ言葉でやろうとして、とても大変な苦労をしたことがあるかとおもう。

手軽にscreenshotを取って他人と共有することで、相互理解を深めやすいが、実際は面倒くさいので、不利益を得ていることもあるだろう。そこで最近教えてもらったflameshotを交えつつ
これまで使ってきたプログラムの名前を列挙しておきたい。

## 使ったことがあるツール

screenshotは、環境に左右されるので、下記は、Xを使っている時の話です。

* CUI only
* wayland

の場合はわからない。

年代順不同です。

- gimp
  - 範囲指定とかもしやすかったが、やっぱりscreenshot取るだけに使うにはtoo much
- imagemagickのimportコマンド
  - コマンドラインから簡単にscreenshotを取るのに使っていたが毎回使い方を思い出さないといけなかった
- gnome-screenshot
  - i3wmのmeta-dのdmenu経由で使っていた
- scrot
  - コマンドラインから指定してscreenshotを取るのは便利だ。しかし`.i3/config`に`bindsym`として登録しておかないと毎回manを引くことになる
  - そのコンピュータdesktopの状態を定点観測の用途にも使えるので、また使うことがはわからない
- flameshot
  - いま使っているプログラム


いまのおすすめは、flameshotで、Debian GNU/Linux Bullseye/Sidなら `apt install flameshot` で入ります。

Screenshotを取ると`~/Pictures/`に保存されます。

範囲指定して、切り取って加工したりがしやすいので気に入りました。gimpを使うほどでもないってのにぴったりです。

```
$ ls
2020-09-24_15-31.png'
```

![my desktop image](<https://yabuki.github.io/friendly-potato/articles/images/2020-09-24_15-31.png> =600x)

## 付録

### Zenn で、github 連携をしている時に画像を使いたい

多分気がついている人多数だと察するが、zennと連携しているrepoでgh pages設定をしている所に画像を置くと、読み込める。

gh pagesブランチにgh pagesをデプロイする設定にしている場合に、ファイルをartcles/imagesの配下に置く。と仮定する。
<https://github.com/yabuki/friendly-potato/blob/gh-pages/articles/images/2020-09-24_15-31.png>
のような置き方になる。それをgh pagesから見たらどうなるかを想像して、下記のようなURLに変換して画像へのリンクを書けばいい。
<https://yabuki.github.io/friendly-potato/articles/images/2020-09-24_15-31.png>

:::message

2025-10-15

いまでは標準でzennがimageをサポートしており、CDNの設定もあるので、上記は推奨しない。

:::

### 自分の環境のpreviewだと

600xに指定するとちょうど良い。

ただし公開してブラウザで見ると、違う風に見える。どうすればいいのか。

### 疑問点

zennのマークダウン記法で画像をクリックすると拡大したimageが得られる記法ってあるの？

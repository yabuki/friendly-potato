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
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

## はじめに

「百聞は一見に如かず」とのことわざがある。コンピュータを使って、他人とコミュニケーションをとる時にぜんぶ言葉でやろうとして、とても大変な苦労をしたことがあるかとおもう。

手軽にscreenshotを取って他人と共有することで、相互理解を深めやすいが、実際は面倒くさいので、不利益を得ていることもあるだろう。そこで最近教えてもらったflameshotを交えつつ
これまで使ってきたプログラムの名前を列挙しておきたい。

## 使ったことがあるツール

screenshotは、環境に左右されるので、下記は、Xを使っている時の話である。

* CUI only
* wayland

の場合はわからない。

年代順不同

* gimp
  * 範囲指定とかもしやすかったが、やっぱりscreenshot取るだけに使うにはtoo much
* imagemagickのimportコマンド
  * コマンドラインから簡単にscreenshotを取るのに使っていたが、毎回使い方を思い出さないといけなかった。
* gnome-screenshot
  * i3wmのmeta-dのdmenu経由で使っていた。
* scrot
  * コマンドラインから、指定してscreenshotを取るのは便利だが、ちゃんと .i3/configにbindsymとして登録しておかないと毎回manを引くことになり、最初の設定を怠ったので、あんまり使わなくなって、インストールしているが使っていない状態になってしまった。
  * そのコンピュータdesktopの状態を定点観測の用途にも使えるので、また使うことがあるかもしれない。
* flameshot

いまのおすすめは、flameshotで、Debian GNU/Linux Bullseye/Sidなら `apt install flameshot` で入ります。

Screenshotを取ると~/Pictures/に保存されます。

範囲指定して、切り取って加工したりがしやすいので気に入りました。gimpを使うほどでもないってのにぴったりです

```
$ ls
2020-09-24_15-31.png'
```

![my desktop image](<https://yabuki.github.io/friendly-potato/articles/images/2020-09-24_15-31.png> =600x)

## 付録

### Zenn で、github 連携をしている時に画像を使いたい

多分気がついている人多数だと思うが、zennと連携しているrepoでgh pages設定をしている所に画像を置くと、読み込める。どういうことかというと。

gh pagesブランチにgh pagesをデプロイする設定にしている場合に、ファイルをartcles/imagesの配下に置くと決めるとする。
<https://github.com/yabuki/friendly-potato/blob/gh-pages/articles/images/2020-09-24_15-31.png>
のような置き方になる。それをgh pagesから見たらどうなるかを想像して、下記のようなURLに変換して画像へのリンクを書けばいい。
<https://yabuki.github.io/friendly-potato/articles/images/2020-09-24_15-31.png>

### 自分の環境のpreviewだと

600xに指定するとちょうどいいのだが。 公開してブラウザで見ると結構違ってしまう。まあ仕方ない。

### 疑問点

zennのマークダウン記法で画像をクリックすると拡大したimageが得られる記法ってあるの？

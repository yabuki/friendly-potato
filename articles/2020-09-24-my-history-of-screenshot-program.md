---
title: "私的Linux上におけるScreenshotを取るプログラムの変遷"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian, Screenshot]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-09-23|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。


# はじめに

「百聞は一見に如かず」とのことわざがある。コンピュータを使って、他人とコミュニケーションをとる時にぜんぶ言葉でやろうとして、とても大変な苦労をしたことがあるかとおもう。

手軽にscreenshotを取って他人と共有することで、相互理解を深めやすいが、実際は面倒くさいので、不利益を得ていることもあるだろう。そこで最近教えてもらった flameshotを交えつつ
これまで使ってきたプログラムの名前を列挙しておきたい。

# 使ったことがあるツール

screenshotは、環境に左右されるので、下記は、Xを使っている時の話である。

* CUI only
* wayland

の場合はわからない。

年代順不同

* gimp
  * 範囲指定とかもしやすかったが、やっぱりscreenshot取るだけに使うにはtoo much
* imagemagick の import コマンド
  * コマンドラインから簡単にscreenshotを取るのに使っていたが、毎回使い方を思い出さないといけなかった。
* gnome-screenshot
  * i3wmのmeta-dのdmenu経由で使っていた。
* scrot
  * コマンドラインから、指定してscreenshotを取るのは便利だが、ちゃんと .i3/config にbindsym として登録しておかないと毎回manを引くことになり、最初の設定を怠ったので、あんまり使わなくなって、インストールが使っていない状態になってしまった。
  * そのコンピュータdesktopの状態をg定点観測の用途にも使えるので、また使うことがあるかもしれない。
* flameshot

いまのおすすめは、flameshot で、Debian GNU/Linux Bullseye/Sidなら `apt install flameshot` で入ります。

Screenshotを取ると~/Pictures/に保存されます。

```
$ ls
2020-09-24_15-31.png'
```

![my desktop image](https://github.com/yabuki/friendly-potato/blob/gh-pages/articles/images/2020-09-24_15-31.png =480x)

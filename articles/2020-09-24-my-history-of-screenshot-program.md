---
title: "私的Linux上におけるScreenshotを取るプログラムの変遷"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian, Screenshot]
published: false
---

# はじめに

「百聞は一見に如かず」とのことわざがある。コンピュータを使って、他人とコミュニケーションをとる時にぜんぶ言葉でやろうとして、とても大変な苦労をしたことがあるかとおもう。


* Light side
  * Github/Gitlabで作ったリポジトリの説明にREAMEファイル(md/rst/adoc)を書いたが、言葉で説明する前にScrenshotを見せることで、よりREADMEファイルを読み進めて貰いたい。 
  * 他人とGUI上の話題について具体的な話をしたい。バグレポートや、プログラムの説明など
* Dark Side
  * 結果の確認という名のscreenshot作成を強要される場合。

上記のうち、他人にアピールという意味では、動きを取り入れる必要があるなら、

* Animation GIF
* asciinema `apt install asciinema` see also [asciinema - Record and share your terminal sessions, the right way](https://asciinema.org/)

をREADMEファイルからLink
する形で使うこともあろう。環境によっては、mp4などの動画を使うこともあるだろう。ソフトウェアによっては、画面共有できるものもありますし。もっと密にやるなら、vscodeのliveshareなども共同作業に都合がいい。

話がそれた。

このように、人に説明したい時に screenshotを使うのはメジャーな手段だといって良い。

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
* flameshot

いまのおすすめは、flameshot

---
title: "Debian GNU/LinuxでKensignton slimbladeの設定を変える "
emoji: "😎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian]
published: false
---
# 要約

Debian GNU/Linuxで、KensingtonのTrackball slimbladeの設定変更方法について述べる。

# はじめに

赤い大玉が特徴的な、4つのボタンがついたTrackballである 
[スリムブレードトラックボール | トラックボール | Kensington](https://www.kensington.com/ja-jp/p/%E8%A3%BD%E5%93%81/%E3%82%B3%E3%83%B3%E3%83%88%E3%83%AD%E3%83%BC%E3%83%AB/%E3%83%88%E3%83%A9%E3%83%83%E3%82%AF%E3%83%9C%E3%83%BC%E3%83%AB/%E3%82%B9%E3%83%AA%E3%83%A0%E3%83%96%E3%83%AC%E3%83%BC%E3%83%89%E3%83%88%E3%83%A9%E3%83%83%E3%82%AF%E3%83%9C%E3%83%BC%E3%83%AB/)
を入手した。

![Kensington slimblade photo](https://twitter.com/YukiharuYABUKI/status/1508984683123544066/photo/1)

## この文章を書いた動機

Linuxで、slimbladeを設定する日本語の記事を軽く検索したが、見つけることができなかった。
これからマシンを設定するたびに、自分で調べなおす 労力をさけるために、ここに記す。

英語では、先達(せんだつ)が、下記の stack overflow に記事を残している。参考にしたドキュメントの 1を参照

この記事を自分でも確かめながら、設定を作ることで、このスレッドとは異なる設定をするときメモを作ることにした。

## この文章はだれ向けか

Linuxを使っていて、Kensington slimbladeの設定を変えてみたい人

## この文書の読み方

下記が、わたし好みの設定です。1,2,3,8と書いているのは、slimbladeの4つのボタンです。Oが赤玉だと見立てていただければさいわいです。
これをこのまま、使いたいひとは、完成した設定ファイルまでお進みください。


そうでない人は、軽く目次を見つつ、必要な部分を拾い読みしてください。



1: 左クリック
2: 右クリック
3: 左右同時クリック(paste)
8: (Browser)reload

```text
奥
+-+-+
|1|2|
+-O-+
|3|8|
+-+-+
手前
```


# 本文

## 準備

下記のステップを踏んで、Linuxが、slimbladeに認識されているのを確認します。

下記の操作を実行するのに、sudoなどの特権昇格、less/lvなどのpager、Xでイベントを
取得するxevをあらかじめインストールしておきます。というか、大抵はインストール済み
ですよね。

xinputだけは、わたしの場合は`sudo apt install xinput`として追加インストールしました。


slimbladeをlinux boxに挿入し、下記のように情報を収集します。


## 完成した設定ファイル

# 参考にしたドキュメントたち

1. [ubuntu - Configuring Kensington Slimblade in Linux - Unix &amp; Linux Stack Exchange](https://unix.stackexchange.com/questions/453069/configuring-kensington-slimblade-in-linux "ubuntu - Configuring Kensington Slimblade in Linux - Unix &amp; Linux Stack Exchange")

# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2022-03-30|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

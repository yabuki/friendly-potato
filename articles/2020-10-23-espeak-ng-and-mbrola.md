---
title: "Debian GNU/Linux で音声合成をしてみる"
emoji: "🦔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [TTS, 音声合成, Debian]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-10-23|
|記事を変更した日|2025-10-17|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたもので。
詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照せよ。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

## はじめに

TTS(Text-To-Speech)という、ソフトウェアの分野がある。
これを読んでいる人も、AndroidやiOS、Windowsはたまたクラウドのサービスとして文字入力したものを読み上げるサービスを使う時代がやってきている。

この分野は昔から目の不自由な人を補助する機能として使われてきているが近年はその読み上げレベルが上昇している。
ちゃんとサーベイをしているわけではないが自然な感じに近づいてきているのはわかる。

とはいえ、使う用途によっては、音声データを自由に使える方が大切です。という利用者もいる。

下記は英語の発音においてeSpeak-ngをエンジンとしてmbrolaの発音データを用いてeSpeakの発音を人に近づける方法について記事にします。

## install

試したのは、2020-10-23の時点で、Debian GNU/Linux sid/bullseyeです。

`apt install espeak-ng`
`apt install mbrola`

そして、aptitudeを使って、mbrolaの発音データを探した。

non-freeに分類されるsectionで、mbrola-us1, mbrola-us2, mbrola-us3, mbrola-en1などの発音データが存在する。
これをインストールする。

## 文字列を与えて喋らせる

コマンドラインから、下記のように、指示してみてください。

-vの部分をmb-us2, mb-us3, mb-en1など変えて試してみてください。enjoy!

`espeak-ng -a 200 -v mb-us1 -s 150 "Hello World!"`

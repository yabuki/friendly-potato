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
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照せよ。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

# はじめに

TTS(Text-To-Speech)という、ソフトウエアの分野がある。これを読んでいる人も、AndroidやiOS, Windows, はたまた、クラウドのサービスとして、文字入力したものを読み上げるサービスを使っているかもしれない。

この分野は、昔から目の不自由な人を補助する機能として使われてきているが、近年はその読み上げレベルが上昇しているようだ。ちゃんとサーベイをしているわけではないが自然な感じに近づいてきているのはわかる。

とはいえ、使う用途によっては、音声データを自由に使える方が大切だ。という利用者もいるだろう。

下記は、英語の発音において、eSpeak-ngをエンジンとして、mbrolaの発音データを用いて、eSpeakの発音を人に近づける方法について記す。

# install

試したのは、2020-10-23の時点で、Debian GNU/Linux sid/bullseye である。

`apt install espeak-ng`
`apt install mbrola`

そして、aptitude を使って、mbrolaの発音データを探した。

non-freeに分類される section に、mbrola-us1, mbrola-us2, mbrola-us3, mbrola-en1 などの発音データが存在するのでインストールする。

# 文字列を与えて喋らせる

コマンドラインから、下記のように、指示してみてください。

-v の部分を mb-us2, mb-us3, mb-en1 など変えて試してみてください。enjoy!

`espeak-ng -a 200 -v mb-us1 -s 150 "Hello World!"`


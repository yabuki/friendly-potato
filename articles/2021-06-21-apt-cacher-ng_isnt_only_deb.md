---
title: "apt-cacher-ng は、deb 以外でも使える。"
emoji: "😽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Linux, Debian, LXD, yadm, ncat]
published: true
---
# 要約

apt-cacher-ng は、Debian や ubuntu だけでなく、OpenSuSE, Arch Linux, Sourceforge mirror network, Cygwin, などでも使えるプロキシーです。

Docker や LXD また、ご家庭にPCが上記のソフトウェアが入っている場合なら、ネットワークに取りにいくよりも、通信料を下げたり、ローカルネット
からデータを取得するので、インストールが速くなったりするでしょう。

追加のスクリプトを書くと、apt-cacher-ng のサーバが存在している場合は、そこから取得ない場合は、直接サーバに取りに行くという、複数のネットワークを渡り歩くノートパソコンにとって便利な設定も可能です。

# はじめに

この記事では、自分の環境での設定方法を書いておきます。LXD を使っていますが、実機や Docker であっても考え方は同じです。

複数台のPCおよび、それなりの数のコンテナを作っては壊ししていると、いちいち外部にパッケージを取得しに行っていると、むだが多い。
プロキシーサーバを立てて、コンテンツのキャッシュをつくろうとしたときに、自分の用途に適しており、時間をかける価値があると思って
構築した。

わたしが、apt-cacher-ng を使っている環境は、自宅で10台以下のDebian machineおよび、仮想環境/コンテナ環境を作っている。主に実マシンと、LXD によるコンテナから apt-cacher-ng を使っている。
docker を使うことがあるので、その時にも何度も外部にパッケージを取りに行くのはネットワークと時間の浪費なので家庭内LANにおけて便利に使っています。

## ネットワーク

LXD をディフォルトでインストールすると、LXD は、IPv4 の Class A な Private IP address をコンテナに割り振ります。また IPv6 のアドレスをホストマシンおよび、コンテナに割り振り振ります。

## この文章はだれ向けか

ある程度の量のパッケージをダウンロードする必要がある人で、まだ Proxy を利用していない人で、通信料やダウンロード時間を短くしたいと考えている人と、自分が環境を最高するときの考慮点を残すためです。

## この文書の読み方

apt-cacher-ng を立てるだけなら、参考にしたドキュメントたち　を読んでいただけれ事足りるかと思います。それらの情報を読んだとして、私の環境における差異を書いておきますので、関係のありそうな部分を拾い読みしてください。

# 本文

ルータから、IPv4 のアドレスを配ってもらっているマシンやコンテナと、固定アドレスを振って使っているマシンがあります。apt-cacher-ng の管理は、apt-cacher-ng が動いているマシン(コンテナ)の 3142 ボート
にアクセスします。(このボート番号はもちろん設定で変更できます。) コンテナで、avahi を動かしている場合、<http://apt-cacher-ng.local:3142/acng-report.html?doCount=Count+Data#stats> のようにアクセル
すると下記の画面のような表示がでます。

![apt-cacher-ng web image](https://yabuki.github.io/friendly-potato/articles/images/2021-06-23_17-47.png =600x)

## ときどき困る点

ホストマシンが再起動したり、avahi がうまくアドレスを返してくれないことがあります。とくに、ホストマシンからコンテナのIPv4アドレスは、ときたまIP Addressが変わったりすることがあるので即値で書きたくありません。
avahiはだいたい答えを返してくれますが、うまく返してくれないこともあり、原因追究よりはワークアラウンドして、いつも同じアドレスを振っていそうなIPv6をで apt-cacher-ng を指定したいことがあります。

所が、スクリプトで利用している netcat は、IPv6 に対応していないので、毎回 lxc list で IP address を確認してから cache を使っている不便さです。そこで、参考にしたドキュメントたちの netcat の記事を見つけた
のです。

## どう解決したか。

上記の記事を読んでから、Debian sid にも ncat パッケージがあることを確認したので、インストール。

```
$ apt-cache search netcat|grep netcat

cryptcat - twofish 暗号化の拡張を施された軽量版 netcat
netcat-openbsd - TCP/IP スイスアーミーナイフ
netcat-traditional - TCP/IP スイスアーミーナイフ
netcat - TCP/IP swiss army knife -- transitional package
netrw - netcat like tool with nice features to transport files over network
ncat - NMAP netcat reimplementation
```

nc と ncat のオプションを確認後、完全に置き換え可能だと判断して置き換えました。

スクリプトの中で、どこのマシンで動いているのか確認もできますが、私は dotfiles の管理に [TheLocehiliosan/yadm: Yet Another Dotfiles Manager](https://github.com/TheLocehiliosan/yadm) を使っています。
このソフトの本格的な使い方は、また記事を書きますが、 [Alternate Files - yadm](https://yadm.io/docs/alternates) と template を使って使う環境ごとに使いまわしをする部分と固有の情報を分離できるので
実験をして使って見ました。yadm add した段階でテンプレートから生成され思ったようになりました。


# 参考にしたドキュメントたち

- [doc/README · upstream/experimental · Adrián Pablo José Sedoski Croce / apt-cacher-ng · GitLab](https://salsa.debian.org/asedoski/apt-cacher-ng/-/blob/upstream/experimental/doc/README)
  - どれが、一番開発が進んでいるかは、 [apt-cacher-ng · Search · GitLab](https://salsa.debian.org/search?search=apt-cacher-ng) を見て決めた方がいいかも。

- [AptCacherNg - Debian Wiki](https://wiki.debian.org/AptCacherNg)
  - 下記の使用できないプロキシは無視したい。は、ここに説明がある。

- [第315回 apt-cacher-ngを使ってAPT用キャッシュプロキシの構築：Ubuntu Weekly Recipe｜gihyo.jp … 技術評論社](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0315)

- [apt-cacher-ng：仮想環境にてホストOS自身もキャッシュを利用する: 個人的健忘録 from 2013](http://bluearth.cocolog-nifty.com/blog/2020/04/post-182a10.html)
- [apt-cacher-ng：使用できないプロキシは無視したい: 個人的健忘録 from 2013](http://bluearth.cocolog-nifty.com/blog/2020/04/post-4dea15.html)
  - とてもいいのだが、残念なことにオリジナルの netcat は、IPv6 に対応していないのでちょっだけ困った。

- apt-cacher-ng の web page [Apt-Cacher NG - Software Package Download Proxy](https://www.unix-ag.uni-kl.de/~bloch/acng/)
  - ドキュメントとしての価値は、salsa.debian.org にあるやつのほうが高いが、あんまり量もないので、ザッと一回は見ておくといいのかも。Alioth は、いまの salsa.debian.org のことです。

- [apt-cacher-ng: Apt のキャッシュプロキシ 平衡点(2017-12-11)](https://uwabami.junkhub.org/log/20171211.html#p01)
  - https に関する設定について言及があったのでこっちに移す。

## repositoies

- [Efreak/apt-cacher-ng at debian/sid](https://github.com/Efreak/apt-cacher-ng/tree/debian/sid)
  - 上記の apt-cacher-ng は、"clone of https://alioth.debian.org/anonscm/git/apt-cacher-ng/apt-cacher-ng.git for easy browsing. Laziness ftw." と書いてあるが、alioth.debian.org は salsa.debian.org の gitlab に移行しています。
- [doc/README · upstream/experimental · Adrián Pablo José Sedoski Croce / apt-cacher-ng · GitLab](https://salsa.debian.org/asedoski/apt-cacher-ng/-/blob/upstream/experimental/doc/README)
  - 

## 大規模につかうなら

- [アーティファクトの管理について、あるいは go-apt-cacher / go-apt-mirror の紹介 - Cybozu Inside Out | サイボウズエンジニアのブログ](https://blog.cybozu.io/entry/2016/07/19/103000)
- [go-apt-cacherによるお手軽APT専用キャッシュサーバーの導入方法 - 2018-03-06 - ククログ](https://www.clear-code.com/blog/2018/3/6.html)

## netcat

- [ネットワーク診断の現場から（netcat編・その1） | NTTデータ先端技術株式会社](https://www.intellilink.co.jp/article/column/security-net01.html)
  - netcat には3種類あって、オリジナルにはIPv6は対応していないのを知った。

# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-06-21|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。


<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->
 

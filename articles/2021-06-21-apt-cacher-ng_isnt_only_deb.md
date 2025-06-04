---
title: "apt-cacher-ng は、deb 以外でも使える。"
emoji: "😽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Linux, Debian, LXD, yadm, ncat]
published: true
---

## 要約

apt-cacher-ngは、Debianやubuntuだけでなく、OpenSuSE, Arch Linux, Sourceforge mirror network, Cygwin, などに対するアクセスを減らせるプロキシーです。Fedoraについては[^1]を参照のこと。

DockerやLXDまた、ご家庭にある複数台のPCが上記のOSやソフトウェアを参照している場合なら、ネットワークに取りにいくよりも、通信料を下げたり、ローカルネットにあるサーバーからデータを取得するので、ほとんどの場合インストールが速くなったりします。

追加のスクリプトを書くと、apt-cacher-ngのサーバーが存在している場合は、そこから取得ない場合は、直接サーバーに取りに行くという、複数のネットワークを渡り歩くノートパソコンにとって便利な設定も可能です。

## はじめに

この記事では、自分の環境での設定方法を書いておきます。LXDを使っていますが、実機やDockerであっても考え方は同じです。

複数台のPCおよび、それなりの数のコンテナを作っては壊ししていると、いちいち外部にパッケージを取得しに行っていると、むだが多い。
プロキシーサーバーを立てて、コンテンツのキャッシュをつくろうとしたときに、自分の用途に適しており、時間をかける価値があると思って
構築した。

わたしが、apt-cacher-ngを使っている環境は、自宅で10台以下のDebian machineおよび、仮想環境/コンテナ環境を作っている。主に実マシンと、LXDによるコンテナからapt-cacher-ngを使っている。
Dockerを使うことがあるので、その時にも何度も外部にパッケージを取りに行くのはネットワークと時間の浪費なので家庭内LANにおけて便利に使っています。

### ネットワーク

LXDをディフォルトでインストールすると、LXDは、IPv4のClass AなPrivate IP addressをコンテナに割り振ります。またIPv6のアドレスをホストマシンおよび、コンテナに割り振り振ります。

### この文章はだれ向けか

以下の条件を満たす人です。

1. ある程度の量のパッケージをダウンロードする必要がある
2. まだProxyを利用していない
3. 通信料やダウンロード時間を短くしたいと考えている

上記の人が、環境を再考するときの考慮点を示すためです。

### この文書の読み方

apt-cacher-ngを立てるだけなら、参考にしたドキュメントたち　を読んでいただけれ事足りるかと思います。それらの情報を読んだとして、私の環境における差異を書いておきますので、関係のありそうな部分を拾い読みしてください。

## 本文

ルータから、IPv4のアドレスを配ってもらっているマシンやコンテナと、固定アドレスを振って使っているマシンがあります。apt-cacher-ngの管理は、apt-cacher-ngが動いているマシン(コンテナ)の3142ボート
にアクセスします。(このボート番号はもちろん設定で変更できます) コンテナで、avahiを動かしている場合、<http://apt-cacher-ng.local:3142/acng-report.html?doCount=Count+Data#stats> のようにアクセス
すると下記の画面のような表示がでます。

![apt-cacher-ng web image](<https://yabuki.github.io/friendly-potato/articles/images/2021-06-23_17-47.png> =600x)

### ときどき困る点

ホストマシンが再起動したり、avahiがうまくアドレスを返してくれないことがあります。とくに、ホストマシンからコンテナのIPv4アドレスは、ときたまIP Addressが変わったりすることがあるので即値で書きたくありません。
avahiはだいたい答えを返してくれますが、うまく返してくれないこともあり、原因追究よりはワークアラウンドして、いつも同じアドレスを振っていそうなIPv6をでapt-cacher-ngを指定したいことがあります。

所が、スクリプトで利用しているnetcatは、IPv6に対応していないので、毎回lxc listでIP addressを確認してからcacheを使っている不便さです。そこで、参考にしたドキュメントたちのnetcatの記事を見つけたのです。

### どう解決したか

上記の記事を読んでから、Debian sidにもncatパッケージがあることを確認したので、インストール。

```
$ apt-cache search netcat|grep netcat

cryptcat - twofish 暗号化の拡張を施された軽量版 netcat
netcat-openbsd - TCP/IP スイスアーミーナイフ
netcat-traditional - TCP/IP スイスアーミーナイフ
netcat - TCP/IP swiss army knife -- transitional package
netrw - netcat like tool with nice features to transport files over network
ncat - NMAP netcat reimplementation
```

ncとncatのオプションを確認後、完全に置き換え可能だと判断して置き換えました。

スクリプトの中で、どこのマシンで動いているのか確認もできますが、私はdotfilesの管理に [TheLocehiliosan/yadm: Yet Another Dotfiles Manager](https://github.com/TheLocehiliosan/yadm) を使っています。
このソフトの本格的な使い方は、また記事を書きますが、 [Alternate Files - yadm](https://yadm.io/docs/alternates) とtemplateを使って使う環境ごとに使いまわしをする部分と固有の情報を分離できるので
実験をして使って見ました。yadm addした段階でテンプレートから生成され思ったようになりました。

### 作業記録

下記のような感じ。LXDではなく、LXC単体での記録ですが、こんな感じです。

```
lxc shell apt-cacher-ng
WARNING: cgroup v2 is not fully supported yet, proceeding with partial confinement
root@apt-cacher-ng:~# apt update
Hit:1 http://deb.debian.org/debian buster InRelease
Get:2 http://security.debian.org/debian-security buster/updates InRelease [65.4 kB]
Get:3 http://security.debian.org/debian-security buster/updates/main amd64 Packages [290 kB]
Get:4 http://security.debian.org/debian-security buster/updates/main Translation-en [150 kB]
Fetched 506 kB in 1s (416 kB/s)     
Reading package lists... Done
Building dependency tree       
Reading state information... Done
All packages are up to date.
root@apt-cacher-ng:~# apt install apt-cacher-ng
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libwrap0
Suggested packages:
  doc-base libfuse2 avahi-daemon
The following NEW packages will be installed:
  apt-cacher-ng libwrap0
0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
Need to get 589 kB of archives.
After this operation, 1,575 kB of additional disk space will be used.
Do you want to continue? [Y/n]
```

avahi-daemonも入れる。

```
apt install avahi-daemon
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  bind9-host geoip-database libavahi-common-data libavahi-common3 libavahi-core7 libbind9-161 libdaemon0 libdns1104 libfstrm0 libgeoip1 libicu63 libisc1100 libisccc161 libisccfg163 liblmdb0 liblwres161
  libnss-mdns libprotobuf-c1 libxml2
Suggested packages:
  avahi-autoipd geoip-bin avahi-autoipd | zeroconf
The following NEW packages will be installed:
  avahi-daemon bind9-host geoip-database libavahi-common-data libavahi-common3 libavahi-core7 libbind9-161 libdaemon0 libdns1104 libfstrm0 libgeoip1 libicu63 libisc1100 libisccc161 libisccfg163 liblmdb0
  liblwres161 libnss-mdns libprotobuf-c1 libxml2
0 upgraded, 20 newly installed, 0 to remove and 0 not upgraded.
Need to get 15.0 MB of archives.
After this operation, 52.7 MB of additional disk space will be used.
Do you want to continue? [Y/n] 
```

```
ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
8: eth0@if9: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:16:3e:c3:a9:fc brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.133.152.75/24 brd 10.133.152.255 scope global dynamic eth0
       valid_lft 3110sec preferred_lft 3110sec
    inet6 fd42:b00f:803e:1956:216:3eff:fec3:a9fc/64 scope global dynamic mngtmpaddr 
       valid_lft 3511sec preferred_lft 3511sec
    inet6 fe80::216:3eff:fec3:a9fc/64 scope link 
       valid_lft forever preferred_lft forever
10: eth1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:16:3e:89:62:26 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.1.76/24 brd 192.168.1.255 scope global dynamic eth1
       valid_lft 83339sec preferred_lft 83339sec
    inet6 fe80::216:3eff:fe89:6226/64 scope link 
       valid_lft forever preferred_lft forever
```

- 自分の中だと、10.133.152.75
- 他のマシンからだと192.168.1.76

設定を /etc/apt/apt-conf.d/05proxyに設定を書いて、apt updateしてから、動作確認
動いている。バンザーイ。

## 参考にしたドキュメントたち

- [doc/README · upstream/experimental · Adrián Pablo José Sedoski Croce / apt-cacher-ng · GitLab](https://salsa.debian.org/asedoski/apt-cacher-ng/-/blob/upstream/experimental/doc/README)
  - どれが、一番開発が進んでいるかは、 [apt-cacher-ng · Search · GitLab](https://salsa.debian.org/search?search=apt-cacher-ng) を見て決めた方がいいかも。

- [AptCacherNg - Debian Wiki](https://wiki.debian.org/AptCacherNg)
  - 下記の使用できないプロキシは無視したい。は、ここに説明がある。

- [第315回 apt-cacher-ngを使ってAPT用キャッシュプロキシの構築：Ubuntu Weekly Recipe｜gihyo.jp … 技術評論社](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0315)

- [apt-cacher-ng：仮想環境にてホストOS自身もキャッシュを利用する: 個人的健忘録 from 2013](http://bluearth.cocolog-nifty.com/blog/2020/04/post-182a10.html)
- [apt-cacher-ng：使用できないプロキシは無視したい: 個人的健忘録 from 2013](http://bluearth.cocolog-nifty.com/blog/2020/04/post-4dea15.html)
  - とてもいいのだが、残念なことにオリジナルのnetcatは、IPv6に対応していないのでちょっだけ困った。

- apt-cacher-ngのweb page [Apt-Cacher NG - Software Package Download Proxy](https://www.unix-ag.uni-kl.de/~bloch/acng/)
  - ドキュメントとしての価値は、salsa.debian.orgにあるやつのほうが高いが、あんまり量もないので、ザッと一回は見ておくといいのかも。Aliothは、いまのsalsa.debian.orgのことです。

- [apt-cacher-ng: Apt のキャッシュプロキシ 平衡点(2017-12-11)](https://uwabami.junkhub.org/log/20171211.html#p01)
  - httpsに関する設定について言及があったのでこっちに移す。

### repositories

これらのrepositoriesは、あなたが思っているようなブランチ構成にはなっていないかもしれません。git-buildpackage/gbpコマンドで便利に使えるようなブランチ構成になっています。[gbp-buildpackage(1) — git-buildpackage — Debian testing — Debian Manpages](https://manpages.debian.org/testing/git-buildpackage/gbp-buildpackage.1.en.html) あたりから調べてください。

- [Efreak/apt-cacher-ng at debian/sid](https://github.com/Efreak/apt-cacher-ng/tree/debian/sid)
  - 上記のapt-cacher-ngは、"clone of <https://alioth.debian.org/anonscm/git/apt-cacher-ng/apt-cacher-ng.git> for easy browsing. Laziness ftw." と書いてあるが、alioth.debian.orgはsalsa.debian.orgのgitlabに移行しています。

- [doc/README · upstream/experimental · Adrián Pablo José Sedoski Croce / apt-cacher-ng · GitLab](https://salsa.debian.org/asedoski/apt-cacher-ng/-/blob/upstream/experimental/doc/README)
  - ドキュメント参照をしたrepository

### 大規模につかうなら

- [アーティファクトの管理について、あるいは go-apt-cacher / go-apt-mirror の紹介 - Cybozu Inside Out | サイボウズエンジニアのブログ](https://blog.cybozu.io/entry/2016/07/19/103000)
- [go-apt-cacherによるお手軽APT専用キャッシュサーバーの導入方法 - 2018-03-06 - ククログ](https://www.clear-code.com/blog/2018/3/6.html)

### netcat

- [ネットワーク診断の現場から（netcat編・その1） | NTTデータ先端技術株式会社](https://www.intellilink.co.jp/article/column/security-net01.html)
  - netcatには3種類あって、オリジナルにはIPv6は対応していないのを知った。

## 謝辞

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-06-21|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

[^1]: Fedraに関しては、もはやサポート外とドキュメントにありました。ちゃんと調べてないけど、rpm系は別の素敵な仕組みがあるのだと思う。

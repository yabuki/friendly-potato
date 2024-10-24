---
title: "コンポジット・マネージャ picom を Debian GNU/Linux で設定する"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [picom, i3wm, Debian]
published: true
---

## 要約

comptonがメンテされなくなり、picom[^1] に移行しろ[\[see also deprecated\]](./2021-07-07-settings-for-picom-with-debian#deprecated)ということで移行文書を残す。

[^1]: 本家の文書では、picomは一環してpicomと表記されておりPicomではないので、本文書でもpicomに統一する。

設定が安定するまでは、何か分かった時点で内容を書き換えます。たまに見にくると内容が書き換わっているかも知れません。(ってか、どんな設定ファイルにするかの設定を調べる前に力尽きそうなので、調べるポイントをまとめてまずは公開メソッドで)

## はじめに

コンポジット・マネージャ[^2] というウインドウの見た目を管理するプログラムがある。ちゃんとした定義は他の人に任せるが、著者はタイル型ウインドウ・マネージャのi3wm[^3] を使っており、主に見栄えの向上(Effect)から得られる認識の向上を実現するために、コンポジット・マネージャを利用している。 --- どれぐらいこの設定に時間を使うべきかは人によるので便利な設定が流通すると私もありがたい。そのためにも文書を公開して利用者が増えると私もHappyなので、可能なら設定公開して文書を書いてもらえるとありがたい。

[^2]: 英語圏ではcompositorと呼ばれているようだ。see also [picom - Debian Package Tracker](https://tracker.debian.org/pkg/picom) とはいえ、この様な表記もある。似てるがちょっとずつ違う。 [Compositing window manager - Wikipedia](https://en.wikipedia.org/wiki/Compositing_window_manager)
[^3]: [i3 - improved tiling wm](https://i3wm.org/) はi3wmと呼ばれることもある。i3の正式名称はi3のようだが、本文書ではi3wmも広く使われているので、 i3wm表記を使うことにする。

この文書を書いている人間は、Debian GNU/Linux Sidを使っている。Debian GNU/Linuxの次のリリースであるBullseyeでi3wmなどを使ってコンポジット・マネージャを利用している人が設定する時にも有益な情報でありたい。もちろんDistro依存の部分は自分が気がつく範囲で書くので、他のDistroの人にも情報提供できると信じる。

### この文章はだれ向けか

コンポジット・マネージャpicomを設定する必要のある人、とりわけDebian GNU/Linuxのbullseye以降を使っている人

### この文書の読み方

## 本文

### 設定ファイルの置き場所

私は、XDGに準拠した置き場所の ~/.config/picom/picom.confに設定ファイルを置くことにしました。他の置き場所については、次の「調べ方」を読んでください。特に興味がなければ、次の「調べ方」はスキップして「設定ファイルの内容」へ読み進めてください。

#### 調べ方

ここは読み飛ばしてokです。

`strace picom 2> /tmp/picom.log` とかで起動時のログを取ります。

```
openat(AT_FDCWD, "/home/yabuki/.config/picom.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/home/yabuki/.config/picom/picom.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/home/yabuki/.config/compton.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/home/yabuki/.config/compton/compton.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/home/yabuki/.compton.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/etc/xdg/picom.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/etc/xdg/picom/picom.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/etc/xdg/compton.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
openat(AT_FDCWD, "/etc/xdg/compton/compton.conf", O_RDONLY) = -1 ENOENT (そのようなファイルやディレクトリはありません)
```

`picom --config path/to/設定ファイル名` で設定ファイルを読み込むことも可能だが、上記の順番で設定ファイルを読むので、上記の順番を知っていても損はない。またcomptonから移行する時にも既存の設定ファイルの置き場所を確認するのにも良いだろう。

### 設定ファイルの内容

### 私がハマった所

下記のようなエラーが発生する。でも、~/.config/picom/picom.confにはそんなエントリーはない。

```
[ 2021年07月08日 08:20:48.077 parse_config_libconfig WARN ] Option `no-dock-shadow` is deprecated, and will be removed. Please use the wintype option `shadow` of `dock` instead.
[ 2021年07月08日 08:20:48.077 parse_config_libconfig WARN ] Option `no-dnd-shadow` is deprecated, and will be removed. Please use the wintype option `shadow` of `dnd` instead.
[ 2021年07月08日 08:20:48.077 parse_config_libconfig WARN ] Option `menu-opacity` is deprecated, and will be removed.Please use the wintype option `opacity` of `popup_menu` and `dropdown_menu` instead.
[ 2021年07月08日 08:20:48.078 parse_config_libconfig WARN ] vsync option will take a boolean from now on. "none" is interpreted as "false" for compatibility, but this will stop working soon
[ 2021年07月08日 08:20:48.078 parse_config_libconfig WARN ] glx-swap-method has been deprecated since v6, your setting "undefined" should be replaced by `use-damage = true`.
[ 2021年07月08日 08:20:48.078 parse_config_libconfig WARN ] "clear-shadow" is removed as an option, and is always enabled now. Consider removing it from your config file
[ 2021年07月08日 08:20:48.078 parse_config_libconfig ERROR ] "paint-on-overlay" has been removed as an option, and the feature is enabled whenever possible
[ 2021年07月08日 08:20:48.078 main FATAL ERROR ] Failed to create new session.
```

* ~/.config/compton.conf が存在するので、~/.config/picom.confが自動生成され、~/.config/picom/picom.confよりも先に読み込まれて、自分が設定したファイルでない部分にエラーがでる。
  * 自分が書いてない設定に関してエラーが出たら、思い出しましょう。

### 関連情報

#### deprecated

* [Debian -- sid の compton パッケージに関する詳細](https://packages.debian.org/sid/compton)
  * > **This package is deprecated and will soon be removed, please switch to picom.**

#### compton-conf

comptonには、qtで書かれた設定ファイル設定ファイル設定ツールがある。[Debian -- sid の compton-conf パッケージに関する詳細](https://packages.debian.org/sid/compton-conf) 。l10nのパッケージもある。[Debian -- sid の compton-conf-l10n パッケージに関する詳細](https://packages.debian.org/sid/compton-conf-l10n)しかし、comptonの設定ファイルがどの程度移行できるかどうかわからないので、自分で設定ファイルを書いた方が結局は早いかもしれない。私にノウハウが少ないのでないとも分からない。

## 参考にしたドキュメントたち

* [yshui/picom: A lightweight compositor for X11](https://github.com/yshui/picom)
  * 本家
* [picom - Debian Package Tracker](https://tracker.debian.org/pkg/picom)
  * Debianのパッケージトラッカ
  * [File: picom.sample.conf | Debian Sources](https://sources.debian.org/src/picom/8.2-1/picom.sample.conf/)
    * 設定ファイルのサンプル (2021-07-07閲覧)
* [Picom - ArchWiki](https://wiki.archlinux.jp/index.php/Picom)
  * 日本語で読める情報源でとてもありがたい。
* [【Linux】コンポジットマネージャをComptonからPicomに移行する - 一応理系男子](https://scienceboy.jp/88io/2021/01/compton2picom/)
  * 先行文献です。いくつか気になる部分があったので、貢献できると思いこの文章を書きました。

### compton related

* [Debian -- sid の compton-conf パッケージに関する詳細](https://packages.debian.org/sid/compton-conf)
* [Debian -- sid の compton-conf-l10n パッケージに関する詳細](https://packages.debian.org/sid/compton-conf-l10n)

## 謝辞

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-07-07|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

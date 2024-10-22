---
title: "英語設定のDebian 12サーバーを日本語設定にする"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian,linux]
published: true
---
## 要約

コンテナやVM、または海外でサーバーを借りるなど、様々な理由で英語環境の
Debian GNU/Linux 12(Bookworm)を自分好みの設定にしたいことがあります。

その手順をここに記します。

## はじめに

自分は、コンテナやVMを扱うのに、incus[^1]というソフトウェアを使っています。

そこで新規にコンテナを使って自分好みの設定にするべく作業した記録を残して
将来の自分のために書き残しておきます。

[^1]: incusについては、[第824回 Dockerコンテナをダイレクトに動かせるようになった「Incus 6.3」を、Ubuntu 24.04で試す | gihyo.jp](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0824) などから、情報をたぐってみてください。わたしはdockerもいいけど、永続化できるコンテナで管理しやすく、軽量なものを探していたので、incusを使っています。ちなみに`incus file mount`コマンドは、dockerのvolumeより、私にはわかりやすかったです。sshfs経由で設定ファイルをコピーすればいいので、lxdのときのcpより使いやすいです。

### この文章はだれ向けか

Debian GNU/Linuxをインストールされた環境を自分好みにしたい人向けです。

### この文書の読み方

必要な部分だけ、拾い読みしてokなはず。

## 本文

### アウトライン

下記の順番で説明をします。

1. ja_JP.UTF-8のロカールを作る
1. システムのロカールをja_JP.UTF-8にする
1. システムのローカルタイムをAsia/Tokyoにする
1. 普段使いのユーザーを作る
    - ユーザからsudoをできるように設定する

ちなみに、openssh-serverを入れていないのは、テンプレート化する時に
openssh-serverの鍵を生成しておくと同じ鍵が使いまわされてよくない
という理由です。なので後から入れるのが良い。

sshサーバーの鍵の再生成について調べるのをサボったともいいますが。

### ロカールがあるかの確認と生成

まずは、日本語のロカールが生成されているかを確認します。
`/etc/locale.gen`のファイルを確認します。rootでviやnanoなど
でja_JP.UTF-8の行が有効になっているか確認します。

有功かどうかを確認するのに、コマンドでやる方法としては
rootで`validlocale ja_JP.UTF-8`を実行してみるのも良い
でしょう。

以下にja_JP.EUC-JPを確認した時の例を載せておきます。

```sh
# validlocale ja_JP.EUC-JP
locale 'ja_JP.EUC-JP' not available
ja_JP.EUC-JP EUC-JP
```

大抵の場合は行頭に#がありコメントになっています。
行頭の#を外して、有効な行とします。[^1]

rootで、`locale-gen`コマンドを実行し、ja_JP.UTF-8を生成するをの確認します。

[^1:]exコマンドを使って編集処理を一括処理にできそうです。
[usr_26 - Vim日本語ドキュメント](https://vim-jp.org/vimdoc-ja/usr_26.html#26.4)
の「シェルスクリプトからVimを使う」を参照してください。
echoコマンドと、exやedコマンドを組み合わせて、編集を自動化するのは便利ですよ。

```sh
# locale-gen 
Generating locales (this might take a while)...
  en_US.UTF-8... done
  ja_JP.UTF-8... done
Generation complete.
```

### ロカールの設定

現在のロカールの設定を確認します。

```sh
# localectl status
System Locale: LANG=en_US.UTF-8
    VC Keymap: (unset)
   X11 Layout: (unset)
```

初期時は上記になっているでしょう。

```sh
localectl set-locale ja_JP.UTF-8
```

で、日本語のロカールにします。

### 別解

2024-09-26バッチ処理をするときに便利な別解を見つけましたので、追記しておきます。

参考文献にもあるように、下記のコマンドを投入します。debconfを使っているので、debian系限定です。
rootのような特権で実行します。

```sh
echo "locales locales/default_environment_locale select ja_JP.UTF-8" | debconf-set-selections
echo "locales locales/locales_to_be_generated multiselect ja_JP.UTF-8 UTF-8" | debconf-set-selections
dpkg-reconfigure --frontend noninteractive locales
```

含んでいるコマンドは、下記なのでdebconfパッケージは入っているだろうから、バッチ処理でいけますね。

```sh
dpkg -S debconf-set-selections
debconf: /usr/share/man/man1/debconf-set-selections.1.gz
debconf: /usr/bin/debconf-set-selections
dpkg -S dpkg-reconfigure
debconf: /usr/sbin/dpkg-reconfigure
debconf: /usr/share/man/man8/dpkg-reconfigure.8.gz
```

### タイムゾーンの設定

現在のタイムゾーンを
`timedatectl status`で確認します。

どのようなタイムゾーンがあるのかは、`timedatectl list-timezones`をlessで受けるなどして
確認してください。

`timedatectl set-timezone Asia/Tokyo`
で日本のローカル時間に合わせます。システムクロックはUTC前提です。

### 一般ユーザの設定

`adduser`で、普段使いのユーザーを作ります。私の場合は、rootで
`adduser yabuki` としました。

新規作成した一般ユーザでもsudoを使えるように、`visudo`コマンドで、/etc/sudoersを編集します。

visudoを使うとsudoersの設定をミスると終了前に教えてくれるのが良い所です。

## 参考にしたドキュメントたち

manコマンドで各コマンドの使い方やsudoersの書き方などを確認しました。

- 別解のネタ元です。
  - [How to automate 'dpkg-reconfigure locales' with one command? - Ask Ubuntu](https://askubuntu.com/questions/683406/how-to-automate-dpkg-reconfigure-locales-with-one-command)

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-09-22|
|記事を変更した日|2024-09-26|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、
[GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)
参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。
受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

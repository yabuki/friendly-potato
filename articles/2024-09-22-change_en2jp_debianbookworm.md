---
title: "英語設定のDebian 12サーバーを日本語設定にする"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian,linux]
published: true
---
# 要約

コンテナやVM、または海外でサーバーを借りるなど、様々な理由で英語環境の
Debian GNU/Linux 12(Bookworm)を自分好みの設定にしたいことがあります。

その手順をここに記します。

# はじめに

自分は、コンテナやVMを扱うのに、incus[^1]というソフトウェアを使っています。

そこで新規にコンテナを使って自分好みの設定にするべく作業した記録を残して
将来の自分のために書き残しておきます。

[^1]: incusについては、[第824回 Dockerコンテナをダイレクトに動かせるようになった「Incus 6.3」を、Ubuntu 24.04で試す | gihyo.jp](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0824) などから、情報をたぐってみてください。わたしはdockerもいいけど、永続化できるコンテナで管理しやすく、軽量なものを探していたので、incusを使っています。ちなみに`incus file mount`コマンドは、dockerのvolumeより、私にはわかりやすかったです。sshfs経由で設定ファイルをコピーすればいいので、lxdのときのcpより使いやすいです。


## この文章はだれ向けか

Debian GNU/Linuxをインストールされた環境を自分好みにしたい人向け

## この文書の読み方

必要な部分だけ、拾い読みしてokなはず。

# 本文

## アウトライン

下記の順番で説明をします。

1. ja_JP.UTF-8のロカールを作る
1. システムのロカールをja_JP.UTF-8にする
1. システムのローカルタイムをAsia/Tokyoにする
1. 普段使いのユーザーを作る
    - ユーザからsudoをできるように設定する

ちなみに、openssh-serverを入れていないのは、テンプレート化する
時に、openssh-serverの鍵を生成しておくとよくないので、後から
入れてもらうのいいかなぁと。

sshサーバーの鍵の再生成について調べるのを
サボったともいいますが。

## ロカールがあるかの確認と生成

まずは、日本語のロカールが生成されているかを確認します。
`/etc/locale.gen`のファイルを確認します。rootでviやnanoなど
で ja_JP.UTF-8の行が有効になっているか確認します。

大抵の場合は、行頭に#があり、コメントになっているので、
行頭の#を外して、有効な行とします。

rootで、`locale-gen`コマンドを実行し、ja_JP.UTF-8を生成するをの確認します。

```
# locale-gen 
Generating locales (this might take a while)...
  en_US.UTF-8... done
  ja_JP.UTF-8... done
Generation complete.
```

## ロカールの設定

現在のロカールの設定を確認します。

```
# localectl status
System Locale: LANG=en_US.UTF-8
    VC Keymap: (unset)
   X11 Layout: (unset)
```

などのようになっていると思います。

```
localectl set-locale ja_JP.UTF-8
```

で、日本語のロカールにします。

## タイムゾーンの設定

現在のタイムゾーンを
`timedatectl status`で確認します。

どのようなタイムゾーンがあるのかは、`timedatectl list-timezones`をlessで受けるなどして
確認してください。

`timedatectl set-timezone Asia/Tokyo`
で日本のローカル時間に合わせます。システムクロックはUTC前提です。

## 一般ユーザの設定

`adduser`で、普段使いのユーザーを作ります。私の場合は、rootで
`adduser yabuki` としました。

新規に作成した一般ユーザでもsudoを便利に使えるように、`visudo`コマンド
で、/etc/sudoersを編集します。visudoを使うとsudoersの設定をミスると
終了前に教えてくれるのが良い所です。

# 参考にしたドキュメントたち

manコマンドで各コマンドの使い方やsudoersの書き方などを確認しました。

# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-09-22|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
    <!-- 読み手に何の情報を伝えるのか -->
    <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

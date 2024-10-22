---
title: "Debian Bullseye で syncthing を使い複数のマシンでタスクと時間管理を行う"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian, syncthing, taskwarrior, timewarrior]
published: false
---
# 要約

Debian GNU/Linux の次のリリースである、Bullseye において、Dropbox などのようにファイル同期を行う syncthing というソフトウェアを用いてファイル同期を行う。
実例として、現在私が使っている、CLIでのタスク管理と時間管理を行う、taskwarrior と timewarrior を事例する記事です。

# はじめに

## この文章を書いた動機

## この文章はだれ向けか

## この文書の読み方

# 本文

## 概念

### device ID

### 設定方法

- ブラウザ
- Native GUI

## Debian における syncthing 関係のパッケージ

Debian bullseye には下記のパッケージが存在します。`apt-cache search syncthing` コマンドで関連するプログラムの検索をcliからしています。

```
apt-cache search syncthing
golang-github-syncthing-notify-dev - File system event notification library on steroids
golang-github-syncthing-syncthing-dev - decentralized file synchronization - dev package
syncthing - decentralized file synchronization
syncthing-discosrv - decentralized file synchronization - discovery server
syncthing-relaysrv - decentralized file synchronization - relay server
syncthing-gtk - GTK3-based GUI and notification area icon for syncthing
```

# 参考にしたドキュメントたち

- [Syncthing — Syncthing v1 documentation](https://docs.syncthing.net/users/syncthing.html)
  - 公式ユーザードキュメント(英語)

# 謝辞

# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-07-25|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->  

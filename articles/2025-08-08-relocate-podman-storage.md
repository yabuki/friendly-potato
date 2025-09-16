---
title: "さまざまなLLMを試すために、podmanのストレージ領域を移動させる"
emoji: "🎃"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [podman, debian]
published: false
---
## 要約

[自作PCでGPT-OSSを動かす](https://zenn.dev/yabuki/articles/2025-08-06-podman-with-gpt-oss)の続きです。
LLMを活用するのに、Diskを増設したので、Dockerを置き換えるPodmanのstorage領域を移動させます。

## はじめに

前回の記事では、Dockerの代わりに、Podmanで、OllamaのROCm対応したイメージでコンテナを動かしました。
そこで、LLMモデルの巨大さに気がつきました。

複数のコンテナイメージを保持し、また複数のLLMモデルを扱うことになるとDiskの空き容量に余裕がある場所に格納したくなるのは当然です。

この記事では、Debian GNU/Linux 12(bookworm)の`apt -y install podman`でインストールし、一般ユーザーのyabukiでrootlessモードで動かしている
Podmanの設定変更について書いていきます。

セキュリティ上の利点で、rootlessを第一の選択肢としていますが、rootで、Podmanを動かすと既定値では/var/lib/containers/stroageに各種イメージが置かれます。
自分の環境での確認方法は、本記事を読み進めるないしは、参考文献を見てください。

### この記事はだれ向けか


### この記事の読み方

## 本文

## 参考文献

1. [Podman とは？をわかりやすく解説](https://www.redhat.com/ja/topics/containers/what-is-podman)

## 謝辞


## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-08-08|
|  記事を公開した日  |----------|
|  記事を変更した日  |----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、
[GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)
を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。
受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->
<!-- 画像はrepoのtopにあるimagesに入れよ -->

---
title: "Debian PackageをGit buildpackageに関するメモ"
emoji: "🐙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian,git]
published: false
---
## 要約


## はじめに

Debianパッケージを作ってメンテナンスするのにGitを利用するgit buildpackageを使うことは知っている人いるでしょう。
参考文献にあるように、さまざまな人がgit buildpackageについて書いています。が、最近までちゃんと理解してなくて
とても困った状態になったので、どういうワークフローでパッケージメンテナンスをすると幸せになるのか。

というのが、本記事の内容です。

git buildpackageは、以下gbpと表記します。コマンド名もgbpですが、実例時に出てくるだけなので混乱しないでしょう。

gbpは、さまざまな背景を持つDebianパッケージに対応するため、設定でメンテナンス上の要求を満たすようになっています。

### この記事はだれ向けか

自分が記事を書いて、情報をまとめておくと、将来の自分が助かるということで、自分向けです。

### この記事の読み方



## 本文

## 参考文献

### 日本語で読めるもの

- [東京エリア Debian 勉強会 Debian パッケージング道場 第 130 回 2015 年 9 月度](https://tokyodebian-team.pages.debian.net/pdf2015/debianmeetingresume201509-presentation.pdf)
    - pdfです。
- [2019-04-11 git-buildpackageを用いたdebパッケージ管理方法の紹介](https://blog.cybozu.io/entry/2019/04/11/110000)

## 謝辞


## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-09-17|
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

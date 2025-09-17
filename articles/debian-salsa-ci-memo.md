---
title: "Debian Projectの公式リポジトリsalsa.debian.orgでCIするための前提知識"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian, ci, gitlab, zennfes2025free]
published: true
---
:::message
実際にドキュメントを読み進めて、わかったことがあれば書き加えていくスタイルです。
:::

## 要約

salsa.debian.orgでパッケージのメンテナンスを行い、パッケージの品質を上げるためにCIを導入するにあたっての前提知識をまとめる。

## はじめに

Debian GNU/Linuxをリリースしている、Debian Projectは、Debパッケージをメンテナンスするのに、salsa.debian.orgを提供しています。

Debian Developerおよび、コントリビュータなどのパッケージ・メンテナンス作業をするにあたってCIを使うことが推奨されています。
実際にsalsa.debian.orgでCIを始めるのは簡単ですが、使われている用語や概念、実際に何がどう動いているのか？がわからないと対処ができないことがあります。

理解してないけど、なんか動いた。では困るのは自分を含めた関係者の誰も幸せにならないので、つらつらと必要そうな知識を列挙していく
記事になります。逐次更新していくので変更履歴を知りたい人は、「さいごに」の部分で、GitHubのpublic repositoryから見てください。

### この記事を書いた動機

2025-09-17 現在、xfireworksにCIを導入しているが、そのチェック能力を十分に生かしていない。salsa.debian.orgでCIをカスタマイズ
するのに事前知識が必要そうだが、自分は知っておくべきことを知らない状態であると判断したので知識を積み上げるためにこの記事を
書くことにした。

私がものを知らないだけ可能性もあるが、書き出すことで他人からのアドバイスがもらえて、私の知識が増えると嬉しい。

### この記事はだれ向けか

salsa.debian.orgでCIする人向け。なのでDebian Developerやコントリビューターは必要になる知識です 。
また、salas.debian.orgはGitLabで動いている。そのためGitLabを使ってCIしている人にとっても有益になる可能性がある。

### この記事の読み方

最初は関係するドキュメントのリンク集を作ってメモ書きにします。そのためレベル感の揃わない雑多なメモ集になります。
一定以上の情報が集まって構造化までいくとよいのですが。

## 基礎的な前提条件

![GitLabとsalsa.debian.orgとの関係図](/images/20250918_030223.png =250x)
*GitLabとsalsa.debian.orgとの関係図*

まずは、参考文献2をザッと目を通すが、そもそもGitLabの用語や概念を十全に理解していないので具体的なイメージが脳内に構築できてないことを自覚した。

そのため、GitLabのドキュメントを読むのが先っぽい。そしてドキュメントやリポジトリのIssueを見るとビルドのバックエンドではコンテナ(Docker?)がRunnerとして動いているような気もする。掘っていくと確信できるだろうか。

- パイプラインって何?
    - [CI/CDパイプライン | GitLab](https://gitlab-docs.creationline.com/ee/ci/pipelines/)
        - 日本語に翻訳してくれているのがあるのでそちらにリンク

## CIで使うプログラムたち

1. [blhc - Debian Wiki](https://wiki.debian.org/blhc)
    - ` blhc xfireworks_1.3-16_amd64.build`のように、ビルドログを食わせて、hardening付きのオプションしてないビルドがあれば指摘する。

## 参考文献

1. [Files · master · Salsa CI Team / Salsa CI pipeline · GitLab](https://salsa.debian.org/salsa-ci-team/pipeline)
    - ローカルで読みたいなら、cloneしよう。
2. [README.md · master · Salsa CI Team / Salsa CI pipeline · GitLab](https://salsa.debian.org/salsa-ci-team/pipeline/-/blob/master/README.md)
    - まずはここから。
3. [RUNNERS.md · master · Salsa CI Team / Salsa CI pipeline · GitLab](https://salsa.debian.org/salsa-ci-team/pipeline/-/blob/master/RUNNERS.md)
    - CIで動かしているRunnerについて
4. [STRUCTURE.md · master · Salsa CI Team / Salsa CI pipeline · GitLab](https://salsa.debian.org/salsa-ci-team/pipeline/-/blob/master/STRUCTURE.md)
    - CIパイプラインの構造についての説明
5. [GitLab Docs](https://docs.gitlab.com/)
    - 公式ドキュメント
6. [GitLabのドキュメント | GitLab](https://gitlab-docs.creationline.com/ee/)
    - 日本の会社がGitLabのドキュメントを機械翻訳をかけて日本語にしている。

## 謝辞


## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-09-17|
|  記事を公開した日  |2025-09-18|
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

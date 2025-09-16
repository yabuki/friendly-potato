---
title: "Debian PackageをGit buildpackageに関するメモ"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian,git]
published: true
---
## 要約

gbp pq コマンドを使いこなそう。

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

最初は関係するメモ書きにします。そのためレベル感の揃わない雑多なメモ集になります。
一定以上の情報が集まって構造化までいくとよいのですが。

## gbpを使うにあたっての前提知識

gbpを使う前に、Debian packageの前提知識として、Debianのソースコードに対する考え方と、パッケージメンテナーが抱える
問題があります。

Debian Projectでは、既存のソフトウェアをDebパッケージにしてDebian Packageを作っています。
基本は、Upstreamがリリースしたソフトウェア一式のtarballを使うことが多いです。

Debian Packageではパッケージ化を行う際に、厳密にupstreamのリリースした内容と、Debianパッケージを作るに当たって
upstreamのソースコードを改変するパッチ集を分離します。パッチを監査して、upstreamとパッケージメンテナの責任を分離
するためです。

そのパッチ管理システムが quiltです。debian/source/formatが下記のようになっているのをdebian packageをひもといて
いるとわかります。
```
cat debian/source/format 
3.0 (quilt)
```

個々のパッチについては、[DEP-3: Patch Tagging Guidelines](https://dep-team.pages.debian.net/deps/dep3/)
というガイドラインがあります。`quilt`や`dpkg-source --commit`でパッチをつくる時は意識していました。

`gbp pq import`して、patch-queue/作業ブランチでコミットを作るときにプログラムが自動的につけるわけ
ではないので同様の情報を残したくなるでしょう。


ただし、gbpを使うなら、生の`quilt`や、`dquilt`または、`dpkg-source --commit`を使うのは自分で自分の足を撃ち抜いても
直せる人だけがわかって使うのならいいけど、基本は「混ぜるな危険」です。今回xfireworksで苦労したのも`gbp pq`
を理解せずに、`dpkg-source --commit`を使ったのが原因でした。

### gbpで知るべきブランチ

- pristine-tar ブランチ
- upstream ブランチ
- パッケージを作るために作業するブランチ、debianの開発版だけに作業するなら、mainないしはmasterを指定する。複数のディストリビューションや、Debianだけでも開発版以外にbackportsにパッケージを提供する場合などはブランチを使い分ける。

の3つに加えて、`gbp pq import`で作られ`gbp pq export`で消滅するpatch-queue/作業ブランチ の4つを意識する必要がある。

### formatが3.0 (quilt)の形式って何よ?

gbpはquiltを使わずにdebianディレトクリ配下の patches/を操作します。内容は下記のような感じです。
```
ls -la debian/patches/
合計 40
drwxrwxr-x 1 yabuki yabuki  424  9月 16 23:04 .
drwxrwxr-x 1 yabuki yabuki  212  9月 16 23:04 ..
-rw-rw-r-- 1 yabuki yabuki 6270  9月 16 23:04 0007-Fix-1114447-FTBFS.patch
-rw-rw-r-- 1 yabuki yabuki  622  9月 16 23:04 0008-Update-FSF-address.patch
-rw-rw-r-- 1 yabuki yabuki  954  9月 16 23:04 0008-blhc-tells-me-need-more-hardening.patch
-rw-rw-r-- 1 yabuki yabuki  607  9月 16 23:04 Fix-FBTFS-for-mkconf
-rw-rw-r-- 1 yabuki yabuki  933  9月 16 23:04 Fix-FBTFS-for-time_t-transition
-rw-rw-r-- 1 yabuki yabuki 1064  9月 16 23:04 cross-build-dh_auto_build
-rw-rw-r-- 1 yabuki yabuki 2368  9月 16 23:04 debian-changes-1.3-7
-rw-rw-r-- 1 yabuki yabuki 2558  9月 16 23:04 hardening
-rw-rw-r-- 1 yabuki yabuki  214  9月 16 23:04 series
```
xfireworksは途中から、gbpに移行したので、最初に連番がついてないやつとついているやつが混在しています。gbpを使うと最初に連番と
patch-queue/masterなどのパッチキューで作業したコミットです。大事なのは、seriesというファイルで
```
cat debian/patches/series 
debian-changes-1.3-7
hardening
cross-build-dh_auto_build
Fix-FBTFS-for-time_t-transition
Fix-FBTFS-for-mkconf
0008-Update-FSF-address.patch
0007-Fix-1114447-FTBFS.patch
0008-blhc-tells-me-need-more-hardening.patch
```
のようにパッチの管理をしている。

### gbp pq は何をするコマンドなのか?

Debian packageを管理するのに、debian/patches/にパッチを作る必要があります。gbp pq import でpatch-queueブランチを作り
patch-queue/作業ブランチで upstream のソースを変更します。Gitの作法に則って、一行目にsummary、2行目は空けて、3行目
から詳細を書く。詳細には上記で説明した[DEP-3: Patch Tagging Guidelines](https://dep-team.pages.debian.net/deps/dep3/)
は自動的に付かないので、必要な情報は説明に含める。

`gbp pq export`でpatch-queueのコミット毎に、一行目をファイル名としてquilt形式のpatchがdebian/patches/に生成される。
patch-queueの内容を確認しなくていいなら(あなたがcommitするのを忘れっぽいなら:-))、`gbp pq export --commit`とするのもいいだろう。

そして、`--drop`オプションを付けている場合patch-queueブランチは削除される。

この状態で、`gbp buildpackage`を動かすと、buildする前にdebian/patches/の内容が適用されてビルドが動きます。

### gbp pq でよく使うコマンド

`gbp pq import --force --time-machine=10`

`--force`オプションは、
> In case of import, import even if the patch-queue branch already exists and overwrite its content with debian/patches.
という説明で、patch-queue ブランチが存在していても、現在のdebian/patches/の内容でpatch-queueブランチを上書きします。

`--time-machine=数値`オプションは、
> --time-machine=NUM
> When importing a patch queue fails, go back commit-by-commit on the current branch to check if the patch-queue applies there.
> Do this at most NUM times. This can be useful if the patch-queue doesn't apply to the current branch HEAD anymore,
> e.g. after importing a new upstream version.

patch-queueのインポートに失敗したときに、現在のブランチのコミット毎にコミットを遡ってpatch-queueが適用できるか確認します。
(コミットを)遡る回数を指定します。新しいupstream versionをインポートする時など、現在のブランチのHEADにもはやpatch-queueが適用できない時に有用です。

`gbp pq export --drop --commit`

`--[no-]drop`
> Whether to automatically drop (delete) the patch queue branch after a successful export
`gbp pq export`と一緒に使う場合、exportが成功した後にpatch-queueブランチは削除されます。指定しない場合はpatch-queueブランチを消しません。

`--commit`
> In case of export, commit debian/patches the changes to Git after exporting the patches.
`gbp pq export`で指定された場合、patchesをエキスポートした後にdebian/patchesへの変更を`git commit`します。

本来は、
```
git add debian/patches
git commit
```
とする必要があるのを楽にしてくれています。

## gbp dch --release

ちゃんと、patch-queueでコミットを作っていると、debian/changelogに一行目のサマリーを転写してchangelogを作るのに楽ができます。

## 参考文献

### Debian

1. [Projects/DebSrc3.0 - Debian Wiki](https://wiki.debian.org/Projects/DebSrc3.0)

### gbp pq

1. [gbp-pq(1) — git-buildpackage — Debian trixie — Debian Manpages](https://manpages.debian.org/trixie/git-buildpackage/gbp-pq.1.en.html)
2. [Working with Patches: Building Debian Packages with git-buildpackage](https://honk.sigxcpu.org/projects/git-buildpackage/manual-html/gbp.patches.html)

### 日本語で読めるもの

- [東京エリア Debian 勉強会 Debian パッケージング道場 第 130 回 2015 年 9 月度](https://tokyodebian-team.pages.debian.net/pdf2015/debianmeetingresume201509-presentation.pdf)
    - pdfです。
- [2019-04-11 git-buildpackageを用いたdebパッケージ管理方法の紹介](https://blog.cybozu.io/entry/2019/04/11/110000)

- quilt
    - [quiltの使い方 #Linux - Qiita](https://qiita.com/htano/items/9440073e5a08c43d66ba)

## 謝辞


## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-09-17|
|  記事を公開した日  |2025-09-17|
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

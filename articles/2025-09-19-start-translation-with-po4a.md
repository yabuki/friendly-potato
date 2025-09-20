---
title: "po4aコマンドだけを使ってドキュメントを翻訳する"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [po4a, 翻訳, zennfes2025free]
published: true
---
## 要約

gettext系のコマンドを使わずに、po4aコマンドだけで英語のドキュメント(ここでは、markdownファイル)からpoファイルを生成し、poファイルが日本語のドキュメント(ここでは、markdownファイル)を生成されるまでのやり方を実例付きでまとめた記事です。

## はじめに

po4aに関しては参考文献にあるように本家ドキュメントや翻訳する人が増えてほしい人たちが書き残したドキュメントがあります。
ですが、基本的に最初から最後までの一連の作業でなく、poファイルを更新して翻訳に反映するというスコープを限定して
とっつきやすさ重視のドキュメントが多いように感じました。

大きなプロジェクトであれば、ほかの誰かが初期設定をしてくれるので、すぐに翻訳に参加する知識を渡して参加してもらうのは合理的です。

近年、ブラウザでWebの記事を翻訳して母語で読めたり、LLMでローカルのドキュメントを翻訳させると、だいたいいいんだけど、おかしな部分は手元で変更して意味が通りやすい日本語にしたい。

また、機械翻訳で文章を読んでも、頭に定着しないので翻訳作業は自分の脳に情報を定着させる作業の一環で機械翻訳をさせない。などの選択肢が広がっています。

そのため、翻訳はより個人的なニーズで行われる作業になっていると感じています。

個人の興味は多様化し、たとえ英語などの多言語が読める人でも、自分しか興味を持たない領域で、必要な部分だけ母語(私の場合は日本語)にするというのもアリでしょう。
共有したければすればいいし、他人と共有しないこともありうる。

とはいえ、他人と共有するとメリットがあるので、po4aでドキュメント翻訳になれてもらい、翻訳文書が増えることが望みです。

gettextベースのツールなので、gettextの利点である上流の文書が更新されたら、その部分は原文の言語(だいたいは英語)で表示されるので変更部分がすぐにわかるのが良い点です。

### この記事を書いた動機

po4aコマンドと、po4a.cfgの書き方を覚えると、po4aコマンドを使うだけでpoファイルや翻訳済みのファイルが生成できるのを紹介したかった。

一連の作業は、po4aコマンドで完結する。最低限のpo4a.cfgの書き方から自分に必要な設定方法を見つけてほしい。

思っているよりも手を動かして、確認しつつやってみよう。

### この記事はだれ向けか

翻訳したいドキュメント(Markdownなど)があるけど、どうやってはじめていいか、わからない人向け。

### この記事の読み方

一通りこの記事を読んだら、自分の手元で試してみてください。
失敗したとしてもリカバリできる環境が望ましいです。Gitが管理されているのが多いかと。

その場合、[Gitで過去の失敗を参考にしつつ新しいブランチで作業する方法](https://zenn.dev/yabuki/articles/2024-09-07-correct-po4a-mistake)
が参考になるかもしれません。

また、翻訳を一人でなくチームでやるなら、翻訳した著作権についての合意、また使っていい翻訳サービスやAI(LLM)についての取り決めなど事前に
詰めておく事柄もあります。

poファイルの上部にある雛形を指定するのは、手前味噌で恐縮ですが、[シェルスクリプトでも、いろんな言語を表示したい! --- gettext.sh 最初の一歩](https://zenn.dev/yabuki/articles/2020-12-11-first-steps-of-gettext-sh)
で少し書いています。

複数人で作業するなら、翻訳する言葉を統一するのにメモリーバンクなどの周辺整備もあり、前述の権利関係、使っていいサービスなどについてまとまった文書が読みたいです。
残念ながら私はまだ見つけられていません。

## 本文

1. po4aのインストール
2. 翻訳する作業ブランチ、ディレクトリの決定
3. po4a.cfgの作成
4. po4aコマンドの実行
5. 翻訳したドキュメントの確認

### po4aのインストール

Debian系であれば、`apt install po4a`でインストールします。

他には、エディターのpoモードを使えるようにしておくと便利でしょう。
Vim系やEmacs系にはpoモードがあります。

### 翻訳する作業ブランチ、ディレクトリの決定

後述する`po4a.cfg`ファイルを作るために、この段階で構想を練っておきます。

私の場合は、Gitを使っているので、`translation/japanese`ブランチを切って作業することにしました。
Pull Request(Merge Request)を必要としたり、他のブランチとの兼ね合いもあるかと思うので、ここは
作業する人と、共同作業するかどうか、upstreamとの関係性などで決まります。

作業ディレクトリをどうするかは、

1. 翻訳対象のドキュメントは何か?(どんな形式か?)
2. 翻訳対象のドキュメントはどこにあるか?
3. 翻訳結果のドキュメントはどうするか?(-jaのポストフィックスをつけたい?)
4. 翻訳結果のドキュメントはどこに出力したい?(ディレクトリの命名方法は?)

を考える必要がある。

#### 具体例

上記では、ピンとこないと思うので具体例として[Files · master · Salsa CI Team / Salsa CI pipeline · GitLab](https://salsa.debian.org/salsa-ci-team/pipeline)を使います。

このリポジトリにおいて翻訳して読みたいドキュメントは、リポジトリのトップにある、

- README.md
- RUNNERS.md
- STRUCTURE.md

の3つになる。翻訳作業ブランチは`tranlate/japanese`とする。

作業ディレクトリは、`translate`とし、po4a.cfgファイルを置くことにします。
`translate/po`には、poファイルを配置し、`translate/ja`には翻訳したmarkdownファイルを配置します。

#### 作業例

もとのGit repoをForkまたは、cloneしてローカルや他のGit repoサービスにpushするなどして、自分の作業用Git repoを作ります。

例としては、<https://salsa.debian.org:salsa-ci-tream/pipiline.git>をforkして、cloneし、upstramのリモートを追加します。
`git remote add upstream git@salsa.debian.org:salsa-ci-team/pipeline.git`

これで、originとupstramの2つのリポジトリを参照できます。upstreamの追従は、`git fetch upstram` してrebaseして追従します。

### po4a.cfgの作成

`po4a`コマンドを実行するのは、`translate`ディレクトリの中で実行する。`po4a.cfg`も`translate`ディレクトリに配置する。
また、poファイルから、翻訳結果は生成されるので、`translate`ディレクトリには.gitignoreを配置する。potファイルもgitで
管理する必要はないはず。

```text:.gitignore
ja/
*.pot
```

`po4a.cfg`ファイルを作る時に意識するのは、言語コード(jaなど)と、相対でのファイル指定です。

```text:po4a.cfg
[po4a_langs] ja
[po4a_paths] po/$master.pot $lang:po/$master.$lang.po
[type: text] ../README.md $lang:$lang/README-$lang.md pot=README
[type: text] ../RUNNERS.md $lang:$lang/RUNNERS-$lang.md pot=RUNNERS
[type: text] ../STRUCTURE.md $lang:$lang/STRUCTURE-$lang.md pot=STRUCTURE
```
最終的なファイル配置は下記のようになります。自分のシステムがja_JP.UTF8の場合$langはjaに変換されます。

```
ls -laR *.md
-rw-rw-r-- 1 yabuki yabuki 52664  9月 18 03:59 README.md
-rw-rw-r-- 1 yabuki yabuki  6961  9月 18 03:59 RUNNERS.md
-rw-rw-r-- 1 yabuki yabuki  7312  9月 18 03:59 STRUCTURE.md

ls -laR translate/
translate/:
合計 8
drwxrwxr-x 1 yabuki yabuki  42  9月 21 01:44 .
drwxrwxr-x 1 yabuki yabuki 620  9月 21 01:18 ..
-rw-rw-r-- 1 yabuki yabuki 200  9月 21 01:44 README.md
drwxrwxr-x 1 yabuki yabuki  80  9月 18 04:30 ja
drwxrwxr-x 1 yabuki yabuki 148  9月 21 01:44 po
-rw-rw-r-- 1 yabuki yabuki 271  9月 21 01:44 po4a.cfg
 
translate/ja:
合計 68
drwxrwxr-x 1 yabuki yabuki    80  9月 18 04:30 .
drwxrwxr-x 1 yabuki yabuki    42  9月 21 01:44 ..
-rw-rw-r-- 1 yabuki yabuki 53077  9月 18 06:32 README-ja.md
-rw-rw-r-- 1 yabuki yabuki  6964  9月 18 06:32 RUNNERS-ja.md
-rw-rw-r-- 1 yabuki yabuki  7320  9月 18 06:32 STRUCTURE-ja.md
 
translate/po:
合計 204
drwxrwxr-x 1 yabuki yabuki   148  9月 21 01:44 .
drwxrwxr-x 1 yabuki yabuki    42  9月 21 01:44 ..
-rw-rw-r-- 1 yabuki yabuki 79070  9月 21 01:44 README.ja.po
-rw-rw-r-- 1 yabuki yabuki 77393  9月 18 06:32 README.pot
-rw-rw-r-- 1 yabuki yabuki 10137  9月 21 01:44 RUNNERS.ja.po
-rw-rw-r-- 1 yabuki yabuki 10108  9月 18 06:32 RUNNERS.pot
-rw-rw-r-- 1 yabuki yabuki 10489  9月 21 01:44 STRUCTURE.ja.po
-rw-rw-r-- 1 yabuki yabuki 10460  9月 18 06:32 STRUCTURE.pot
```

`translate`ディレクトリのREADME.mdには、po4aに関する注意事項や翻訳関係の注意事項を書いておきます。

### po4aコマンドの実行

初回に、translateディレクトリで`po4a po4a.cfg`として実行すると、potファイルとja.poファイルが生成されます。
初回だと翻訳が存在しないので、翻訳結果は出力されません。

エディターで、README.ja.poを翻訳してみます。po4aコマンドは既定値では80%の翻訳が終わっていないと翻訳結果(README-ja.mdなど)を出力しません。
まずは一文翻訳して、`po4a -k0 po4a.cfg`と、-k(--keep)オプションで0%の翻訳率でも出力する指示をして中身を確認しましょう。

### 翻訳した中身の確認

`translate/ja`にあるファイルを確認します。あとはひたすら、ja.poファイルを翻訳して、うまく反映されているかを確認していくだけです。

## 参考文献

- [po4a - ようこそ](https://www.po4a.org/)
    - 本家、こまったらここ。
- [nginx をネタに po4a で翻訳管理を始めてみる例 #Gettext - Qiita](https://qiita.com/nabetaro/items/fe05e35b48dad3566a02)

## 謝辞

po4aを作った人、翻訳した人、po4a記事を書いた先人たちに謝辞を送ります。

## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-09-19|
|  記事を公開した日  |2025-09-21|
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

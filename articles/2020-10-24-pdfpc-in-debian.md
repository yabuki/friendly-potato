---
title: "pdfpcは、Debian GNU/Linux では、pdf-presenter-console で探せ。"
emoji: "🐈"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian, pdf, プレゼンテーション]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-10-24|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照せよ。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

# はじめに

pdfを使って、プレゼンテーションをするソフトウェアに、 [pdfpc/pdfpc: A presenter console with multi-monitor support for PDF files.](https://github.com/pdfpc/pdfpc) があります。このソフトウェアも Debian GNU/Linux には収録されているのですが、名前が説明的な名前になっています。

タイトルにあるように、pdf-presenter-console です。

コマンドの名前は、pdfpc で変わりません。

# install 方法

`apt install pdf-presenter-console` をrootかsudoを使って特権で実行してください。

# 使い方というか終了方法

終了の仕方は、ctrl+q です。操作する前に、man を読んだりして、操作に習熟しておくのをオススメします。

Enjoy!

# 昔の名前で出ています?

pdfpc の前身は、 pdf-presenter-console という名前でした。[jakobwesthoff/Pdf-Presenter-Console: A Keynote like presenter console with multi-monitor support and the ability to read PDF as input files.](https://github.com/jakobwesthoff/Pdf-Presenter-Console)に、その時のrepoが残っています。

Debian GNU/Linux における、pdf-presenter-console の更新状況は、 [Debian Package Tracker - pdf-presenter-console](https://tracker.debian.org/pkg/pdf-presenter-console) で確認ができます。

ここを見ると、パッケージ名は、昔の名前ですが、新しいコミットを適用しているのが確認できます。

下記は、想像でメンテナーに確認していないので想像で書きます。pdfpcというバイナリの名前は一緒だが、パッケージ名はより説明的な名前を選択したのだとおもいます。

Ubuntuなどの Debian からの派生プロジェクトにも、なにもなければ、このパッケージ名でインストールすることになると思いますので、一筆言上さしあげました。

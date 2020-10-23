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

下記は、メンテナーに確認していないので想像で書きます。pdfpcというバイナリの名前は一緒だが、パッケージ名はより説明的な名前を選択したのだとおもいます。

Ubuntuなどの Debian からの派生プロジェクトにも、なにもなければ、このパッケージ名でインストールすることになると思いますので、一筆言上さしあげました。

# 別解

下記のように、rootか、sudo で apt-file update 後に、一般ユーザーでpdfpc を含むファイルを探すことで、どのパッケージに、そのファイルが属しているかを調べることができます。

存外に喜ばしいのは、pdfpcのLaTeXスタイルがあることが分かったことです。これを使えばスライドの時間などの情報を指定できる模様です。あと動画埋め込みも。

```bash
$ apt-file search pdfpc
pdf-presenter-console: /etc/pdfpcrc
pdf-presenter-console: /usr/bin/pdfpc
pdf-presenter-console: /usr/share/man/man1/pdfpc.1.gz
pdf-presenter-console: /usr/share/man/man5/pdfpcrc.5.gz
pdf-presenter-console: /usr/share/pixmaps/pdfpc/blank.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/empty.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/eraser.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/hidden.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/highlight.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/linewidth.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/loaded.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/locked.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/move.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/pause.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/pdfpc.css
pdf-presenter-console: /usr/share/pixmaps/pdfpc/pen.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/saved.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/settings.svg
pdf-presenter-console: /usr/share/pixmaps/pdfpc/snow.svg
texlive-latex-extra: /usr/share/texlive/texmf-dist/tex/latex/pdfpc-movie/pdfpc-movie.sty
texlive-latex-extra: /usr/share/texlive/texmf-dist/tex/latex/pdfpc/pdfpc.sty
texlive-latex-extra-doc: /usr/share/doc/texlive-doc/latex/pdfpc-movie/README.md
texlive-latex-extra-doc: /usr/share/doc/texlive-doc/latex/pdfpc-movie/pdfpc-movie-doc.pdf
texlive-latex-extra-doc: /usr/share/doc/texlive-doc/latex/pdfpc/README.md
texlive-latex-extra-doc: /usr/share/doc/texlive-doc/latex/pdfpc/pdfpc-doc.pdf
texlive-latex-extra-doc: /usr/share/doc/texlive-doc/latex/pdfpc/pdfpc-doc.tex.gz
```

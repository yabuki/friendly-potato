---
title: "Linuxで自分の持っているEPUBファイルを修正する2024年11月版"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian,Linux,epub]
published: true
---
## 要約

Linuxで自分の持っているEPUBファイルの中身を書き換える方法を述べます。

## はじめに

電子書籍のフォーマットのひとつに、EPUBがあります。

EPUBには、規格があります。[EPUB 3.3](https://www.w3.org/TR/epub-33/)

大まかな導入として、EPUB3の特徴については、[JEPA｜日本電子出版協会 EPUB3とは？](https://www.jepa.or.jp/ebookpedia/201512_2781/)
などを参考にしてください。

2024-11-23 20:26追記:残念なことに、Kindleはルビタグを認識しても、アシスタントリーダーは参照して読んでくれませんでした。残念です。

### この記事を書いた動機

- 2024-11-27 下記の記事を読んだら、iPadならKindleで読み上げることができない電子書籍も読み上げることが可能なことを
知りました。
  - [積読を消化する技術 - sasasin’s blog](https://sasasin.hatenablog.com/entry/2024/11/04/190451)

Kindleの読み上げ機能を使って積ん読を解消する記事は世の中にいくつかあります。EPUBをKindleに送って読み上げてもらっていると
最新版では修正されいる誤植やOCRからEPUBにしている場合の文字化け、読み方の指示がないためにKindleの読み間違いがあると
気になるので、EPUBの中身を書き換えたくなります。

そのため、自分の使っているDebian GNU/LinuxでどうしたらEPUBの中身を書き換えられるかについて調べて、EPUBを修正し、Kindleに
送って読み上げてもらうまでを記しておきます。

### この記事はだれ向けか

Kindleに読み上げをさせて快適な読書をしたい人、かつComputerを使っている人。この記事ではDebian GNU/Linux Sidをベースに
話をしているが、他のOSの人でも参考になれば幸いです。

Debian GNU/Linux Sidは開発版なので、わりと新しいソフトウェアを利用できますが、開発者以外は安定版を使った方がいいかも
しれません。たまに起きるソフトウェアの更新に伴う不整合を手動で直す必要があるのでLinuxのスキルは伸びるのですが、人は選ぶでしょう。

### この記事の読み方

## 本文

1. 編集したいEPUBを用意する
2. Sigilをインストールする
3. Sigilの初期設定をする
4. EPUBを編集する
5. Send to Kindleでパーソナルドキュメントエリアに送り込む
6. 読み上げたい端末でダウンロードして内容を確認する

気がすむまで4から6を繰り返します。

### Sigilのインストールと初期設定

Debian GNU/Linuxで、Sigilを導入します。
`sudo apt intall sigil`

編集(E)→環境設定(F5)で環境設定のダイアログを出します。

![環境設定ダイアログ](<https://yabuki.github.io/friendly-potato/articles/images/2024-11-23_18-11.png> =600x)

変更点は、EPUBのversionを3に指定すること。次のセクションでPageEditを使うなら、エディターのパスを設定する事です。
SigilとPageEditをaptでいれるなら、画像と同じ設定にしてください。

### EPUBの編集

PageEditなしでもちょこちょこと変更はできます。OCRの誤認識由来の文字化けを訂正したり
ルビをつけるぐらいならなくても不便ではありません。

#### PageEdit

ちょこちょこ書き換えるのではく、がっつりと書き換えるのなら、PageEditを使ってみるのも良いでしょう。
`sudo apt install pageedit`

PageEditは、Sigilと同じ所が開発しているEPUBエディターです。(XHTMLエディターというべきか)

余談ですが、他にEPUBを生成するには下記の方法があります。

- markdownから*pandoc*を使ってEPUBを生成する方法がある。
- 他のOSで動くソフトウェアでは、ワードプロセッサーから変換するものがある。

Pandocについては、自分で書くドキュメントも読み上げ可能にできるので、試す時間があれば書きます。

### Kindleのパーソナルドキュメントエリアに送り込む

自分のマシンから、[Send to Kindle](https://www.amazon.co.jp/sendtokindle)にアクセスして、変更したEPUBファイルを
アップロードします。

私が試した限りでは、同じファイル名のEPUBに更新をかけるなら、[Amazon.co.jp: コンテンツと端末の管理](https://www.amazon.co.jp/hz/mycd/digital-console/contentlist/pdocs/dateDsc/)
でコンテンツを削除してからuploadして、再度端末にダウンロードしないと前のままを読み取るようです。

### コンテンツの内容確認

私の場合は、Android端末(スマホ・タブレット)なので、読み上げさせています。

## 参考文献

### Sigil

- [Sigil User Guide - Sigil-Ebook](https://sigil-ebook.com/sigil/guide/)
- [Download Sigil - Sigil-Ebook](https://sigil-ebook.com/sigil/download/)

- [Sigilの初心者向け使い方、電子書籍のEPUBの作成に最適！ | 定年後のスローライフブログ](https://yanai-ke.com/sigil/)

### PageEdit

- [What is PageEdit? - Sigil-Ebook](https://sigil-ebook.com/pageedit/)

### ルビを振る

- [HTMLでルビ（ふりがな）を振る：rubyタグの使い方](https://catnose.me/learning/html/ruby)

## さいごに

OCRに大量の処理をさせると、やはりぼつぽつと誤認識します。また本のレイアウトが複雑だと
狙った順番に文章が配置されるわけではないです。何度もKindleに読み上げさせるなら、修正した
い部分を変更できるとストレスがなくなります。

私は自分の手元にできるだけデータを置きたい人なので、Kindleの本を買うのよほどの時です。
頭の中に知識を定着させるのに、何度も読んだり聞いたりするこの手法は、コスパ・タイパが
悪いように見えて、実は血肉になっているのではないか。と密かに思っています。

あとは、読み上げた内容をmp3などにしたいのですが、よい方法ないですかね。

昔のTVの録音のように静かにしてタブレットの前で録音機器を動かすとかアナログにすぎる。
読み終わったら、録音も止めたいし。もちろん個人の利用範囲でやります。


|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2024-11-23|
|  記事を公開した日  |2024-11-23|
|  記事を変更した日  |2024-11-27|

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

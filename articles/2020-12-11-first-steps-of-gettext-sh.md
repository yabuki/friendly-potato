---
title: "シェルスクリプトでも、いろんな言語を表示したい! --- gettext.sh 最初の一歩"
emoji: "😽"
type: "tech"
topics: [gettext, shell, 翻訳, Unix, Linux] # 5つまで
published: true
---


## 要約

あなたのプログラムや文書をいろんな国のひとに使ってもらえる可能性が増える方法として国際化(i18n)[^i18n]がある。

[^i18n]: Internationalization つづりが長いので真ん中と最後の文字を18文字省略しているとの意味です。 see also [I18N(国際化対応) - MDN Web Docs 用語集: ウェブ関連用語の定義 | MDN](https://developer.mozilla.org/ja/docs/Glossary/I18N)]

身近に利益を感じてもらうため hello world レベルの shell スクリプトを gettext.sh 使って国際化する方法を書いている。

例題を試すための github repository も用意している。

## はじめに

シェルスクリプトは、多くのひとに使われています。とくに自分や他人のために自動化スクリプトを書いたひとはいるでしょう。

最近はありがたいことにUTF-8のシステムが増えて、日本語など英語以外の言語でも、コンピュータ上で表示しやすくなりました。

コンピュータ上で複数の言語を扱うにはいくつか方法があります。その中でメジャーな実装の1つが、gettextです。

<!-- @suppress DoubledJoshi -->
プログラマが新しく言語を覚えたいときはまず環境構築をします。その次に動作確認のためプログラマは儀式めいた慣習ですが コンソール(外部の世界)へ "hello world" を出力するプログラムを書くことがあります。この文章はそれにならって gettext の "hello world" を出力する shell script を例に文章を書きます。

gettext はプログラムが出力する言語を切り替えるために使われてきました。
現在では、[man po4a (1): PO ファイルと翻訳済みドキュメントを一括更新](http://ja.manpages.org/po4a) を使って文書の翻訳に使う例もあります。

技術文書のように頻繁に更新され翻訳が追いつかない部分は英語でいいから把握したいというニーズに応えます。^[ [nginx をネタに po4a で翻訳管理を始めてみる例 - Qiita](https://qiita.com/nabetaro/items/fe05e35b48dad3566a02)]

### この文章を書いた動機

最初「ssft はいいぞ」という文章を書きたかったのですが、その前提となる gettext.sh について自分にとってわかりやすい文章がなかったので書きました。
gettextを扱えるひとが増えて、より多くの優れたソフトウェアや技術文書が言語のカベを越えて流通することで自分もそれにあやかりたい。という動機です。

そして文書を書いて公開することで、より詳しい人からツッコミを入れてもらい自分の理解を深めるためです。

### この文章はだれ向けか

自分の書いたプログラムが、自分の母語を越えて利用されるプログラマ、または、自分の書いたプログラムを母語以外のひとにも使ってほしいプログラマ向けです。

すぐに使えるのは日常的にシェルスクリプトを書いている人で、複数の言語への対応をしたいと考えている人です。

例題はシェルスクリプトですが、gettext における作業手順について他のプログラム言語でgettextを扱うとき応用ができるように書きます。

### この文書の読み方

この文書は、読んだ人が手を動かして追体験ができるように、下記の順番で進めます。

比較的冗長に書くので、読者の側で分かっている部分については飛ばして読んで下さい。

具体的には、先に仕組みや説明を知りたいひとは実践している部分は飛ばして、背景を読んでから戻ってくるのもいいでしょう。

## 実践

1. Debian GNU/Linux 上での環境設定
1. gettext.sh の説明をして
1. リポジトリのクローンをして、プログラムが動くのを確認します。
1. その背景の説明をします。

### 環境設定

この文章を試すのに必要なパッケージは、

- gettext
- git

です。その他のプログラムはご自分でお好きに選んでください。Debian 標準は dash を sh として使っているのでdashを利用しますが、たぶんbashでも動くでしょう。

この記事を書いている時点(2020-12-13)で、私が利用しているのは、Debian GNU/Linux bullseye/sid です。gettextは充分に古いので、他の Unix 系でも何らかの方法でパッケージなどがあるでしょう。

私はすでにgettextをパッケージで導入していたので、gettext-base が入っていました。gettext.shがどのパッケージにあるのか確認する方法は下記です。

```
apt-file search gettext.sh
backup-manager: /usr/share/backup-manager/gettext.sh
fcitx-libs-dev: /usr/share/cmake/fcitx/fcitx-extract-gettext.sh
gettext-base: /usr/bin/gettext.sh
```

なので、

```
dpkg -l gettext*
要望=(U)不明/(I)インストール/(R)削除/(P)完全削除/(H)保持
| 状態=(N)無/(I)インストール済/(C)設定/(U)展開/(F)設定失敗/(H)半インストール/(W)トリガ待ち/(T)トリガ保留
|/ エラー?=(空欄)無/(R)要再インストール (状態,エラーの大文字=異常)
||/ 名前           バージョン   アーキテクチ 説明
+++-==============-============-============-======================================================
ii  gettext        0.19.8.1-10  amd64        GNU Internationalization utilities
ii  gettext-base   0.19.8.1-10  amd64        GNU Internationalization utilities for the base system
ii  gettext-doc    0.19.8.1-10  all          Documentation for GNU gettext
```

を参考に入れて下さい。ドキュメントはお好みで offline でも参照できる文書が欲しい派なのでわたしは入れています。

### サンプルの導入

<!-- @suppress SentenceLength -->
[yabuki/gettext-sandbox: This is a sandbox which is test for gettext with program.](https://github.com/yabuki/gettext-sandbox) を git clone してください。

#### ディレクトリ構成

```
/(repository root)
- LICENSE
- README.md (This file)
+ dash
  - README.md (Test environment building guide)
  + gettext.sh
    - hello.mo
    - hello.sh
    - messages.po
    - messages-1.po
    - messages-2.po
    - ja.po
    + locale
      + ja
        + LC_MESSAGES
          - hello.mo
```

message.po に枝番をつけたファイルは、初期に `xgettext` コマンドが生成したものを1、msginit コマンドが生成したものを2という風に変化を見るべく置いていました。

### サンプルの実行

git clone した所から、cd dash/gettest.sh へ移動して、`dash ./hello.sh` と実行してください。

私の環境では、

```
$ dash ./hello.sh 
こんにちは世界
こんにちは世界
```

と、表示されます。LANGが、ja_JP.UTF-8に設定してあるからです。

それでは、`LANG=C dash ./hello.sh`を実行してください。

```
LANG=C dash ./hello.sh 
Hello World
Hello World
```

と表示されているでしょうか。日本語がUTF-8でない環境の人は、異なるエンコードでファイルを作成してみるのもいいでしょう。

また、日本語と英語以外を追加してみるのもいいでしょう。

### プログラムの説明

プログラムそれ自体は、いわゆる "Hello World"プログラムなので簡単です。その前の各種設定についての説明が主体となります。

2023-01-20にgettextを生で使うのから、eval_gettextを使うようにサンプルを変更した。コメントで指摘していただきありがとう
ございました。おかげで私の理解が進みました。

```sh:hello.sh
     1 #!/bin/dash -x
     2 
     3 # 下記をやる
     4 . gettext.sh
     5 
     6 # TEXTDOMAIN=@PACKAGE@
     7 TEXTDOMAIN=hello
     8 export TEXTDOMAIN
     9 # TEXTDOMAINDIR=/home/yabuki/lib/locale
    10 TEXTDOMAINDIR=`pwd`/locale
    11 export TEXTDOMAINDIR
    12 
    13 eval_gettext "Hello World"; echo
    14 echo "`eval_gettext "Hello World"`"
```

- 1行め 実行内容をトレースしながら動け
- 4行め おまじない
- 7行め 実行プログラム名などを入れる。翻訳の入ったmoファイル名でもあります。
- 10行め どこにmoファイルを置くlocaleディレクトリが存在しているか。を **絶対ディレクトリ**で指定します。相対ではダメです。`pwd`コマンドが効いてきます。
- 13行め eval_gettext に文字を渡して、翻訳した結果を受け取ります。echoで改行してます。
- 14行め echo を先に書きたい派の人はこっちを使います。この段階では、13行めと14行めの書き方は好みの範囲です。変数が関係するとエスケープの個数を変化させる必要があります。しかし、いまはこれ以上踏み込みません。

ここまでで、やりたいことの半分が達成できました。

後の半分は、ご自分で別のサンプルプログラムを作って実践をお願いします。

## po ファイル作成手順

1. xgettext コマンドで、shell scriptから、翻訳すべき文字列を取り出す。指定がなければ message.po ファイルを生成する。
1. msginit コマンドで、ロケール情報、扱う文字列のエンコード情報などの情報をあたえて、日本語で指定がないなら、ja.po ファイルを生成する。
1. 好きなエディタで、poファイルを編集する。
1. 翻訳ができあがったら msgfmt コマンドで mo ファイルを生成します。その時ファイル名はTEXTDOMAINと合わせること。
1. moファイルができたらつぎのようにします。
1. TEXTDIMAINDIRで指定されている`pwd`/localeを起点として、ja(地域と同じ)のディレクトリ配下にLC_MESSAGESのディレクトリがあることを確認します。英語圏ならjaの代わりにenです。フランス語ならfrです。同一地域で複数言語ならbn_ID,bn_BDになるのでしょう。en@arabicのような表記については不勉強なのですいませんがわかりません。
1. `pwd`/local/ja/LC_MESSAGES/ファイルをコピーします。

プログラムを作っているプロジェクトの構成に応じて、もっと柔軟に変更できる例を出すことができるといいのですが。

<!-- @suppress DoubledJoshi JapaneseStyle -->
プログラムを開発していくと表示するメッセージが増えたり、減ったりするのも普通にあります。また対象となるプログラムファイルが単一だとも限りません。

上記については別の機会に書きたいです。いまでも充分長い文章なので。他のひとが書いてくれるかも知れないし:-)

## 背景

### gettext とは

gettextとはロケール(Locale)にしたがって、日本語、英語など複数の言語を表示するしくみです。Unix系のOSであれば、localeにしたがって画面に表示する文字を切り替えることができます。

身近な所でお使いのターミナルで、`echo $LANG` を実行してください。わたしの環境では、下記のように表示します。(Debian GNU/Linux Sid, bash)

```
$ echo $LANG
ja_JP.UTF-8
```

いま見てもらったのは、端末(Terminal)で、日本語入力や表示をする仕組みの一部です。

書いたプログラムに gettext を適用し、先ほど見た LANG 環境変数によって表示する文字列を切り替えます。英語から日本語のように。ちなみに、先ほどのLANGにCを代入することで、一時的に文字列を英語にして、プログラムでパースしやすくするというテクニックをご存知のひとも多いでしょう。

日本語を扱う[^1]場合には、最近のUnix系システムでは、UTF-8というエンコード[^2]を使っています。なので、日本という地域の日本語をUTF-8エンコードで扱います。という宣言をしています。

地域によっては、小数点が dot だけでなく comma のことがあります。また数字の区切りが3桁や4桁、それ以外など異なっています。このように元が同じデータであっても、その地域に応じた表示を必要とします。

gettext は、そのうち表示文字について翻訳する部分を担当しています。

<!-- @suppress DoubledJoshi -->
gettext を使ってプログラム作成から翻訳を入れ、表示する文字を切り替える一連の作業は、技術者の間では、 gettextize と呼びます。

技術者の間では、会話の情報密度をあげるのに複数のことがらを1つにまとめる言葉を専門用語として使っていることがあります。

<!-- @suppress SentenceLength -->
[^1]: 細かい話をすると、そこには何が入るのかについて、IETF言語タグの話 [IETF language tag - Wikipedia](https://en.wikipedia.org/wiki/IETF_language_tag) とか ISO 639-1 の話や言語コード毎にジャンプできる [ISO 639-3 - Wikipedia](https://en.wikipedia.org/wiki/ISO_639-3) の話をする必要があるのかもしれませんが、ここはふんわりとした理解でまずは慣れよう。という記事です。
[^2]: 文字コードの符号化について、エンコードも説明する必要があるかも知れないが、符号化以上にもろもろをコンパクトに説明するほど理解できていないので、他の本や文書を参照してほしい。

### gettext を使う手順

1. gettextを適用するオリジナルのプログラムを作ったり、見つけて改変します。どのように改変するかは、後述します。
1. xgettext コマンドで翻訳対象とする文字列が入ったファイル、(指示をしなければ)message.poファイルを作成する
1. msginit コマンドで前述のmessage.poファイルを入力とし、コマンドラインから取得した情報を入れてja.poなどのファイルとして出力します。[^3]このプログラムを使うと手で書く部分が減って間違いが減ります。
1. ja.poを慣れているエディタで開いて翻訳します。多くのエディタ(vimやEmacsなど)はpoファイルを編集するのに便利な機能を提供しています。余裕があれば調べておくと良いでしょう。
<!-- @suppress DobuleJoshi -->
1. 人間が読みやすい ja.po ファイルから、msgfmt コマンドを用いて、gettextプログラムが扱いやすい moファイル形式へ変更します。
1. 生成された、既定のファイルをプログラムが読み取る場所にコピーします。

<!-- @suppress SentenceLength -->
[^3]: ja.po ファイルって、確かに日本語の翻訳ファイル名ということで納得していました。が、msginit に `--locale=ja_JP.UTF-8`を与えることで、`ja_JP.UTF-8`が Tokenize されて、ja.poのファイルないに展開され、出力ファイル名も日本の地域=jaを表すファイルが生成されて、納得度が高まりました。

### shell script における gettext 対象

プログラムの説明でもでてきた gettext "foo" の foo が翻訳対象になり、LANGの値によって書き換わります。

### xgettext コマンド

対象とするブログラム(po4aの場合は文書)内の文字列をスキャンして、指定がないときは、 messages.po を生成します。プログラムの開発が進むと表示すべき文字列の増減や変更はしばしばあります。

<!-- @suppress SuggestExpression -->
その変更に追従するため gettextコマンドを実行する必要があります。そうやって翻訳内容を追従させるのです。

必要に応じて `man 1 xgettext` を参考にしてください。いくつか書く必要があるオプションを書き出します。

<!-- @suppress DoubledJoshi CommaNumber SentenceLength ParenthesizedSentence -->
- -L または --language オプション 今回の場合なら -L "shell"を渡します。(C, C++, ObjectiveC, PO, Shell, Python, Lisp, EmacsLisp, librep, Scheme, Smalltalk, Java, JavaProperties, C#, awk, YCP, Tcl, Perl, PHP, GCC-source, NXStringTable, RST, Glade,  Lua, JavaScript, Vala, Desktop) が対象のもようです。これは man からの引用なので、ソースコードは確認していません。
<!-- @suppress SuccessiveSentence -->
- 入力ファイルやディレクトリを指定するオプション
- 出力ファイルやディレクトリを指定するオプション。とりわけdefault-domainはそのプログラム名、またはプロジェクト名の概念なので、インターネットのドメインと取り違えないように。
- 既存のファイルに追加する -j --joinexisting
- TAGという概念 (調べて書く必要がある)
- コメント どのように使うかは例示がいるか。
<!-- @suppress ParenthesizedSentence -->
- --check でunicodeの妥当性チェック (ellipsis-unicode, space-ellipsis, quote-unicode, bullet-unicode)
- --copyright-holder=STRING poファイルの翻訳をした著作権者を書く(著作の管理に関する事項です)
- --foreign-user omit FSF copyright in output for foreign user
- --package-name=PACKAGE set package name in output
- --package-version=VERSION set package version in output
- --msgid-bugs-address=EMAIL@ADDRESS set report address for msgid bugs msgidに不具合があったときの連絡メールアドレスを設定する。

パッケージの概念や、バージョニングの概念自体はどういう風にするかは裁量があるのだろう。

翻訳による著作権の話は発生する。とだけ書いて済ましたい。プログラミングから翻訳まで全部同一人物でやるなら、なんら問題はない。

<!-- @suppress SuggestExpression -->
問題となる前に対処して置くのがいいでしょう。具体的には翻訳結果も取りまとめて管理するか、 翻訳はすべてソースコードと矛盾しないオープンソースなライセンスにするなどです。

### msginit コマンド

`man 1 msginit` を読もう。

### msgfmt コマンド

`man 1 msgfmt` を読もう。

## 参考にしたドキュメントたち

- [GNU gettext utilities: Preparing Shell Scripts](https://ayatakesi.github.io/gettext/0.18.3/html/Preparing-Shell-Scripts.html)
  - 同じドキュメントは、Debianのgettext-docパッケージをインストールすると、/usr/share/doc/gettext-doc/gettext_15.html で読むことができます。Offlineで集中したい人は、あらかじめパッケージをインストールして、お好きなブラウザで、ローカルファイルを指定して読んでください。
- [GNU gettext utilities: Preparing Strings](https://ayatakesi.github.io/gettext/0.18.3/html/Preparing-Strings.html#Preparing-Strings)
<!-- @suppress DoubledJoshi JapaneseAmbiguousNounConjunction -->
- [gettext API - Oracle Solaris でのアプリケーションの国際化とローカライズ](https://docs.oracle.com/cd/E56342_01/html/E54072/gnkbn.html)
<!-- @suppress DoubledJoshi -->
- [gettext のコマンドラインツールを使おう: SuperTuxKart を例に - Qiita](https://qiita.com/okano_t/items/da2ba18a65f46b31b699)
- `man 1 xgettext`
- `man 1 msginit`
- `man 1 msgfmt`

## 謝辞

下記の「参考にしたドキュメントたち」を読んで、試しながらこの文章と、試した結果を手元でも再現できるリポジトリを作りました。gettextを
shellで使えるように整備してもらい、この文章ができました。ありがとうございます。

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-12-11|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

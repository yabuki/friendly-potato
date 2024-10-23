---
title: "erbに関する私的メモ"
emoji: "📚"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [erb, ruby, Debian]
published: true
---

## 要約

自分の使いやすいテンプレートエンジンを求めて、このメモを残します。

## はじめに

### この文章を書いた動機

dotfilesの管理プログラムに、[TheLocehiliosan/yadm: Yet Another Dotfiles Manager](https://github.com/TheLocehiliosan/yadm) というプログラムがある。このプログラムには、templateと呼ばれる機能があり、呼び出されたOS, マシン名、 クラス(自分で定義できるスキーマみたいなの), ユーザ名、 distroなどを受け取って、テンプレート展開できる。 see [Templates - yadm](https://yadm.io/docs/templates#) これを使うと、dotfilesをsymbolic linkで作っていると実行可能なファイルは自分で動的に切り替えられるが、そうでないファイルは編集し回らないといけない手間が減る。

現在yadmは、素朴なawkによる実装、esh(shで作られた、テンプレートエンジン), j2cli(pythonのjinja2), envtplをサポートしている。どれをメインで使うのがいいのか、それともerbを使うのがいいのかを判断する一助として本文章を書いている。主に自分のためであり、動的に設定ファイルを生成したい時にこの文章を見ることになろう。

### この文章はだれ向けか

主に自分、erbに興味を持っている人。動的に設定ファイルを作る方法について興味がある人

### この文書の読み方

この文書は、本文だけだと意味がわからないと思うので、必要に応じて動機なども確認してください。

## 本文

### sample

下記はサンプルを改変して、yadmで使ったときに便利そうな書き方を試している。

yadm標準だと、distro名はとれるが、versionはとれないが、マシン名はとれるので、case when句で、複数のマシン名で処理をくくれるのは、素朴なawk実装だと面倒くさい。
yadmのドキュメントにもあるが、shell scriptや ~/.vimrcなど実行して評価される系のやつはこんな仕掛けは必要なく、自分で分岐したらいい。

でも、~/.Xresourceなどに画面スケールを埋める場合は、使っているマシン毎に変えたくなる部分がでるだろう。

知見がたまったら、また書く。programの中のヒアドキュメントとして使われる例が多数だが、テンプレート展開として、こう使うといいみたいのができるといいな。

```erb

<? xml version="1.0" ?>
<%# コメントだよ %>
<% user = ENV["USER"] %>
<% require 'prime' -%>
<erb-example>
  <calc><%= 1+1 %></calc>
  <var><%= __FILE__ %></var>
  <library><%= Prime.each(10).to_a.join(", ") %></library>
  <% if user == "yabuki" %> hello yabuki <% else %> hello you <% end %>
  <% case user
  when "yabuki" then %>
hello yabuki
  <% when "yukiharu" %>
hello yukiharu
  <% else %>
hello you
  <% end %>
  <% machine = `hostname`.chomp %>
  <%= $?.to_s %>
  <%= machine %>
  <% case machine
  when "Orlanth", "Odayla" %>
you are in Debian/Sid.
  <% else %>
you are in Debian/Buster.
  <% end %>

</erb-example>
```

下記のように実行する。
`erb -T -  examples.erb`

```
<? xml version="1.0" ?>


<erb-example>
  <calc>2</calc>
  <var>examples.erb</var>
  <library>2, 3, 5, 7</library>
   hello yabuki 
  
hello yabuki
  
  
  pid 3878586 exit 0
  Orlanth
  
you are in Debian/Sid.
  

</erb-example>

```

空白行ができる件については、設定ファイルなら問題にならないこともあるので、問題にぶつかるまでは放置。erb -Tオプションと、その使い方かなぁ。コメント書くと空白行が増えるのはいまいちだけど。あと、これは自動生成だから、yadm.sourceを触れというのもいるな。

erbには、まだまだわかっていないことがあって `<%`でなく `%` で始まるのは、どこでどう有効なのかとか。 -Tオプションの使い方とか。わかったら追記していこう

## 参考にしたドキュメントたち

- [標準添付ライブラリ紹介 【第 10 回】 ERB](https://magazine.rubyist.net/articles/0017/0017-BundledLibraries.html)
  - 昔、西山さんが書いていた、この記事から芋づる式にオンラインで引っ掛けることができる文章を読むことにする。
  - [ERB](http://www.druby.org/ilikeruby/erb.html)
  - [the erb way](http://www.druby.org/ilikeruby/erbway.html)
  - [ERB More](http://www.druby.org/ilikeruby/erbmore.html)

- [class ERB - Documentation for Ruby 2.6.0](https://docs.ruby-lang.org/en/2.6.0/ERB.html)
  - 2021-06-19現在、Debian sidのruby versionは `ruby 2.7.3p183 (2021-04-05 revision 6847ee089d) [x86_64-linux-gnu]` であり、最も近そうなバージョンのドキュメントを参照した。

- [Rubyでヒアドキュメントを使う - Qiita](https://qiita.com/mogulla3/items/3e114e9c4697f0dea84c)
  - `<<-`(ハイフン) の記法の読み方がよく分からなかったので、'ruby here document' でヒットした、この記事で、`<<-`の意味を知った。
  - [リテラル (Ruby 2.6.0 リファレンスマニュアル)](https://docs.ruby-lang.org/ja/2.6.0/doc/spec=2fliteral.html#here)上記で、言葉がわかったので、ここのヒア・ドキュメントも参照して、答え合わせをする。
  - `<<~`(チルダ) を使うと、`.gsub(/^  /, '')` とか `.gsub(/^ */, "")` の処理はいらなくなっているのでは。
- [ERB and the case statement](https://gist.github.com/davidphasson/91613)
  - ERBで、case whenは、このように書け。というのは、このgistで学んだ。

### 関連するかも知れないドキュメントたち

- [k0kubun/mruby-erb: Direct port of ERB from CRuby -&gt; MRuby](https://github.com/k0kubun/mruby-erb)
  - mrubyでのcrubyからの移植

- [itamae-kitchen/mitamae: mitamae is a fast, simple, and single-binary configuration management tool with a DSL like Chef](https://github.com/itamae-kitchen/mitamae)
  - ドキュメントを読むとわかるが、mitamaeは、erbも使える模様です。
  - see also [Dockerコンテナでの設定ファイル生成にテンプレートとしてERBを使う - Qiita](https://qiita.com/nowlinuxing/items/6109fb0c153c3cd91cfa)
    - この記事内で、mruby単体だとerbが使えないので、mitamaeを使っていると解説している。busybox的というか、kitchen sinkアプローチというか。相対的に小さい単体のバイナリは便利だねメソッド。

## 謝辞

erb作者、そして、erb周辺のドキュメントを整備していただいている方々に。

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-06-19|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

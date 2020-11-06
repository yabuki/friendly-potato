---
title: "vimでできるだけ簡単に文章校正ツールのRedpenを使う設定"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [vim, Redpen, 文章校正]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-11-06|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために、書き手が載せたものであり、詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照せよ。

記事に対するTypoの指摘などは、pull reqをしてもらえると嬉しい。受け入れるかどうかは、差分とPull reqの文章で判断します。

# 謝辞

この記事は、vim の slack で教えて頂いた内容をまとめております。助言を頂いた方々に感謝をいたします。

# はじめに

VOoM などの、アウトライナーを使って文章を作っていると、Redpenなどの文章校正ツールが使いたくなってきます。textlintなどの他のツールもありますが、
Redpenには、この手の文章がなかったので書いておきます。

# 対象となる Redpen のバージョン

[Release Release 1.10.4 · redpen-cc/redpen](https://github.com/redpen-cc/redpen/releases/tag/redpen-1.10.4) を使っています。これ以前だとジャンプに必要な情報がたりないかと思います。

install方法は、ドキュメントを読んでください。私の場合は、openjdkをいれているので、ダウンロードして実行場所にpathを通しただけで動いています。`redpen-distribution-1.10.4/bin`の下ですね。

# 対象となるvim/nvimのバージョン

特に、依存はないと思います。

# ~/.vimrc に追加する内容

```
"
" Redpen
"
augroup RedpenSettings
    "autocmd FileType {redpen_filetype} :setlocal makeprg=redpen\ %
    "autocmd FileType {redpen_filetype} :setlocal errorformat=%f:%l:\ Validation%t%*[a-z]%m\ at\ line:%.\\*
    autocmd FileType changelog let &l:makeprg='redpen %'
    autocmd Filetype changelog let &l:errorformat = '%f:%l: Validation%t%*[a-z]%m at line:%.\*'
augroup END

`{redpen_filetype}` の部分は、例のように、自分が校正するファイルのファイルタイプを指定してください。`echo &filetype` で、今開いているファイルのファイルタイプを確認できます。

```

# Redpen を動かす方法

`:make`

 で、redpenを起動してください。makeprgで置き換えています。結果は、`:cNext` などのquickfixを移動する方法でお願いします。人によってバインドがちがうでしょうし。この表記で。

# おわりに

この設定をすると、文章校正が楽になります。


別解としては、[mattn/efm-langserver: General purpose Language Server](https://github.com/mattn/efm-langserver) を使うという手もあるかと思います。

P.S. autocmd の :setlocal は、&l: と等価であり、エスケープの部分が楽になるという知見も得ました。

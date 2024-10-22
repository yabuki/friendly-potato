---
title: "vimでできるだけ簡単に文章校正ツールのRedpenを使う設定"
emoji: "✨"
type: "tech"
topics: [vim,Redpen,文章校正]
published: true
---

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2020-11-06|
|記事を変更した日|2024-10-23|

上記はこの記事の鮮度を判断する一助のために書き手が載せたものです。詳細な変更履歴は [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

## 謝辞

この記事は、vimのslackで教えて頂いた内容をまとめております。助言を頂いた方々に感謝をいたします。

## はじめに

<!-- @suppress  -->
VOoMなどの、アウトライナを使って文章を作っていると、Redpenなどの文章校正ツールが使いたくなってきます。^[Redpenの他にtextlint,prhなどのツールもあります。この文章は校正ツール比較に対して対象範囲外です。これ以上言及しません。誰か包括的な比較文書を書いてくれるといいのですが。]

私の知る限りでは、vimで簡単にRedpenを使い始める文章が見つけられなかったので書いておきます。

## 対象となるRedpenのバージョン

[Release Release 1.10.4 · redpen-cc/redpen](https://github.com/redpen-cc/redpen/releases/tag/redpen-1.10.4) を使っています。これ以前だとジャンプに必要な情報が足りないかと思います。

Installする方法は、ドキュメントを読んでください。私の場合は、openjdkをいれているので、ダウンロードして実行場所にpathを通しただけで動いています。`redpen-distribution-1.10.4/bin`の下ですね。

## 対象となるvim/nvimのバージョン

特に、依存はないと思います。

<!-- @suppress -->
## ~/.vimrcに追加する内容

<!-- @suppress -->
 ~/.vimrc に下記を追加してください。

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
```

`{redpen_filetype}` の部分は、例のように、自分が校正するファイルのファイルタイプを指定してください。`echo &filetype` で、今開いているファイルのファイルタイプを確認できます。

## Redpenを動かす方法

`:make`

 で、redpenを起動してください。makeprgで置き換えています。

結果は、`:cNext` などのquickfixを移動する方法でお願いします。人によって割り当て先のキー・バインドがちがうでしょうし。この表記で。

## おわりに

この設定をすると、文章校正が楽になります。

別解としては、[mattn/efm-langserver: General purpose Language Server](https://github.com/mattn/efm-langserver) を使うという手もあるかと思います。

P.S. autocmd の :setlocal は、&l: と等価であり、エスケープの部分が楽になるという知見も得ました。

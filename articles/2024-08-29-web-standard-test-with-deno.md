---
title: "Denoでやる「web標準のバックエンドアプリのテスト」の記事"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Deno, Web, TypeScript, JavaScript]
published: true
---

## 要約

yusukebeさんの [Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)の記事をdenoで
やっています。

## はじめに

かなり長い間、zennに記事を書いてないので、もっと気軽に記事を出してみるテスト。

### この文章を書いた動機

他のプログラミング言語でプログラムを書いた経験はある人であっても、typescriptでプログラミング
を始めるには、私はちょっとめんどくさいと思っています。

具体的には、その時々で選べるツールがおおく、気持ちよくプログラミングを開始する環境設定に手間取る所です。

Denoならlinter/formater/test/LSPが全部ついてきて、サクっとコードを書いてtypescriptを学習するのに便利なんで、 私はDenoを好んでいます。
Denoいろいろと野心的な取り組みをしているので、同じtypescriptでも他の方法で書いてあることを読み替えて実行しないといけないのがあります。
Denoでのやりかたをわかっていないとまごつくので、その試行錯誤の記録を書いておくのが良いと判断しました。

JS/TSの開発環境は、流れが早いので、2024-08-29時点でのスナップショットになります。

### この文章はだれ向けか

他言語から、TypeScriptの環境でWeb開発、テストについて興味がありDenoを使ってみようと思っている人が対象です。

### この文書の読み方

元文書のyusukebeさんの[Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)を読んでいること。
あとは、そんなに長くしないので、サクッとざっくり読み下しておいてください。

## 本文

zennのトレンドに、yusukebeさんの[Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)が投稿されていたので、記事を読みながら、Denoでやるとどうするのか。実際に手を動かしてみました。

元記事は、Denoでも対応しているということで、コピペして実行してみる。

最初の部分は当たり前だが、Denoへの言及もあり、そのままコピペしても動きます。

### 提示されている「最小限のテスト」をどう実行するか

- <https://zenn.dev/yusukebe/articles/9a6335ed793c43#%E6%9C%80%E5%B0%8F%E9%99%90%E3%81%AE%E3%83%86%E3%82%B9%E3%83%88>

ここからは、bunを例にしてあるので、denoだとちょっと読み替えが必要になる。

ユニットテストのファイル名の命名方法はdenoでも、そのままでも良い。

```ts
import app from './index'

describe('Testing My App', () => {
  it('Should return 200 response', () => {
    const res = app.fetch()
    expect(res.status).toBe(200)
  })
})
```

上記のプログラムをこのまま、`deno test src/index.test.ts`とすると、下記のエラーになる。

1. import app from './index' に拡張子がない
2. describeやexpectが見つからない。

とか指摘される。

#### 拡張子がない

拡張子がないことは、拡張子なくても実行できるように
`deno test src/index.test.ts --unstable-sloppy-imports`
で回避する方法もある。拡張子を付ける方法もあるかも知れないが、bunやnodejsの作法がいまいち分かってないので、ひとまずこれで。

#### BDDなキーワードがみつからない

describeやexpect、後から出てくるitなどはdenoは親切に下記のメッセージがでます。

```
error: TS2582 [ERROR]: Cannot find name 'describe'. Do you need to install type definitions for a test runner? Try `npm i --save-dev @types/jest` or `npm i --save-dev @types/mocha`.
describe('Testing My App', () => {
~~~~~~~~
    at file:///home/yabuki/scm/git/etude-deno/web-standard-test/src/index.test.ts:3:1

TS2582 [ERROR]: Cannot find name 'it'. Do you need to install type definitions for a test runner? Try `npm i --save-dev @types/jest` or `npm i --save-dev @types/mocha`.
  it('Should return 200 response', () => {
  ~~
    at file:///home/yabuki/scm/git/etude-deno/web-standard-test/src/index.test.ts:4:3

TS2304 [ERROR]: Cannot find name 'expect'.
    expect(res.status).toBe(200)
    ~~~~~~
    at file:///home/yabuki/scm/git/etude-deno/web-standard-test/src/index.test.ts:6:5
```

のように、色々と教えてくれるが、ここでは、denoが推している新しいレジストリーのJSRを使ってみる。
denoのstdライブラリを使い、BDDをやってみる。

もちろん、人によってはjestやmochaを使う人もいるだろう。

テストの行頭に下記の行を追加します。

```ts
import { describe, it } from "jsr:@std/testing/bdd";
import { expect } from "jsr:@std/expect";
```

そして、`deno test src/index.test.ts --unstable-sloppy-imports`
を実行してください。

これで、denoでも、記事を参考にテストを実行していくことができるようになりました。

では、楽しんでください。

## 参考にしたドキュメントたち

- [Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)
- [Testing](https://docs.deno.com/runtime/fundamentals/testing/#behavior-driven-development)
  - docs.deno.comにあるBDDについての文書

## 謝辞

下記の方々に感謝します。

元記事のyusukebeさん。
[fix: bdd testing example by kt3k · Pull Request #760 · denoland/docs](https://github.com/denoland/docs/pull/760)
をfixしてくれたkt3kさん。

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-08-29|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

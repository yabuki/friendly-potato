---
title: "Denoでやるweb標準のバックエンドアプリのテストの記事"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Deno, Web]
published: true
---
# 要約

yusukebeさんの [Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)の記事をdenoで
やってみる記事

# はじめに

かなり長い間、zennに記事を書いてないので、もっと気軽に記事を出してみるテスト。

## この文章を書いた動機

他言語の経験はあっても、typescriptは環境を作って維持していくのがちょっと敷居があって、denoなら
linter/formater/test/LSPが全部ついてきて、サクっとコードを書いて学習するのに便利なんで、
私はDenoを使っています。

いろいろと野心的な取り組みをしているので、他の方法で書いてあることを読み替えて実行しないと
いけないのが、作法が分かってない段階だとまごつくので、その記録を書いておくのが良いと
判断しました。

JS/TSの開発環境は、流れが早いので、2024-08-29時点でのスナップショットになります。

## この文章はだれ向けか

他言語から、TypeScriptの環境でWeb開発、テストについて興味がありDenoを使ってみようと
思っている人

## この文書の読み方

元文書のyusukebeさんの[Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)を読んでいること
あとは、そんなに長くしないので、サクッとざっくり読み下しておいてください。

# 本文

zennのトレンドに、yusukebeさんの[Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)が
上がっていたので中身を読みながら、denoでやるとどうするのか。手を動かしてみた。

denoでも対応しているということで、コピペして実行してみる。最初は、当たり前だが、denoへの
言及もあり、なにも考えずに動く。

## 最小限のテスト

- <https://zenn.dev/yusukebe/articles/9a6335ed793c43#%E6%9C%80%E5%B0%8F%E9%99%90%E3%81%AE%E3%83%86%E3%82%B9%E3%83%88>

ここからは、bunを例にしてあるので、denoだとちょっと読み替えが必要になる。

ユニットテストのファイル名の命名方法などはそのままでもいいが

```ts
import app from './index'

describe('Testing My App', () => {
  it('Should return 200 response', () => {
    const res = app.fetch()
    expect(res.status).toBe(200)
  })
})
```

が与えられている。これをこのまま、`deno test src/index.test.ts`とすると、エラーになる。

1. import app from './index' に拡張子がない
2. describeやexpectが見つからない。

とか指摘される。

### 拡張子がない

拡張子がないことは、拡張子なくても実行できるように
`deno test src/index.test.ts --unstable-sloppy-imports`
で回避する方法もある。拡張子を付ける方法もあるかも知れないが、bunやnodejsの作法が
いまいち分かってないので、ひとまずこれで。

### BDDなキーワードがみつからない

describeやexpect、後から出てくるitなどは denoは親切にも
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

のように、色々と教えてくれるが、ここでは、新しいレジストリーのJSRを使ってみる。
もちろん、人によってはjestやmochaを使う人もいるだろう。

テストの行頭に、

```ts
import { describe, it } from "jsr:@std/testing/bdd";
import { expect } from "jsr:@std/expect";
```

を追加して、`deno test src/index.test.ts --unstable-sloppy-imports`
を実行してみてほしい。

これで、denoでも、記事を参考にテストを実行していくことができるようになったと思う。

では、楽しんでください。

# 参考にしたドキュメントたち

- [Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)
- [Testing](https://docs.deno.com/runtime/fundamentals/testing/#behavior-driven-development)
    - docs.deno.comにあるBDDについての文書

# 謝辞

元記事のyusukebeさんと、
[fix: bdd testing example by kt3k · Pull Request #760 · denoland/docs](https://github.com/denoland/docs/pull/760)
をfixしてくれたkt3kさん

# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-08-29|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
    <!-- 読み手に何の情報を伝えるのか -->
    <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

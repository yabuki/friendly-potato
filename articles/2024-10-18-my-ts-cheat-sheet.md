---
title: "自分向けTSのチートシート"
emoji: "🦔"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [TypeScript, JavaScript]
published: false
---
## 要約

自分向けのTypeScriptとJavaScriptのCheat Sheet

## はじめに

### この文章を書いた動機

### この文章はだれ向けか

自分向け

### この文書の読み方

## 本文

### 関数

成立は、関数定義、関数式、Arrow Function(ES2005)の順で、表記と逆順を意識している。
Arrow Functionはshort handで記述できるので、2024年現在よく見かける。

関数式、Arrow Functionで関数名を省略した場合、匿名関数または無名関数と呼ぶ。

- Arrow Function
  - 関数式で関数を生成して変数に代入する発展形
  - thisの意味合いが違ってくる

```Typescript
// 仮引数の数と定義
const fnA = () => { /* 仮引数が0個のとき */ };
const fnB = (x) => { /* 仮引数が1個のとき */ };
const fnC = x => { /* 仮引数が1個だけなら、()は省略可能 */ };
const fnD = ( x, y ) => { /* 仮引数が複数のとき */ };
// 値の返し方
// 次の2つは同じ意味
const mulA = x => { return x * x }; // ブロック内でreturn
const mulB = x => x * x; // 一行のみの場合は、returnとブロックを省略できる
```

- 関数式
  - 関数式で関数を生成し、変数に代入する
  - 関数定義で命名した関数名は、関数内部からしか見えない。再帰などで使うことがある。

```TypeScript
const hoge = function() {
    return;
}
const hoge = function inneHoge() { // innerHogeは関数内からのみアクセス可能
    return;
}
```

- 関数定義
  - もともとの関数定義、使い分けはどうする？

```TypeScript
funciton hoge () {
    return;
}
```

### クラス

- ここに書いてないことは、[クラス · JavaScript Primer #jsprimer](https://jsprimer.net/basic/class/) を参照すること。
関数同様に、classも定義とクラス式で生成する方法がある

class名には大文字で開始し、クラスのインスタンスは小文字で開始すると名前がかぶらないのでいいという
ことで、文法ではないが慣習です。

- プロバティの先頭に#がついている。
  - [\[ES2022\] Privateクラスフィールド](https://jsprimer.net/basic/class/#private-class-fields)
  - Privateクラスフィールドが出きるまでは、慣習で変数名を\_(アンダースコア)で始める慣習で対処していた。

```TypeScript
class Hoge {
    #fuga;
    constructor(){
        #fuga = "moge";
    }
}
```

### データ組み立て

#### Object.assign

受け取ったデータに、付加情報を与えて使いたいときなど。

- [オブジェクトのマージと複製](https://jsprimer.net/basic/object/#copy-and-merge)

```typescript
// 使い方
const obj = Object.assign(target, ...sources);

// 例示
const objectA = { a: "a" };
const objectB = { b: "b" };
const merged = Object.assign({}, objectA, objectB);
console.log(merged); // => { a: "a", b: "b" }

// `version`のプロパティ名が被っている
const objectA = { version: "a" };
const objectB = { version: "b" };
const merged = Object.assign({}, objectA, objectB);
// 後ろにある`objectB`のプロパティで上書きされる
console.log(merged); // => { version: "b" }
```

- [[ES2018] オブジェクトのspread構文でのマージ](https://jsprimer.net/basic/object/#object-spread-syntax)

```typescript
const objectA = { a: "a" };
const objectB = { b: "b" };
const merged = {
    ...objectA,
    ...objectB
};
console.log(merged); // => { a: "a", b: "b" }
```

### モジュール

```typescript:src/index.ts
export default { // ファイルに一個しか置けない
  fetch: (req?: Request) => { // 下で解説する
    return new Response('Hi')
  },
}
```

を

```typescript:src/index.test.ts
import app from './index'

describe('Testing My App', () => {
  it('Should return 200 response', () => {
    const res = app.fetch()
    expect(res.status).toBe(200)
  })
})
```

でテストできるのは、`src/index.ts`

- src/index.tsの解説
  - fetch:で、そのモジュールでオブジェクト生成したときに、fetchというメソッドを定義している
  - (req?: Request) 引数のこの部分は、req?でオプショナル引数で、引数がなくてもokとしている。Requestは型です。
- src/index.test.tsの解説
  - なぜ拡張子をつけてないかは、まだよくわからん。'./index.ts'でないなら、Denoでは`--unstable-sloopy-imports`をオプションとして与えないといけない。see details [Unstable feature flags --unstable-sloppy-imports](https://docs.deno.com/runtime/reference/cli/unstable_flags/#--unstable-sloppy-imports)
  - `app.fetch()`でfetchを引数なしで呼び出している。
  - responseオブジェクトが帰ってきているので、テストしている

### 非同期処理

いくつかのトピックがある。

- 同期処理
- 非同期処理
  - try catch同期処理だけか？ Promiseにつながる？
  - どうやって非同期処理の関数か調べるには
- イベントループ
- Promise
- async/await

処理順序が気になるなら、イベントループで実行環境のランタイムのキュー(複数)にどのように積まれ、取り出されるのかを気になるだろう。

そこまで気にせず、処理について集中するなら,Promiseと、その発展形のasync/awaitをやることになる。とはいえ最低限のイベントループのイメージを持つ必要はあるだろう。

#### どうやって非同期処理の関数かを調べるには

TypeScriptの場合、戻り値の型にPromiseがあるかどうかをlspに教えてもらえばよいってことか？
たぶん、そう。VS Codeで確認したら、ちゃんと教えてくれる。

### 型

#### satifies

- 型推論を活かしながら型を注釈できる機能

```ts
interface Foo {
  id: number,
  name: string
}

const json = JSON.stringify({id: 1, name:'yabuki'} satisfies Foo);
```

これで、anyからjsonに型が付く

- [TypeScript: satisfiesオペレーターの使い所のひとつとして #TypeScript - Qiita](https://qiita.com/suin/items/1b74645158263d2fa9af)

- [Typescript satisfiesの活用シーン](https://zenn.dev/makoto1995/articles/ts-satisfies)

> Typescript では、変数が特定のプロパティだけを持つことを保証してコードを堅牢にするために、型注釈が利用されます。
> 一方それは、型推論がより具体的な型を導き出す可能性があるのにも関わらず、一般的な型で上書きしてしまうことになります。
>
> 型推論の柔軟性を維持しつつ、型安全性を担保したいシーンで、satisfies の利用を検討してみると良いと思いました。

- [TypeScript4.9で追加されたsatisfiesを理解する](https://zenn.dev/toshinobu/articles/208f2ea21ce8d0)

- as constは、wideningを防止する。
  - as constの挙動は、[as constとは---TypeScript 4.9のas const satisfiesが便利。型チェックとwidening防止を同時に行う](https://zenn.dev/tonkotsuboy_com/articles/typescript-as-const-satisfies#as-const-%E3%81%A8%E3%81%AF)
  - wideningとは、[wideningとは---TypeScript 4.9のas const satisfiesが便利。型チェックとwidening防止を同時に行う](https://zenn.dev/tonkotsuboy_com/articles/typescript-as-const-satisfies#widening-%E3%81%A8%E3%81%AF)

## 参考にしたドキュメントたち

- [付録: JavaScriptチートシート · JavaScript Primer #jsprimer](https://jsprimer.net/cheatsheet/#cheat-sheet)
- [Web標準のバックエンドアプリのテスト](https://zenn.dev/yusukebe/articles/9a6335ed793c43)

## 謝辞

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-10-18|
|記事を変更した日|----------|

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

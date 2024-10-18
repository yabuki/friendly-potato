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
    - もともとの関数定義、使い分けはどうする?

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
    - Private クラスフィールドが出きるまでは、慣習で変数名を\_始める慣習で対処していた。

```TypeScript
class Hoge {
    #fuga;
    constructor(){
        #fuga = "moge";
    }
}
```

### 非同期処理

いくつかのトピックがある。
- 同期処理
- 非同期処理
    - try catch同期処理だけか? Promiseにつながる?
- イベントループ
- Promise
- async/await


## 参考にしたドキュメントたち

- [付録: JavaScriptチートシート · JavaScript Primer #jsprimer](https://jsprimer.net/cheatsheet/#cheat-sheet)


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

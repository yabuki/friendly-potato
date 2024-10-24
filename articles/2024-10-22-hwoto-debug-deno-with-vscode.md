---
title: "Visual Stdio Codeを使ってDeno testをDebugで活用する 2024/10版"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [deno, vscode, test, debug, editor]
published: true
---
## 要約

この文書では、下記の情報を取り扱う。

- Visual Studio Codeを使って、TypeScriptランタイム環境のDenoのunittestをするときにデバッガーを使えるように設定する。
- いわゆるモノレポ形式のリポジトリで、Visual Studio Codeのデバッガーの設定ファイルの`deno test`の設定例を提示し、説明する。
- Visual Studio Codeの「ワークスペース」でDenoの設定について提示し、考察する。
- Denoの権限管理(permissions)について、`deno test`でどのように扱うかを考察する。
- denoの設定ファイル、deno.jsoncにおけるunstable機能設定について考察する。

## はじめに

Deno 2.0系がリリースされ、新規にDenoを使い始めた人もいるでしょう。Denoのよい所は、unittest/linter/formatter/benchmark/coverageなどが付いているので、別々にインストールして設定しまくる負担が減っており、他の言語からTypeScriptなどの言語で良いプラクティスを最初から実施しやすいのが良いと思っています。

また、Denoはランタイムで権限許可の仕組みを持っていて適切に使えば、悪意ある攻撃からプログラムを守ることができます。

他にも多々お勧めできる点はあるのですが、自分でコードを書いたり実行したりしてDenoやTypeScriptを動かして学びたい人が使っているであろう環境かつ、比較的人口に膾炙した組み合わせで活用方法を紹介します。

他のエディターや開発環境をお使いの方々は、Visual Studio Codeに依存しない部分を持って帰ってください。

### この文章を書いた動機

Visual Studio Codeを使ってDenoで一つのGitリポジトリに複数のプロジェクトを使ってサンプルプログラムを作るにあたって調べたことを中心に2024年10月の時点で良さそうなプラクティスや設定をまとめたものです。

また1から調べるのも大変だし、これから変わっていくにしても、自分の中で差分元を設定する必要があり、どこからでも参照できるようにZenn.devで公開するのが良いと判断しました。

### この文章はだれ向けか

前提として、下記を想定しています。

- 開発経験があり、Gitなどの説明は不要だ。
- Denoのインストールは済んでいる
- Visusl Stdio Codeのインストールと設定については、他の記事を参照せよ。
  - Visual Stuido Codeをインストールして、拡張などを好みに設定できるレベルの人を想定している。
- TypeScriptに関して詳しくはないが、他の言語は使ったことがある人を想定している。
  - TypeScriptを実際に動かして確認したい人を想定している。

### この文書の読み方

興味のある部分を拾い読みをしても大丈夫なはずですが、足りない部分は別の場所で補っていることもあるし不明点はリンク先の[参考にしたドキュメントたち](#参考にしたドキュメントたち)を見て補って下さい。

## 本文

### リポジトリの構成

Denoのサンプルプログラムをいくつも作るにあたって、いちいちGitのレポジトリを用意するのは面倒だし、面倒だと腰が重くなってやらなくなってしまう。

参考文献のリンク[monorepoとworkspace](#monorepoとworkspace)には、わりと大層なMonorepoの説明がされているし、実際そういう部分もある。だが私が意図しているのは、いくつもの独立したプロジェクトを一つのリポジトリに置いて気軽にコードを書いていきたい。という所です。

例えば、下記は不要な部分を消していますが、実際使っている`etude-deno`というリポジトリに、root project/cliffy/ndcdirsyahoなどの書き捨てのプロジェクトを量産しています。

`deno init ディレクトリ名(プロジェクト名)`で、プロジェクトを作っていきます。rootプロジェクトは`deno init`だけ実行するのが良いでしょう。

`deno init`すると、`deno bench`の雛形もあって、書いたコードの計測、テスト`deno test`、カバレッジ`deno test --coverage`と `deno coverage`、フォーマッター`deno fmt`やリンター`deno lint`が付いているのでコードを書くこと、と書いたコードの計測に集中できます。

下記はプロジェクトのレイアウト例です。

```
/etude-deno/
├── .vscode
│   ├── launch.json
│   └── settings.json
├── README.md
├── cliffy
│   ├── cmd1.ts
│   ├── cmd2.ts
│   └── cmd3.ts
├── kata.ts
├── memo.changelog
├── ndcdir
│   ├── README.md
│   ├── coverage
│   │   ├── 06c2de81-380a-4b07-8af4-5c37bca0f6da.json
│   │   └── 9490dd25-f081-4149-aa34-e19c2f653232.json
│   ├── deno.jsonc
│   ├── deno.lock
│   ├── main.ts
│   ├── main_test.ts
│   └── ndcdir
├── syaho
│   ├── deno.jsonc
│   ├── deno.lock
│   ├── main.ts
│   ├── main_bench.ts
│   └── test
│       ├── edu
│       │   └── main_test.ts
│       └── main_test.ts
```
<!-- markdownlint-disable-next-line -->
*プロジェクトのレイアウト例*

### リポジトリでのVisual Studio Codeの設定

[この文章を書いた動機](#この文章を書いた動機)にもあるように、Deno自身のインストールや、拡張機能のDenoの[Deno - Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=denoland.vscode-deno)設定はできているものとします。

[リポジトリの構成](#リポジトリの構成)のプロジェクト例にある`.vscode`ディレクトリー配下の`settings.json`について私の設定を下記に例示します。設定内容の意味は、Visual Studio Codeのホバーが教えてくれますし、ドキュメントは[Deno &amp; Visual Studio Code](https://docs.deno.com/runtime/reference/vscode/)を参照します。

私に取ってはCode Lens機能はないと困るので、有効にしています。editor関係の設定は、`deno fmt`の設定に合わせること。デフォルトでは同じはずです。ですが、設定を変えたときハマらないように注意喚起をしておきます。

下記はsettings.jsonの例です。

```json:.vscode/settings.json
{
    "deno.enable": true,
    "deno.unstable": [],
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "denoland.vscode-deno",
    "editor.tabSize": 2,
    "editor.autoIndent": "advanced",
    "editor.detectIndentation": true,
    "deno.codeLens.implementations": true,
    "deno.codeLens.references": true,
    "deno.codeLens.test": true
}
```
<!-- markdownlint-disable-next-line -->
*settings.jsonの例*

`.vscode/launch.json`については、後ほど例示と解説をします。リポジトリを作ったばかりだと、`launch.json`は存在していないのが正しいです。

#### --unstableオプションの扱い

Denoはあるバージョンから、--unstableのオプションを細分化しました。see also [2023年のDenoの変更点やできごとのまとめ](https://zenn.dev/uki00a/articles/whats-new-for-deno-in-2023#unstable%E3%82%AA%E3%83%97%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E5%B0%8E%E5%85%A5)
2024年10月現在だと、Visual Studio Codeの拡張などで、--unstableオプションを細分化する前の指定がされている場合があります。

いろいろと考え方はありますが、`deno.jsonc`または`deno.json`で指定してしまい、起動オプションやVisual Studio Codeでの指定はしないのが良いと現時点での筆者の考えです。

この部分は、`.vscode/launch.json`の話をするときにも参照します。

### テストを書く

Deno.test`のスタイルや、bddなスタイルなとを選ぶことができます。お好みで使い分けてください。

サンプルとしてBDDスタイルの下記を置いておきます。expectを使いたい人は、deno addしてから、コメントのimportを有効にして書いてみると良いでしょう。

```ts:main_test.ts
import { assertEquals } from "@std/assert";
import { describe, it } from "@std/testing/bdd";
// import { expect } from "@std/expect";

import { checkNdcdata, isDirExist } from "./main.ts";

describe("NDCデータのテスト", () => {
  it("空のデータが来たら", () => {
    const data: Array<string> = [];
    assertEquals(checkNdcdata(data), false);
  });
  it("数字なしのデータがきたら", () => {
    const data: Array<string> = ["hoge"];
    assertEquals(checkNdcdata(data), false);
  });
  it("-なしのデータが来たら", () => {
    const data: Array<string> = ["410数学"];
    assertEquals(checkNdcdata(data), false);
  });
  it("410-数学", () => {
    const data: Array<string> = ["410-数学"];
    assertEquals(checkNdcdata(data), true);
  });
  it("336.91-簿記・勘定科目，帳簿組織，商業簿記", () => {
    const data: Array<string> = ["336.91-簿記・勘定科目，帳簿組織，商業簿記"];
    assertEquals(checkNdcdata(data), true);
  });
  it(".-数学と来たらfalseを返す", () => {
    const data: Array<string> = [".-数学"];
    assertEquals(checkNdcdata(data), false);
  });
  it("-数学と来たらfalseを返す", () => {
    const data: Array<string> = ["-数学"];
    assertEquals(checkNdcdata(data), false);
  });
  it("数学と来たらfalseを返す", () => {
    const data: Array<string> = ["数学"];
    assertEquals(checkNdcdata(data), false);
  });
  it("410-とだけきたらfalseを返す", () => {
    const data: Array<string> = ["410-"];
    assertEquals(checkNdcdata(data), false);
  });
});

describe("ディレクトリの存在チェックテスト", () => {
  it("ディレクトリかファイルが存在するとき", async () => {
    assertEquals(await isDirExist("main.ts"), true);
  });
  it("ディレクトリかファイルが存在しないとき", async () => {
    assertEquals(await isDirExist("nainai.ts"), false);
  });
});

// 権限付与は、人間がコマンドラインから、意図的に行い
// テストでは、権限を付与されたのを剥奪することで、権限
// がない場合のテストを行うというデザインらしい。
describe("権限なしのディレクトリの存在チェックテスト", {
  permissions: { read: false },
}, () => {
  it("ディレクトリかファイルが存在するときに例外発生する", async () => {
    try {
      await isDirExist("main.ts");
    } catch (e) {
      if (e instanceof Error) {
        // console.error(e);
      }
    }
    // assertEquals(await isDirExist("main.ts"), true);
  });
});
```

#### テストとDenoの権限管理

既存のランタイムとの優位として、Denoは権限管理(permissions)を持っています。ファイルシステムの読み書き、ネットへのアクセスなど許可しておかないと権限要求されているけどええのか。とプロンプトが出ます。詳しくは、本家ドキュメント[Security and permissions](https://docs.deno.com/runtime/fundamentals/security/)を参照しましょう。

基本的なこととして、権限の許可は人間がプログラム実行時に行います。ただ、ユニットテストとしては、権限がない時のテストもしたいわけで、それが上記のmain_test.tsの最後の部分になります。権限がないのに実行しようとすると例外があがります。

### Unittestとデバッガー

デバッグの手法にも色々ありまして、printfデバッグを好む人もいるのは知っています。TypeScriptだとconsole.logデバッグか。
ただ、デバッガーを使えるに越したことはなく、できないよりできた方がいいので、必要な時に使えるようにここに書いておきます。

設定はVisual Studio Codeのメニューで「実行(R)」「構成の追加」でDenoを選びます。そして下記のような`launch.json`を作ります。

Monorepoの場合、デバックするときには対象となるプログラムのデバッグ先がかわります。私は、どんどん`launch.json`を書き換えていきますが、個別に置いておくのが好みの人はそうしましょう。

```json:.vscode/launch.json
  // IntelliSense を使用して利用可能な属性を学べます。
  // 既存の属性の説明をホバーして表示します。
  // 詳細情報は次を確認してください: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "request": "launch",
      "name": "Deno Debug --- ndcdir",
      "type": "node",
      "program": "${workspaceFolder}/ndcdir/main.ts",
      "cwd": "${workspaceFolder}/ndcdir",
      "env": {},
      "runtimeExecutable": "/home/yabuki/.deno/bin/deno",
      "runtimeArgs": [
        "run",
        "--inspect-brk",
        "--allow-all"
      ],
      "attachSimplePort": 9229
    },
    {
      "request": "launch",
      "name": "Deno test Debug --- ndcdir",
      "type": "node",
      "program": "${workspaceFolder}/ndcdir/main_test.ts",
      "cwd": "${workspaceFolder}/ndcdir",
      "env": {},
      "runtimeExecutable": "/home/yabuki/.deno/bin/deno",
      "runtimeArgs": [
        "test",
        "--inspect-brk",
        "--allow-all"
      ],
      "attachSimplePort": 9229
    }
  ]
}
```
<!-- markdownlint-disable-next-line -->
*デバッガの設定例*

説明が必要そうなのは、既定値が`deno run`であったり`--unstable`オプションが指定してあったの削除したり"--inspect-wait"を"--inpect-brk"に変えた部分でしょうか。

"--inpect-brk"は、本家ドキュメントのお勧めに従いました。

`deno test`を実行したいので、runtimeArgsの第一引数をtestに換え、"--unstable"を削除し、必要なら`deno.jsonc`などに設定します。テスト対象はキー"program"のvalueに記述します。必要に応じてカレントディレクトリのキー"cwd"も変えましょう。
"${workpaceFolder}"は、Gitリポジトリのrootと一緒になるはず。

Visual Studio Code以外の人は、ブラウザにアタッチさせてデバッグするのかしら。良く分からないけど。

## 参考にしたドキュメントたち

### monorepoとworkspace

- Monorepoについての本家ドキュメントworkspaceという概念があり設定できる。
  - [Workspaces and monorepos](https://docs.deno.com/runtime/fundamentals/workspaces/)

- モノレポってどういうものなの？ってなら
  - [Monorepoとは？基本概念と利点についての詳しい解説 | 株式会社一創](https://www.issoh.co.jp/tech/details/3934/)
    - 検索で引っかかったのはこれ。他によさそうなURLがあれば教えてほしい。

### DenoのVisual Studio Codeの設定について

- Visual Stdio Code設定で私が示した部分で足りない部分は下記の公式ドキュメントを参考にしてみてください。
  - [Deno &amp; Visual Studio Code](https://docs.deno.com/runtime/reference/vscode/)

### deno.jsonおよびdeno.jsoncに関して

- [deno.json and package.json](https://docs.deno.com/runtime/fundamentals/configuration/) 2024-10-22閲覧
- [deno.json（Deno設定ファイル）の書き方【随時更新】 #JavaScript - Qiita](https://qiita.com/access3151fq/items/7aa44ee69b4a5ff867c7) 2024-10-22閲覧

## 謝辞

Deno Slackにいらっしゃる方々から色々と教えを受けています。

とりわけ、uki00aさんには、私のうろ覚えなpermissionsについて、具体的な情報を教えていただきました。

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-10-24|
|記事を変更した日|2024-10-25|

上記は、この記事の鮮度を判断する一助のために書き手が載せた。

詳細な変更履歴は、
[GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)
を参照せよ。

記事に対するTypoの指摘などは、pull reqを希望する。
受け入れるかどうかは、差分とPull reqの文章で判断します。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

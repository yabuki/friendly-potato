---
title: "TypeScript(Deno)におけるモジュールとパッケージの使い分け"
emoji: "🐙"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: [deno, typescript, contest2025ts]
published: true
---
## 要約

TypeScript実行環境であるDenoを例に、モジュール(ESM)/パッケージ/ワークスペースの概念と適切な使い分けを整理します。これらを理解することで、コードの構造化とプロジェクト管理が効率的になります。

## はじめに

TypeScriptはJavaScriptに型システムを加えた言語ですが、歴史的経緯から複雑な概念が存在します。特に、処理をどこに配置するのが適切かという点は重要な課題です。

本記事では、Denoのワークスペース機能を理解する過程で明確になった、モジュール・パッケージ・ワークスペースの役割と使い分けについて解説します。

### 対象読者
- 他言語経験者でTypeScriptを学習中の方
- コードの構造化手法を探している方
- モノレポ構成のベストプラクティスを知りたい方

## 本文

メンテナンス性の高いプログラムでは、関心の分離が重要です。以下のような分割手法があります。

### 関心の分離手法

- 処理単位
    - 式を分ける
    - 文を分ける
    - メソッドを分ける
    - 名前空間を分ける
    - クラスを分ける
    - パッケージを分ける
    - アプリケーションを分ける

- データストア
    - 名前空間を分ける
    - カラムを分ける
    - テーブルを分ける
    - スキーマを分ける
    - データベースを分ける

- コミュニケーション
    - 名前空間を分ける
    - メッセージを分ける
    - キューを分ける
    - セッションを分ける
    - ネットワークを分ける

### ES Module(ESM)

現代のTypeScript/JavaScriptではESMが主流です。

ファイルシステムのディレクトリ構成で分割可能
例えば、DDD(Domain-Driven Design)のディレクトリ構成などはよく例に出てきます。

必要な名前空間のみexport/import可能になります。
ESMは基本1ファイルで完結します。しかし参考文献のWebの2などを読むと、複数のESMを再度importしてひとつのESMにまとめることができます。(モジュールの集約)

```ts:math.ts
// 単一モジュールの例
export function add(a: number, b: number): number {
      return a + b;
}
```

```ts:app.ts
// モジュールの利用例
import { add } from './math.ts';
console.log(add(2, 3)); // 5
```


### Package

Packageは、基本は複数のファイルからなる処理単位を取り込むものです。主にnpmやjsrなどのパッケージレジストラーに登録して他のプロジェクトが生成するプログラムからも利用できるようするために使います。

名前空間を必要な部分だけexport/importできるのが良い点です。

複数ファイルからなる再利用可能な単位の特徴は下記です。

- npm/JSRなどのレジストリに登録して共有可能です。
- バージョン管理（SemVer）が可能です。
- メタデータ（deno.json/jsr.json/package.jsonなど）で定義します。

```json:jsr.json
{
  "name": "@jsr/example__utils",
  "version": "1.0.0",
  "exports": "./mod.ts"
}
```

### Workspce

workspaceは、モノレポというひとつの巨大なリポジトリに全部詰め込んで、聖域なくソースコードを変えていきたい。という要求からはじまりました。
巨大なアプリケーションの依存関係を満足させ、コードの参照と必要な時に書き換えるためには全部丸抱えにするのが良い。という手法です。

具体的にはDenoやnode.jsには、workspaceという機能が存在する。(参考文献1)これを使うと、トップレベルで設定した内容を各ディレトクリのサブ・プロジックトに適用できます。
一種の設定の継承関係を作ることができます。またレジストリに公開を前提としないパッケージを作ることもできます。

deno.jsonまたはdeno.jsoncに下記のようなメタデータを追加します。
```json
{
  "name": "@jsr/example__utils",
  "version": "1.0.0",
  "exports": "./mod.ts"  // 公開するメインエントリポイント
}
```

```json
  "name": "@yabuki/foopackage",
  "version": "0.1.0",
  "exports": {
    ".": "./mod.ts"
  },
  "license": "MIT",
  "tasks": {},
  "imports": {
    "@std/expect": "jsr:@std/expect@^1.0.13",
    "@std/testing": "jsr:@std/testing@^1.0.9",
  }
}
```

のように書いてworkspaceにパッケージを置くこともできます。

repositoryのtopに存在するdeno.jsonまたはdeno.jsoncには下記のように書きます。
```json
{
    "workspace": [
        "./packages/*"
        "./modules/*"
    ]
}
```
packageまたはmoduleも置けます。

その他のworkspaceの利点については、参考文献Web 5を参照してください。

## 参考文献

### Web

1. [Workspaces and monorepos](https://docs.deno.com/runtime/fundamentals/workspaces/)
2. [JavaScript モジュール - JavaScript | MDN](https://developer.mozilla.org/ja/docs/Web/JavaScript/Guide/Modules)
3. [Publishing packages - Docs - JSR](https://jsr.io/docs/publishing-packages)
4. [npm-publish | npm Docs](https://docs.npmjs.com/cli/v11/commands/npm-publish)
5. [Deno workspaces - uki00a](https://scrapbox.io/uki00a/Deno_workspaces)

### 書籍

1. [『リファクタリング(第2版) 既存のコードを安全に改善する』のレビュー 児玉公信 (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4274224546)
2. [『Tidy First? 個人で実践する経験主義的ソフトウェア設計』のレビュー 吉羽龍太郎 (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4814400918)

## さいごに


TypeScriptやPythonを使ったシステム構築や、プロジェクトのマネージメントなどシステム構築や開発のサポートなどお仕事を募集しております。

GitHubから[yabuki (YABUKI Yukiharu)](https://github.com/yabuki) 連絡お待ちしております。


|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-06-04|
|  記事を公開した日  |2025-06-04|
|  記事を変更した日  |2025-06-05|

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
<!-- 画像はrepoのtopにあるimagesに入れよ -->

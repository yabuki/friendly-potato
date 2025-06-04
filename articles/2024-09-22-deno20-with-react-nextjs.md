---
title: "Deno 2.0 rcでreactとnext.jsの設定を試す"
emoji: "👋"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [react,nextjs,deno,frontend]
published: true
---
## 要約

Deno 2.0 rc.4で、reactとnext.jsの環境設定をしてみる。

## はじめに

Deno 2.0がもうすぐリリースされる。今はRC(release candidate)がでており、フィードバックを求められている。
私もDeno 2.0でいくつかの環境を試して、記録に残そうとしている。

### この文章はだれ向けか

Denoを使ってアプリケーションの実行環境を作ってみたい人向けの文章です。

### この文書の読み方

足りてない部分は、「参考にしたドキュメントたち」にあります。
deno初心者は足りない情報を別の文書で探して読む必要があります。
必要に応じて、検索やコミュニティへの参加などのアクションを取って
ください。

## 本文

大まかな方針は下記になります。

1. deno.jsonに、既定値のnoneではなく、manualを設定する。 [Deno 2.0 Release Candidate](https://deno.com/blog/v2.0-release-candidate#the-manual-mode)
1. denoで読み替えて、`deno add npm:next@latest npm:react@latest npm:react-dom@latest`を実行する。
    - TypeScriptの実行環境はdenoが持っているし、型情報は`--dev`でインストールする

### 下準備

私の場合は、incusでコンテナ環境を作って、denoをインストールし、その後deno 2.0のリリース候補にアップグレードして試しています。

```sh
$ deno --version
deno 2.0.0-rc.4 (release candidate, release, x86_64-unknown-linux-gnu)
v8 12.9.202.13-rusty
typescript 5.6.2
```

一般ユーザーのsrcディレクトリを作り、etude-react/firstという場所を割り当てて実験しています。

### deno の初期設定

deno.jsonを作って、下記の内容にします。

```json:deno.json
{
  "nodeModulesDir": "manual",
}
```

### deno add で環境設定

- 必要なパッケージを下記のようにインストールする。

```sh
$ deno add npm:next@latest npm:react@latest npm:react-dom@latest
Add npm:next@14.2.13
Add npm:react@18.3.1
Add npm:react-dom@18.3.1
```

```json:deno.json
{
  "nodeModulesDir": "manual",
  "imports": {
    "next": "npm:next@^14.2.13",
    "react": "npm:react@^18.3.1",
    "react-dom": "npm:react-dom@^18.3.1"
  }
}
```

```sh
deno add --dev npm:@types/react npm:@types/node npm:typescript
Add npm:@types/react@18.3.8
Add npm:@types/node@22.5.5
Add npm:typescript@5.6.2
```

```json:deno.json
{
  "nodeModulesDir": "manual",
  "imports": {
    "@types/node": "npm:@types/node@^22.5.5",
    "@types/react": "npm:@types/react@^18.3.8",
    "next": "npm:next@^14.2.13",
    "react": "npm:react@^18.3.1",
    "react-dom": "npm:react-dom@^18.3.1",
    "typescript": "npm:typescript@^5.6.2"
  }
}
```

ファイルも、package-lock.jsonと同様なdeno.lockができています。もちろんnode_modules/ディレクトリにパッケージも入っています。

```sh
ls -la
合計 12
drwxr-xr-x 1 yabuki yabuki   60  9月 22 14:22 .
drwxr-xr-x 1 yabuki yabuki   10  9月 22 13:51 ..
-rw-r--r-- 1 yabuki yabuki  161  9月 22 14:21 deno.json
-rw-r--r-- 1 yabuki yabuki 6023  9月 22 14:22 deno.lock
drwxr-xr-x 1 yabuki yabuki   54  9月 22 14:22 node_modules
```

```sh
$ ls -la node_modules/
合計 12
drwxr-xr-x 1 yabuki yabuki  54  9月 22 14:22 .
drwxr-xr-x 1 yabuki yabuki  60  9月 22 14:22 ..
drwxr-xr-x 1 yabuki yabuki  44  9月 22 14:22 .bin
drwxr-xr-x 1 yabuki yabuki 872  9月 22 14:22 .deno
lrwxrwxrwx 1 yabuki yabuki  36  9月 22 14:22 next -> .deno/next@14.2.13/node_modules/next
lrwxrwxrwx 1 yabuki yabuki  37  9月 22 14:22 react -> .deno/react@18.3.1/node_modules/react
lrwxrwxrwx 1 yabuki yabuki  45  9月 22 14:22 react-dom -> .deno/react-dom@18.3.1/node_modules/react-dom
```

実行するスクリプトを`deno.json`に記述します。下記の例のtasksに注目してください。

```json:deno.json
{
  "nodeModulesDir": "manual",
  "tasks": {
    "dev": "deno run -A npm:next dev",
    "build": "deno run -A npm:next build",
    "start": "deno run -A npm:next start",
    "lint": "deno run -A npm:next lint"
  },
  "imports": {
    "@types/node": "npm:@types/node@^22.5.5",
    "@types/react": "npm:@types/react@^18.3.8",
    "next": "npm:next@^14.2.13",
    "react": "npm:react@^18.3.1",
    "react-dom": "npm:react-dom@^18.3.1",
    "typescript": "npm:typescript@^5.6.2"
  }
}
```

### タスクの設定

設定したら、denoは下記のように認識します。

```sh
$ deno task
Available tasks:
- dev
    deno run -A npm:next dev
- build
    deno run -A npm:next build
- start
    deno run -A npm:next start
- lint
    deno run -A npm:next lint
```

### サンプルコードを動かす

`mkdir app`を行い、appディレクトリを作ります。
そして、とほほさんが例示している`layout.tsx`と`page.tsx`を作ります。

### 動かして、アクセスしてみる

```sh
$ deno task dev
Task dev next dev
  ▲ Next.js 14.2.13
  - Local:        http://localhost:3000

 ✓ Starting...

   We detected TypeScript in your project and created a tsconfig.json file for you.
 ✓ Ready in 1650ms
 ○ Compiling / ...
 ✓ Compiled / in 3.5s (432 modules)
 GET / 200 in 3987ms
```

ブラウザで、アクセスして表示されるまでを確認しました。

## 付記

### この記事の問題点

2点あります。

#### DenoでのPermissionの設定

denoのpermissionをちゃんと検討するなら、taskを実行させる時に`deno run -A`を
使わないで必要な権限だけ許可するようにしましょう。その辺のことは、動かしてあたりをつける
のを目的としており、スパッと緩くしています。

#### 動作確認

動きました。が、正しく設定されているか。との間には距離があるのは技術者なら自覚していますよね。
他の方もどんどん試して、記事にして切磋琢磨していくことになるでしょう。

特にTypeScriptの実行環境であるdenoで動かしているが、
依存関係でTypeScriptを導入しているのが気になっています。

発生していたエラー `deno add --dev npm:typescirpt`すると、もちろん発生しない。

```sh
$ deno task dev
Task dev deno run -A npm:next dev
  ▲ Next.js 14.2.13
  - Local:        http://localhost:3000

 ✓ Starting...
It looks like you're trying to use TypeScript but do not have the required package(s) installed.
Installing dependencies

If you are not trying to use TypeScript, please remove the tsconfig.json file from your package root (and any TypeScript files in your pages directory).


Installing devDependencies (npm):
- typescript

error: Uncaught Error: spawnSync npm ENOENT
    at __node_internal_captureLargerStackTrace (ext:deno_node/internal/errors.ts:93:9)
    at __node_internal_errnoException (ext:deno_node/internal/errors.ts:141:10)
    at _createSpawnSyncError (ext:deno_node/internal/child_process.ts:683:17)
    at new ChildProcess (ext:deno_node/internal/child_process.ts:285:13)
    at Object.spawn (node:child_process:118:10)
    at spawn (file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/compiled/cross-spawn/index.js:1:370)
    at file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/lib/helpers/install.js:82:47
    at new Promise (<anonymous>)
    at install (file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/lib/helpers/install.js:27:14)
    at installDependencies (file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/lib/install-dependencies.js:31:36)
error: Uncaught (in promise) TypeError: Unknown signal: 0
    at toDenoSignal (ext:deno_node/internal/child_process.ts:387:11)
    at ChildProcess.kill (ext:deno_node/internal/child_process.ts:296:53)
    at handleSessionStop (file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/cli/next-dev.js:84:51)
    at ChildProcess.<anonymous> (file:///home/yabuki/src/etude-react/second/node_modules/.deno/next@14.2.13/node_modules/next/dist/cli/next-dev.js:253:23)
    at ChildProcess.emit (ext:deno_node/_events.mjs:393:28)
    at ext:deno_node/internal/child_process.ts:275:16
    at eventLoopTick (ext:core/01_core.js:175:7)
```

### 横道にそれるが deno で tsc を実行してみる

どんな意味があるかはよくわからないが、試したらできた。

```sh
$ deno run -A npm:typescript/tsc -v
Version 5.6.2
```

## 参考にしたドキュメントたち

- [Deno: the easiest, most secure JavaScript runtime | Deno Docs](https://docs.deno.com/)
  - 本家ドキュメント。まずはココから。
- [Deno 2.0 Release Candidate](https://deno.com/blog/v2.0-release-candidate)
  - 英語の記事ですが、いまdeno 2.0を試すならよく読んでおきましょう。
- [とほほのNext.js入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/nextjs.html)

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-09-22|
|記事を変更した日|2024-09-26|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、
[GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato)
参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。
受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
<!-- 読み手に何の情報を伝えるのか -->
<!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

---
title: "Deno 2.0 rcでreactとnext.jsの設定を試す"
emoji: "👋"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [react,nextjs,deno]
published: false
---
# 要約

Deno 2.0 rc.4で、reactとnext.jsの環境設定をしてみる。

# はじめに



## この文章を書いた動機


## この文章はだれ向けか


## この文書の読み方


# 本文

1. deno.jsonに、既定値のnoneではなく、manualを設定する。 [Deno 2.0 Release Candidate](https://deno.com/blog/v2.0-release-candidate#the-manual-mode)
1. denoで読み替えて、`deno add npm:next@latest npm:react@latest npm:react-dom@latest`を実行する。typescriptの実行環境はdenoが持っているし、型情報は困ったら考える。

## 下準備

私の場合は、incusでコンテナ環境を作って、denoをインストールし、その後deno 2.0のリリース候補にアップグレードして試しています。

```
$ deno --version
deno 2.0.0-rc.4 (release candidate, release, x86_64-unknown-linux-gnu)
v8 12.9.202.13-rusty
typescript 5.6.2
```

一般ユーザーのsrcディレクトリを作り、etude-react/firstという場所を割り当てて実験しています。

## deno の初期設定

deno.jsonを作って、下記の内容にします。
```json:deno.json
{
  "nodeModulesDir": "manual",
}
```

## deno add で環境設定

- 必要なパッケージを下記のようにインストールする。

```
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

```
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

```
ls -la
合計 12
drwxr-xr-x 1 yabuki yabuki   60  9月 22 14:22 .
drwxr-xr-x 1 yabuki yabuki   10  9月 22 13:51 ..
-rw-r--r-- 1 yabuki yabuki  161  9月 22 14:21 deno.json
-rw-r--r-- 1 yabuki yabuki 6023  9月 22 14:22 deno.lock
drwxr-xr-x 1 yabuki yabuki   54  9月 22 14:22 node_modules
```

```
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
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
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

## タスクの設定

設定したら、denoは下記のように認識します。
```
$ deno task
Available tasks:
- dev
    next dev
- build
    next build
- start
    next start
- lint
    next lint
```

## サンプルコードを動かす

`mkdir app`を行い、とほほさんが例示している`layout.tsx`と`page.tsx`を作ります。


## 動かして、アクセスしてみる

```
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

## 問題点

動かしただけなので、正しく設定されているかについて自信がないです。特にtypescriptをnpmで
導入しており、denoで動いているのか。自信がないです。

# 参考にしたドキュメントたち

- [Deno 2.0 Release Candidate](https://deno.com/blog/v2.0-release-candidate)
    - 英語の記事ですが、いまdeno 2.0を試すならよく読んで起きましょう。
- [とほほのNext.js入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/nextjs.html)

# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2024-09-22|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
    <!-- 読み手に何の情報を伝えるのか -->
    <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

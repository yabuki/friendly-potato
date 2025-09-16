---
title: "Incusで隔離されたVibe Coding環境をセットアップする 2025/08版"
emoji: "💨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [incus, gemini, debian]
published: true
---
## 要約

VMみたいに使える、揮発しない環境だが、ホストに影響しないVibe Coding環境をIncusで作る。
Google ChromeやVisual Studio Codeもコンテナの中からホスト側で動かせる環境の構築をする。

## はじめに

Vibe Codingに必要なツール、たとえばGoogle ChromeやVisual Studio Codeなどを使うコンテナ環境を構築しておくと、壊しても簡単に元に戻せる。(Incusのスナップショット機能でスナップショットを取った時点に戻せる)
これで安心して、面倒くさい作業にとりかかれる。

- [Dev Containers上でClaude Codeの認証が安定しない問題](https://zenn.dev/nstock/articles/2c1ea72861f87c)
このへんの永続化で問題がでるのもimmutableなコンテナを使っているから発生しているように私からは見える。

常に永続化され、snapshotで巻き戻せるincusを使えば上記の問題からは解放される。

### この記事を書いた動機

安全に、Vibe Codingする独立した環境を作る。

### この記事はだれ向けか

immutableなコンテナでなく、VMみたいな使い心地のコンテナで開発をしてみたい人向け

## 本文

### X11でアプリケーションのフォワードを設定する。

下記のように、sshでコンテナの中のX11 clientをホスト側のX11 serverで動かしたいときに下記のようにメッセージが出ますが、

```
ssh -X yabuki@10.184.187.149
yabuki@10.184.187.149's password: 
Linux vibe 6.12.38+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.38-1 (2025-07-16) x86_64
 
The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
 
Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Tue Aug 12 15:44:35 2025 from 10.184.187.1
/usr/bin/xauth:  file /home/yabuki/.Xauthority does not exist
```

のように~/.Xauthorityが作られるので気にしなくても良い。

```
ls -la ~/.Xauthority 
-rw------- 1 yabuki yabuki 102  8月 12 19:27 /home/yabuki/.Xauthority
```

### 認証用のブラウザをインストールする

X11のForwardingを有効にしたので、次はブラウザをインストールします。
ただし、ブラウザが使っているFontは事前にインストールしておきましょう。
私の場合は、UD Biz フォントを入れ忘れていたので、ブラウザの日本語が豆腐だらけになってあわてました。

自分がブラウザで使っているFontは事前にインストールしてから下記をやってください。

incusのコンテナ内でGoogle Chromeをダウンロードしたバイナリをインストールします。

ホスト側でバイナリがあれば、それでもいいです。`incus file push` `incus file mount` コマンドなどを使うとよいでしょう。
詳しくは参考文献1を見てください。

その後インストールします。

具体的には
```
sudo apt install ./google-chrome-stable_138.0.7204.168-1_amd64.deb
```

で、関連するパッケージをインストールします。下記のような状態になります。

![Google Chromeを選択している画面](/images/2025-08-12_22-10.png)
*Google Chromeを選択している画面*

そして、`ssh -X` した端末から、`chrome`コマンドを実行するとホスト側にブラウザが立ち上がれば認証用のブラウザの設定はおわりです。

### gmini-cliをインストールする。

まずは、[google-gemini/gemini-cli: An open-source AI agent that brings the power of Gemini directly into your terminal.](https://github.com/google-gemini/gemini-cli)を確認します。

System Requirementは、Node.jsの20以上とのことで、Debian 13(trixie)に収録されている nodejsは20.19.2+dfsg-1ということでDebianパッケージで提供されているものを使う事にします。
パッケージの確認方法は、`apt-cache search nodejs`したあとに`apt-cache show nodejs`するのが良いでしょう。

```
sudo apt update
sudo apt -y install nodejs npm
```

大量にパッケージが導入されますが、終わるまで待ちます。

```
# npm install -g @google/gemini-cli
 
 added 432 packages in 13s
  
  127 packages are looking for funding
    run `npm fund` for details
```

で、グローバルインストールを終えます。

### gemin-cliを自分Google Accountに接続する

コンテナ内で`ssh -X`した端末から一般ユーザーになって`gemini`コマンドを実行します。

どの認証方法で、geminiを使うかの選択画面がでるので、事前に設定したchromeでGoogle Accountに接続します。

![認証後にブラウザ上で表示されるメッセージ](/images/2025-08-12_23-39.png)
*認証後にブラウザ上で表示されるメッセージ*

### gemini cliの初期設定

まずは、下記の公式ドキュメントを読んでから、初期設定をはじめることにする。
- [Gemini Cli Documentgation](https://github.com/google-gemini/gemini-cli?tab=readme-ov-file#-documentation)

ドキュメントを読みながら設定していくことになる。

Visual Studio Code からエージェントモードで使える。
コンテナにはリモートでVisual Studio Codeをつなぐと考えていたが、Incusで動かしているコンテナ内にVisual Stuido Codeをインストールしてgeminiと連携させるのが良さそう。
[Gemini Code Assist エージェント モード --- Gemini CLI | Gemini Code Assist | Google for Developers](https://developers.google.com/gemini-code-assist/docs/gemini-cli?hl=ja)

- [Gemini CLI が切り拓く！待望のエージェントモード(Agent Mode)が Gemini Code Assist に！ 【紹介編】](https://zenn.dev/google_cloud_jp/articles/8911c960113904)
    - この辺の記事も読んでおきたい。

### gemini cliの更新方法

:::message

gemini cliをインストールしてもどんどん新しくなっていくので更新して、最新においついていく方法を知る必要があります。

rootで、`npm i -g @google/gemini-cli`を実行したので、

rootで
`npm -g outdated`
でどのバージョンにあげるか確認したり
`npm -g update`
で最新にあげたりします。

`npm outdate`に関しては、参考文献2を参照してください。
`npm update`に関しては、参考文献3を参照してください。

:::

### 戻りたい時点にきたら

設定やコーディングで一区切りして、環境を一度保存したいなら、Incusだと下記の方法があります。

1. `incus create snapshot`でスナップショットを取っておく。
2. `incus export`と`incus import`コマンドを使って、環境をファイルに書き出す。
3. 別のincusサーバーを用意してインスタンスを退避しておく。

詳しくは、[インスタンスをバックアップするには - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/howto/instances_backup/)にあります。
btrfsを使っているなら、snapshotがおすすめ。

## 参考文献

1. [インスタンス内のファイルにアクセスするには - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/howto/instances_access_files/)
2. [npm-outdated | npm Docs](https://docs.npmjs.com/cli/v9/commands/npm-outdated)
    - Debian trixieのnpmが"9.2.0"なので、9系を指している。
3. [npm-update | npm Docs](https://docs.npmjs.com/cli/v9/commands/npm-update)
    - Debian trixieのnpmが"9.2.0"なので、9系を指している。

## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-08-12|
|  記事を公開した日  |2025-08-13|
|  記事を変更した日  |2025-08-15|

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

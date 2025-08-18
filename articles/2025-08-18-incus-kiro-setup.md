---
title: "Incusで作ったコンテナに、Kiroをインストールした"
emoji: "🐷"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [incus, kiro, debian]
published: true
---
## 要約

参考文献1を参考に、Incusで作ったmutableなコンテナで、Kiroを設定した事例紹介です。
Debを使ってインストールしたり、AWS Builders IDを使って使い始める部分は新しいかなと。

## はじめに

Waiting Listに入れていたKiroからの応答が2025-08-12にあり、ようやく時間ができたのでIncusで設定を始めた。
Incusの設定と、Gemini-cliをセットアップした、参考文献2まで終わっている前提です。

## 本文

下記の順番に作業を進めます。

1. Kiroからの応答メールにあるダウンロードリンクを使って、Kiroのバイナリをダウンロードする。
2. ダウンロードしたDebパッケージをincusで作ったコンテナに移す。
3. コンテナ内部でインストールする。

### Kiroバイナリのダウンロード

![Kiroのダウンロード画面](/images/2025-08-18_17-32.png)
*Kiroのダウンロード画面*

使っているコンテナは、Debian 13(Trixie)なので、debパッケージ版を選択します。

### ダウンロードしたDebパッケージをコンテナ内部に移す

ダウンロードしたKiroは下記のようなファイル名です。一見するとKiroの名前が入っていないので間違えないようにします。

```
ls -la 202508150626-distro-linux-x64.deb 
-rw-rw-r-- 1 yabuki yabuki 185723420  8月 18 17:18 202508150626-distro-linux-x64.deb
```

今回はdebファイル一個だけなので、`incus file push` コマンドを使って、コンテナ内部に送り込みます。
```
incus file push --help
Description:
  Push files into instances
 
Usage:
  incus file push <source path>... [<remote>:]<instance>/<path> [flags]
 
Examples:
  incus file push /etc/hosts foo/etc/hosts
     To push /etc/hosts into the instance "foo".
 
Flags:
  -p, --create-dirs   Create any directories necessary
      --gid           Set the file's gid on push (default -1)
      --mode          Set the file's perms on push
  -r, --recursive     Recursively transfer files
      --uid           Set the file's uid on push (default -1)
 
Global Flags:
      --debug          Show all debug messages
      --force-local    Force using the local unix socket
  -h, --help           Print help
      --project        Override the source project
  -q, --quiet          Don't show progress information
      --sub-commands   Use with help or --help to view sub-commands
  -v, --verbose        Show all information messages
      --version        Print version number
```

~/Downloads/202508150626-distro-linux-x64.deb を コンテナvibeの/rootに送り込むので
```
incus file push ~/Downloads/202508150626-distro-linux-x64.deb vibe/root/
```
最後の/は忘れないように。
```
Error: sftp: "open /root: is a directory" (SSH_FX_FAILURE)
```
というメッセージでエラーが発生します。

成功すると
```
root@vibe:~# ls -la /root/
合計 181400
drwx------ 1 root   root         170  8月 18 18:05 .
drwxr-xr-x 1 root   root         132  7月 21 14:30 ..
-rw------- 1 root   root        3300  8月 15 00:01 .bash_history
-rw-r--r-- 1 root   root         607  5月 13 04:25 .bashrc
-rw------- 1 root   root          20  8月 12 22:28 .lesshst
drwxr-xr-x 1 root   root          84  8月 12 23:03 .npm
-rw-r--r-- 1 root   root         132  5月 13 04:25 .profile
drwx------ 1 root   root           0  7月 21 14:25 .ssh
-rw------- 1 root   root        8940  8月 12 20:02 .viminfo
-rw-rw-r-- 1 yabuki yabuki 185723420  8月 18 18:05 202508150626-distro-linux-x64.deb
```
のように、ファイルが転送されたのがわかります。ちなみにownerとgroupがそのまま引き継がれているのも確認できます。
コンテナの外と中で、yabukiアカウントを同じuid、gidで作っているからです。

```
apt install ./202508150626-distro-linux-x64.deb 
注意、'./202508150626-distro-linux-x64.deb' の代わりに 'kiro' を選択します
Installing:
  kiro
 
Summary:
  Upgrading: 0, Installing: 1, Removing: 0, Not Upgrading: 0
  Download size: 0 B / 186 MB
  Space needed: 703 MB / 970 GB available
 
取得:1 /root/202508150626-distro-linux-x64.deb kiro amd64 0.2.13-1755242677 [186 MB]
Preconfiguring packages ...
以前に未選択のパッケージ kiro を選択しています。
(データベースを読み込んでいます ... 現在 68792 個のファイルとディレクトリがインストールされています。)
.../202508150626-distro-linux-x64.deb を展開する準備をしています ...
kiro (0.2.13-1755242677) を展開しています...
kiro (0.2.13-1755242677) を設定しています ...
shared-mime-info (2.4-5+b2) のトリガを処理しています ...
Notice: ファイル '/root/202508150626-distro-linux-x64.deb' がユーザ '_apt' からアクセスできないため、ダウンロードは root でサンドボックスを通さずに行われます。 - pkgAcquire::Run (13: 許可がありません)
```

調べたところ、インストールは成功しているが、`/root/202508150626-distro-linux-x64.deb`がuid:gidがyabuki:yabukiなのでユーザ`_apt`からアクセスできないだけのようだ。依存関係があるといやだったので`apt`コマンドを使ったが、`dpkg -i`コマンドを使えば良かったのかもしれない。
ということで次に進む。気になるひとは、参考文献3を読むのもいいでしょう。

### Kiro起動

`ssh -X`してX11 Forwardingを有効にした端末から、`kiro`と打ち込んで下記の画面を出します。

![サインイン画面](/images/2025-08-18_18-37.png)
*サインイン画面*

私の場合は、AWS Builder IDを持っているので、それでサインインしてみる。
コンテナ内のブラウザで、AWS Builder IDの入力画面が開いて認証開始となる。
![](/images/2025-08-18_18-56.png)

認証したら、メールアドレスに認証コードを送ってくるので、そいつを入力する。

一回で成功しなくても、再度チャレンジしてみてください。

![情報読み取りの許可画面](/images/2025-08-18_18-59.png)
*情報読み取りの許可画面*

![Visual Studio Codeからの設定をインポート](/images/2025-08-18_19-00.png)
*Viual Studio Codeからの設定をインポート*

![DarkかLightかのテーマ選択](/images/2025-08-18_19-07.png)
*DarkかLightかのテーマ選択画面*

![Shellの設定](/images/2025-08-18_19-07_1.png)
*Shellの設定*

迷いましたが、自分でshellはカスタマイズしているので後から自分で入れようとおもいます。

![起動画面](/images/2025-08-18_19-08.png)
*起動画面*

お疲れさまでした。インストールが完了しました。

![使えるクレジットの量](/images/2025-08-18_19-48.png)
*使えるクレジットの量*



## 参考文献

1. [Hello Kiro ~要件定義からアプリ起動まで~](https://zenn.dev/acntechjp/articles/f501c283aecba8)
2. [Incusで隔離されたVibe Coding環境をセットアップする 2025/08版](https://zenn.dev/yabuki/articles/2025-08-12-incus-vibe-coding)
3. [Ubuntuにおける「ダウンロードはルートとしてサンドボックスなしで実行されます」というAPTエラーの理解](https://ja.linux-console.net/?p=31132)

## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-08-18|
|  記事を公開した日  |2025-08-18|
|  記事を変更した日  |----------|

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

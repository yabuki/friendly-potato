---
title: "Debian GNU/Linuxで始めるプライベートリポジトリ(gitolite) 2025/09版"
emoji: "🦁"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [gitolite, git, debian, zennfes2025free]
published: true
---
## 要約

Debian GNU/Linuxで、gitoliteを設定する。

## はじめに

みなさん、Git使ってますか？　Gitを使っているが、pull requestやmerge requestがメインの利用をしている人が一定数いるのは理解しています。

GitHub EnterpriseやGitLabは、それらやIssue管理までやってくれますが、インフラ側でインストールして維持管理するのが大変です。
少人数で、少ないコストで複数のリポジトリを管理したい。閉鎖ネットワークでGitを使いたいときにGitoliteは選択肢になります。

私の場合であれば、`hledger`を使って、plaintext会計を実践しようとしています。
このとき機微情報であるお金にまつわる情報を外部に出したくないので、GitHubやGltLab、その他外部のサービスを使う気にはなれませんでした。

また、少数の人間で開発するときにNDAの関係で外部に情報送信ができないときは全部、自前で環境を作ることになります。その時少人数なのに手間をかけて、GitHub EnterpriseやGitLabやその他便利だが重厚長大なソフトウェアをインストールして更新していくのはToo muchです。
もっと、人数が増えて作業が分化したときに導入すればいいのです。

### この記事を書いた動機

自分が、gitoliteをインストールして使い始めるまでのTipsを記録して置かないと、忘れた頃に何だったかな。と、この記事を読むために書いています。

### この記事はだれ向けか

個人や少人数で、自前で複数のGit repositoryを使いたい人向けです。既存の記事だと古い情報になっている部分があるので、2025/09版と銘打って
現状の設定方法をお届けします。

### この記事の読み方

Debian系のLinuxディストロなら、だいたい同じかとおもいますが、適宜確認してあなたの環境に合わせてください。

### この記事には何を書いていないか

Pull requestやMerge requestの代わりにコードをreviewする方法については書いていません。
Gitのマージマスターと呼ばれる人が各人のブランチをマージする(取り込む際)にレビューを
するのは別部分で語られます。

gerritや、git reviewは書いていません。

また、Linux Kernel ML(LKML)のように、メールでコードをレビューする方法もありますが
ここでは割愛します。

## 本文

### 作業環境

- Debian GNU/Linux 13.1(Trixi)

### 予備知識

Gitoliteは、Debianパッケージ名だと **gitolite3**になります。

パッケージをインストールすると、gitolite3ユーザーとグループが生成されます。
日常の利用では気にすることはありませんが、gitolite3ユーザーのHomeは/var/lib/gitolite3/になります。

```
root@Orlanth:/var/lib/gitolite3# ls -la
合計 12
drwxr-xr-x 1 gitolite3 gitolite3  138  9月 23 18:05 .
drwxr-xr-x 1 root      root      1030  9月 23 16:46 ..
-rw------- 1 gitolite3 gitolite3   30  9月 23 18:09 .bash_history
drwx------ 1 gitolite3 gitolite3   38  9月 23 16:52 .gitolite
lrwxrwxrwx 1 root      root        26  9月 23 16:52 .gitolite.rc -> /etc/gitolite3/gitolite.rc
drwx------ 1 gitolite3 gitolite3   10  9月 23 17:00 .local
drwx------ 1 gitolite3 gitolite3   30  9月 23 18:02 .ssh
-rw------- 1 gitolite3 gitolite3   34  9月 23 18:02 projects.list
drwx------ 1 gitolite3 gitolite3  130  9月 23 17:38 repositories
```

"/var/lib/gitolite3/repositories/"配下に、リポジトリが生成されます。

そのため、backupの対象に、"/var/lib/gitolite3/"を含めてください。
FHSについては、[Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)(英文)か、`man hier`を参照してください。

必要に応じて、/varにDiskを割り当てておくのも良いでしょう。LVMやbtrfsで、raid 1などで拡張可能にしておくのは良い考えです。

### 事前準備

管理用のアカウント、利用者のアカウント(1から複数人)を用意します。私は、rootと、普段使いのyabukiというアカウントで運用しています。

sshの鍵を生成します。`man ssh-keygen`コマンドで、`ssh-keygen`の使い方を復習するのも良いです。

私の場合は、管理用のアカウントはrootの`.ssh/id_ed25519.pub`の公開鍵を使うことにしました。

```
ssh-keygen -t ed25519 -C root@Orlanth
```
インストール時に公開鍵の場所、
または公開鍵の内容debcoonfに聞かれるので事前に準備をしておきます。

### gitoliteのインストール

rootの端末、またはsudoを使って`gitolite3`パッケージを下記のコマンドでインストールします。

```
apt install gitolite3
```

debconfで、管理者のssh鍵を登録するように指示されます。fileへのpathでもいいし、sshのprivate keyそのままでも良いとのこと。

#### 利用者のssh鍵登録

私のおすすめは、管理者のssh鍵と、普段使いのssh鍵を分けてgitoliteに設定します。rootのssh鍵を生成しておいたので
ed25519.pubの**公開鍵**の方を指定します。

設定が終了したら、gitolite-adminリポジトリをcloneして、普段使いのアカウントや複数人でgitolite3を使うなら、その人たちのssh**公開鍵**をkeydirの下に置いてコミットしていきます。
ここで各人の権限管理について気になりますが、`@all`などのディレクティブについては、本家の英語ドキュメントを参考にしてください。


登録したssh鍵を確認したいならgitolite3ユーザーになり下記のコマンドを実行する。gitoliteコマンドに関してはもっと先に説明を書いた。

```
~$ gitolite sshkeys-lint
sshkeys-lint: ==== checking authkeys file:
sshkeys-lint: ==== checking pubkeys:
sshkeys-lint: admin.pub maps to user admin
sshkeys-lint: yabuki.pub maps to user yabuki
```

#### 利用するリポジトリの設定

gitolite-adminリポジトリのconfの下にgitolite.confがあります。初期値から、@adminとetude-refactoringおよび、bookkeepingを追加しています。それぞれの意味については英文の公式ドキュメントを参考にしてください。まあ何となくわかるかも知れませんが。
```
@admin = admin yabuki
 
repo gitolite-admin
    RW+     =   @admin
 
repo testing
    RW+     =   @all
 
repo etude-refactoring
    RW+     =   @all
 
repo bookkeeping
    RW+     =   yabuki
```

### gitoliteに情報を問い合わせる

#### リポジトリの一覧

```
ssh gitolite3@Orlanth.local info
Warning: Permanently added 'orlanth.local' (ED25519) to the list of known hosts.
Enter passphrase for key '/home/yabuki/.ssh/id_ed25519': 
hello yabuki, this is gitolite3@Orlanth running gitolite3 3.6.12-4 (Debian) on git 2.47.3
 
 R W    bookkeeping
 R W    etude-refactoring
 R W    gitolite-admin
 R W    testing
```

```
# ssh gitolite3@localhost info
hello admin, this is gitolite3@Orlanth running gitolite3 3.6.12-4 (Debian) on git 2.47.3
 
 R W    etude-refactoring
 R W    gitolite-admin
 R W    testing
```

ユーザーyabukiとrootで見えているリポジトリの違いがわかるだろうか。(bookkeepingの有無)

#### リポジトリの説明の参照と設定

```
ssh gitolite3@Orlanth.local desc bookkeeping
会計情報を扱うリポジトリ
```

こいつの設定は、gitoite3のbare repositoryに直接書くと、エディターが使えて便利です。UTF-8も使えてます。
```
root@Orlanth:/var/lib/gitolite3/repositories/bookkeeping.git# cat description 
会計情報を扱うリポジトリ
```

### gitoliteコマンド

`gitolite3`パッケージをインストールすると、`/usr/bin/gitolite` コマンドがインストールされます。

rootや一般ユーザー(gitoliteアカウントや普段お使いのユーザー)からも利用可能です。
しかしgitoliteのログなどはgitolite3ユーザーの`.gitolite`ディレクトリ配下に存在いる。
`gitolite`サブコマンドをどのユーザーで実行するかは確認しながら実行する。

```
$ gitolite 
 
Usage:  gitolite [sub-command] [options]
 
The following built-in subcommands are available; they should all respond to
'-h' if you want further details on each:
 
    setup                       1st run: initial setup; all runs: hook fixups
    compile                     compile gitolite.conf
 
    query-rc                    get values of rc variables
 
    list-groups                 list all group names in conf
    list-users                  list all users/user groups in conf
    list-repos                  list all repos/repo groups in conf
    list-phy-repos              list all repos actually on disk
    list-memberships            list all groups a name is a member of
    list-members                list all members of a group
 
Warnings:
  - list-users is disk bound and could take a while on sites with 1000s of repos
  - list-memberships does not check if the name is known; unknown names come
    back with 2 answers: the name itself and '@all'
 
In addition, running 'gitolite help' should give you a list of custom commands
available.  They may or may not respond to '-h', depending on how they were
written.
```

Debianパッケージでインストールしているので、setupを利用する機会はないでしょう。

gitolite3ユーザーで理解して実行しないとダメそうなコマンド群のヘルプは下記です。

多くは、全員には不必要で`/etc/gitolite3/gitolite.rc`を設定して有効にする。

```
$ gitolite help
hello, this is gitolite3@Orlanth running gitolite3 3.6.12-4 (Debian) on git 2.47.3
 
list of gitolite commands available:
 
        1plus1
        D
        access
        compile-template-data
        config
        create
        creator
        desc
        fork
        git-annex-shell
        git-config
        help
        htpasswd
        info
        list-dangling-repos
        lock
        mirror
        motd
        newbranch
        option
        owns
        perms
        print-default-rc
        push
        readme
        rsync
        sshkeys-lint
        sskm
        sudo
        svnserve
        symbolic-ref
        who-pushed
        writable
```

既定値のrcファイルを参照したいなら、gitolite3ユーザーで`gitolite print-default-rc`を実行する。
rcファイルに関しては、[「rc」ファイル - Gitolite(英文)](https://gitolite.com/gitolite/rc#structure-of-the-rc-file)
を入り口に読み解くのが良い。ドキュメントと設定ファイルのコメントを良く読むこと。

rcファイルは、debianの設定ファイルポリシーで/etc/gitolite3/gitolite.rcにハードリンクされており、Debian系に慣れている人はハードリンク先を変更する作法になれている。

### 私がよくわかっていないもの

私に取ってgitoliteを十全に活用するにはわかっていたほうが良いが、知らなくても困っていない事項です。

```
sh gitolite3@Orlanth.local help
Warning: Permanently added 'orlanth.local' (ED25519) to the list of known hosts.
Enter passphrase for key '/home/yabuki/.ssh/id_ed25519': 
hello yabuki, this is gitolite3@Orlanth running gitolite3 3.6.12-4 (Debian) on git 2.47.3
 
list of remote commands available:
 
        desc
        help
        info
        perms
        writable
```

writableは設定が足りていないのかちゃんと動いていない動きをしている。
permsは調べてないです。


## 参考文献

- [Gitolite](https://gitolite.com/gitolite/)
    - 公式サイト
    - [basic administration - Gitolite](https://gitolite.com/gitolite/basic-admin.html)
        - この辺から管理方法についてや設定ファイルについて学ぶのが良い。bare repositoryの生成はgitoliteにやらせること。

- [Debian -- trixie の git-review パッケージに関する詳細](https://packages.debian.org/trixie/git-review)
- [Filesystem Hierarchy Standard](https://refspecs.linuxfoundation.org/FHS_3.0/fhs/index.html)
- [gitolite3とgitwebの導入@Ubuntu #Git - Qiita](https://qiita.com/kyokuheki/items/643ba491d7031fafb23d)
    - 2016年07月の記事なので、いまの手順とは異なるが、参考になる部分もある。

## 謝辞


## さいごに

他にも書くべきことはまだあるが、もう不完全でも外部に出しておかないと自分が困りそうなので、時間ができたらもうちょっと情報を付け足します。
いまは色々と作法を知っている前提なのですが、自分なら困らないぐらいのヒントは書きました。

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-09-24|
|  記事を公開した日  |2025-10-13|
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

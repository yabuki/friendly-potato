---
title: "コンテナをVMみたいに使うならincusが便利だよ。2025/08版"
emoji: "🫙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [incus, debian, container]
published: true
---
## 要約

Debian GNU/Linux 13(code name:trixie)で、Vibe Codingをする準備のためにIncusをインストールして設定する。
今回は、インストールまでに考慮したことをなぜそうしたか。について書く。

## はじめに

最近のVibe Codingブームもあり、コンテナで作業をしている人も多いことでしょう。
イミュータブル(immutable)な特性を持つDockerコンテナで何でも解決しようとしているでしょうか。
イミュータブルなコンテナは、コンテナを再起動すると永続化可能な領域にデーターを置いていない限り初期状態に戻ります。

この特性は便利な場面も多々ありますが、Virtual Machine(以下VM)のように、中に入って作業しても作業内容が消えないことが便利な場合もあります。
用途によって道具を使い分けるのが良いのではないか。という提案が本記事になります。参考文献の7のスライド、水野さんはLXDの話をしていますが、これはほぼIncusでも通用する話です。

IncusはLXDからのForkになります。(詳しくは、参考文献の3.を参照せよ) snapdをインストールしなくても使えるので、私がメインで使っている。
Debian GNU/Linux stable(Debian 12)でも、backportされて、aptでインストール可能になっています。BackportされているIncusは、LTSバージョンの6.0.4です。

ちなみに私も必要があれば、イミュータブルなコンテナは使います。Podmanを試してからDockerにすることが多いです。
また、Incusの中で、PodmanやDockerを動かせます。まさに開発環境をコンテナの中に閉じ込めて、保存することができます。

保存方法も、snapshotを取って、切り戻ししたり、export/importしたり、複数のIncusが立ち上がっているなら、別のIncusに移すこともできます。
詳細については、参考文献の1または2で説明があります。

### この記事はだれ向けか

イミュータブルな機能が不要なののに、頑張ってDockerコンテナを使って苦労している人向けです。
また、Ubuntuで、LXDやIncusの記事はそれなりにかかれていますが、Debian GNU/Linuxでの例を知りたい人向けでもあります。

### この記事の読み方

推奨は、順番に読むことを想定しています。設定済みのインスタンスの部分まで読んでもらえたらokです。

それ以降は、よりincusを便利に使いたい人向けのやりこみコンテンツになります。

## 本文

### 所与の条件

今回の記事に入る前に、事前に決定済みの条件は下記になります。

今回使うOSは、Debian GNU/Linux 13(コードネーム trixie)です。2025-08-10 時点での安定版です。file systemは、btrfsを使っています。
開発用に使っているので、ext4よりもコンテナを活用するのに、インストール時からbtrfsを使っています。パックアップ用HDDなどは耐障害性から、ext4を使うこともあります。
ハードディスクなどで、Readできないセクターが発生したら`fsck -c`などを使いますから。

Debian 13(trixie)には、[Debian -- パッケージ検索結果 -- incus](https://packages.debian.org/search?searchon=sourcenames&keywords=incus)で確認できますが、incusパッケージがあります。

まだ、Debian 12(bookworm)を使っている場合は、 参考文献の4を見るとわかりますが、backports.debian.orgにIncusを使います。
商用サポートや参考文献の5にあるdockerイメージを動かしたい場合は別途Debianのexperimentalのソースパッケージを使うか、別のリポジトリを使ってください。

aptでbackports.debian.orgを参照して、パッケージをインストールする方法については、参考文献6を読んで実行しておいてください。

### incusの導入

incusパッケージには、lxcコンテナを扱うものと、kvmで仮想マシンも使えるものに分割されています。今回は軽量なコンテナだけを扱う予定です。
したがって、`apt update;apt -y install incus-client incus-base`とします。

参考文献8では、incus-adminグループを作っていたりしますが、Debian packageではすでに、incus, incus-adminグループは作成ずみです。
/etc/groupsを見て確認できます。

私は、普段使いのアカウント(yabuki)でincusを操作したいので、incus,incus-adminのどちらに属するか悩みましたが、`sudo usermod -aG yabuki`として
ログインしなおして、
```
id
uid=1000(yabuki) gid=1000(yabuki) groups=1000(yabuki),6(disk),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),100(users),106(netdev),111(bluetooth),113(lpadmin),116(scanner),993(incus-admin)
```
となっていることを確認しました。

### incus admin init

incusの初期設定です。この辺は特にデフォルトの設定のままでいいかと思います。気になるなら、参考文献1,2,8あたりを参照すると良いかと。

:::details 初期化する前の状態

```
btrfs subvolume list /var
ID 259 gen 70386 top level 5 path videos
```
/var/videos は、会議などを録画する領域としてHDD上に事前に用意して、/home/yabuki/Videos/の下にmountしています。
```
incus admin init --dump
config: {}
networks: []
storage_pools: []
storage_volumes: []
profiles:
- config: {}
  description: Default Incus profile
  devices: {}
  name: default
  project: ""
projects:
- config:
    features.images: "true"
    features.networks: "true"
    features.networks.zones: "true"
    features.profiles: "true"
    features.storage.buckets: "true"
    features.storage.volumes: "true"
  description: Default Incus project
  name: default
```
:::

それでは初期化していきます。

```
 incus admin init
Would you like to use clustering? (yes/no) [default=no]: 
Do you want to configure a new storage pool? (yes/no) [default=yes]: 
Name of the new storage pool [default=default]: 
Name of the storage backend to use (btrfs, dir) [default=btrfs]: 
Would you like to create a new btrfs subvolume under /var/lib/incus? (yes/no) [default=yes]: 
Would you like to create a new local network bridge? (yes/no) [default=yes]: 
What should the new bridge be called? [default=incusbr0]: 
What IPv4 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
What IPv6 address should be used? (CIDR subnet notation, “auto” or “none”) [default=auto]: 
Would you like the server to be available over the network? (yes/no) [default=no]: 
Would you like stale cached images to be updated automatically? (yes/no) [default=yes]: 
Would you like a YAML "init" preseed to be printed? (yes/no) [default=no]: 
```

:::details 初期化後の状態

```
 btrfs subvolume list /var
ID 259 gen 71984 top level 5 path videos
ID 260 gen 71990 top level 5 path lib/incus/storage-pools/default
```

subvolumeが追加されているのがわかります。

```
config: {}
networks:
- config:
    ipv4.address: 10.184.187.1/24
    ipv4.nat: "true"
    ipv6.address: fd42:41ff:4ab7:deb4::1/64
    ipv6.nat: "true"
  description: ""
  name: incusbr0
  type: bridge
  project: default
storage_pools:
- config:
    source: /var/lib/incus/storage-pools/default
    volatile.initial_source: /var/lib/incus/storage-pools/default
  description: ""
  name: default
  driver: btrfs
storage_volumes: []
profiles:
- config: {}
  description: Default Incus profile
  devices:
    eth0:
      name: eth0
      network: incusbr0
      type: nic
    root:
      path: /
      pool: default
      type: disk
  name: default
  project: ""
projects:
- config:
    features.images: "true"
    features.networks: "true"
    features.networks.zones: "true"
    features.profiles: "true"
    features.storage.buckets: "true"
    features.storage.volumes: "true"
  description: Default Incus project
  name: default
```
:::

### ログの置き場所

```
ls -la /var/log/incus/
合計 4
drwx------ 1 root incus-admin   80  8月 11 19:04 .
drwxr-xr-x 1 root root        1352  8月 11 11:08 ..
-rw-r--r-- 1 root root           0  8月 11 19:04 dnsmasq.incusbr0.log
-rw------- 1 root root           0  8月 11 11:03 incus.log
-rw------- 1 root root         159  8月 11 11:03 incus.log.1
```

### インスタンスの立ち上げ方

`incus launch` すればいい。参考文献12を参照してください。

### 設定済みのインスタンスを動かす

localeを日本語にして、timezoneをAsia/Tokyoにしたりなど毎回やらないといけない処理を省くには王道としてはincusのイメージを作ることですが、
[サードパーティーツールと統合 - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/third_party/)にあるDistrobuilderをつかうのかもしれません。^[GRAM: GitHub の自己ホストランナーを稼働できる Github Actions Runner Manager を作るのも楽しそう]

:::message

2025-08-12 追記

タイムゾーンの変更方法は cloud-init を使う方法もあると教えてもらいました。詳しくは参考文献13を読んでください。

https://x.com/hnakamur2/status/1954921794437267837

イメージの後ろに/cloudとあるやつが、cloud-init対応だそうです。cloud-initに関しては 
[cloud-init 25.1.4 documentation](https://cloudinit.readthedocs.io/en/latest/index.html)
がドキュメントのようです。Cloud上で初期設定をするのに広く使われているようですね。
:::


incusに対して、terraformやOpenTofuで設定する方法もありますが、ansibleがお手軽っぽい。でも今回はもっと簡単にインスタンスのバックアップから任意のインスタンスを作る方法を試します。

Odaylaというマシンで、trixieという名前でDebian 13を設定したコンテナを作りました。
```
incus export trixie ./trixie-backup.tar.gz
```
でバックアップファイルを作ります。

scpでOrlanthという新しくincusをセットアップしたマシンに、trixie-backup.tar.gzを
コピーします。

上記のファイルを元にvibe coding用のコンテナを作ります。

```
incus import ./trixie-backup.tar.gz vibe
```
進捗表示がでたあとにコマンドプロンプトが戻ってくるのでコピーできたか確認します。

```
incus list
+------+---------+------+------+-----------+-----------+
| NAME |  STATE  | IPV4 | IPV6 |   TYPE    | SNAPSHOTS |
+------+---------+------+------+-----------+-----------+
| vibe | STOPPED |      |      | CONTAINER | 0         |
+------+---------+------+------+-----------+-----------+
```
望むインタンスができているようなので、
`incus start vibe`で起動させます。

```
incus list
+------+---------+-----------------------+------------------------------------------------+-----------+-----------+
| NAME |  STATE  |         IPV4          |                      IPV6                      |   TYPE    | SNAPSHOTS |
+------+---------+-----------------------+------------------------------------------------+-----------+-----------+
| vibe | RUNNING | 10.184.187.149 (eth0) | fd42:41ff:4ab7:deb4:1266:6aff:fe69:93e5 (eth0) | CONTAINER | 0         |
+------+---------+-----------------------+------------------------------------------------+-----------+-----------+

```

ひとまず、ここまでで、一区切りとします。以下は追加的なコンテンツです。
気になる人だけ読んでください。


### project と profile

以下はincusを便利に使うための話になります。だんだんと複雑になります。

個々のインスタンスに統一したプロファイルを適用して、インスタンスをグループ化して扱うのが
projectです。より詳しい説明は、参考文献9を参照してください。

ただし、プロジェクトにはユーザーのできることを制限することにも使えるが、それを設定すると参考文献10のような罠があるので困ったときのためのリンクを置いておきます。

#### incusのインスタンスをLANのIPで運用したい。

文献8を参考に、profileを作る。profileの基礎的なことは、参考文献11を参照すること。

```
incus profile create --help
Description:
  Create profiles
 
Usage:
  incus profile create [<remote>:]<profile> [flags]
 
Examples:
  incus profile create p1
      Create a profile named p1
 
  incus profile create p1 < config.yaml
      Create a profile named p1 with configuration from config.yaml
 
Flags:
      --description   Profile description
 
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

```
incus profile create bridge
```

Linux machineで利用しているイーサネットのデバイス名を取得する
```
ip a | grep  'state UP'
2: enp6s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
```
:::details incus network list
```
incus network list
+----------+----------+---------+-----------------+---------------------------+-------------+---------+---------+
|   NAME   |   TYPE   | MANAGED |      IPV4       |           IPV6            | DESCRIPTION | USED BY |  STATE  |
+----------+----------+---------+-----------------+---------------------------+-------------+---------+---------+
| enp6s0   | physical | NO      |                 |                           |             | 0       |         |
+----------+----------+---------+-----------------+---------------------------+-------------+---------+---------+
| incusbr0 | bridge   | YES     | 10.184.187.1/24 | fd42:41ff:4ab7:deb4::1/64 |             | 1       | CREATED |
+----------+----------+---------+-----------------+---------------------------+-------------+---------+---------+
| lo       | loopback | NO      |                 |                           |             | 0       |         |
+----------+----------+---------+-----------------+---------------------------+-------------+---------+---------+
```
:::

`incus network list`を確認することで、incusのnetworkにenp6s0が生成されているのを確認した。

:::details incus network attach-profileコマンドの確認
```
incus network attach-profile --help
Description:
  Attach network interfaces to profiles
 
Usage:
  incus network attach-profile [<remote>:]<network> <profile> [<device name>] [<interface name>] [flags]
 
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
:::


```
incus network attach-profile enp6s0 bridge eth0
```



## 参考文献

1. [Incus documentation](https://linuxcontainers.org/incus/docs/main/)
    - incusのドキュメント(英文)
2. [Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/)
    - 1.のドキュメントを有志の方々が日本語訳を作ってくれています。ありがたいことです。
3. [第796回 LXDとIncus、今後どちらをUbuntuユーザーは使うべきか？ | gihyo.jp](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0796)
    - LXDのコミュニティ・フォークがIncusとなります。
4. [Incus - Debian Wiki](https://wiki.debian.org/Incus)
5. [第824回 Dockerコンテナをダイレクトに動かせるようになった「Incus 6.3」を、Ubuntu 24.04で試す | gihyo.jp](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0824#sec5)
6. [Debian Backports](https://backports.debian.org/)
7. [Dockerに疲れた人のためのLXDではじめるシステムコンテナ入門 - Speaker Deck](https://speakerdeck.com/devops_vtj/dockernipi-retaren-notamenolxddehazimerusisutemukontenaru-men)

8. [プロのインフラエンジニアが、incus で Docker してみた。 ② ～ incus 編 ～｜笛あおい。](https://note.com/fueaoi/n/n417dd67c2895)

9. [プロジェクトについて - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/explanation/projects/#projects-confined)
10.  [Incus(≒LXD)の&quot;User restricted project&quot;の設定方法について - turgenev’s blog](https://turgenev.hatenablog.com/entry/2025/04/24/022718)
11. [プロファイルを使用するには - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/profiles/)
12. [インスタンスを作成するには - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/howto/instances_create/)
13. [cloud-initを使用するには - Incus ドキュメント](https://incus-ja.readthedocs.io/ja/latest/cloud-init/)

- [第459回 LXDを使ってDockerコンテナをマイグレーション | gihyo.jp](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0459)

## 謝辞

言及している参考文献の方々に御礼申し上げます。とりわけincusのドキュメントを翻訳していただいている方々。

## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-08-11|
|  記事を公開した日  |2025-08-11|
|  記事を変更した日  |2025-08-12|

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

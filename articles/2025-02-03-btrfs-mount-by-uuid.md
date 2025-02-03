---
title: "Linuxで確実にDiskをマウントする方法"
emoji: "💭"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [linux, debian, btrfs]
published: true
---
## 要約

Linuxでデバイス名が変わったとしても、確実に特定のDiskをマウントしてアクセスさせる方法

## はじめに

Desktop Linuxなどの環境において、接続するUSB経由などで接続するストレージが変化することがあり、起動時に振られる/dev/sd?が一定しないことがある。
そんな時に、確実にストレージを特定して必要な場所にmountしたいときに、UUIDでMountする方法がある。

以下は、Debian GNU/Linux Bookworm(Debian 12)を用いて、実際に行っているが、このあたりはLinux一般の話なので、ほかのDistroをお使いの人でも
参考になるだろう。自分が使っているDistroに適宜読み替えて欲しい。

### この記事を書いた動機

私はautofsを使っているが、autofsで特定のストレージを特定のマウントポイントにmountしたいので、ストレージのUUIDを調べる所から始めた。
また同じような作業をするときに自分が困らないようにメモを残すために書いた。

### この記事はだれ向けか

Linuxで、btrfsを使い、複数のストレージを使う人で、必ず特定のmountポイントに特定のストレージを割り当てたい人。

### この記事の読み方

下記の順番で説明する。知っている部分を飛ばしてもよいが、必要なら戻って読み返してほしい。

1. ストレージのUUIDの調べ方
2. どこに、どうmountするかを決定する。

## 本文

### 事前にやっておくこと

Mountするストレージデバイスを初期化する。具体的にはパーティションを切って、mkfsする。私はmkfs.btrfsをしました。ここは人によってmkfs.ext4にするなど差がでてくる所でしょう。

### ストレージのUUIDの調べ方

まずは、わからなくても `man blkid`をするのをオススメする。特権のrootで操作するものなので、何をするのか先に調べておくのは良い習慣です。

何も指定しないと、manにあるように、/proc/partitionsにあるパーティションを対象にします。

ちなみに接続しているのは、1TBのm.2 SSDがEFI/filesystem/swap SCSI接続の500GBが/dev/sda1 SCSIの変換アダプター経由の m.2 SSDが/dev/sdbになります。

```
$ cat /proc/partitions 
major minor  #blocks  name

   8        0  488386584 sda
   8        1  488385560 sda1
 259        0  976762584 nvme0n1
 259        1     524288 nvme0n1p1
 259        2  975236096 nvme0n1p2
 259        3    1000448 nvme0n1p3
   8       16  976762584 sdb
   8       17     524288 sdb1
   8       18  975236096 sdb2
```

```
# blkid
/dev/nvme0n1p3: UUID="0b90f75a-1c2c-4551-92f4-97dacd1027a9" TYPE="swap" PARTUUID="8e2a584b-b869-44dd-b549-7c704d66a2b7"
/dev/nvme0n1p1: UUID="2468-3B9E" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="1053d31e-82b9-4ed1-900e-821b6c6ab8b9"
/dev/nvme0n1p2: UUID="61882e3f-be9f-4f8a-83ca-b86c27e5c611" UUID_SUB="a37d5703-33f2-4d7c-84b5-24fbe78e1e85" BLOCK_SIZE="4096" TYPE="btrfs" PARTUUID="83745a95-90e5-428f-8766-13a116540681"
/dev/sdb2: UUID="cd1de55e-b3cc-427a-897a-3b7590479459" UUID_SUB="14742391-8b60-4071-ae03-6663f10ddf17" BLOCK_SIZE="4096" TYPE="btrfs" PARTUUID="69fb348f-0b3d-41a2-aa55-9d87324a2751"
/dev/sdb1: UUID="9F33-CFF4" BLOCK_SIZE="512" TYPE="vfat" PARTUUID="d518acad-99e1-4488-a7fe-e3841c50e735"
/dev/sda1: UUID="b70f725b-1db9-4539-b2a6-a82d1804bb7e" UUID_SUB="731efbe2-cc12-4d14-9da4-3bfa540a0390" BLOCK_SIZE="4096" TYPE="btrfs" PARTUUID="8e828aad-01"
```

### ストレージのマウント

/etc/fstabにストレージのマウントするエントリーを書きます。予め/mnt2は作っておくこと。
`UUID=b70f725b-1db9-4539-b2a6-a82d1804bb7e /mnt2           btrfs defaults,noatime,autodefrag,compress-force=lzo,space_cache   0       0`
mount -aコマンドだけだと
```
root@Orlanth:~# mount -a
mount: (hint) your fstab has been modified, but systemd still uses
       the old version; use 'systemctl daemon-reload' to reload.
```
と言われるので、systemctl daemon-reloadもやります。

### subvolumeの作成


```
# btrfs subvolume create /mnt2/var
Create subvolume '/mnt2/var'
# btrfs subvolume list .
ID 256 gen 9 top level 5 path var
# btrfs subvolume show var
var
        Name:                   var
        UUID:                   05e17096-3018-6548-b333-2531b8d27419
        Parent UUID:            -
        Received UUID:          -
        Creation time:          2025-02-03 18:22:01 +0900
        Subvolume ID:           256
        Generation:             10
        Gen at creation:        8
        Parent ID:              5
        Top level ID:           5
        Flags:                  -
        Send transid:           0
        Send time:              2025-02-03 18:22:01 +0900
        Receive transid:        0
        Receive time:           -
        Snapshot(s):
# btrfs subvolume set-default 256 /mnt2/var/
# cp -a /var /mnt2/
```

subvolume set-defaultしているのは、/mnt/varでなく、/varとして見せるため。と昔のメモだでてきたので、そのように。/varの内容を/mnt2/varにコピーもしておきます。


#### tips

/etc/fstabにエントリーを書いて、/varに/mnt2/varをマウントします。参考例としてデバイスネームばかりの例がでてきましたが、UUIDで指定したかったのでbtrfs subvolme showで表示されるUUIDを指定して、そんなUUIDはない。と怒られていたわけですが。

よくよく考えてみると、/dev/sda1の代わりにUUIDを使っているので、b70f725b-から始まるUUIDを指定すべきというのに思いつくまで少々時間がかかってしまいました。わかってしまえば、そうゃそうだ。と納得するわけですけど。


## 参考文献

- [イマドキのディスクマウント方法 #Linux - Qiita](https://qiita.com/pluser/items/645531b570dfcc65e324)
- [uuidによるデバイスのマウント #Linux - Qiita](https://qiita.com/qpSHiNqp/items/8e33f11b0f1a4a717e1a)

- [Subvolumes — BTRFS documentation](https://btrfs.readthedocs.io/en/latest/Subvolumes.html#subvolume-flags)
- [Btrfs を練習してみた #RaspberryPi - Qiita](https://qiita.com/masataka55/items/0ee9254ad9d0cf6b457a)

## 謝辞


## さいごに

これで、incusで/varに好みのコンテナを作ったり、gitolite3で、外に出したくないgit repoを作る準備ができた。

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-02-03|
|  記事を公開した日  |----------|
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

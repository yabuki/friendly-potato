---
title: "Debian GNU/Linux で T480のBIOS updateのためCD-Rを焼くメモ"
emoji: "🐷"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian,CDR,DVD]
published: true
---

## 要約

Debian GNU/Linux で、CD/DVDのイメージから、CD/DVDに焼きこむ作業に関するメモです。

## はじめに

昨今(さっこん)は、めっきりCDやDVDのイメージを物理デバイスに書き込むことが減りました。やったとしても USB memory stick が安価になり容量の制限も緩くなっているからです。

とはいえ、私の場合 Think Pad T480 の BIOS を更新するのにisoイメージがあったのと、もう使わないだろうが、残っているCD media を使い切るために、久しぶりに CD を焼いてみるので、記事にまとめておきます。

自分が、次にCD/DVDを焼く環境を設定する時に参考になるように。

ちなみに、BIOSのバージョンがある程度新しいと、LinuxからでもBIOS updateは可能になるので、この作業は必要なくなるかとは思います。

Thinkpad T480以外の新しい機種だと最初から Linux でupdateできるかも知れません。私のように必要な人だけがやれば良いのですが、もはや古(いにしえ)の技術になったので書いておきます。

貧乏性なのか、まだ使える空メディアを捨てることができないので、こうやって使ってから長い間つかっていないメディアを捨てていきたい。

### この文章はだれ向けか

Linux で、物理のCD/DVDを焼く必要があり、環境設定をする必要のある人

ただ、著者がDebian GNU/Linux を使っているのと、ssh越しに CD を焼く必要があるので、書いている内容は必ずしもあなたのニーズに一致しないかも知れない。

その時は、いくつか私が思いついたフックを書いておくので、自分なりに試してほしい。

### この文書の読み方

上記の「この文章はだれ向けか」でも、書いているが ssh 越しに、CD/DVDを焼きたいので、主に CUI のプログラム wodim について記述する。

GUIのプログラムがお好みであれば、GNOMEなら [Debian -- パッケージ検索結果 -- brasero](https://packages.debian.org/search?keywords=brasero) が、Nautilus にあるイメージを連携して焼いてくれるとかの設定ができる模様です。

Xface なら、 [Debian -- パッケージ検索結果 -- xfburn](https://packages.debian.org/search?keywords=xfburn) が良さそうです。

KDEなら、[Debian -- パッケージ検索結果 -- k3b](https://packages.debian.org/search?keywords=k3b) でしょうか。

わたしは i3wm なのでやっぱり、GUIでなくてCUIを使うかもしれません。

## 本文

wodim は、cdrecord から派生した。CUIの CD/DVD ライティングソフトです。

wodim はここに書いている以上の機能をもっています。詳しくはドキュメントを参照してください。

### インストール

私が利用しているのは、Debian GNU/Linux Sid ですが、Debian 11 --- bullseye がリリースされたばかりなので、限りなく bullseye に近いです。

apt コマンドを使って wodim をインストールします。特権(root権限)が必要なので、`su` コマンドか `sudo` コマンドなどを使うことになるか思います。

```
apt install wodim
パッケージリストを読み込んでいます... 完了
依存関係ツリーを作成しています... 完了        
状態情報を読み取っています... 完了        
以下の追加パッケージがインストールされます:
  genisoimage
提案パッケージ:
  cdrkit-doc
以下のパッケージが新たにインストールされます:
  genisoimage wodim
アップグレード: 0 個、新規インストール: 2 個、削除: 0 個、保留: 6 個。
736 kB のアーカイブを取得する必要があります。
この操作後に追加で 2,642 kB のディスク容量が消費されます。
続行しますか? [Y/n]
```

cdrkit-doc は、ドキュメント(英文)ですが、入れておいて必要に応じて読むと、私が書いている機能以外についても知ることができるでしょう。

### CD/DVD ドライブの確認

私の CD/DVD ドライブはUSB接続なので、マシンに接続して dmesg で下記のようなメッセージを確認します。

```
[135541.216435] usb 1-1: new high-speed USB device number 6 using xhci_hcd
[135541.367575] usb 1-1: New USB device found, idVendor=0411, idProduct=00f9, bcdDevice= 2.40
[135541.367585] usb 1-1: New USB device strings: Mfr=96, Product=76, SerialNumber=63
[135541.367590] usb 1-1: Product: Mass Storage Device
[135541.367594] usb 1-1: Manufacturer: USB2.0 External
[135541.367597] usb 1-1: SerialNumber: DEF1104CEF61
[135541.371052] usb-storage 1-1:1.0: USB Mass Storage device detected
[135541.371811] scsi host4: usb-storage 1-1:1.0
[135542.386536] scsi 4:0:0:0: CD-ROM            Optiarc  DVD RW AD-7560A  DX09 PQ: 0 ANSI: 0
[135542.387693] scsi 4:0:0:0: Attached scsi generic sg2 type 5
[135542.401483] sr 4:0:0:0: Power-on or device reset occurred
[135542.405369] sr 4:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 cdda tray
[135542.405373] cdrom: Uniform CD-ROM driver Revision: 3.20
[135542.440286] sr 4:0:0:0: Attached scsi CD-ROM sr0
```

```
  Odayla  yabuki  ~  ls -la /dev/cdrom 
lrwxrwxrwx 1 root root 3  8月 21 14:17 /dev/cdrom -> sr0
  Odayla  yabuki  ~  ls -la /dev/dvd
lrwxrwxrwx 1 root root 3  8月 21 14:17 /dev/dvd -> sr0
  Odayla  yabuki  ~  ls -la /dev/sr0 
brw-rw----+ 1 root cdrom 11, 0  8月 21 16:27 /dev/sr0
  Odayla  yabuki  ~  id
uid=1000(yabuki) gid=1000(yabuki) groups=1000(yabuki),24(cdrom),25(floppy),27(sudo),29(audio),30(dip),44(video),46(plugdev),108(netdev),111(bluetooth),999(docker)
```

Debian GNU/Linux だと勝手に、/dev/sr0 へ /dev/cdrom や /dev/dvd からシンボリックリンクを作ってくれています。また、`id`コマンドで、自分のユーザが、/dev/sr0 に書き込めることを確認しています。

さて、接続を確認します。

```
  Odayla  yabuki  ~  wodim dev=/dev/cdrom -scanbus 
scsibus4:
        4,0,0   400) 'Optiarc ' 'DVD RW AD-7560A ' 'DX09' Removable CD-ROM
        4,1,0   401) *
        4,2,0   402) *
        4,3,0   403) *
        4,4,0   404) *
        4,5,0   405) *
        4,6,0   406) *
        4,7,0   407) *
```

ドライブが認識されています。

### iso イメージの取得

自分で、cd-image を作るなら、`genisoimage` コマンドについて調べてください。

私の場合は、目的が Thinkpad T480 の BIOS update のため、Lenovo のサイトからダウンロードします。一応データが化けていないか、md5sum コマンドで、サイトに掲示してある値とつき合わせておきます。

### お試し

自分のCD-Rの書き込み速度を確認しておきます。遅い分には時間がかかるだけなので、分からないなら0を指定するのがいいかもしれません。

私のドライブは書き込みは x24 の模様です。

試し焼きのログです。

```
  Odayla  yabuki  ~  wodim -dummy -v speed=24 -eject -data -pad ~/Downloads/n24ur26w.iso 
wodim: No write mode specified.
wodim: Assuming -tao mode.
wodim: Future versions of wodim may have different drive dependent defaults.
TOC Type: 1 = CD-ROM
wodim: Operation not permitted. Warning: Cannot raise RLIMIT_MEMLOCK limits.
Device was not specified. Trying to find an appropriate drive...
Looking for a CD-R drive to store 33.36 MiB...
Detected CD-R drive: /dev/cdrw
Using /dev/cdrom of unknown capabilities
scsidev: '/dev/cdrom'
devname: '/dev/cdrom'
scsibus: -2 target: -2 lun: -2
Linux sg driver version: 3.5.27
Wodim version: 1.1.11
Driveropts: 'burnfree'
SCSI buffer size: 64512
Device type    : Removable CD-ROM
Version        : 0
Response Format: 2
Capabilities   : 
Vendor_info    : 'Optiarc '
Identification : 'DVD RW AD-7560A '
Revision       : 'DX09'
Device seems to be: Generic mmc2 DVD-R/DVD-RW.
Current: 0x0009 (CD-R)
Profile: 0x0012 (DVD-RAM) 
Profile: 0x0015 (DVD-R/DL sequential recording) 
Profile: 0x0016 (DVD-R/DL layer jump recording) 
Profile: 0x002B (DVD+R/DL) 
Profile: 0x001B (DVD+R) 
Profile: 0x001A (DVD+RW) 
Profile: 0x0014 (DVD-RW sequential recording) 
Profile: 0x0013 (DVD-RW restricted overwrite) 
Profile: 0x0011 (DVD-R sequential recording) 
Profile: 0x0010 (DVD-ROM) 
Profile: 0x000A (CD-RW) 
Profile: 0x0009 (CD-R) (current)
Profile: 0x0008 (CD-ROM) 
Profile: 0x0002 (Removable disk) 
Using generic SCSI-3/mmc   CD-R/CD-RW driver (mmc_cdr).
Driver flags   : MMC-3 SWABAUDIO BURNFREE 
Supported modes: TAO PACKET SAO SAO/R96P SAO/R96R RAW/R16 RAW/R96P RAW/R96R
Drive buf size : 1895168 = 1850 KB
Beginning DMA speed test. Set CDR_NODMATEST environment variable if device
communication breaks or freezes immediately after that.
FIFO size      : 12582912 = 12288 KB
Track 01: data    33 MB         padsize:   30 KB
Total size:       38 MB (03:47.93) = 17095 sectors
Lout start:       38 MB (03:49/70) = 17095 sectors
Current Secsize: 2048
ATIP info from disk:
  Indicated writing power: 4
  Is not unrestricted
  Is not erasable
  Disk sub type: Medium Type A, high Beta category (A+) (3)
  ATIP start of lead in:  -11849 (97:24/01)
  ATIP start of lead out: 359847 (79:59/72)
Disk type:    Long strategy type (Cyanine, AZO or similar)
Manuf. index: 25
Manufacturer: Taiyo Yuden Company Limited
Blocks total: 359847 Blocks current: 359847 Blocks remaining: 342752
Speed set to 4234 KB/s
Starting to write CD/DVD at speed  24.0 in dummy TAO mode for single session.
Last chance to quit, starting dummy write in    0 seconds. Operation starts.
Waiting for reader process to fill input buffer ... input buffer ready.
Starting new track at sector: 0
Track 01:   33 of   33 MB written (fifo 100%) [buf  99%]  11.7x.
Track 01: writing  30 KB of pad data.
Track 01: Total bytes read/written: 34975744/35006464 (17093 sectors).
Writing  time:   28.310s
Average write speed   8.1x.
Min drive buffer fill was 99%
Fixating...
WARNING: Some drives don't like fixation in dummy mode.
Fixating time:    0.037s
BURN-Free was never needed.
wodim: fifo had 551 puts and 551 gets.
wodim: fifo was 0 times empty and 343 times full, min fill was 96%.
```

それぞれのオプションの意味は、2021-08-21 に実行している時点の man から引用

```
       -dummy The CD/DVD-Recorder will go through all steps of the recording process, but the laser is turned off during  this  proce‐
              dure.   It  is  recommended to run several tests before actually writing to a Compact Disk or Digital Versatile Disk, if
              the timing and load response of the system is not known.

       -v     Increment the level of general verbosity by one.  This is used e.g. to display the progress of the writing process.

       -eject Eject disk after doing the work.  Some devices (e.g. Philips) need to eject the medium before creating a new disk. Doing
              a -dummy test and immediately creating a real disk would not work on these devices.

       -data  If  this  flag  is  present, all subsequent tracks are written in CD-ROM mode 1 (Yellow Book) format. The data size is a
              multiple of 2048 bytes.  The file with track data should contain  an  ISO-9660  or  Rock  Ridge  filesystem  image  (see
              genisoimage for more details). If the track data is an ufs filesystem image, fragment size should be set to 2 KB or more
              to allow CD-drives with 2 KB sector size to be used for reading.

              -data is the default, if no other flag is present and the file does not appear to be of one of the well known audio file
              types.

              If  neither -data nor -audio have been specified, wodim defaults to -audio for all filenames that end in .au or .wav and
              to -data for all other files.

       -pad   If the track is a data track, 15 sectors of zeroed data will be added to the end of this and each subsequent data track.
              In  this  case,  the  -pad  option  is superseded by the padsize= option. It will remain however as a shorthand for pad‐
              size=15s.  If the -pad option refers to an audio track, wodim will pad the audio data to be a multiple  of  2352  bytes.
              The audio data padding is done with binary zeroes which is equal to absolute silence.

              -pad remains valid until disabled by -nopad.
```

本番では、-dummy を抜いて実行します。

```
  Odayla  yabuki  ~  wodim -v speed=24 -eject -data -pad ~/Downloads/n24ur26w.iso 
wodim: No write mode specified.
wodim: Assuming -tao mode.
wodim: Future versions of wodim may have different drive dependent defaults.
TOC Type: 1 = CD-ROM
wodim: Operation not permitted. Warning: Cannot raise RLIMIT_MEMLOCK limits.
Device was not specified. Trying to find an appropriate drive...
Looking for a CD-R drive to store 33.36 MiB...
Detected CD-R drive: /dev/cdrw
Using /dev/cdrom of unknown capabilities
scsidev: '/dev/cdrom'
devname: '/dev/cdrom'
scsibus: -2 target: -2 lun: -2
Linux sg driver version: 3.5.27
Wodim version: 1.1.11
Driveropts: 'burnfree'
SCSI buffer size: 64512
Device type    : Removable CD-ROM
Version        : 0
Response Format: 2
Capabilities   : 
Vendor_info    : 'Optiarc '
Identification : 'DVD RW AD-7560A '
Revision       : 'DX09'
Device seems to be: Generic mmc2 DVD-R/DVD-RW.
Current: 0x0009 (CD-R)
Profile: 0x0012 (DVD-RAM) 
Profile: 0x0015 (DVD-R/DL sequential recording) 
Profile: 0x0016 (DVD-R/DL layer jump recording) 
Profile: 0x002B (DVD+R/DL) 
Profile: 0x001B (DVD+R) 
Profile: 0x001A (DVD+RW) 
Profile: 0x0014 (DVD-RW sequential recording) 
Profile: 0x0013 (DVD-RW restricted overwrite) 
Profile: 0x0011 (DVD-R sequential recording) 
Profile: 0x0010 (DVD-ROM) 
Profile: 0x000A (CD-RW) 
Profile: 0x0009 (CD-R) (current)
Profile: 0x0008 (CD-ROM) 
Profile: 0x0002 (Removable disk) 
Using generic SCSI-3/mmc   CD-R/CD-RW driver (mmc_cdr).
Driver flags   : MMC-3 SWABAUDIO BURNFREE 
Supported modes: TAO PACKET SAO SAO/R96P SAO/R96R RAW/R16 RAW/R96P RAW/R96R
Drive buf size : 1895168 = 1850 KB
Beginning DMA speed test. Set CDR_NODMATEST environment variable if device
communication breaks or freezes immediately after that.
FIFO size      : 12582912 = 12288 KB
Track 01: data    33 MB         padsize:   30 KB
Total size:       38 MB (03:47.93) = 17095 sectors
Lout start:       38 MB (03:49/70) = 17095 sectors
Current Secsize: 2048
ATIP info from disk:
  Indicated writing power: 4
  Is not unrestricted
  Is not erasable
  Disk sub type: Medium Type A, high Beta category (A+) (3)
  ATIP start of lead in:  -11849 (97:24/01)
  ATIP start of lead out: 359847 (79:59/72)
Disk type:    Long strategy type (Cyanine, AZO or similar)
Manuf. index: 25
Manufacturer: Taiyo Yuden Company Limited
Blocks total: 359847 Blocks current: 359847 Blocks remaining: 342752
Speed set to 4234 KB/s
Starting to write CD/DVD at speed  24.0 in real TAO mode for single session.
Last chance to quit, starting real write in    0 seconds. Operation starts.
Waiting for reader process to fill input buffer ... input buffer ready.
Performing OPC...
Starting new track at sector: 0
Track 01:   33 of   33 MB written (fifo 100%) [buf  99%]  11.7x.
Track 01: writing  30 KB of pad data.
Track 01: Total bytes read/written: 34975744/35006464 (17093 sectors).
Writing  time:   30.989s
Average write speed   9.3x.
Min drive buffer fill was 99%
Fixating...
Fixating time:   28.828s
BURN-Free was never needed.
wodim: fifo had 551 puts and 551 gets.
wodim: fifo was 0 times empty and 342 times full, min fill was 96%.
```

無事にCD-Rが焼けたようです。あとは、このCD-Rからbootして、Thinkpad T480のBIOSを更新するだけです。

無事にbootable CD-Rが焼けてBIOS更新できました。

## 参考にしたドキュメントたち

- [BurnCd - Debian Wiki](https://wiki.debian.org/BurnCd)
- [cdrecord が wodim になっていた](http://www.ice.is.kit.ac.jp/~umehara/misc/comp/20061122.html)

- Thinkpad T480 関連
  - [シリアル番号の探し方 - PC - Lenovo Support JP](https://support.lenovo.com/jp/ja/solutions/HT510152#cmm)

## 謝辞

wodim をメンテナンスしている人たちへ謝辞を送ります。また参考にしたドキュメントを書いた方々にも謝辞を送ります。

## 将来の自分ためのメモ

- 自分の機種
  - [ポータブルDVDドライブ | バッファロー](https://www.buffalo.jp/product/detail/dvsm-p58u2_b.html)
    - ファームウェアの更新情報は見つけることができなかった。

- ファームウェア
  - 現在のバージョンは、DX09 というのが、wodim のメッセージから分かる。
  - 新しいバージョンは、 [Optiarc AD-7560A Firmware Downloads - Firmware HQ](https://www.firmwarehq.com/Optiarc/AD-7560A/files.html) にあるようだが、下記の3点で、更新に躊躇している。問題にぶつかるまではいまのままでも良いような気もする。
    - (1)出自がいまいち分からない
    - (2)どれをあてていいのかわからない。
    - (3)更新方法がわからない。

ちなみに、wodim のドキュメントを読むと、ファームのバグで書き込みに失敗する事例があり問題切り分けをしてパグレポートをするときに何をリファレンスとするか注意すること。

## さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-08-21|
|記事を変更した日|2024-10-23|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。

<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->

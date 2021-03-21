---
title: "Debian bullseye Early Access"
emoji: "🗂"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Debian]
published: true
---
<!-- 文章の目的は何か -->
  <!-- 読み手に何の情報を伝えるのか -->
  <!-- 読んだひとにどういう行動をしてもらいたいのか -->
<!-- だれに向けての文章か -->
<!-- この文章の肝はどこか -->
# 要約

この記事を書いている段階で、Debian 11 Bullseye のインストーラーを
試す方法を記録として残しておきます。

usb stick memory を使って、Ryzen 7の入った、Lenovo M75t へインストールします。

とくにおすすめは、AMDのRyzenを使っているひとは、これを使うと新しめのカーネルを
つかってインストールできるので、使う価値があると考えます。

これを書いている段階では、Kernel 5.10.0-4 がインストールされます。

# はじめに

作業をやった部分から、更新します。

## この文章を書いた動機

Debian installer をテストするときに、スムーズにいくように。ドキュメント整備する。自分がやったことを他人にしてもらうため。

## この文章はだれ向けか

Linux のコンソールを使っている。かつ Debian installer のテストをしたい人。Install時から新しめのカーネルを使って Ryzen を動かしたい人

## この文書の読み方

# つかったもの

## PC

Lenovo M75t Ryzen 7

## secure boot

enabled

# 手順

概略の手順として、下記の順番になります。

1. isoのダウンロード
1. usb memory stick の用意
1. usb へ iso イメージを書き込む。　
1. usb から boot するように、bios を設定してreboot
1. installer を実行

installer を実行した後に、今回のスペシャルメニューとして
ibus-mozc をインストールすると、自動的に日本語が入力
可能になるかを試します。

上記は、Debian の Default である、Gnome が、絵文字を使うために
パッケージを追加したので、ibus が必須になったためです。

Gnome 以外をインストールして、日本語環境を設定したり、Gnome でも自分で日本語環境を im-conrfig などを使って設定できるなら、べつに好きな方法を使えばいいかと思います。あくまでも既定値でインストールしたときに日本語がはいらない。というのを救う手段なので。

## isoのダウンロード

[Index of /cdimage/weekly-builds/amd64/iso-dvd](https://cdimage.debian.org/cdimage/weekly-builds/amd64/iso-dvd/) から、iso イメージをダウンロードします。でかいので、ぼちぼちどうぞ。

## usb memory stick の用意

上記の DVD image が、3.7Gなんで、それより大きい usb memory stick を用意します。最近は安価に出回っているので、中身を潰してもいいヤツを確保してください。

## usb へ iso image を書き込む

*注意* usb memory の中身を上書きします。

### 確認方法

#### Linux マシンでの確認方法

usb memory stick を linux machine にさして、 dmesg を確認して、/dev/sdX のxが何に割当たっているか確認します。ここを間違えると、正常な機器をぶっ壊すことになるので、指差し呼称をして確認するぐらいの慎重さがいるでしょう。

usb meory stick をぶっ刺してから sudo dmesg すると

下記のようなメッセージが、出ているはずです。

```
[97646.998501] usb-storage 4-1.1:1.0: USB Mass Storage device detected
[97646.999332] scsi host5: usb-storage 4-1.1:1.0
[97648.191812] scsi 5:0:0:0: Direct-Access     I-O DATA USB Flash Disk   1100 PQ: 0 ANSI: 6
[97648.192778] sd 5:0:0:0: Attached scsi generic sg3 type 0
[97648.193966] sd 5:0:0:0: [sdd] 15694656 512-byte logical blocks: (8.04 GB/7.48 GiB)
[97648.194630] sd 5:0:0:0: [sdd] Write Protect is off
[97648.194636] sd 5:0:0:0: [sdd] Mode Sense: 22 00 00 00
[97648.195299] sd 5:0:0:0: [sdd] Write cache: disabled, read cache: enabled, doesn't support DPO or FUA
[97648.210616]  sdd: sdd1 sdd2
[97648.214339] sd 5:0:0:0: [sdd] Attached SCSI removable disk
```

### 書き込み

`$sudo cp path/to/debian-testing-amd64-DVD-1.iso /dev/sdX`

で書き込みます。ネットでは様々な方法で書き込む方法が掲示してありますが、ここではDebianの前のバージョン buster のインストール方法で述べてある方法を使いました。

私の場合は上記の情報から、下記になります。**各自の環境は違うのでこのままコピペ実行しないで**

```
sudo  cp /home/yabuki/Downloads/debian-testing-amd64-DVD-1.iso /dev/sdd
```

素っ気なく、なにもメッセージがでることなく、終わります。書き込みが無事に全部終わっていることを確認すべく、sync コマンドを実行しておくのが良いでしょう。
心配性のひとは、accessランプがついた、usb memory stick を使うといいのでは。

わたしは、CPコマンドが帰ってきてから、sync 三回ぐらいしたら、おもむろに usb を引っこ抜いて、Lenovo M75t にさします。

### usbからbootするように、biosを変更する。

F1を使う作法や、DELを使う作法などありますが、Lenovo M75t は F1 でした。ユーザマニュアルを見ましょう。中にアクセスしてハードウェアの確認などで読むでしょ?



# 参考にしたドキュメントたち



# 謝辞


# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-03-21|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。



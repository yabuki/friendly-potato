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

Debian 11 Bullseye のインストーラを試す方法です。これは記録です。

usb memory stick を使って、Ryzen 7の入った、Lenovo M75t gen2 へインストールします。

AMDのRyzenを使っているひとは、Debian bullseye installer を使うと新しめのカーネルを
つかってインストールできるので、Ryzen/Ryzen APU/GPUの対応が進んでおり、使う価値があると考えます。

これを書いている段階では、Kernel 5.10.0-4 がインストールされます。内容は試した
時期によって変わることがあります。

# はじめに

作業をやった部分から、更新します。

## この文章を書いた動機

Debian installer をテスト時、まごつかないようにドキュメントを整備する。

自分がやったことを他人にも試してもらうため。

## この文章はだれ向けか

Linux のコンソールを使っている。かつ Debian installer のテストをしたい人。Install時から新しめのカーネルを使って Ryzen を動かしたい人

## この文書の読み方

# つかったもの

## PC

Lenovo M75t gen 2  Ryzen 7 

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

上記は、Debian の Default、Gnome が、絵文字を使うためパッケージが追加されたので、ibus が必須となったためです。

Gnome 以外をインストールして、日本語環境を設定したり、Gnome でも自分で日本語環境を im-conrfig などを使って設定できるなら、べつに好きな方法を使えば良い。

あくまでも既定値でインストールしたとき日本語がはいらない。というのを救う手段なので。

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

<!-- @suppress SuggestExpression -->
`$sudo cp path/to/debian-testing-amd64-DVD-1.iso /dev/sdX`

で書き込みます。

ネットでは様々な方法で書き込む方法が掲示してあります。ここではDebianの前バージョン buster におけるインストール方法で書いている方法を使いました。[^1]

上記の情報から、下記になります。**あなたの環境はわたしと違います。コピペ実行しないで**

間違えて書き込むと書き込んだ先のデータが潰れます。

```
sudo  cp /home/yabuki/Downloads/debian-testing-amd64-DVD-1.iso /dev/sdd
```

素っ気なく、なにもメッセージがでることなく、終わります。書き込みが無事に全部終わっているか確認すべく、sync コマンドを実行しておくのが良いでしょう。
心配性のひとは、accessランプがついた、usb memory stick を使うといいでしょう。

わたしは、CPコマンドが帰ってから、sync を三回実行します。

そして、おもむろに usb を引っこ抜いて、Lenovo M75t gen 2 にさします。

### usbからbootするように、biosを変更する。

F1を使う作法や、DELを使う作法などありますが、Lenovo M75t gen 2 は F1 でした。ユーザマニュアルを見ましょう。[^2] 

### install

とくに、初期状態だと、日本語を選択したあとは、マシン名とか、rootやユーザ設定をするぐらい。

ディスクの切り方にこだわりがあるなら、好きなように切ってください。

わたしは HDDとM2 を積んでいるので、/ は btrfs とした。
swap はHDDに置きました。SWAPすると負け前提です。

その他はとくに気にならなかった。 secure boot も on 設定のままでした。

しかし、bios を変更せずに、インストール後 boot した。

desktop とかも、わざとdefault 設定のまま、gnome でやった。

### 追加でやったこと

Gnome を選択したので、ログインしたら当然gnomeがあがってくる。

sudo の設定はせずに root を有効にしていたため、`su -` したい。

Gnome検索で　term を入力すると gnome-terminal? が選べる

そのターミナルで、`su -`する。

そのあと`apt update;apt install ibus-mozc` を実行する。DVDを入れろといわれるので、もうネットワークにつながっているなら、

`vi /etc/apt/source.ist`を実行し、DVDの参照をやめてしまおう。

apt lineが、初期値では main  のみになので、必要に応じて contrib や non-free を追加する。

ログアウトして、ログインしたら gnome-terminal で ibus-mozc が動いているのが確認できる。

ちなみに、つないだキーボードがHHK Professional でした。漢字キーを探すのが面倒で、全部GUIで日本語入力をonにしました。使い込むなら、このへんも ibus-setup あたりで確認して設定するのでしょうね。　

### 別の記事でやる予定

下記のリストは、別の記事でやる予定です。

- 画面解像度を変える
- 自分が主に使っている i3wm へ変更方法
- NICOLA(親指シフト)入力が恋しいので、その設定方法

# 参考にしたドキュメントたち

参考にしたドキュメントは、footnote に番号で対応付けてあります。

[^1]:[Debian GNU/Linux インストールガイド](https://www.debian.org/releases/bullseye//amd64/install.ja.pdf) の 「4.3 USB メモリでの起動用ファイルの準備」
[^2]:[m75t_gen2_ug_ja.pdf](https://download.lenovo.com/pccbbs/thinkcentre_pdf/m75t_gen2_ug_ja.pdf)


# 謝辞

2021-03-22 に開催された、Debian 勉強会にて、情報を頂いた各位

# さいごに

|     件名       |   日付   |
|:----           |:----:|
|記事を書いた日  |2021-03-21|
|記事を変更した日|----------|

上記は、この記事の鮮度を判断する一助のために書き手が載せたものです。

詳細な変更履歴は、 [GitHub - yabuki/friendly-potato: zenn-contents](https://github.com/yabuki/friendly-potato) を参照してください。

記事に対するTypoの指摘などは、pull reqをしてもらえるとありがたいです。受け入れるかどうかは、差分とPull reqの文章で判断いたします。



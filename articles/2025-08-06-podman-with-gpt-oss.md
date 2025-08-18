---
title: "自作PCでGPT-OSSを動かす"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [debian, podman, ollama, llm]
published: true
---
## 要約

自作PCで、話題のGPT-OSSを動かす。

## はじめに



### この記事を書いた動機

もうすぐ、新しいリリースがでるDebian GNU/Linuxの安定版を使わなくても、現行のDebian 12(bookworm)でLLMを活用できる。
また、収録されているソフトウェアよりもハードウェアの選択と収録されているソフトウェアの設定に気にかけてやりたいことを実現する方法について記述したかった。

外に出せない情報をローカルで動かすLLMで、処理する知見をアウトプットしておきたい。リミットレートを気にせずにつかうことで新しい使い方に気がつく可能性もあるから。

### この記事はだれ向けか

自作PCでローカルLLMを動かす事例を見たい人

### この記事の読み方

前提条件を確認後に必要な部分を読んでください。


本記事を参考にして設定をする時には、確認方法も一緒に実行して確認してください。
うまくいかないのは、だいたい前提条件を満たしてないとか、ちゃんと設定を確認できてないなどのケアレスミスが多いからです。丁寧な確認が結局は早道です。

## 前提条件

- ハードウェア
    - 下記のscreenfetchの結果を参照してください。

```
screenfetch
         _,met$$$$$gg.           yabuki@Orlanth
      ,g$$$$$$$$$$$$$$$P.        OS: Debian 12 bookworm
    ,g$$P""       """Y$$.".      Kernel: x86_64 Linux 6.12.12+bpo-amd64
   ,$$P'              `$$$.      Uptime: 8d 22h 19m
  ',$$P       ,ggs.     `$$b:    Packages: 2485
  `d$$'     ,$P"'   .    $$$     Shell: bash
   $$P      d$'     ,    $$P     Resolution: 3780x2160
   $$:      $$.   -    ,d$$'     WM: i3
   $$\;      Y$b._   _,d$P'      GTK Theme: Adwaita [GTK3]
   Y$$.    `.`"Y$$$$P"'          Disk: 5.8T / 14T (43%)
   `$$b      "-.__               CPU: AMD Ryzen 7 5700G with Radeon Graphics @ 16x 4.673GHz
    `Y$$                         GPU: AMD Radeon Graphics (gfx1100, LLVM 15.0.6, DRM 3.59, 6.12.12+bpo-amd64)
     `Y$$.                       RAM: 31251MiB / 128614MiB
       `$$b.                    
         `Y$$b.                 
            `"Y$b._             
                `""""           
```

Diskに関しては、本体に1TのSSDと、/varに1TのHDDをbtrfsでmountしています。後述するようにLLMのモデルは大きいものがおおいので複数のモデルを切り替えるなら、ある程度大きなDiskを備えておくのが良いでしょう。
なぜ、/varにDiskを追加しているかは、Linuxの場合、(今回は使いませんが)DockerやIncus(LXD)などのコンテナ基盤が大量に領域を使うからです。まともな管理者ならdisk fullにしてシステムを止めないように監視プログラムなどの対策をしているとおもいますが、小さいと管理のオーバーヘッドばかり大きくなって気軽にソフトウェアを試せなくなります。
Incusのコンテナで、gmini-cliなど試す記事は別途書く予定です。タイミングはと今月にでるであろうDebian 13(trixie)のリリース後になります。

また、autofsで必要にに応じてNFSマウントをしており、使用頻度が低くなったデータで消せないものなどはどんどんNASに追い出しています。

必要なコマンドは、install済みとします。今回は、podmanです。podmanのインストールに関しては、[Postgresqlをpodman-composeでDebian Bookworm 上で動かす。2025/04版](https://zenn.dev/yabuki/articles/2025-04-21-postgresql-with-podman-compose)が、2025-08-07 時点でも参考になります。

## 本文

### ROCmの設定

参考文献5のrocm-podman-supportをインストールします。apt-proxy-ngパッケージも入ります。

```
/usr/bin/rocm-podman-setup -h
 
Verifies that a given user can use an AMD GPU in a rootless podman container.
 
If USER isn't specified, then the invoking user will be checked.
 
Synopsis:
  /usr/bin/rocm-podman-setup -h
 
  /usr/bin/rocm-podman-setup [-u USER]
 
Options:
  -h     Show this help
 
Examples:
 
  $ /usr/bin/rocm-podman-setup
 
  $ /usr/bin/rocm-podman-setup -u someuser
```

`/usr/bin/rocm-podman-setup`を実行すると下記のように修正点を教えてくれます。

```
Checks
======
  [OK] Key packages are installed
  [OK] Local APT cache detected, make sure to use it
  [OK] /dev/kfd is present
  [OK] Group 'render' is present
[TODO] User 'yabuki' is not in group 'render'.
       You can fix this with: sudo gpasswd -a yabuki render
  [OK] User 'yabuki' is in group 'video'
  [OK] unprivileged_userns_clone is enabled
[TODO] /etc/subgid is missing a subordinate GID mapping for user 'yabuki' group 'render'.
       You can fix this by adding the folowing line to /etc/subgid:
           yabuki:105:1
[TODO] /etc/subgid is missing a subordinate GID mapping for user 'yabuki' group 'video'.
       You can fix this by adding the folowing line to /etc/subgid:
           yabuki:44:1
  [OK] /etc/subgid contains a large subordinate GID range
  [OK] /etc/subuid contains a large subordinate UID range
```
修正して再実行し、下記の結果がでてlogout/loginして有効にします。
```
Checks
======
  [OK] Key packages are installed
  [OK] Local APT cache detected, make sure to use it
  [OK] /dev/kfd is present
  [OK] Group 'render' is present
  [OK] User 'yabuki' is in group 'render'
  [OK] User 'yabuki' is in group 'video'
  [OK] unprivileged_userns_clone is enabled
  [OK] /etc/subgid contains a subordinate GID mapping for user 'yabuki' group 'render'
  [OK] /etc/subgid contains a subordinate GID mapping for user 'yabuki' group 'video'
  [OK] /etc/subgid contains a large subordinate GID range
  [OK] /etc/subuid contains a large subordinate UID range
```


### ollamaをpodmanで動かす。

自作マシンには、ASUS製のRX7900XTX 24GBを載せている。そのためAMDの[ROCm™ 7 ソフトウェア](https://www.amd.com/ja/products/software/rocm/whats-new.html)が供給しているソフトウェアを使うのが良い。ollamaはROCm入りのコンテナ・イメージを供給している。(参考文献2)
podmanで利用するには、下記のコマンドを実行する。

```
podman run -d --device /dev/kfd --device /dev/dri -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama:rocm
```

上記のコマンドで、ollamaを起動する。gpt-oss:20bをコマンドラインで実行するのに、ollama pullなどでもモデルを取ってこれるが、
```
podman exec -it ollama ollama run gpt-oss:20b
```

とすると、参考文献3にあるリストのモデルを取ってきて実行する。これらのモデルも大きい物がおおい。

![13GBを越えるgpt-oss:20bのでーた量](/images/2025-08-07_08-02.png)
*13GBを越えるgpt-oss:20bのデータ量をダウンロードしている様子*

GPT-OSSについては、参考文献4参照すること。

こんな感じで動いています。
https://youtu.be/IatGpNTCZbU

### ollamaでGPT OSS:20Bを動かした所感

まずは、モデルの大きさが気になりました。

```
podman exec -it ollama ollama ls
NAME           ID              SIZE     MODIFIED    
gpt-oss:20b    f2b8351c629c    13 GB    9 hours ago 
```
*ollamaコマンドで取得してきたモデルを確認してみた例*

podmanがイメージを置いている場所を確認して、大きなイメージをいっぱい置いても大丈夫にしたいですね。

また、ROCmが有効に動いているかを確認する方法はどうしたらいいのか。も気になりました。
暫定として`apt install -y radeontop` として、GPUのモニタリングをしてみることにしました。

![radeontop](/images/2025-08-07_16-39.png)
*radeontopの表示例*


追記予定としては、podmanのイメージ置き場をDisk容量に余裕のある/varに移す部分を書く予定です。

## 参考文献

1. [ollama/ollama - Docker Image | Docker Hub](https://hub.docker.com/r/ollama/ollama)
2. [ollama/ollama - Docker Image | Docker Hub](https://hub.docker.com/r/ollama/ollama#amd-gpu)
    - AMD GPUに対応する ROCmを利用するならここを参照すること。
3. [library](https://ollama.com/library)
4. [gpt-oss](https://ollama.com/library/gpt-oss)
5. [Debian -- trixie の rocm-podman-support パッケージに関する詳細](https://packages.debian.org/ja/trixie/rocm-podman-support)


## 謝辞


## さいごに

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-08-06|
|  記事を公開した日  |2025-08-07|
|  記事を変更した日  |2025-08-18|

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

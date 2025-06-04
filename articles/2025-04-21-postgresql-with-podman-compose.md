---
title: "Postgresqlをpodman-composeでDebian Bookworm 上で動かす。2025/04版"
emoji: "📌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [postgresql, podman, debian, docker]
published: true
---

:::message alert
2025-06-05 podmanのstorage方式の既定値がVFSだったので、OverlayFSに置き換える方法を追記しました。
:::

## 要約

Debian GNU/Linux bookwormで、Docker.ioを追加して、PostgresqlのOffical Docker Imageを動かします。

## はじめに

この記事を書いている、2025-04-21現在、Debian GNU/Linuxは、現行の12(コードネームbookworm)から次のバージョン13(コードネームtrixie)をリリースするためにパッケージのフリーズをしてバグ出しをしています。
2年単位でリリースされるDebian GNU/Linuxに収録されているDocker互換のPodmanとPodman-composeを使ってここまでできたという報告になります。

### この記事を書いた動機

Dockerは基本、rootで動くので、Dockerが作成するファイルはownerがrootになりがちです。一般ユーザーの領域にrootのファイルが置いてあると処置が面倒なんで、基本ユーザーで動くPodmanを使いたいと思っていました。

Debian GNU/Linuxに、PostgreSQLのパッケージは存在しますが、アプリケーション開発時にSQLiteの機能では足りないときに事実上Dockerコンテナを使うことが多々あるのと、ORMでコードをいっぱい書かないと実現できないことを、標準のSQLで確認する簡単に作って壊せる環境が欲しかったのもあります。

SQLを初心者だけでなく、中級者(caseとかを使いたくなった人向け)SQL関係の本を読みながら、手を動かすのにも良いので、記事にして、本と一緒に、これ読んで。と渡せるのが良いと考えています。

### この記事はだれ向けか

2種類の人を想定しています。

1. さくっとPostgreSQLを試したい。ちゃんとしたデータベースの設計(ハードウェアやパーティション、チューニング込み)は、それなりの必要が出てからでよいと思っている人です。
2. Debian系のディストリビューションを使っており、Dockerだけにbidするのは、いまいちだな。と思って別の方法のノウハウを貯めておきたいと動き始めた人です。

### この記事の読み方

この記事は、大別して2つトピックがあります。

1. Debian GNU/Linux 12(bookworm)で、PodmanをインストールしてDocker.ioからイメージを取得するようにする。
2. Podman-composeで、Docker.ioに登録されているOffical PostgreSQL imageをDocker-compose.ymlを書いて起動し、その使い方の説明をする。

です。片方のトピックだけ興味がある場合は、片方だけ読むのもありだと思います。

## 本文

### Debian GNU/Linux 12(bookworm)でPodman-composeをインストールする

私は、aptitudeを使っているので、PodmanとPodman-composeを指定して、インストールしました。aptでなら、

```
sudo apt install podman podman-compose containers-storage
```

でよいです。あとは、参考文献の1。にあるDebian Wikiを参考に確認していきます。

Podmanのインストール後の動作確認として

```
podman search --limit 3 quay.io/podman
```

を実行しておきます。

ここまでのステップでDocker.ioを追加します。

```
mkdir -p $HOME/.config/containers
echo 'unqualified-search-registries=["docker.io", "quay.io"]' > $HOME/.config/containers/registries.conf
```

ちゃんと登録できたかを確認します。

```
podman search postgresql
```

で、結果を見ます。

:::message

podmanは、storageのタイプを指定しないと、vfsが選択されます。
あとから、storageの変更をするには`podman system reset --force` を実行してデータを全部吹き飛ばす必要があります。
そのため、最初からstorage typeを好みのタイプにしておくのは結構重要です。

```ini:$HOME/.config/containers/storage.conf
[storage]
driver = "overlay"
```

などとしておきましょう。詳しくは `man 5 containers-storage.conf`を実行してください。containers-storage.confのマニュアルはcontainers-storageパッケージに入っているので入っていない場合はインストールしておきましょう。VFSだけならなくても困らないかもですが。VFSを使いつづけるの非効率です。

:::

### PostgreSQLのOffical ImageをPodman-composeで使う

参考文献の2で示す、PostgreSQLをオンメモリで使う設定は、ちょこっとSQLの独習にはちょうどいい。
テストデータをちょこっと入れたりとかにもいい。

留意点は下記

- 正しくDocker-compose.ymlをコピペしよう。
  - 間違えると、Podman-compose up -dするときに

```
  File "/usr/lib/python3/dist-packages/podman_compose.py", line 239, in <listcomp>
    dst = [i.split("=", 1) for i in src if i]
           ^^^^^^^
AttributeError: 'dict' object has no attribute 'split'
```

みたいなエラーでて、困ることがある。新しいバージョンだともっとロバストになっている可能性はあるが、まずは間違えないことが重要です。

#### Podman-composeに成功したら

下記のような表示がでて、サービスが起動します。

```
podman-compose up -d
['podman', '--version', '']
using podman version: 4.3.1
** excluding:  set()
['podman', 'network', 'exists', 'podman_default']
podman run --name=podman_db_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=podman --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=podman --label com.docker.compose.project.working_dir=/home/yabuki/podman --label com.docker.compose.project.config_files=docker-compose.yml --label com.docker.compose.container-number=1 --label com.docker.compose.service=db -e POSTGRES_PASSWORD=example --net podman_default --network-alias db --shm-size 128mb --restart always postgres
✔ docker.io/library/postgres:latest
Trying to pull docker.io/library/postgres:latest...
Getting image source signatures
Copying blob 07db60713289 done  
Copying blob 97cdd47d9131 done  
Copying blob 8a628cdd7ccc done  
Copying blob e4847368ad17 done  
Copying blob 2817206b0512 done  
Copying blob 3a6f8814136c done  
Copying blob 0c942aac37b1 done  
Copying blob 8c63b71925de done  
Copying blob 97f28320a07a done  
Copying blob 2a08aad74366 done  
Copying blob 6cea4d95608f done  
Copying blob c1b7de8085d1 done  
Copying blob f15c43cffa70 done  
Copying blob 6948dc7760c1 done  
Copying config f49abb9855 done  
Writing manifest to image destination
Storing signatures
0be0494caf057940ad75902d70e34338ae962f7022a38956ec1ae7c85878fe87
exit code: 0
['podman', 'network', 'exists', 'podman_default']
podman run --name=podman_adminer_1 -d --label io.podman.compose.config-hash=123 --label io.podman.compose.project=podman --label io.podman.compose.version=0.0.1 --label com.docker.compose.project=podman --label com.docker.compose.project.working_dir=/home/yabuki/podman --label com.docker.compose.project.config_files=docker-compose.yml --label com.docker.compose.container-number=1 --label com.docker.compose.service=adminer --net podman_default --network-alias adminer -p 8080:8080 --restart always adminer
✔ docker.io/library/adminer:latest
Trying to pull docker.io/library/adminer:latest...
Getting image source signatures
Copying blob dc6d32971fca done  
Copying blob 115c7a04f6c0 done  
Copying blob b1220d176a8d done  
Copying blob 0d55cff53123 done  
Copying blob 88d591373a19 done  
Copying blob f18232174bc9 done  
Copying blob ffeef6b41a56 done  
Copying blob 6d95abe48138 done  
Copying blob a80d3af78a9d done  
Copying blob f3fe38446507 done  
Copying blob c6d0aade0806 done  
Copying blob 4f4fb700ef54 done  
Copying blob e434f3dae19e done  
Copying blob 8b847f2809a2 done  
Copying blob 93b26376816c done  
Copying blob 52e9abf80869 done  
Copying config 8a5794f84c done  
Writing manifest to image destination
Storing signatures
a63aacb8933f810b366895c7173cc7f141e5f0d80c28b720706e3875832d3558
exit code: 0
```

PHPのデータベース管理のインタフェースであるadminerにアクセスするには、http://localhost:8080/か、http://動いている環境のIP:8080/にアクセスします。
ドキュメントどおりなら、ユーザー名:postgresパスワードはDocker-compose.ymlに書いているdatabase名はpostgresでアクセスできます。

一回動かしてしまえば、あとはドキュメントを読みながらちょこちょこと書き換えて試せます。

それじゃ、あとは動かして楽しんで！

### 2025-04-30 追記

#### ロケールをja_JP.utf8にする。およびタイムゾーンをAisa/Tokyoにする

Dockerと同じであるが、

Dockerfileを下記にする。

```Dockerfile
FROM postgres:17
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata
# containerの中では、systemdは動かないので、timezoneの設定
# は別の方法ですること。
run echo 'Asia/Tokyo' > /etc/timezone
ENV TZ=Asia/Tokyo
#run apt-get update && apt-get install -y postgresql-15
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
        && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8
ENV LANG ja_JP.utf8
```

```compose.yml
version: '3'
services:
  postgres:
    container_name: sample-db
    build: .
    restart: always
    ports: 
      - "5432:5432"
    volumes:
      - ./postgres/init:/docker-entrypoint-initdb.d
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
```

psqlは、`podman exec -it sample_db bash`してから、psql -U postgresで接続するとか
手元にapt install postgresql-clientをいれて、`psql -U postgres -h localhost -d データベース名`
とする。Debian stableのpostgresqlは15なので、17をつかっているので警告はでるが事実上は問題ない。

./postgres/init/の内容については、参考文献の3を参照のこと。初期化のsqlを置くことができる。

接続文字列としては、だいたい下記のようになってる。

```
DATABASE_URL=postgresql://[user[:password]@][host][:port]/[dbname]
```

```
DATABASE_URL=postgresql://[postgres:postgrespassword@localhost/[接続したいデータベース名]
```

## 参考文献

1. [Podman - Debian Wiki](https://wiki.debian.org/Podman)
2. [postgres - Official Image | Docker Hub](https://hub.docker.com/_/postgres/)
3. [【PostgreSQL】docker-composeで起動と初期データ投入 #Docker - Qiita](https://qiita.com/ke_suke0215/items/90deba2bf484293000fc)
## 謝辞

## さいごに

TypeScriptやPythonを使ったシステム構築や、プロジェクトのマネージメントなどシステム構築や開発のサポートなどお仕事を募集しております。
GitHubから[yabuki (YABUKI Yukiharu)](https://github.com/yabuki) 連絡お待ちしております。


|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-04-21|
|  記事を公開した日  |2025-04-21|
|  記事を変更した日  |2025-06-05|

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

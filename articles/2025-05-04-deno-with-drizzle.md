---
title: "Deno、DrizzleとPostgreSQLを使った開発イテレーション高速化 (2025/05版)"
emoji: "🚀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [Deno, drizzle, postgresql, podman, contest2025ts]
published: true
---

:::message alert
2025-05-30 compose.ymlにミスを見つけたので修正しました。
:::

## 要約

本記事では、TypeScriptランタイムとしてDeno、ORMとしてDrizzle、データベースとしてPostgreSQL、コンテナ管理としてPodmanおよびPodman Composeを用いた開発環境を構築し、開発イテレーションを高速化する方法を2025年5月時点の情報に基づいて解説します。

## はじめに

Kent Beck氏の『Tidy First?』や『テスト駆動開発』、Martin Fowler氏の『リファクタリング(第2版)』などの書籍で提唱されている原則は、本記事で目指す開発スタイルと親和性が高いです。これらの実践は、設計と実装の距離を縮め、開発イテレーションを高速化し、将来の変更に対する柔軟性を確保することに繋がります。

この記事では、その一環として筆者が試行錯誤中の開発環境を紹介します。

なお、podman/podman-composeは、docker/docker composeと互換があるので、dockerのエコシステムでも動くはずです。


### この記事の読み方

本記事では、環境構築から実際のコード実行までを順を追って説明します。各セクションで使用する技術についても解説しますので、順番にお読みいただくことを推奨します。

技術選択の理由や背景に興味がある方は、「この記事を書いた動機と意図」セクションもご覧ください。

この記事は特定の方法論を示し、その中で得られた知見や成果の一部を例として紹介するものです。タイトルに「2025/05版」とあるように、技術の進化やベストプラクティスの変化により、将来的には異なる解決方法が存在する可能性があることをご了承ください。

### この記事はだれ向けか

- 複数のプログラミング言語経験があり、TypeScriptのスキルを深めるためにシステム全体の構築を経験したい方。
- ORMが生成するSQLを確認する方法や、問題発生時の調査方法にも興味がある方。

## 本文

### 使った環境

- オペレーティング・システム: Debian GNU/Linux 12 (Bookworm)
- TypeScript実行環境: Deno 2.3.1 (またはそれ以降の安定版)
- コンテナ: Podman 4.3.1, Podman-compose 1.0.3 (Debian stableリポジトリ提供版)
    - Podman (podman version 4.3.1+ds1-8+deb12u1)
    - Podman-compose (1.0.3-3)
- PostgreSQL: 17 (コンテナイメージ)
- Drizzle ORM / Drizzle Kit: (インストールするバージョンに依存)

### ディレクトリ構造

プロジェクトルート（例: etude-podman-drizzle）は以下のようになります。
```
etude-podman-drizzle/
├── .env
├── Dockerfile  # PostgreSQLコンテナのカスタマイズ用
├── compose.yml # Podman Compose設定ファイル
├── deno.json   # Denoプロジェクト設定ファイル
├── deno.lock   # Denoロックファイル
├── drizzle/    # Drizzle Kitが生成するファイル (マイグレーションSQLやスキーマなど)
├── drizzle.config.ts # Drizzle Kit設定ファイル
├── postgres/
│   └── init/
│       └── init.sql # PostgreSQL初期化用SQL
└── src/
    ├── db/
    │   └── schema.ts # アプリケーション用DBスキーマ定義(Drizzle Kit生成物を元に作成・配置)
    └── scripts.ts   # 動作確認用スクリプト
```

### 設定手順

1. プロジェクトディレクトリ作成と初期化
任意の名前でプロジェクトディレクトリを作成します。

```bash
mkdir etude-podman-drizzle
cd etude-podman-drizzle
deno init # deno.json と deno.lock を生成
git init  # 必要に応じてGitリポジトリを初期化
```


2. Drizzle関連パッケージのインストール
Drizzle ORM、Drizzle Kit (スキーマ生成・マイグレーションツール)、およびPostgreSQLドライバをインストールします。

```bash
# Denoにnpmパッケージをインストール
deno install npm:drizzle-orm npm:drizzle-kit npm:pg npm:@types/pg
```

3. 設定ファイルの準備
以下の設定ファイルを作成します。詳しい内容はアコーディオン形式で示します。

:::details .env (環境変数ファイル)
データベース接続情報を記述します。compose.yml の設定と合わせてください。
```dotenv
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/sample_db"
```
:::

:::details Dockerfile(PostgreSQLイメージカスタマイズ用)
```Dockerfile
FROM postgres:17
RUN DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y tzdata
run echo 'Asia/Tokyo' > /etc/timezone
ENV TZ=Asia/Tokyo
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
        && localedef -i ja_JP -c -f UTF-8 -A /usr/share/locale/locale.alias ja_JP.UTF-8
ENV LANG ja_JP.UTF8
```
:::

:::details compose.yml(Podman Compose設定)

```compose.yml
version: '3'
services:
  postgres:
    build: . # Dockerfileを使う
    container_name: sample-db
    #image: postgres:17
    restart: always
    ports: 
      - "5432:5432"
    volumes:
      - ./postgres/init:/docker-entrypoint-initdb.d
      # 永続化が必要なら、下記のpostgres_dataのコメントを外せ
      # - postgres_data:/var/lib/postgresql/data # データ永続化のためボリュームを追加推奨
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "postgres"
      # POSTGRES_DB: "sample_db" # DB名をここで指定するとテーブルができない。
      TZ: "Asia/Tokyo"         # コンテナのタイムゾーン設定
      PGTZ: "Asia/Tokyo"       # PostgreSQL内部のタイムゾーン設定
#volumes: # トップレベルにvolumesセクションを追加
- #  postgres_data:
```

2025-05-30 追記

compose.ymlでデータベースを指定してしまうと、init.sqlで
CREATE DATABASE 文で失敗するので、後に続くinit.sqlの内容
が失敗する。なのでここは、指定しないのが正解です。

:::

:::details init.sql(PostgreSQL初期化スクリプト)

``` postgres/init/init.sql
-- DB作成
-- compose.ymlで定義したので、init.sqlでは実行しなくてよい。
-- CREATE DATABASE sample_db;
--CREATE DATABASE test
--   LOCALE_PROVIDER icu
--   ICU_LOCALE "en-US"
--   LOCALE "en_US.utf8"
--   TEMPLATE template0;
-- テーブル作成
-- テーブル種別
DROP TABLE IF EXISTS table_kind;
CREATE TABLE table_kind (
  id serial NOT NULL PRIMARY KEY, -- 1から2,147,483,647の値を取り扱う
  table_name text NOT NULL,
  unique (table_name)
);

insert into table_kind(table_name) values('健康保険標準報酬テーブル');
insert into table_kind(table_name) values('厚生年金標準報酬テーブル');

-- 適用開始
DROP TABLE IF EXISTS yukou;
CREATE TABLE youkou (
  id serial NOT NULL PRIMARY KEY, -- 1から2,147,483,647の値を取り扱う
  shubetu int NOT NULL, --  -2,147,483,648から2,147,483,647の整数を取り扱う
  beginDate date NOT NULL, -- この日付(月)から適用、次月が最初の引き落とし
  endDate date, -- この日付は含まない。半開区間になる。
  unique (shubetu, beginDate)
);

-- 健康保険テーブル
-- 地方やどこの健保組合かで異なるので、テーブルを分ける。テーブル名は暫定
DROP TABLE IF EXISTS kenpo_money;
CREATE TABLE kenpo_money (
  table_version smallint NOT NULL, -- テーブルのバージョン
  grade smallint NOT NULL, -- 等級
  base money NOT NULL, -- 標準報酬月額
  lowerValue money, -- 報酬月額(以上)
  highValue money, -- 報酬月額(以下)
  unique (table_version, grade, base) -- テーブルのバージョン、等級および標準月額報酬はユニーク
);

-- 厚生年金テーブル
DROP TABLE IF EXISTS kousei_money;
CREATE TABLE kousei_money (
  table_version smallint NOT NULL, -- テーブルのバージョン
  grade smallint NOT NULL, -- 等級
  base money NOT NULL, -- 標準報酬月額
  lowerValue money, -- 報酬月額(以上)
  highValue money, -- 報酬月額(以下)
  unique (table_version, grade, base) -- テーブルのバージョン、等級および標準月額報酬はユニーク
);

-- 都道府県JISコード(JIS X0401)
DROP TABLE IF EXISTS jis_x0401;
CREATE TABLE jis_x0401 (
  prefecture_id smallint NOT NULL PRIMARY KEY,
  name varchar(10) NOT NULL
);

insert into jis_x0401(prefecture_id, name) values(1,'北海道');
insert into jis_x0401(prefecture_id, name) values(2,'青森県');
insert into jis_x0401(prefecture_id, name) values(3,'岩手県');
insert into jis_x0401(prefecture_id, name) values(4,'宮城県');
insert into jis_x0401(prefecture_id, name) values(5,'秋田県');
insert into jis_x0401(prefecture_id, name) values(6,'山形県');
insert into jis_x0401(prefecture_id, name) values(7,'福島県');
insert into jis_x0401(prefecture_id, name) values(8,'茨城県');
insert into jis_x0401(prefecture_id, name) values(9,'栃木県');
insert into jis_x0401(prefecture_id, name) values(10,'群馬県');
insert into jis_x0401(prefecture_id, name) values(11,'埼玉県');
insert into jis_x0401(prefecture_id, name) values(12,'千葉県');
insert into jis_x0401(prefecture_id, name) values(13,'東京都');
insert into jis_x0401(prefecture_id, name) values(14,'神奈川県');
insert into jis_x0401(prefecture_id, name) values(15,'新潟県');
insert into jis_x0401(prefecture_id, name) values(16,'富山県');
insert into jis_x0401(prefecture_id, name) values(17,'石川県');
insert into jis_x0401(prefecture_id, name) values(18,'福井県');
insert into jis_x0401(prefecture_id, name) values(19,'山梨県');
insert into jis_x0401(prefecture_id, name) values(20,'長野県');
insert into jis_x0401(prefecture_id, name) values(21,'岐阜県');
insert into jis_x0401(prefecture_id, name) values(22,'静岡県');
insert into jis_x0401(prefecture_id, name) values(23,'愛知県');
insert into jis_x0401(prefecture_id, name) values(24,'三重県');
insert into jis_x0401(prefecture_id, name) values(25,'滋賀県');
insert into jis_x0401(prefecture_id, name) values(26,'京都府');
insert into jis_x0401(prefecture_id, name) values(27,'大阪府');
insert into jis_x0401(prefecture_id, name) values(28,'兵庫県');
insert into jis_x0401(prefecture_id, name) values(29,'奈良県');
insert into jis_x0401(prefecture_id, name) values(30,'和歌山県');
insert into jis_x0401(prefecture_id, name) values(31,'鳥取県');
insert into jis_x0401(prefecture_id, name) values(32,'島根県');
insert into jis_x0401(prefecture_id, name) values(33,'岡山県');
insert into jis_x0401(prefecture_id, name) values(34,'広島県');
insert into jis_x0401(prefecture_id, name) values(35,'山口県');
insert into jis_x0401(prefecture_id, name) values(36,'徳島県');
insert into jis_x0401(prefecture_id, name) values(37,'香川県');
insert into jis_x0401(prefecture_id, name) values(38,'愛媛県');
insert into jis_x0401(prefecture_id, name) values(39,'高知県');
insert into jis_x0401(prefecture_id, name) values(40,'福岡県');
insert into jis_x0401(prefecture_id, name) values(41,'佐賀県');
insert into jis_x0401(prefecture_id, name) values(42,'長崎県');
insert into jis_x0401(prefecture_id, name) values(43,'熊本県');
insert into jis_x0401(prefecture_id, name) values(44,'大分県');
insert into jis_x0401(prefecture_id, name) values(45,'宮崎県');
insert into jis_x0401(prefecture_id, name) values(46,'鹿児島県');
insert into jis_x0401(prefecture_id, name) values(47,'沖縄県');
```
:::

`.env` ファイルには、`compose.yml` で設定したデータベースのユーザー名やパスワードなど、接続情報を記述します。例は以下の通りです。


.envは、compose.ymlに設定した。idとパスワードを設定します。例としては下記になります。
```.env
DATABASE_URL=postgresql://postgres:postgres@localhost/sample_db
```

Denoは標準では `.env` ファイルを自動で読み込みませんが、`--env` オプションを使用することで、指定したファイルから環境変数を読み込むことができます。

データベースの内容を確認するため、下記の操作でpsqlを動かす準備をします。

```podman exec -it sample-db bash```

コンソールに入ったら、下記を実行しpsqlに入ります。

```
psql -U postgres -d sample_db
```

データベース名がアンダースコアでつないでいるので間違えないようします。`\d`でテーブルを確認したり、`select * from jis_x0401;`などをして、データを確認します。

下記のように、drizzleの設定ファイルdrizzle.config.tsを作ります。

```drizzle.config.ts
import { defineConfig } from "drizzle-kit";
// import "std/dotenv/load.ts"; // もし --env を使わずスクリプト内で読み込みたい場合

export default defineConfig({
  out: "./drizzle",
  schema: "./src/db/schema.ts",
  dialect: "postgresql",
  dbCredentials: {
    url: Deno.env.get("DATABASE_URL")!,
  },
  // verbose: true, // SQLログを見たい場合
  // strict: true,  // 厳格モード
});
```

そして、databaseの内容をdrizzleに取り込みます。
`deno --env -A --node-modules-dir npm:drizzle-kit pull`

`--node-modules-dir`オプションはnode_modulesディレクトリを作りますが、drizzle-kitを動かすために必要です。実行権限は`-A`で全部与えていますが、気になる人は制限してください。--envオプションで。envの内容を読み取って環境変数に渡しています。

drizzle-kitのpullサブコマンドは、DBからスキーマを読み取り、`drizzle.config.ts` の `schema` で指定されたファイル (この場合は `./src/db/schema.ts`) を**上書き**または生成します。

また、`drizzle/` ディレクトリはマイグレーションファイル (`drizzle-kit generate` で生成) の出力先 (`out` オプション) です。

データベースの内容を、drizzle/schema.tsなどに書き出します。
```
ls -la drizzle/*
-rw-r--r-- 1 yabuki yabuki 1585  5月  4 08:22 drizzle/0000_parallel_squadron_sinister.sql
-rw-r--r-- 1 yabuki yabuki   81  5月 15 23:18 drizzle/relations.ts
-rw-r--r-- 1 yabuki yabuki 2203  5月 15 23:18 drizzle/schema.ts

drizzle/meta:
合計 12
drwxr-xr-x 1 yabuki yabuki   62  5月  4 08:22 .
drwxr-xr-x 1 yabuki yabuki  120  5月  4 08:22 ..
-rw-r--r-- 1 yabuki yabuki 6498  5月  4 08:22 0000_snapshot.json
-rw-r--r-- 1 yabuki yabuki  220  5月  4 08:22 _journal.json
```

スキーマが生成されるので、src/dbにコピーしておきます。
srcに、サンプルスクリプトを置きます。

```scripts.ts

import * as schema from './db/schema.ts';
import { drizzle } from "drizzle-orm/node-postgres";
import { Pool } from "pg";

const pool = new Pool({
  connectionString: Deno.env.get("DATABASE_URL"),
});

const db = drizzle(pool, { schema });
const result = await db.query.jisX0401.findMany();

console.log(result);
```

これを `deno run -A --env src/scripts.ts` で実行するとselectされた結果が帰っています。
これを足がかりにして、処理を作っていくことができるでしょう。

通貨型の扱いについて


```
export const kenpoMoney = pgTable("kenpo_money", {
	tableVersion: smallint("table_version").notNull(),
	grade: smallint().notNull(),
	// TODO: failed to parse database type 'money'
	base: unknown("base").notNull(),
	// TODO: failed to parse database type 'money'
	lowervalue: unknown("lowervalue"),
	// TODO: failed to parse database type 'money'
	highvalue: unknown("highvalue"),
}, (table) => [
	unique("kenpo_money_table_version_grade_base_key").on(table.tableVersion, table.grade, table.base),
]);
```

となり、TODOとなっていて、unknownになっているのがわかります。

現在のDrizzle Kitでは、PostgreSQLの `money` 型を直接サポートしておらず `unknown` 型として解釈されます。そのため、`NUMERIC` 型などで代用し、アプリケーション側で適切に扱うことになるでしょう。（参考文献Web 8参照）。

こんな風に動かして、コードを確認して堅牢なコードを書いていきましょう。AIにサポートは受けても、確認は必要なので。

::: details schema.ts

```
import { pgTable, integer, char, timestamp, unique, serial, text, date, smallint, varchar, pgSequence } from "drizzle-orm/pg-core"
import { sql } from "drizzle-orm"

export const tableKind = pgTable("table_kind", {
	id: serial().primaryKey().notNull(),
	tableName: text("table_name").notNull(),
}, (table) => [
	unique("table_kind_table_name_key").on(table.tableName),
]);

export const youkou = pgTable("youkou", {
	id: serial().primaryKey().notNull(),
	shubetu: integer().notNull(),
	begindate: date().notNull(),
	enddate: date(),
}, (table) => [
	unique("youkou_shubetu_begindate_key").on(table.shubetu, table.begindate),
]);

export const kenpoMoney = pgTable("kenpo_money", {
	tableVersion: smallint("table_version").notNull(),
	grade: smallint().notNull(),
	// TODO: failed to parse database type 'money'
	base: unknown("base").notNull(),
	// TODO: failed to parse database type 'money'
	lowervalue: unknown("lowervalue"),
	// TODO: failed to parse database type 'money'
	highvalue: unknown("highvalue"),
}, (table) => [
	unique("kenpo_money_table_version_grade_base_key").on(table.tableVersion, table.grade, table.base),
]);

export const kouseiMoney = pgTable("kousei_money", {
	tableVersion: smallint("table_version").notNull(),
	grade: smallint().notNull(),
	// TODO: failed to parse database type 'money'
	base: unknown("base").notNull(),
	// TODO: failed to parse database type 'money'
	lowervalue: unknown("lowervalue"),
	// TODO: failed to parse database type 'money'
	highvalue: unknown("highvalue"),
}, (table) => [
	unique("kousei_money_table_version_grade_base_key").on(table.tableVersion, table.grade, table.base),
]);

export const jisX0401 = pgTable("jis_x0401", {
	prefectureId: smallint("prefecture_id").primaryKey().notNull(),
	name: varchar({ length: 10 }).notNull(),
});
```
:::

### ToDoリスト

- PostgredSQLのmoney型を変更する。
- Deno.json/Deno.jsoncにtaskを定義して、`deno -A npm drizzle-kit <subcommnd>`を簡単に呼び出せるようににする。
- すでに下ごしらえをしている`sheetJS`を利用し社会保険データを抜き出して、データの検算をする。

## この記事を書いた動機と意図

この記事を書くにあたって意識したことは下記です。

- 新しいことを覚えるにあたって、一度にいっぱいの変化がやってくると受け入れる側が大変なので下記を気にしました。
    - 開発環境は自分の手慣れて、安定しているDebian GNU/Linux 12(Bookworm)を選択した。

- AI(LLM)のサポートを受けながら、プログラミングをすることをVibe Codingと呼んでいる。
- Vibe Codingをするのに、現状ではTypeScriptかPythonに一日の長があるように見える。フロントエンドとバックエンドの両方をひとつの言語で済むTypeScriptを選ぶことにした。
- Vibe CodingをおこなうためにCopilotを使い始めた。ただしcopilotの無料枠なので、学習されても構わないプログラミング対象を選択する。つまりオープンソースとして出せそうな対象を題目とした。

- TypeScriptの実行環境にDenoを選んだのは次の理由があります。node.jsは真面目にプログラミング環境を揃えるのに個別にlsp/linter/formatter/test suite/profilingインストールする必要かあります。Denoは初期状態で全部入っています。
- OSは、自分が使い慣れたDebian GNU/Linux stableを使いました。そのDebian GNU/Linuxのstableに収録されているPodmanをDockerの代わりとして使っていました。特別な設定をしなくてもPodmanならほぼDockerと同じように使えます。具体的な使い方については、参考文献Web 4。を参照してください。

- 社会保険料の料率計算は、公開情報であり自分で検算をするのにもちょうど良い題材に思えた。Excelでデータが提供されており、TypeScriptでエクセルを読み取るのに、複数パッケージを比較検討し、読み取るだけだしSheetJS(a.k.a xlsx package) が妥当そうだという結論に達した。

- TypeScriptにおける技術スタックの選定には、参考文献Web 2のmizchi氏の影響を受けています。前述の理由に加えて私がDrizzleを使うのは初めてなので知っているPostgreSQLのSQLからどういう風にdrizzleとつながっていくのか確認したかった。また、[Drizzle ORM - Why Drizzle?](https://orm.drizzle.team/docs/overview#why-sql-like)が主張している、If you know SQL, you know Drizzle. 意訳ですが、SQLを使えるなら、Drizzleを使えるという表現も気に入りました。SQLの様々なテクニックをDrizzleなら表現できそうだと思った。必要なら、[Drizzle ORM - Magic sql operator](https://orm.drizzle.team/docs/sql)を使えば良さそだから。生のSQLを使いたくなる場合については、参考文献書籍4や5などを参照して判断してください。

また、私はDenoでDrizzleを動かす目的で参考文献Web 5の記事を追試しましたが、うまくできませんでした。この記事であなたもDenoでDrizzleを動かすことができるといいのですが。

Mizchi氏のPGLiteは手元でも動かすことができましたが、そのうちdrizzle-kit studioなども動かしてみたいのと、psqlでどういうデーターが入っていくのか確認したい。というのもありこの構成にしています。

CREATE TABLEや初期データの投入はスクリプトで行い、それをDrizzleでスキーマとして取り込み、確認することも目的のひとつです。

この記事は、[記事投稿コンテスト「TypeScriptでやってみた 挑戦・学び・工夫」 | Zenn](https://zenn.dev/contests/contest2025ts)に向けても書いています。

## 参考文献

### Web

1. [Learn more about using Drizzle to define schemas and their relations](https://orm.drizzle.team/docs/schemas)
2. [Deno + Pglite + Drizzle で依存の少ないDBアプリを作る](https://zenn.dev/mizchi/articles/deno-drizzle-pglite)
3. [deno-drizzle-pglite/README.md at main · mizchi/deno-drizzle-pglite](https://github.com/mizchi/deno-drizzle-pglite/blob/main/README.md)
4. [Postgresqlをpodman-composeでDebian Bookworm 上で動かす。2025/04版](https://zenn.dev/yabuki/articles/2025-04-21-postgresql-with-podman-compose)
5. [Build a Database App with Drizzle ORM and Deno](https://docs.deno.com/examples/drizzle_tutorial/)
6. [postgres - Official Image | Docker Hub](https://hub.docker.com/_/postgres/)
7. [【PostgreSQL】docker-composeで起動と初期データ投入 #Docker - Qiita](https://qiita.com/ke_suke0215/items/90deba2bf484293000fc#%E8%B5%B7%E5%8B%95)
8. [8.2. 通貨型](https://www.postgresql.jp/document/16/html/datatype-money.html)

### 書籍

1. [『Tidy First? 個人で実践する経験主義的ソフトウェア設計』のレビュー KentBeck (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4814400918)
2. [『テスト駆動開発』のレビュー KentBeck (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4274217884)
3. [『リファクタリング(第2版) 既存のコードを安全に改善する』のレビュー マーチン・ファウラー (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4274224546)
4. [『達人に学ぶSQL徹底指南書 第2版 初級者で終わりたくないあなたへ (CodeZine BOOKS)』のレビュー ミック (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4798157821)
5. [『SQL実践入門 高速でわかりやすいクリエの書き方 (Web+DB Press Plus)』のレビュー ミック (YABUKI Yukiharuさん) - ブクログ](https://booklog.jp/users/yyabuki/archives/1/4774173010)

## 謝辞

参考文献に載せた方々や必要なドキュメントを作ってくれた人なと、さまざまな人の肩に載ってこの記事が書けました。御礼申し上げます。

## さいごに

TypeScriptやPythonを使ったシステム構築や、プロジェクトのマネージメントなどシステム構築や開発のサポートなどお仕事を募集しております。
- [KIIRE JAPAN INC.](https://www.kiire.co.jp/) 

|       件名         |   日付   |
|:----               |:--------:|
|記事を書きはじめた日|2025-05-04|
|  記事を公開した日  |2025-05-21|
|  記事を変更した日  |2025-05-31|

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

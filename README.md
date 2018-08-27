# Docker 版 mastodon を 簡単に動かす

# 概要

いくつかのコマンドを実行するだけで、ほぼ設定なしでローカルでマストドンを起動することができます。

v2.4.3 の mastodon は [productionモードでは https 接続が強制されており、](https://github.com/tootsuite/mastodon/blob/v2.4.3/.env.production.sample#L22)。簡単に動作を確認することができません。
また、mastodon Docker版では developmentモードがうまく動かず、[推薦もされていません](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Development-guide.md)。

そこで、[こちらのパッチ](https://github.com/ailispaw/mastodon-barge/tree/master/patches)を適用して、productionモードで動作するようにしています。

また、マストドンが送信するすべてのメールは、[MailCatcher](https://mailcatcher.me)でのみ確認することができます。
外部には配送されませんので、メールサーバの設定なども不要です。

データはすべてDocker の Named Volumeに保存されます。 `docker volume ls` で確認できます。

[ailispaw](https://github.com/ailispaw)さん、ありがとうございます！

# 必要な環境

* Docker
* bash
* curl

## 確認環境

* [DockerCE for Mac(18.06.0-ce-mac70)](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* Ubuntu 18.04, Docker 18.06.0-ce

にて動作確認しています。

# ご注意

このマストドンは外部に公開することは想定されていません。動作の確認はローカルでの実行、もしくはSSHのポートフォワード専用です。
docker-compose.yml の ports の 127.0.0.1: をはずすとiptables -A INPUT でのアクセス制限を迂回して公開されますのでVPS等で実行される場合はご注意ください。 

# 構築と起動

## 取得

このリポジトリを取得します。

	$ git clone https://github.com/mamemomonga/mstdn-docker.git
	$ cd mstdn-docker

## 作成

以下のコマンドを実行すると、取得と構築が行われます。
.env.production も含め全て初期化されますのでご注意ください。
リストアの場合事前にcreateする必要はありません。

	$ ./mastodon.sh create

**SUCCESS** と表示されたら構築完了でマストドンが起動されます。

## 登録とログイン

[http://localhost:3000/](http://localhost:3000/) にアクセスしてユーザ登録を行います。

メールはどの宛先のメールも外部には届かず、内部のメールボックスに届きます。以下から確認できます。
メールアドレスはDNSチェックを行っているようですので、ドメインは実在する必要があります。

[http://localhost:1080/](http://localhost:1080/) 受信メール


登録が完了したらメールを選択して、承認リンクをクリックてください。
そうすると、ログインすることができます。

## 管理者への昇格

以下のコマンドを実行してください。mamemomongaの部分を対象のユーザに置き換えてください。

	$ ./mastodon.sh rails mastodon:make_admin USERNAME=mamemomonga


# バックアップとリストア

## バックアップ

/var/backup 以下へデータをバックアップします。redisはバックアップしません(HTLは消えます)。

	$ ./mastodon.sh backup

## リストア

/var/backup 以下のデータをリカバリします。既存のデータはすべて削除されます。

	$ ./mastodon.sh restore

# 便利なコマンド

# mastodon.sh コマンド一覧


 コマンド              | 内容
-----------------------|----------
./mastodon         | ヘルプ
./mastodon create  | 新規作成 
./mastodon destroy | 破棄
./mastodon up      | 起動
./mastodon down    | 停止
./mastodon shell   | web の /mastodon に入る
./mastodon psql    | db の psql に入る
./mastodon psql    | logを表示する
./mastodon rails ...  | rails のコマンドを実行する

### rails コマンドのヘルプ参照

マストドン用のいろんなコマンドがあるみたいです。以下の方法で確認できます。

	$ ./mastodon.sh rails --help

# ディストリビューション別実行ガイド

ほぼ素の状態のディストリビューション別の起動例一覧です

# Ubuntu 18.04 LTS Minimal

## Dockerのインストール

	$ wget https://get.docker.com -O - | sh
	$ sudo sh -c 'usermod -a -G docker $SUDO_USER'

いちどログアウトして、再ログインする。

## ほかに必要なツールのインストール

	$ sudo apt install git curl

## マストドン開始

	$ git clone https://github.com/mamemomonga/mstdn-docker.git
	$ cd mstdn-docker
	$ ./mastodon.sh create

別ターミナルから実行

	$ ssh -L 3000:localhost:3000 -L 1080:localhost:1080 [ユーザ名]@[パスワード]

http://localhost:3000/ でマストドン、http://localhost:1080/ でメール が見えれば成功です。

# Container-Optimized OS 68-10718.86.0 stable

COSでは mastodon.sh を ./mastodon.sh では実行できません。bash mastodon.sh で実行してください。

以下は実行までの流れです。

	$ git clone https://github.com/mamemomonga/mstdn-docker.git
	$ cd mstdn-docker
	$ bash mastodon.sh create

別ターミナルから実行

	$ ssh -L 3000:localhost:3000 -L 1080:localhost:1080 [ユーザ名]@[パスワード]

http://localhost:3000/ でマストドン、http://localhost:1080/ でメール が見えれば成功です。

# Raspberry Pi 3 + Raspbian

Dockerfile の FROMを以下のように書き換えます。

	# FROM tootsuite/mastodon:v2.4.5
	FROM mamemomonga/multiarch-armhf-mastodon:v2.4.5

mastodon の DOCKER_COMPOSE を以下のように書き換えます。

	# DOCKER_COMPOSE="docker/compose:1.22.0"
	DOCKER_COMPOSE="mamemomonga/armhf-docker-compose:1.22.0"

あとは Ubuntuと同じです。

なお、SWAPが無効の場合はassetsのビルドに失敗する場合があります。

# 参考資料

* [Mastodon on Barge with Vagrant](https://github.com/ailispaw/mastodon-barge)
* [Mastodon: Docker](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Docker-Guide.md)
* [Mastodon: Mastodon Production Guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)
* [DockerHub: mastodon](https://hub.docker.com/r/gargron/mastodon/)


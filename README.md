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
* Docker Compose
* bash
* curl

## 確認環境

* [DockerCE for Mac(18.06.0-ce-mac70)](https://store.docker.com/editions/community/docker-ce-desktop-mac)
* Ubuntu 18.04, Docker 18.06.0-ce, Docker-Compose 1.21.2

にて動作確認しています。

このツールでの外部への公開や連携は想定されておりませんので動作テスト用としてお使いください。

# 構築と起動

## 取得

このリポジトリを取得します。

	$ git clone git@github.com:mamemomonga/mstdn-revert-enforce-https.git
	$ cd mstdn-revert-enforce-https

## 準備

docker-compose.yml をコピーします

	$ cp docker-compose/mstdn-revert-enforce-https.yml docker-compose.yml

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
 ./mastodon.sh         | ヘルプ
 ./mastodon.sh create  | 新規作成 
 ./mastodon.sh destroy | 破棄
 ./mastodon.sh up      | 起動
 ./mastodon.sh down    | 停止
 ./mastodon.sh backup  | バックアップ
 ./mastodon.sh restore | 作成とリストア
 ./mastodon.sh shell   | web の /mastodon に入る
 ./mastodon.sh psql    | db の psql に入る
 ./mastodon.sh psql    | logを表示する
 ./mastodon.sh rails ...  | rails のコマンドを実行する

### rails コマンドのヘルプ参照

マストドン用のいろんなコマンドがあるみたいです。以下の方法で確認できます。

	$ ./mastodon.sh rails --help

# 参考資料

* [Mastodon on Barge with Vagrant](https://github.com/ailispaw/mastodon-barge)
* [Mastodon: Docker](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Docker-Guide.md)
* [Mastodon: Mastodon Production Guide](https://github.com/tootsuite/documentation/blob/master/Running-Mastodon/Production-guide.md)
* [DockerHub: mastodon](https://hub.docker.com/r/gargron/mastodon/)



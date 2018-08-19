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
	$ ./mastodon.sh init revert-enforce-https
	$ ./mastodon.sh create

別ターミナルから実行

	$ ssh -L 3000:localhost:3000 -L 1080:localhost:1080 [ユーザ名]@[パスワード]

http://localhost:3000/ でマストドン、http://localhost:1080/ でメール が見えれば成功です。

# Container-Optimized OS 68-10718.86.0 stable

COSでは mastodon.sh を ./mastodon.sh では実行できません。bash mastodon.sh で実行してください。

以下は実行までの流れです。

	$ git clone https://github.com/mamemomonga/mstdn-docker.git
	$ cd mstdn-docker
	$ bash mastodon.sh init revert-enforce-https
	$ bash mastodon.sh create

別ターミナルから実行

	$ ssh -L 3000:localhost:3000 -L 1080:localhost:1080 [ユーザ名]@[パスワード]

http://localhost:3000/ でマストドン、http://localhost:1080/ でメール が見えれば成功です。


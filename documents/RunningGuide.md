# ディストリビューション別実行ガイド

ディストリビューション別の起動例一覧です

# Container-Optimized OS 68-10718.86.0 stable

* mastodon.sh は ./mastodon.sh では実行できません。bash mastodon.sh で実行してください。
* 公開鍵を登録し、そのキーでインスタンスにログインしてください。

	$ ssh [ユーザ名]@[パスワード]
	$ git clone https://github.com/mamemomonga/mstdn-revert-enforce-https.git
	$ cd mstdn-revert-enforce-https
	$ cp docker-compose/mstdn-revert-enforce-https.yml docker-compose.yml
	$ bash mastodon.sh create

別ターミナルから実行

	$ ssh -L 3000:localhost:3000 -L 1080:localhost:1080 [ユーザ名]@[パスワード]

http://localhost:3000/ でマストドン、http://localhost:1080/ でメール が見えれば成功です。


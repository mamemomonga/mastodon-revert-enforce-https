#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"

COMMANDS="example-env example-compose local standalone clean"

source $BASEDIR/scripts/functions

function do_example-env {
	$CURL -s https://raw.githubusercontent.com/tootsuite/mastodon/$MSTDN_VER/.env.production.sample
}

function do_example-compose {
	$CURL -s https://raw.githubusercontent.com/tootsuite/mastodon/$MSTDN_VER/docker-compose.yml
}

function do_local {
	cd $BASEDIR
	if [ -e 'docker-compose.yml' ]; then echo 'docker-compose.yml already exists.'; exit 1; fi
	if [ -e '.mastodon-image-name' ]; then echo '.mastodon-image-name already exists.'; exit 1; fi

	MSTDN_TYPE=local
	MAIL_CATCHER=true

	if [ $(uname -m) == 'armv7' ]; then
		MASTODON="mamemomonga/rpi-mastodon-revert-enforce-https:$MSTDN_VER"
	else
		MASTODON="mamemomonga/mastodon-revert-enforce-https:$MSTDN_VER"
	fi

	echo $MASTODON > .mastodon-image-name

	docker run --rm \
		-v $PWD/templates/docker-compose.yml.j2:/t:ro \
		-e JIMAGE=$MASTODON \
		-e JMAILCATCHER=1 \
		$DIMG_UTILS j2 --format=env /t > docker-compose.yml

	echo "Write: docker-compose.yml"
	gen_env_prod
}

function do_standalone {
	MASTODON="tootsuite/mastodon:$MSTDN_VER"
	true
}

function do_clean {
	cd $BASEDIR
	echo "removing configs"
	rm -fv docker-compose.yml
	rm -fv .mastodon-image-name
	rm -fv .env.production
}

function gen_env_prod {
	cd $BASEDIR
	if [ -e '.env.production' ]; then echo '.env.production already exists.'; exit 1; fi 

	docker run --rm -it $MASTODON true

	cat > .env.production << 'EOS'
REDIS_HOST=redis
REDIS_PORT=6379
DB_HOST=db
DB_USER=postgres
DB_NAME=postgres
DB_PASS=
DB_PORT=5432
STREAMING_CLUSTER_NUM=1
RAILS_ENV=production
EOS

	if [ $MSTDN_TYPE == 'local' ]; then
		echo 'LOCAL_HTTPS=false' >> .env.production
		echo 'LOCAL_DOMAIN=localhost:3000'  >> .env.production

	else 
		if [ -n "$DOMAIN_NAME" ]; then
			echo 'LOCAL_DOMAIN='$DOMAIN_NAME >> .env.production
		fi
	fi

	if [ $MAIL_CATCHER ]; then
		cat >> .env.production << 'EOS'
SMTP_SERVER=mailcatcher
SMTP_PORT=1025
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_FROM_ADDRESS=notifications@localhost
SMTP_AUTH_METHOD=none
EOS
	fi

	echo "create secrets."
	echo 'SECRET_KEY_BASE='$( docker run --rm $MASTODON rake secret ) >> .env.production
	echo 'OTP_SECRET='$( docker run --rm $MASTODON rake secret ) >> .env.production

	echo "generate_vapid_key."
	eval $( docker run --rm --env-file=.env.production $MASTODON \
		rake mastodon:webpush:generate_vapid_key | $PERL -npe 's/^(.+)/local $1/mg' )
	echo 'VAPID_PRIVATE_KEY='$VAPID_PRIVATE_KEY >> .env.production
	echo 'VAPID_PUBLIC_KEY='$VAPID_PUBLIC_KEY >> .env.production

	echo "Write: .env.production"
}

run $@

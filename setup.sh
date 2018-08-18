#!/bin/bash
set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )"  && pwd )"
PERL='docker run --rm -i perl:5-slim perl'

source $BASEDIR/.env

cd $BASEDIR
mkdir -p repos

function do_create_volumes {
	for i in postgres redis assets packs system; do
		local volname=$COMPOSE_PROJECT_NAME'-'$i
		echo -n "create named volume: "
		docker volume create $volname
	done
}

function do_remove_volumes {
	for i in postgres redis assets packs system; do
		local volname=$COMPOSE_PROJECT_NAME'-'$i
		echo -n "remove named volome: "
		docker volume rm $volname || true
	done
}

function do_repos {
	if [ ! -d 'repos/mastodon' ]; then
		cd repos
		git clone https://github.com/tootsuite/mastodon.git
		cd mastodon
		git checkout -b $MSTDN_VER $MSTDN_VER
		cd ../..
	fi
	
	if [ ! -d 'repos/mastodon-barge' ]; then
		cd repos
		git clone https://github.com/ailispaw/mastodon-barge.git
		cd mastodon-barge
		git checkout -b $MSTDN_VER $MSTDN_BERGE_REF 
		cd ../..
	fi
	
}

function do_env {
	cp -f  repos/mastodon/.env.production.sample .env.production

	cat >> .env.production << 'EOS'
LOCAL_DOMAIN=127.0.0.1:3000
LOCAL_HTTPS=false
RAILS_ENV=production

SMTP_SERVER=mailcatcher
SMTP_PORT=1025
SMTP_LOGIN=
SMTP_PASSWORD=
SMTP_FROM_ADDRESS=notifications@localhost
SMTP_AUTH_METHOD=none

EOS

	local SECRET_KEY_BASE=$( docker-compose run --rm web rake secret | $PERL -npe 's/\r//g' )
	local OTP_SECRET=$( docker-compose run --rm web rake secret | $PERL -npe 's/\r//g' )

	cat .env.production | $PERL -pE " \
		s/^SECRET_KEY_BASE=/SECRET_KEY_BASE=$SECRET_KEY_BASE/m; \
		s/^OTP_SECRET=/OTP_SECRET=$OTP_SECRET/m \
	" > .env.production.tmp
	mv -f .env.production.tmp .env.production

	eval $( docker-compose run --rm web rake mastodon:webpush:generate_vapid_key | $PERL -npe 's/\r//sg; s/^(.+)/local $1/mg' )

	cat .env.production | $PERL -pE " \
		s/^VAPID_PRIVATE_KEY=/VAPID_PRIVATE_KEY=$VAPID_PRIVATE_KEY/m; \
		s/^VAPID_PUBLIC_KEY=/VAPID_PUBLIC_KEY=$VAPID_PUBLIC_KEY/m \
	" > .env.production.tmp
	mv -f .env.production.tmp .env.production

}

function do_create {
	rm -rf  mstdn-revert-enforce-https/assets
	mkdir -p mstdn-revert-enforce-https/assets

	cp -rf repos/mastodon-barge/patches mstdn-revert-enforce-https/assets/
	cp -f  repos/mastodon/.env.production.sample mstdn-revert-enforce-https/assets/

	cp -f  repos/mastodon/.env.production.sample .env.production
	do_create_volumes
	docker-compose build
	docker-compose run --rm web rake --version

	do_env

	MUID=$( docker-compose run --rm web id -u | $PERL -npe 's/\r//g' )
	MGID=$( docker-compose run --rm web id -g | $PERL -npe 's/\r//g' )

	docker run --rm -i \
		-v $COMPOSE_PROJECT_NAME'-assets:/m/assets' \
		-v $COMPOSE_PROJECT_NAME'-packs:/m/packs' \
		-v $COMPOSE_PROJECT_NAME'-system:/m/system' \
		alpine:3.8 chown -v -R $MUID:$MGID /m
 
	docker-compose run --rm web rails db:setup SAFETY_ASSURED=1
	docker-compose run --rm web rails assets:precompile
}

function do_destroy {
	docker-compose down || true
	sleep 1
	do_remove_volumes
}


case "${1:-}" in

	"create"  )
		do_repos
		do_create
		echo " *** SUCCESS ***"
		;;

	"destroy" )
		do_destroy
		;;

	*  )
		echo "USAGE: $0 [ create | destroy ]"
		exit 1
		;;

esac


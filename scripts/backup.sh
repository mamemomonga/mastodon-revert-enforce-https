#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
COMMANDS="backup restore"
source $BASEDIR/scripts/functions

BACKUP_DIR='var/backup/latest'

function do_backup {
	cd $BASEDIR

	if [ -z $(docker ps -q -f "id=$(dcr-cmp ps -q db)" -f "status=running") ]; then
		echo "database not running."
		exit 1
	fi

	rm -rf $BACKUP_DIR
	mkdir -p $BACKUP_DIR

	local credis=$(dcr-cmp ps -q redis)
	local cpg=$(dcr-cmp ps -q db)
	
	echo "start backup redis."
	local lastsave=$(docker exec $credis redis-cli lastsave)
	sleep 1
	docker exec $credis redis-cli bgsave
	while [ "$lastsave" = "$(docker exec $credis redis-cli lastsave)" ]; do
		sleep 1
		echo -n "."
	done
	echo

	echo "start backup postgresql."
	docker exec $cpg pg_dump -U postgres postgres > $BACKUP_DIR/mastodon.sql

	echo "start backup files."
	for i in assets packs system redis; do
		docker run --rm -i -v $COMPOSE_PROJECT_NAME'-'$i:/m/$i \
		$DIMG_UTILS tar cC /m $i > $BACKUP_DIR/$i.tar
	done

	cp -vf .env.production     $BACKUP_DIR/
	cp -vf docker-compose.yaml $BACKUP_DIR/

}

function do_restore {
	
	if [ -n "$( docker volume ls -q | $PERL -nE 'chomp; say if(/\Q'$COMPOSE_PROJECT_NAME'\E/)' )" ]; then
			echo "volumes in use"
			exit 1
	fi
	volume-create

	dcr-cmp up -d db
	sleep 5

	local DB_CTNR=$(docker ps -q -f "id=$(dcr-cmp ps -q db)" -f "status=running")
	cat $BACKUP_DIR/mastodon.sql | docker exec -i $DB_CTNR psql -U postgres

	for i in assets packs system redis; do
		cat $BACKUP_DIR/$i.tar | \
			docker run --rm -i -v $COMPOSE_PROJECT_NAME'-'$i:/m/$i \
			$DIMG_UTILS sh -c "tar xC /m"
	done

	volume-permissions

	cp -vf $BACKUP_DIR/.env.production .
	cp -vf $BACKUP_DIR/docker-compose.yaml .

	dcr-cmp up -d
}

run $@


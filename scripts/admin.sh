#!/bin/bash
set -eu

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
COMMANDS="rails make_admin shell_web psql redis"

source $BASEDIR/scripts/functions

function do_rails {
	exec docker exec -it $(dcr-cmp ps -q web) rails $@
}

function do_make_admin {
	exec docker exec -it $(dcr-cmp ps -q web) rails mastodon:make_admin USERNAME=$1
}

function do_shell_web {
	exec docker exec -it $(dcr-cmp ps -q web) sh
}
 
function do_psql {
	exec docker exec -it $(dcr-cmp ps -q db) psql -U postgres postgres
}

function do_redis {
	exec docker exec -it $(dcr-cmp ps -q redis) redis-cli $@
}
run $@

#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
COMMANDS="create remove permissions"
source $BASEDIR/scripts/functions

function do_remove {
    for i in postgres redis assets packs system; do
        local volname=$COMPOSE_PROJECT_NAME'-'$i
        echo -n "remove named volume: "
        docker volume rm $volname || true
    done
}

function do_create {
	volume-create
}

function do_permissions {
	volume-permissions
}

run $@

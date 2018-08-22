#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
COMMANDS="build db assets mastodon_local"
source $BASEDIR/scripts/functions

function do_build {
	dcr-cmp pull
	dcr-cmp build
}

function do_db {
	dcr-cmp run --rm web rails db:setup SAFETY_ASSURED=1
}

function do_assets {
	dcr-cmp run --rm web rails assets:precompile
}

function do_mastodon_local {
	bash $BASEDIR/mastodon template local
	bash $BASEDIR/mastodon volume create
	bash $BASEDIR/mastodon volume permissions
	bash $BASEDIR/mastodon setup build
	bash $BASEDIR/mastodon setup db
	bash $BASEDIR/mastodon setup assets
	bash $BASEDIR/mastodon up
}

run $@

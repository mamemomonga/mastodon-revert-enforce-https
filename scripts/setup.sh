#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
COMMANDS="build db assets"
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
	$BASEDIR bash mastodon template local
	$BASEDIR bash mastodon volume create
	$BASEDIR bash mastodon volume permissions
	$BASEDIR bash mastodon setup build
	$BASEDIR bash mastodon setup db
	$BASEDIR bash mastodon setup assets
	$BASEDIR bash mastodon up
}

run $@

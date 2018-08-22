#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../.. && pwd )"
source $BASEDIR/.env

PUBLISH=false

if [ "$(uname -m)" == 'armv7l' ]; then
	IMAGE_NAME="mamemomonga/rpi-mastodon-revert-enforce-https:$MSTDN_VER"
	set -x
	docker build \
		--build-arg "image_name=$IMAGE_NAME" \
		--build-arg "parent_image=mamemomonga/rpi-mastodon:$MSTDN_VER" \
		--build-arg "mstdn_berge_ref=cb9448685907d8a70933f89b047456a7a05c3507" \
		-t $IMAGE_NAME .
else
	IMAGE_NAME="mamemomonga/mastodon-revert-enforce-https:$MSTDN_VER"
	set -x
	docker build --no-cache \
		--build-arg "image_name=$IMAGE_NAME" \
		--build-arg "parent_image=tootsuite/mastodon:$MSTDN_VER" \
		--build-arg "mstdn_berge_ref=cb9448685907d8a70933f89b047456a7a05c3507" \
		-t $IMAGE_NAME .
fi

if $PUBLISH; then
	docker push $IMAGE_NAME
fi


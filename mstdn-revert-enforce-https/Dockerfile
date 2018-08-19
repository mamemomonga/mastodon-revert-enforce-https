FROM tootsuite/mastodon:v2.4.3

ARG MSTDN_VER=v2.4.3
ARG MSTDN_BERGE_REF=cb9448685907d8a70933f89b047456a7a05c3507

USER root

RUN set -xe && \
	apk --no-cache --update add patch curl git && \
	mkdir -p /src && \
	chown mastodon:mastodon /src

USER mastodon

RUN set -xe && \
	mkdir -p /src && \
	curl https://raw.githubusercontent.com/tootsuite/mastodon/$MSTDN_VER/.env.production.sample > /mastodon/.env.production.sample && \
	cd /src && \
	git clone https://github.com/ailispaw/mastodon-barge.git && \
	cd mastodon-barge && \
	git checkout -b $MSTDN_VER $MSTDN_BERGE_REF && \
	cd /mastodon && \
 	for patch in /src/mastodon-barge/patches/*.patch; do \
 		patch -p1 -d /mastodon < ${patch}; \
 	done && \
 	rm -f /mastodon/.env.production.sample


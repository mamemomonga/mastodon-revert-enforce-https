FROM tootsuite/mastodon:v2.4.5
# FROM mamemomonga/multiarch-armhf-mastodon:v2.4.5

ARG mstdn_ver=v2.4.5
ARG mstdn_berge_ref=268130a0ccdaf89d8aa47f8d5afa2d3ae92ef08f

USER root
RUN set -xe && \
	apk --no-cache --update add patch curl git && \
	mkdir -p /src && \
	chown mastodon:mastodon /src

USER mastodon

RUN set -xe && \
	mkdir -p /src && \
	curl https://raw.githubusercontent.com/tootsuite/mastodon/$mstdn_ver/.env.production.sample > /mastodon/.env.production.sample && \
	cd /src && \
	git clone https://github.com/ailispaw/mastodon-barge.git && \
	cd mastodon-barge && \
	git checkout -b $mstdn_ver $mstdn_berge_ref && \
	cd /mastodon && \
 	for patch in /src/mastodon-barge/patches/*.patch; do \
 		patch -p1 -d /mastodon < ${patch}; \
 	done && \
 	rm -f /mastodon/.env.production.sample


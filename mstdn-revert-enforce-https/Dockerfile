FROM tootsuite/mastodon:v2.4.3

COPY assets/patches /patches
COPY assets/.env.production.sample /mastodon/.env.production.sample

USER root

RUN set -xe && \
	apk --no-cache --update add patch && \
	for patch in /patches/*.patch; do \
		patch -p1 -d /mastodon < ${patch}; \
	done && \
	rm -f /mastodon/.env.production.sample

USER mastodon


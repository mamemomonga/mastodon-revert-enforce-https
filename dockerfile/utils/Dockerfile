FROM alpine:3.8

RUN set -xe && \
	apk add --no-cache \
		perl \
		py2-pip \
		curl \
		tzdata && \
	pip install j2cli && \
	cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	apk del tzdata && \
	rm -rf /var/cache/apk/*
	

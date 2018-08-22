#!/bin/bash
set -eux

docker network create \
	--driver=bridge \
	--subnet=192.168.88.0/24 \
	--gateway=192.168.88.1 \
	-o com.docker.network.bridge.name=mstdn \
	mstdn


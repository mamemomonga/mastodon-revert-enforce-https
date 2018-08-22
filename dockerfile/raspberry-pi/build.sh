#!/bin/bash
set -eux

# https://gist.github.com/mamemomonga/36b7b74e29b900e58608ac00152d2f6e

mkdir ruby
cd ruby
wget https://raw.githubusercontent.com/docker-library/ruby/c43fef8a60cea31eb9e7d960a076d633cb62ba8d/2.4/alpine3.6/Dockerfile
docker build -t mamemomonga/rpi-ruby:2.4.4-alpine3.6 .
docker push mamemomonga/rpi-ruby:2.4.4-alpine3.6
cd ..

mkdir postgres
cd postgres
wget https://raw.githubusercontent.com/docker-library/postgres/master/9.6/alpine/Dockerfile
wget https://raw.githubusercontent.com/docker-library/postgres/master/9.6/alpine/docker-entrypoint.sh
docker build -t mamemomonga/rpi-postgres:9.6-alpine .
docker push mamemomonga/rpi-postgres:9.6-alpine
cd ..

mkdir redis
cd redis
wget https://raw.githubusercontent.com/docker-library/redis/master/4.0/alpine/Dockerfile
wget https://raw.githubusercontent.com/docker-library/redis/master/4.0/alpine/docker-entrypoint.sh
docker build -t mamemomonga/rpi-redis:4.0-alpine .
docker push mamemomonga/rpi-redis:4.0-alpine
cd ..

git clone https://github.com/docker/compose.git
cd compose
git checkout 1.22.0
docker build -t mamemomonga/rpi-docker-compose:1.22.0 -f Dockerfile.armhf .
docker push mamemomonga/rpi-docker-compose:1.22.0
cd ..


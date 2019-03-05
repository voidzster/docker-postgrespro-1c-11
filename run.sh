#!/bin/sh

docker run --name postgrespro-1c \
  --net host \
  --detach \
  --volume postgrespro-1c-data:/data \
  --volume /etc/localtime:/etc/localtime:ro \
  --env POSTGRES_PASSWORD=password \
  voidzster/postgrespro-1c

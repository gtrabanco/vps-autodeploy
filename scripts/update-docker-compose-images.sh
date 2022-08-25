#!/usr/bin/env sh

docker compose pull
docker compose up --force-recreate --build -d --remove-orphans
docker image prune -f

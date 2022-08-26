#!/usr/bin/env

# TODO: All script to make universal. Tested and works.

# Create a new volume with current project name and volume name
docker volume create \
  --label com.docker.compose.project=vps-apps \
  --label com.docker.compose.version=3 \
  --label com.docker.compose.volume=vaultwarden-data \
  vps-name_vaultwarden-data

# Migrate from previous volume from project http-docker-apps
# and volume vaultwarden-data to new project name vps-name
# and volume vaultwarden-data
docker container run --rm -it \
  -v http-docker-apps_vaultwarden-data:/from \
  -v vps-apps_vaultwarden-data:/to \
  alpine ash -c "cd /from ; cp -av . /to"

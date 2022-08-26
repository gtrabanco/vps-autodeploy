#!/usr/bin/env bash

set -e

backup_date="$(date +%Y-%m-%d-%H-%M-%S)"

VOLUME_PATH="/data"
BACKUP_PATH="$PWD"
IMAGE="alpine:latest"
BACKUP_PREFIX="backup"
COMPOSE_FILE="docker-compose.yml"
PROJECT_DIRECTORY="$PWD"
COMPOSE_PROJECT_NAME=""

while [[ -n "${1:-}" ]]; do
  case "$1" in
  --compose-file | -f)
    COMPOSE_FILE="${2:-}"
    shift 2
    ;;
  --project-name | -p)
    COMPOSE_PROJECT_NAME="${2:-}"
    shift 2
    ;;
  --project-directory | -d)
    PROJECT_DIRECTORY="${2:-}"
    shift 2
    ;;
  --volume-name | -v)
    VOLUME_NAME="${2:-}"
    shift 2
    ;;
  --volume-path | -vp)
    VOLUME_PATH="${2:-}"
    shift 2
    ;;
  --backup-path | -bp)
    BACKUP_PATH="${2:-}"
    shift 2
    ;;
  --backup-prefix | -bx)
    BACKUP_PREFIX="${2:-}"
    shift 2
    ;;
  --image | -i)
    IMAGE="${2:-}"
    shift 2
    ;;
  --help | -h)
    echo "Usage: $0 --compose-file <compose-file> [--project-name <project-name>] [--project-directory <project-directory>] [--volume-name <volume-name>] [--volume-path <volume-path>] [--backup-path <backup-path>] [--backup-prefix <backup-prefix>] [--image <image>]"
    echo
    echo "Options:"
    echo "  --compose-file <compose-file>              Compose file to use"
    echo "  --project-name <project-name>              Project name to use"
    echo "  --project-directory <project-directory>    Project directory to use"
    echo "  --volume-name <volume-name>                Volume name to use (mandatory)"
    echo "  --volume-path <volume-path>                Volume path to use"
    echo "  --backup-path <backup-path>                Backup path to use"
    echo "  --backup-prefix <backup-prefix>            Backup prefix to use, project name and volume name is added always"
    echo "  --image <image>                            Image to use to do the backup, default: alpine:latest"
    echo
    echo "Defaults:"
    echo "  --compose-file docker-compose.yml"
    echo "  --project-name docker-compose"
    echo "  --project-directory \$PWD"
    echo "  --volume-path /data"
    echo "  --backup-path \$PWD"
    echo "  --backup-prefix backup-\$(date +%Y-%m-%d-%H-%M-%S)    Now would be backup-$(date +%Y-%m-%d-%H-%M-%S)"
    echo
    echo "Example:"
    echo "  $0 --compose-file docker-compose.yml --volume-name my-volume --volume-path /data --backup-path ./backup --backup-prefix backup"
    echo
    echo "  $0 <volume_name> [<backup_prefix> [<backup_path>]]"
    echo
    echo
    exit 0
    ;;
  *)
    if [[ -z "${VOLUME_NAME:-}" ]]; then
      VOLUME_NAME="${1:-}"
    fi
    shift

    if [[ -n "${1:-}" ]]; then
      BACKUP_PREFIX="${1:-backup}"
      shift 1
    fi

    if [[ -n "${1:-}" ]]; then
      BACKUP_PATH="${1:-$PWD}"
      shift 1
    fi
    ;;
  esac
done

if [[ -z "${VOLUME_NAME:-}" ]]; then
  echo "No volume name specified"
  exit 1
fi

if [[ -z "${COMPOSE_FILE:-}" ]]; then
  echo "No compose file specified"
  exit 1
fi

if [[ -z "${COMPOSE_PROJECT_NAME:-}" ]]; then
  COMPOSE_PROJECT_NAME="$(basename "$(dirname "$(readlink -f "$COMPOSE_FILE")")")"
fi

# Check if docker volume name exists

if [[ -n "${COMPOSE_FILE:-}" ]]; then
  _COMPOSE_ARGS=()

  if [[ -n "${PROJECT_FILE:-}" ]]; then
    _COMPOSE_ARGS+=(--file "$COMPOSE_FILE")
  fi

  if [[ -n "${COMPOSE_PROJECT_NAME:-}" ]]; then
    _COMPOSE_ARGS+=(--project-name "$COMPOSE_PROJECT_NAME")
  fi

  if [[ -n "${PROJECT_DIRECTORY:-}" ]]; then
    _COMPOSE_ARGS+=(--project-directory "$PROJECT_DIRECTORY")
  fi

  _COMPOSE_ARGS+=(stop)

  docker compose "${_COMPOSE_ARGS[@]}" stop
fi

for volume in $(docker volume ls -q --filter name="${COMPOSE_PROJECT_NAME}_${VOLUME_NAME}"); do
  docker run --rm --volume "${volume}:${VOLUME_PATH}" --volume "${BACKUP_PATH}:/backup" "${IMAGE}" tar cjf "/backup/${BACKUP_PREFIX}-${backup_date}-${COMPOSE_PROJECT_NAME}_${VOLUME_NAME}.tar.bz2" "${VOLUME_PATH}"
done

# start again docker compose
docker compose "${_COMPOSE_ARGS[@]}" start

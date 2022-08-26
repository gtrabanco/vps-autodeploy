#!/usr/bin/env bash

if [[ $# -eq 0 ]] || [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
  # Print usage
  echo "  Usage: $0 * * * * * command to be executed"
  echo
  cat <<EOF
    * * * * * "command to be executed"
    - - - - -
    | | | | |
    | | | | ----- Day of week (0 - 7) (Sunday=0 or 7)
    | | | ------- Month (1 - 12)
    | | --------- Day of month (1 - 31)
    | ----------- Hour (0 - 23)
    ------------- Minute (0 - 59)

    Quotes are optional, just one cronjob per call.


    Example:
      $0 0 */12 * * * "\${HOME}/vps-apps/scripts/docker-compose-backup.sh --project-name vps-apps --volume-name vaultwarden --volume-path "/data" --backup-path "/backup" --backup-prefix "vaultwarden" --image alpine:latest"

      This cronjob will perform a backup every 12 hours.
EOF
  exit 1
fi

(
  crontab -l
  printf "%s " "$@"
  printf $'\n'
) | crontab -

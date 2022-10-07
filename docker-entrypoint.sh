#!/usr/bin/env bash
set -eo pipefail

CONFIG_FILE=/data/lldap_config.toml

fail() {
  if [[ ! -z "$DEBUG" ]]; then
    echo "[entrypoint] Pausing for 300 seconds"
    sleep 300
    echo "[entrypoint] Exiting..."
  fi

  exit 1
}

if [[ ! -d "/data" ]]; then
  echo "[entrypoint] The /data folder does not exist"
  fail
fi

if [[ ! -w "/data" ]]; then
  echo "[entrypoint] The /data folder cannot be written to."
  fail
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "[entrypoint] Copying the default config to $CONFIG_FILE"
  echo "[entrypoint] Edit this file to configure LLDAP."
  cp /app/lldap_config.docker_template.toml $CONFIG_FILE
fi

if [[ ! -r "$CONFIG_FILE" ]]; then
  echo "[entrypoint] Config file is not readable. Check the permissions"
  fail
fi

echo "> Setup permissions.."
find /app \! -user "$UID" -exec chown "$UID:$GID" '{}' +
find /data \! -user "$UID" -exec chown "$UID:$GID" '{}' +


echo "> Starting lldap.."
echo ""
exec su-exec "$UID:$GID" /app/lldap "$@"

exec "$@"

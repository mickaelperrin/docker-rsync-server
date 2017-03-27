#!/bin/bash
set -e

# Allow to run complementary processes or to enter the container without
# running this init script.
if [ "$1" == '/usr/bin/rsync' ]; then

  # Ensure time is in sync with host
  # see https://wiki.alpinelinux.org/wiki/Setting_the_timezone
  if [ -n ${TZ} ] && [ -f /usr/share/zoneinfo/${TZ} ]; then
    ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime
    echo ${TZ} > /etc/timezone
  fi

  # Defaults
  VOLUME_PATH=${VOLUME_PATH:-/docker}
  HOSTS_ALLOW=${HOSTS_ALLOW:-0.0.0.0/0}
  READ_ONLY=${READ_ONLY:-false}
  CHROOT=${CHROOT:-no}
  VOLUME_NAME=${VOLUME_NAME:-volume}
  USERNAME=${USERNAME:-rsyncuser}

  # Ensure VOLUME PATH exists
  if [ ! -e $VOLUME_PATH ]; then
    mkdir -p /$VOLUME_PATH
  fi

  # Grab UID of owner of the volume directory
  if [ -z $OWNER_ID ]; then
    OWNER_ID=$(stat -c '%u' $VOLUME_PATH)
  else
    echo "OWNER_ID is set forced to: $OWNER_ID"
  fi
  if [ -z $GROUP_ID ]; then
    GROUP_ID=$(stat -c '%g' $VOLUME_PATH)
  else
    echo "GROUP_ID is set forced to: $GROUP_ID"
  fi

  # Generate password file
  if [ ! -z $PASSWORD ]; then
    echo "$USERNAME:$PASSWORD" >  /etc/rsyncd.secrets
    chmod 600 /etc/rsyncd.secrets
  fi

  # Generate configuration
  eval "echo \"$(cat /rsyncd.tpl.conf)\"" > /etc/rsyncd.conf

  # Check if a script is available in /docker-entrypoint.d and source it
  # You can use it for example to create additional sftp users
  for f in /docker-entrypoint.d/*; do
    case "$f" in
      *.sh)  echo "$0: running $f"; . "$f" ;;
      *)     echo "$0: ignoring $f" ;;
    esac
  done

fi

exec "$@"



#!/bin/bash

set -e

# if an 'etc' directory exists within the data dir, symlink it to where 'etc' lives
if [[ -d /opt/splunk/var/lib/splunk/etc ]]; then
  mv /opt/splunk/etc /opt/splunk/.etc.old
  ln -s /opt/splunk/var/lib/splunk/etc /opt/splunk/etc
fi

# if the etc directory is new, initialize it with the default config
if [[ ! -e /opt/splunk/etc/splunk.version ]]; then
  cp -a --no-clobber /opt/splunk/etc.orig/. /opt/splunk/etc/
fi

# move docker-image provided files in place, overwriting any conflicts
cp -a /opt/splunk/.etc-docker/. /opt/splunk/etc/

if [[ -e "/opt/splunk/var/lib/splunk" ]]; then
  uid="$(stat -L -c '%u' /opt/splunk/var/lib/splunk)"
else
  uid="$(stat -L -c '%u' /opt/splunk/var)"
fi
if [[ "$(stat -L -c '%u' /opt/splunk)" != "$uid" ]] || [[ "$(getent passwd splunk | awk -F: '{ print $3 }')" != "$uid" ]]; then
  usermod -u "$uid" splunk
  find /opt/splunk -mount -exec chown splunk {} +
fi

syslog-ng --no-caps

splunk start --accept-license --answer-yes --no-prompt
trap "splunk stop" EXIT INT TERM QUIT

pid="$(pgrep -x splunkd | head -n 1)"

while kill -0 "$pid" &>/dev/null; do sleep 1; done

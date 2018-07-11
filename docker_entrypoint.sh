#!/bin/bash
# set -eo pipefail

source /usr/share/gridengine/default/common/settings.sh

echo "$HOSTNAME" > /usr/share/gridengine/default/common/act_qmaster
echo "domain $HOSTNAME" >> /etc/resolv.conf
sed -i -e"s/docker/$HOSTNAME/" debug.queue

/usr/share/gridengine/default/common/sgemaster start
/usr/share/gridengine/default/common/sgeexecd start

qconf -mattr "queue" "hostlist" "$HOSTNAME" "debug"
qconf -as $HOSTNAME

export HOME=/home/user
export PATH="/usr/local/go/bin:$PATH"
su -m root



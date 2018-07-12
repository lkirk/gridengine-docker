#!/bin/sh

. /ge/default/common/settings.sh

echo "$HOSTNAME" > /ge/default/common/act_qmaster
echo "domain $HOSTNAME" >> /etc/resolv.conf
sed -i -e"s/docker/$HOSTNAME/" /ge/config/debug.queue

/ge/default/common/sgemaster start
/ge/default/common/sgeexecd start

qconf -mattr "queue" "hostlist" "$HOSTNAME" "debug"
qconf -as $HOSTNAME

export HOME=/home/user
export PATH="/usr/local/go/bin:$PATH"
su --login user

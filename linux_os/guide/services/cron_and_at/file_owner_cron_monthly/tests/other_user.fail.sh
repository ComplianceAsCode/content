#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.monthly
chown ${USER} /etc/cron.monthly

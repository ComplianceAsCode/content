#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.weekly
chown ${USER} /etc/cron.weekly

#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.allow
chown ${USER} /etc/cron.allow

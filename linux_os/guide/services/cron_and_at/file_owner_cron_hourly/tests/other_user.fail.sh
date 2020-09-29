#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.hourly
chown ${USER} /etc/cron.hourly

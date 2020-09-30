#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.daily
chown ${USER} /etc/cron.daily

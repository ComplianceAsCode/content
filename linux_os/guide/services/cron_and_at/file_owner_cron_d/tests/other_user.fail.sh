#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/cron.d
chown ${USER} /etc/cron.d

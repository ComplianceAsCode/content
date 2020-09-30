#!/bin/bash
#
USER=ssgttuser

useradd ${USER}
touch /etc/crontab
chown ${USER} /etc/crontab

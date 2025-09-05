#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
USER=ssgttuser

useradd ${USER}
touch /etc/cron.allow
chown ${USER} /etc/cron.allow

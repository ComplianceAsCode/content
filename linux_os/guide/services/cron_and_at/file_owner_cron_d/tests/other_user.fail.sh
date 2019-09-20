#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S
USER=ssgttuser

useradd ${USER}
touch /etc/cron.d
chown ${USER} /etc/cron.d

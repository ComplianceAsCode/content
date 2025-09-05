#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
USER=ssgttuser

useradd ${USER}
touch /etc/ssh/sshd_config
chown ${USER} /etc/ssh/sshd_config

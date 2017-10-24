#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_rht-ccp
USER=ssgttuser

useradd ${USER}
chown ${USER} /etc/shadow

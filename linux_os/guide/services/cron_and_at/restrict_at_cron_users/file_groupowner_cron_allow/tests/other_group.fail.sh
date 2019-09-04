#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.allow
chgrp ${GROUP} /etc/cron.allow

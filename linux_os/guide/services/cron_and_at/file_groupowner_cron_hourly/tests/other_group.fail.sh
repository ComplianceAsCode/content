#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_C2S
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.hourly
chgrp ${GROUP} /etc/cron.hourly

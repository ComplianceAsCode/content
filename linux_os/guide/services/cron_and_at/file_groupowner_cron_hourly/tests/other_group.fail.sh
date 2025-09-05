#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.hourly
chgrp ${GROUP} /etc/cron.hourly

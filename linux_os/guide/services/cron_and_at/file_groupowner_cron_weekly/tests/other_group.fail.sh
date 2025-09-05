#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.weekly
chgrp ${GROUP} /etc/cron.weekly

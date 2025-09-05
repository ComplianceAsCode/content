#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.allow
chgrp ${GROUP} /etc/cron.allow

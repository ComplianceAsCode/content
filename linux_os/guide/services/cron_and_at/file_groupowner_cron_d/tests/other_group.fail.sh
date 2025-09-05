#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.d
chgrp ${GROUP} /etc/cron.d

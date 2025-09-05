#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.monthly
chgrp ${GROUP} /etc/cron.monthly

#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/cron.daily
chgrp ${GROUP} /etc/cron.daily

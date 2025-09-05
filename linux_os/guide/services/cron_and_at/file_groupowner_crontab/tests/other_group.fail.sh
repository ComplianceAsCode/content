#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/crontab
chgrp ${GROUP} /etc/crontab

#!/bin/bash
#
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/ssh/sshd_config
chgrp ${GROUP} /etc/ssh/sshd_config

#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_ospp
GROUP=ssgttgroup

groupadd ${GROUP}
touch /etc/ssh/sshd_config
chgrp ${GROUP} /etc/ssh/sshd_config

#!/bin/bash
#
# profiles = xccdf_org.ssgproject.content_profile_rht-ccp
GROUP=ssgttgroup

groupadd ${GROUP}
chgrp ${GROUP} /etc/shadow

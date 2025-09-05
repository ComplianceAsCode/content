#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

# purpose of this scenario is to install the rsyslog package
# and thus configure the syslog group. The group is required
# for the Ubuntu check and remediations but is missing
# in podman containers by default.

chgrp syslog /var/log


#!/bin/bash
# packages = audit

source common.sh

touch "/var/log/audit/audit.log"
chown root -R "/var/log/audit/"
# The 'audit' group may not created by the package on all distros
groupadd -f audit
chgrp audit -R "/var/log/audit"

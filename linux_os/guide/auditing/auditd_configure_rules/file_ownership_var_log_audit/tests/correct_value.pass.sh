#!/bin/bash
# packages = audit

source common.sh

touch "/var/log/audit/audit.log"
chgrp root -R "/var/log/audit/"
chown root -R "/var/log/audit/"

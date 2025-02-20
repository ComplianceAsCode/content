#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/cloud-init.log
chgrp nogroup /var/log/cloud-init.log*

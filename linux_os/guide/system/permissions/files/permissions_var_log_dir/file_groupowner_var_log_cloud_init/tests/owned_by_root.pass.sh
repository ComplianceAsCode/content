#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/cloud-init.log
chgrp root /var/log/cloud-init.log*

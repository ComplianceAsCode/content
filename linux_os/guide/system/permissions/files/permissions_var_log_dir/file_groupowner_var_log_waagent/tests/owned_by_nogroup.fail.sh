#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/waagent.log
chgrp nogroup /var/log/waagent.log*

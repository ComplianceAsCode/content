#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/auth.log
chgrp nogroup /var/log/auth.log

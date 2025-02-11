#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/auth
chgrp nogroup /var/log/auth*

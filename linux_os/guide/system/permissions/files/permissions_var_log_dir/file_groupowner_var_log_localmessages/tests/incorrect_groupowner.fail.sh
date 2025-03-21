#!/bin/bash
# platform = Ubuntu 24.04
# packages = rsyslog

touch /var/log/localmessages
touch /var/log/localmessages1
chgrp nogroup /var/log/localmessages*

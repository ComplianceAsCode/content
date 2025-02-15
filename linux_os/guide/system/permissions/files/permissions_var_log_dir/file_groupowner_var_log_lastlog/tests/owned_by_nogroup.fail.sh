#!/bin/bash
# platform = Ubuntu 24.04

touch /var/log/lastlog
touch /var/log/lastlog.1
chgrp nogroup /var/log/lastlog*

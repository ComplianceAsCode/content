#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

chgrp root -R /var/log/*

touch /var/log/test.log
chgrp adm /var/log/test.log

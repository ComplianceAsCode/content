#!/bin/bash
# platform = multi_platform_ubuntu

chgrp root -R /var/log/*

touch /var/log/test.log
chgrp root /var/log/test.log

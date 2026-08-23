#!/bin/bash
# platform = multi_platform_ubuntu

chgrp root -R /var/log/*

ln -s /etc/issue /var/log/test.log.symlink
chgrp -h nogroup /var/log/test.log.symlink

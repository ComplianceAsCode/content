#!/bin/bash
# platform = Ubuntu 24.04

chgrp root -R /var/log/*

ln -s /etc/issue /var/log/test.log.symlink
chgrp -h nogroup /var/log/test.log.symlink

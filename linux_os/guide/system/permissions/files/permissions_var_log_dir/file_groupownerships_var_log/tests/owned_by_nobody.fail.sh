#!/bin/bash
# platform = multi_platform_ubuntu
# packages = rsyslog

chgrp root -R /var/log/*

touch /var/log/test.log
chgrp nogroup /var/log/test.log
{{%- if product == 'ubuntu2204' %}}
#make sure nogroup has members
usermod -aG nogroup nobody
chown nobody /var/log/test.log
{{%- endif %}}

#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$ActionSendStreamDriverAuthMode 0" >> /etc/rsyslog.conf

#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$ActionSendStreamDriverMode 0" >> /etc/rsyslog.d/encrypt.conf

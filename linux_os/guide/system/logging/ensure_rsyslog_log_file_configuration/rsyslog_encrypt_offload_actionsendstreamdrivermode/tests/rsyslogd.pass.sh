#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$ActionSendStreamDriverMode 1" >> /etc/rsyslog.d/encrypt.conf

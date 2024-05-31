#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$ActionSendStreamDriverAuthMode x509/name" >> /etc/rsyslog.d/encrypt.conf

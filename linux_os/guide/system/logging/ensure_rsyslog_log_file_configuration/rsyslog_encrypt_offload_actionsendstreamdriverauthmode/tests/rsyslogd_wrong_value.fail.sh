#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$ActionSendStreamDriverAuthMode x509/certvalid" >> /etc/rsyslog.d/encrypt.conf

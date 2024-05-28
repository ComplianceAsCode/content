#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$DefaultNetstreamDriver none" >> /etc/rsyslog.d/encrypt.conf

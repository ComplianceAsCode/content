#!/bin/bash
# packages = rsyslog
bash -x setup.sh

echo "\$DefaultNetstreamDriver gtls" >> /etc/rsyslog.conf

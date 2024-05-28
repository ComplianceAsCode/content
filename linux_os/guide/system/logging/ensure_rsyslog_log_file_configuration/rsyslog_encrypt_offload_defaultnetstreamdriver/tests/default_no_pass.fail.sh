#!/bin/bash
# packages = rsyslog
bash -x setup.sh

if [[ -f encrypt.conf ]]; then
  sed -i i/\$DefaultNetstreamDriver*.$//g /etc/rsyslog.d/encrypt.conf
fi
  sed -i i/\$DefaultNetstreamDriver*.$//g /etc/rsyslog.conf

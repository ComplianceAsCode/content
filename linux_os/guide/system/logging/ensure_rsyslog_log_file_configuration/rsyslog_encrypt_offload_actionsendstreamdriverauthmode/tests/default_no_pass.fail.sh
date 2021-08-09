#!/bin/bash
bash -x setup.sh

if [[ -f encrypt.conf ]]; then
  sed -i "/^\$ActionSendStreamDriverMod.*/d" /etc/rsyslog.conf
fi
  sed -i "/^\$ActionSendStreamDriverMod.*/d" /etc/rsyslog.conf

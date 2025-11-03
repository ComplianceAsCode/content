#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

remove_encrypt_offload_configs

if [[ -f encrypt.conf ]]; then
  sed -i i/\$ActionSendStreamDriverMod//g /etc/rsyslog.d/encrypt.conf
fi
  sed -i i/\$ActionSendStreamDriverMod//g /etc/rsyslog.conf

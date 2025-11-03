#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

remove_encrypt_offload_configs

echo "\$ActionSendStreamDriverMode 1" >> /etc/rsyslog.d/encrypt.conf

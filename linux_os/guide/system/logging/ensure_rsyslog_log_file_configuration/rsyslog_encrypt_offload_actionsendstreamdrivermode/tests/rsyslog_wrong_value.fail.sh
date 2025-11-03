#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

echo "\$ActionSendStreamDriverMode 0" >> /etc/rsyslog.d/encrypt.conf

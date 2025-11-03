#!/bin/bash
# packages = rsyslog
bash -x setup.sh
bash -x remove_encrypt_offload_configs.sh

remove_encrypt_offload_configs

echo "\$DefaultNetstreamDriver gtls" >> /etc/rsyslog.conf

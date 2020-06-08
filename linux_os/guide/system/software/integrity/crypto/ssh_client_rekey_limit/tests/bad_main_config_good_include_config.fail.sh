#!/bin/bash

echo "RekeyLimit 2G 1h" >> /etc/ssh/ssh_config
echo "RekeyLimit 512M 1h" >> /etc/ssh/ssh_config.d/02-rekey-limit.conf

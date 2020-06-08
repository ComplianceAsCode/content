#!/bin/bash
# platform = multi_platform_all


echo "RekeyLimit 512M 2h" >> /etc/ssh/ssh_config.d/02-rekey-limit.conf

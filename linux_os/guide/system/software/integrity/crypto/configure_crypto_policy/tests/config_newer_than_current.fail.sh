#!/bin/bash
# platform = Oracle Linux 8,Oracle Linux 9,multi_platform_rhel
# packages = crypto-policies-scripts

update-crypto-policies --set "DEFAULT"
sleep 1s
touch /etc/crypto-policies/config

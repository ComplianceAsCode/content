#!/bin/bash
# platforms = multi_platform_ubuntu
# packages = ufw
# remediation = none

source common.sh

ufw allow 22
ufw limit 53
ufw deny 631
ufw -f enable


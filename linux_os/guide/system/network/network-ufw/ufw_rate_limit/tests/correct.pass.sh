#!/bin/bash
# platform = multi_platform_ubuntu,multi_platform_debian
# packages = ufw

source common.sh

ufw limit 22
ufw limit 53
ufw deny 631
ufw -f enable

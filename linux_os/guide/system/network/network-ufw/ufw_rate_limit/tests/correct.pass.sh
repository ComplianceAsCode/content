#!/bin/bash
# platform = multi_platform_ubuntu
# packages = ufw

source common.sh

ufw limit 22
ufw limit 53
ufw deny 631
ufw -f enable

#!/bin/bash

# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

SECURE_MAX_PASS_AGE=60

usrs_max_pass_age=( $(awk -F: '$5 > SECURE_MAX_PASS_AGE || $5 == "" {print $1}' /etc/shadow) )
for i in ${usrs_max_pass_age[@]};
do
  passwd -x $SECURE_MAX_PASS_AGE $i
done

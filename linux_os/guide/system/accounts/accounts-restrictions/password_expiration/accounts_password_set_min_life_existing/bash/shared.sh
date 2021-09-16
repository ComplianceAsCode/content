#!/bin/bash

# platform = multi_platform_sle
# reboot = false
# strategy = restrict
# complexity = low
# disruption = low

SECURE_MIN_PASS_AGE=1

usrs_min_pass_age=( $(awk -F: '$4 < SECURE_MIN_PASS_AGE || $4 == "" {print $1}' /etc/shadow) )
for i in ${usrs_min_pass_age[@]};
do
  passwd -n $SECURE_MIN_PASS_AGE $i
done

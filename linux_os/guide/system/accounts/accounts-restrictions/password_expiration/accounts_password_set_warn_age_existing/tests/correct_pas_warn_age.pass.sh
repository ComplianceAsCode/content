#!/bin/bash
# platform = multi_platform_sle

SECURE_PASS_WARN_AGE=7

usrs_pass_warn_age=( $(awk -F: '$6 < $SECURE_PASS_WARN_AGE || $6 == "" {print $1}' /etc/shadow) )
for i in ${usrs_pass_warn_age[@]};
do
  chage --warndays $SECURE_PASS_WARN_AGE $i
done

#!/bin/bash

SECURE_MAX_PASS_AGE=60

usrs_max_pass_age=($(awk -v max="$SECURE_MAX_PASS_AGE" -F: '(/^[^:]+:[^!*]/ && ($5 > max || $5 == "")) {print $1}' /etc/shadow) )
for i in ${usrs_max_pass_age[@]};
do
  chage -M $SECURE_MAX_PASS_AGE $i
done

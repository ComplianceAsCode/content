#!/bin/bash

SECURE_MIN_PASS_AGE=1

usrs_min_pass_age=( $(awk -v min="$SECURE_MIN_PASS_AGE" -F: '(/^[^:]+:[^!*]/ && ($4 < min || $4 == "")) {print $1}' /etc/shadow) )
for i in ${usrs_min_pass_age[@]};
do
  chage -m $SECURE_MIN_PASS_AGE $i
done

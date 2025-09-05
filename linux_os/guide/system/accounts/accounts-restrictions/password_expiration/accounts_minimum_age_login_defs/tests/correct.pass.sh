#!/bin/bash

grep -q "^PASS_MIN_DAYS" /etc/login.defs && \
  sed -i "s/PASS_MIN_DAYS.*/PASS_MIN_DAYS\t7/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
    echo -e "PASS_MIN_DAYS\t7" >> /etc/login.defs
fi

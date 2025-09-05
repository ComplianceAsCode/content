#!/bin/bash

grep -q "^PASS_WARN_AGE" /etc/login.defs && \
  sed -i "s/PASS_WARN_AGE.*/# PASS_WARN_AGE\t7/g" /etc/login.defs
if ! [ $? -eq 0 ]; then
	echo -e "# PASS_WARN_AGE\t7" >> /etc/login.defs
fi

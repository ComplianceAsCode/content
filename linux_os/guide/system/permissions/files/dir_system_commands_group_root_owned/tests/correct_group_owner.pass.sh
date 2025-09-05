#!/bin/bash

for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
  find -L $SYSLIBDIRS ! -group root -type d -exec chgrp root '{}' \;
done

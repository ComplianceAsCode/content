#!/bin/bash

for SYSLIBDIRS in /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin
do
  find -L  $SYSLIBDIRS  -perm /022 -type f -exec chmod go-w '{}' \;
done

touch /usr/bin/$(printf "evil_filename_\334_non_utf8_character")

#!/bin/bash
#

find / -xdev -type f -perm -002 -exec chmod o-w {} \;
touch /etc/$(printf "evil_filename_\334_non_utf8_character")

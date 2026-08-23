#!/bin/bash

UNOWNED_FILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nouser)

IFS=$"\n"
for f in $UNOWNED_FILES; do
	rm -f "$f"
done
touch /etc/$(printf "evil_filename_\334_non_utf8_character")

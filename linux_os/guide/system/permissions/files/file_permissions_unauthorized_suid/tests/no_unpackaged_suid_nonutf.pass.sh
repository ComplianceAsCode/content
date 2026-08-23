#!/bin/bash

for x in $(find / -perm /u=s) ; do
	if ! rpm -qf $x ; then
		rm -rf $x
	fi
done
touch /usr/bin/$(printf "evil_filename_\334_non_utf8_character")

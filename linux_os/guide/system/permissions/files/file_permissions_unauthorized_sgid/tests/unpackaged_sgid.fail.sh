#!/bin/bash

# remediation = none

for x in $(find / -perm /g=s) ; do
	if ! rpm -qf $x ; then
		rm -rf $x
	fi
done

touch /usr/bin/sgid_binary
chmod g+xs /usr/bin/sgid_binary

#!/bin/bash

# remediation = none

for x in $(find / -perm /u=s) ; do
	if ! rpm -qf $x ; then
		rm -rf $x
	fi
done

touch /usr/bin/suid_binary
chmod u+xs /usr/bin/suid_binary

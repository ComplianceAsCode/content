#!/bin/bash
#
UNOWNED_FILES=$(df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -nogroup)

IFS=$"\n"
for f in $UNOWNED_FILES; do
	rm -f "$f"
done

touch /root/test
chown 9999:9999 /root/test
echo "testgroup:x:9999:" >> /usr/lib/group
